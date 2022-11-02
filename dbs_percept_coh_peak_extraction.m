function dbs_percept_coh_peak_extraction(initials, rec_id, condition, hemisphere, ROI)





try
    [files, seq, root, details] = dbs_subjects_percept(initials, rec_id);
catch
    return;
end


if strcmp(details.chan{1}(end-3),'L')
    chan_L=details.chan{1};
    chan_R=details.chan{2};
else
    chan_R=details.chan{1};
    chan_L=details.chan{2};
end

switch hemisphere
    case 'Left'
        chan=chan_L;
    case 'Right'
        chan=chan_R;      
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


D=spm_eeg_load(files);



res = mkdir('BF');

%%
source{1}.spm.tools.beamforming.data.dir = {fullfile(pwd, 'BF')};
source{1}.spm.tools.beamforming.data.val = 1;
source{1}.spm.tools.beamforming.data.gradsource = 'inv';
source{1}.spm.tools.beamforming.data.space = 'MNI-aligned';
source{1}.spm.tools.beamforming.data.overwrite = 1;
source{2}.spm.tools.beamforming.sources.BF(1) = cfg_dep('Prepare data: BF.mat file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
source{2}.spm.tools.beamforming.sources.reduce_rank = [2 3];
source{2}.spm.tools.beamforming.sources.keep3d = 1;

for i = 1:size(ROI, 1)
    source{2}.spm.tools.beamforming.sources.plugin.voi.vois{i}.voidef.label = ROI{i, 1};
    source{2}.spm.tools.beamforming.sources.plugin.voi.vois{i}.voidef.pos = ROI{i, 2};
    source{2}.spm.tools.beamforming.sources.plugin.voi.vois{i}.voidef.ori = [0 0 0];
end

source{2}.spm.tools.beamforming.sources.plugin.voi.radius = 0;
source{2}.spm.tools.beamforming.sources.plugin.voi.resolution = 5;
source{2}.spm.tools.beamforming.sources.visualise = 1;
source{3}.spm.tools.beamforming.features.BF(1) = cfg_dep('Define sources: BF.mat file', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
source{3}.spm.tools.beamforming.features.whatconditions.all = 1;
source{3}.spm.tools.beamforming.features.woi = [-Inf Inf];
source{3}.spm.tools.beamforming.features.modality = {'EEG'};
source{3}.spm.tools.beamforming.features.fuse = 'no';
source{3}.spm.tools.beamforming.features.plugin.contcov = struct([]);
source{3}.spm.tools.beamforming.features.regularisation.manual.lambda = 0.01;
%source{3}.spm.tools.beamforming.features.regularisation.mantrunc.pcadim = 50;
source{3}.spm.tools.beamforming.features.bootstrap = false;
source{4}.spm.tools.beamforming.inverse.BF(1) = cfg_dep('Covariance features: BF.mat file', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
source{4}.spm.tools.beamforming.inverse.plugin.lcmv.orient = false;
source{4}.spm.tools.beamforming.inverse.plugin.lcmv.keeplf = false;
source{5}.spm.tools.beamforming.output.BF(1) = cfg_dep('Inverse solution: BF.mat file', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
source{5}.spm.tools.beamforming.output.plugin.montage.method = 'keep';
source{5}.spm.tools.beamforming.output.plugin.montage.vois = {};
source{6}.spm.tools.beamforming.write.BF(1) = cfg_dep('Output: BF.mat file', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
source{6}.spm.tools.beamforming.write.plugin.spmeeg.mode = 'online';
source{6}.spm.tools.beamforming.write.plugin.spmeeg.modality = 'EEG';
source{6}.spm.tools.beamforming.write.plugin.spmeeg.addchannels.channels{1}.type = 'LFP';
source{6}.spm.tools.beamforming.write.plugin.spmeeg.prefix = 'B';



%reduce{1}.spm.meeg.preproc.reduce.channels{1}.type = 'LFP';
reduce{1}.spm.meeg.preproc.reduce.keepothers = true;
reduce{1}.spm.meeg.preproc.reduce.prefix = 'cohpeaks_';

for k = 1:size(ROI, 1)
    reduce{1}.spm.meeg.preproc.reduce.method.imagcsd.chanset(k).origchan.channels{1}.regexp = ['^' ROI{k, 1}];
    reduce{1}.spm.meeg.preproc.reduce.method.imagcsd.chanset(k).refchan.channels{1}.chan = chan;
    reduce{1}.spm.meeg.preproc.reduce.method.imagcsd.chanset(k).outlabel = ROI{k, 1};
    reduce{1}.spm.meeg.preproc.reduce.method.imagcsd.chanset(k).foi = ROI{k, 3};
end



D = montage(D, 'switch', 0);
D = montage(D, 'remove', 1:D.montage('getnumber'));
save(D);
D = dbs_eeg_headmodelling(D);

source{1}.spm.tools.beamforming.data.D = {fullfile(D)};


spm_jobman('run', source);


D = D.reload;

chantokeep = D.chanlabels(D.indchantype('LFP'));

for c = 1:numel(chantokeep)
    reduce{1}.spm.meeg.preproc.reduce.channels{c}.chan = chantokeep{c};
end

D = chantype(D, ':', 'PHYS');
D = chantype(D, D.indchannel(details.chan), 'LFP');
save(D);

reduce{1}.spm.meeg.preproc.reduce.D = {fullfile(D)};

spm_jobman('run', reduce);

D = D.montage('switch', 0);
save(D);


