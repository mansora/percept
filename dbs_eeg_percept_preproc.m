function [D, S_trl] = dbs_eeg_percept_preproc(files, details, f)
% Fuse simultaneously recorded EEG and Percept PC datasets based on a
% stimulation stamps sent by percept PC
% 
% FORMAT  D = presma_brainamp_preproc(S);
%
% S           - input structure (optional)
% (optional) fields of S:
%   S.dataset       - name of the MEG dataset
%   S.ref1     - name of the reference channel in EEG dataset
%   S.ref2     - name of the reference channel in MEG dataset
%
% D        - MEEG object (also written to disk, with a 'u' prefix)
%__________________________________________________________________________
% Copyright (C) 2011 Wellcome Trust Centre for Neuroimaging
%
% Vladimir Litvak
% $Id: dbs_meg_brainamp_preproc.m 176 2019-04-09 15:46:36Z vladimir $

SVNrev = '$Rev: 176 $';

%-Startup
%--------------------------------------------------------------------------
spm('FnBanner', mfilename, SVNrev);
spm('FigName','Brainamp preproc'); spm('Pointer','Watch');

% if nargin == 0
%     S = [];
% end

keep=1;

S = [];
S.dataset = files{1};
S.outfile = ['spmeeg' num2str(f) '_' spm_file(S.dataset,'basename')]; 

%-Get MEEG objects
%--------------------------------------------------------------------------
if ~isfield(S, 'dataset')
    [dataset, sts] = spm_select(1, '.*', 'Select EEG dataset');
    if ~sts, dataset = []; return; end
    S.dataset = dataset;
end

if ~isfield(S, 'ref1')
    S.ref1 = 'StimArt_filtered';
end

%% TODO add somewhere the possibility to choose which files you want synched 
% for ex if there's no video with the file to not process it in
% dbs_eeg_percept_prepare_allfiles, also the same for markers
% [eeg_file, dbs_file, logfile, stim] = dbs_eeg_percept_prepare_allfiles(S.dataset);

if details.process_logfiles==1 && ~isempty(files{3})
    disp('Preparing logfile...')
    [trl trialinfo]=dbs_eeg_percept_logfiles_prepare(files{1}, files{3});
else
    disp('no logfile available for this EEG dataset')
    trl=[];
end



if details.process_videos==1 && ~isempty(files)
    disp('Preparing and synchronizing video file with EEG')
    video_file=dbs_eeg_percept_videofiles_prepare(files{1}, fullfile(files{4}, '\'), spm_file(files{4}, 'filename'));
    
    if strcmp(details.vidoffset_tocompute{f}, 'no')
        video_file.LED_offset_start=details.vidoffset(1,f);
        video_file.LED_offset_end=details.vidoffset(2,f);
        video_file.LED_signal=load(files{6}).LED_signal;
    else
        [LED_offset_start, LED_offset_end, LED_signal]=dbs_eeg_percept_determine_video_offset_LED([files{5},'.mp4'], files{3}, files{1});
        video_file.LED_offset_start=LED_offset_start;
        video_file.LED_offset_end=LED_offset_end;
        video_file.LED_signal=LED_signal;
        % TODO write outputs of the video offset to the excel file
        % note that you may have to do this not now but after
        % dbs_eeg_percept_synchronise as it corrects stuff there, but then
        % you'll have to look in the code to change some stuff
       
    end

    [eeg_file_withvid, offset_end]=dbs_eeg_percept_synchronise_video(video_file, files{1});
    %TODO save the eeg_file_withvid somewhere as temporary file and include
    %the option to take this file from memory
    % TODO this intermediate needs to be saved in home file not where the
    % code is
    D1=spm_eeg_ft2spm(eeg_file_withvid, [details.initials, '_synchedVideo.mat']);
    
else
    disp('no motion tracking data added to this EEG dataset')
    video_file=[];

    S = [];
    S.dataset = files{1};
    S.mode = 'continuous';
    D1 = spm_eeg_convert(S);

end

if details.synch_percept_stamp==1
    if ~isempty(video_file)
        [eeg_file, dbs_file]=dbs_eeg_percept_prepare_for_syncing_perceptstamp(eeg_file_withvid, files{1}, files{2}, details, f);
        [eeg_file, trl]=dbs_eeg_percept_synching_perceptstamp(eeg_file, dbs_file, trl, details);

    else
        cfg = [];
        cfg.dataset = files{1};
        eeg_file_temp=ft_preprocessing(cfg);
        [eeg_file, dbs_file]=dbs_eeg_percept_prepare_for_syncing_perceptstamp(eeg_file_temp, files{1}, files{2}, details, f);
        [eeg_file, trl]=dbs_eeg_percept_synching_perceptstamp(eeg_file, dbs_file, trl, details);
        
    end

    D=spm_eeg_ft2spm(eeg_file, [details.initials, '_synchPRstamp.mat']);
%     S1 = [];
%     S1.D  = D;
%     S1.bc = 0;
%     S1.trl = [trl(:,1), trl(:,1)+mean(trl(:,2)-trl(:,1))];
%     S1.conditionlabels=trialinfo;
%     D_epoched = spm_eeg_epochs(S1);

    S_trl=[];
    S_trl.trl=[trl(:,1), trl(:,1)+mean(trl(:,2)-trl(:,1))]; % TODO check why you wrote this bit
    S_trl.conditionlabels=trialinfo;

end

%% TODO actually you can do both percept and ecg stamping I guess, to fine tune
% the synching, so make sure you can incorporate that in the script
if details.synch_ecg==1
    if details.synch_percept_stamp==1
        S=[];
        S.D=D;
        % there must be a better way to do this
        S.channels=D.chanlabels(find(~strcmp(D.chantype,'LFP')));
        S.prefix='eeg';
        D1=spm_eeg_crop(S);

        S=[];
        S.D=D;
        S.channels=D.chanlabels(D.indchantype('LFP'));
        S.prefix='lfp';
        D2=spm_eeg_crop(S);
    else
        load(files{2})
        D2 = spm_eeg_ft2spm(data, [details.initials '_lfp.mat']);
    end
    
    %% TODO add logfiles to this function
    S = [];
    S.D1 = D1;
    S.D2 = D2;
    S.ref1 = details.eeg_ref{f};
    S.ref2 = details.lfp_ref;
    D= dbs_eeg_percept_noise_merge(S); 

    if ~keep, delete(S.D1); delete(S.D2); end

    D = chantype(D, D.indchannel(details.chan), 'LFP');
    
    if isfield(details, 'ecgchan') && ~isempty(details.ecgchan)
        D = chantype(D, D.indchannel(details.ecgchan), 'ECG');
    end

%     D.fname=[D.fname, '_synchECG'];
    save(D);

    % Question: do we want to get the epoched data as output for this
    % function or just output the trl data also (maybe save it somewhere for later use)
%     S1 = [];
%     S1.D  = D;
%     S1.bc = 0;
%     S1.trl = [trl(:,1), trl(:,1)+mean(trl(:,2)-trl(:,1))];
%     S1.conditionlabels=trialinfo;
%     D_epoched = spm_eeg_epochs(S1);

    S_trl=[];
    S_trl.trl=[trl(:,1), trl(:,1)+mean(trl(:,2)-trl(:,1))];
    S_trl.conditionlabels=trialinfo;
end

save(D);
% D = spm_eeg_ft2spm(eeg_file, S.outfile);

end

