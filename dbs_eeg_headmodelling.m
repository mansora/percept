function D = dbs_eeg_headmodelling(D)

try
    [files, seq, root, details] = dbs_subjects_percept(D.initials, 2);
catch
    [files, seq, root, details] = dbs_subjects_percept(D.initials, 1);
end

template = 0;
if ~exist(fullfile(details.mridir, ['r' D.initials '.nii']), 'file')
    if ~exist(fullfile(details.mridir, [D.initials '.nii']), 'file')
        warning(['Cannot find the structural ' D.initials '.nii']);
        template = 1;
    else
        
        matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {fullfile(spm('dir'), 'canonical', 'single_subj_T1.nii,1')};
        matlabbatch{1}.spm.spatial.coreg.estwrite.source = {fullfile(details.mridir, [D.initials '.nii'])};
        
        spm_jobman('run', matlabbatch);
    end
end

try
    fid = importdata(details.fiducials);
end

try
    D = rmfield(D, 'inv');
end

save(D);

cd(D.path);

clear matlabbatch
matlabbatch{1}.spm.meeg.source.headmodel.D = {fullfile(D)};
matlabbatch{1}.spm.meeg.source.headmodel.val = 1;
matlabbatch{1}.spm.meeg.source.headmodel.comment = '';
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshres = 2;

if ~template
    matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.mri = {fullfile(details.mridir, ['r' D.initials '.nii'])};        
    if exist('fid', 'var');
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'spmnas';
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.type = fid.data(1, :);
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'spmlpa';
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.type = fid.data(2, :);
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'spmrpa';
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.type = fid.data(3, :);
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 1;
    else
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'spmnas';
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.select = 'nas';
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'spmlpa';
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.select = 'lpa';
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'rpa';
        matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.select = 'rpa';
    end
else
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregdefault = 1;
end

matlabbatch{1}.spm.meeg.source.headmodel.forward.eeg = 'EEG BEM';

spm_jobman('run', matlabbatch);
%%
D = reload(D);

% check and display registration
%--------------------------------------------------------------------------
spm_eeg_inv_checkdatareg(D);

try
    print('-dtiff', '-r600', fullfile(D.path, 'datareg.tiff'));
end

D = spm_eeg_inv_forward(D);

spm_eeg_inv_checkforward(D);

try
    print('-dtiff', '-r600', fullfile(D.path, 'forward.tiff'));
end

save(D);