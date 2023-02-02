function dbs_percept_dics_bootstrap(initials, rec_id, condition, band)

    if nargin <2
        rec_id = 1;
    end
    
    
%     condition = 'R';
   

    space = 'mni';%'native';%

    try
        [files_, seq, root, details] = dbs_subjects_percept(initials, rec_id);
    catch
        return;
    end

    cd(fullfile(root, condition));

    try
        files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    end

    D = spm_eeg_load(files);

    banddir = sprintf('band_%d_%dHz', band);

    res = mkdir(banddir);

    cd(banddir);

    res = mkdir('BF');

    dbatch{1}.spm.tools.beamforming.data.dir = {fullfile(root, condition, banddir, 'BF')};
    dbatch{1}.spm.tools.beamforming.data.D = {fullfile(D)};
    dbatch{1}.spm.tools.beamforming.data.val = 1;
    dbatch{1}.spm.tools.beamforming.data.gradsource = 'inv';
    dbatch{1}.spm.tools.beamforming.data.space = 'MNI-aligned';
    dbatch{1}.spm.tools.beamforming.data.overwrite = 1;
    dbatch{2}.spm.tools.beamforming.sources.BF(1) = cfg_dep('Prepare data: BF.mat file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
    dbatch{2}.spm.tools.beamforming.sources.reduce_rank = [2 3];
    dbatch{2}.spm.tools.beamforming.sources.plugin.grid.resolution = 5;
    dbatch{2}.spm.tools.beamforming.sources.plugin.grid.constrain = 'iskull';
    dbatch{2}.spm.tools.beamforming.sources.plugin.grid.space = 'MNI template';
    
    spm_jobman('run', dbatch);


    fbatch{1}.spm.tools.beamforming.features.BF = {fullfile(root, condition, banddir, 'BF', 'BF.mat')};
    fbatch{1}.spm.tools.beamforming.features.whatconditions.all = 1;
    fbatch{1}.spm.tools.beamforming.features.woi = [-Inf Inf];
    fbatch{1}.spm.tools.beamforming.features.modality = {D.modality};
    
    fbatch{1}.spm.tools.beamforming.features.fuse = 'no';
    fbatch{1}.spm.tools.beamforming.features.plugin.csd.foi = band;
    fbatch{1}.spm.tools.beamforming.features.plugin.csd.taper = 'dpss';
    fbatch{1}.spm.tools.beamforming.features.plugin.csd.keepreal = 0;
    fbatch{1}.spm.tools.beamforming.features.plugin.csd.hanning = 0;

    fbatch{1}.spm.tools.beamforming.features.regularisation.manual.lambda = 0.01;

    fbatch{1}.spm.tools.beamforming.features.bootstrap = false;
    fbatch{2}.spm.tools.beamforming.inverse.BF(1) = cfg_dep('Covariance features: BF.mat file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
    fbatch{2}.spm.tools.beamforming.inverse.plugin.dics.fixedori  = 'yes';


    obatch{1}.spm.tools.beamforming.output.BF = {fullfile(root, condition, banddir, 'BF', 'BF.mat')};
    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.whatconditions.all = 1;
    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.sametrials = true;
    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.woi = [-Inf Inf];
    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.contrast = 1;
    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.foi = band;
    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.taper = 'dpss';
    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.result = 'singleimage';
    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.scale = 'no';
    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.modality = D.modality;
    
    obatch{2}.spm.tools.beamforming.write.BF(1) = cfg_dep('Output: BF.mat file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
    obatch{2}.spm.tools.beamforming.write.plugin.nifti.normalise = 'separate';
    obatch{2}.spm.tools.beamforming.write.plugin.nifti.space = space;
    obatch{3}.cfg_basicio.file_dir.file_ops.file_move.files(1) = cfg_dep('Write: Output files', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    obatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.patrep.pattern = '.*';
    obatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.unique = false;
    obatch{4}.spm.tools.beamforming.write.BF(1) = cfg_dep('Output: BF.mat file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
    obatch{4}.spm.tools.beamforming.write.plugin.nifti.normalise = 'no';
    obatch{4}.spm.tools.beamforming.write.plugin.nifti.space = space;
    obatch{5}.cfg_basicio.file_dir.file_ops.file_move.files(1) = cfg_dep('Write: Output files', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    obatch{5}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.patrep.pattern = '.*';
    obatch{5}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.unique = false;

    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.reference.refchan.shuffle = 0;

    for c = 1:numel(details.chan)
        
         res = mkdir(fullfile(root, condition, banddir), details.chan{c});
        
        
        if c == 1
            fbatch{1}.spm.tools.beamforming.features.bootstrap = 0;
            spm_jobman('run', fbatch);
        end
        
        obatch{1}.spm.tools.beamforming.output.plugin.image_dics.reference.refchan.name = details.chan{c};
        obatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.moveto = {fullfile(root, condition, banddir, details.chan{c})};
        obatch{5}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.moveto = {fullfile(root, condition, banddir, details.chan{c})};
        
       
        obatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.patrep.repl = 'full_orig';
        obatch{5}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.patrep.repl = 'us_full_orig';
        
        spm_jobman('run', obatch);
    end

    obatch{1}.spm.tools.beamforming.output.plugin.image_dics.reference.refchan.shuffle = 1;

    for c = 1:numel(details.chan)
        if c == 1
            fbatch{1}.spm.tools.beamforming.features.bootstrap = 0;
            spm_jobman('run', fbatch);
        end
        
        obatch{1}.spm.tools.beamforming.output.plugin.image_dics.reference.refchan.name = details.chan{c};
        obatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.moveto = {fullfile(root, condition, banddir, details.chan{c})};
        obatch{5}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.moveto = {fullfile(root, condition, banddir, details.chan{c})};
        
        
        obatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.patrep.repl = 'full_shuffled';
        obatch{5}.cfg_basicio.file_dir.file_ops.file_move.action.moveren.patrep.repl = 'us_full_shuffled';
        
        spm_jobman('run', obatch);
    end


    res = rmdir(char(dbatch{1}.spm.tools.beamforming.data.dir), 's');