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

keep=0;

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
    video_file=dbs_eeg_percept_videofiles_prepare(files{1}, fullfile(files{4}, '\'), spm_file(files{4}, 'filename'), details.automatic_tracking);
    
    if strcmp(details.vidoffset_tocompute{f}, 'no')
        video_file.LED_offset_start=details.vidoffset(1,f);
        video_file.LED_offset_end=details.vidoffset(2,f);
        video_file.LED_signal=load(files{6}).LED_signal;
    else
        if details.save_LED_info==1
        txt=[];
        while ~strcmp(txt,'y')
            [LED_offset_start, LED_offset_end, LED_signal]=dbs_eeg_percept_determine_video_offset_LED([files{5},'.mp4'], files{3}, files{1});
            video_file.LED_offset_start=LED_offset_start;
            video_file.LED_offset_end=LED_offset_end;
            video_file.LED_signal=LED_signal;
            figure, plot(LED_signal)
            title('are you happy with the LED signal? y/n ')
            txt = input('are you happy with the LED signal? y/n ',"s");
        end
        

        dbsroot='\\piazzolla\vlad_shared';
        [~, file_table] = xlsread(fullfile(dbsroot, details.initials, [details.initials '.xlsx']));
        excel_entry=strmatch(erase(spm_file(files{1},'filename'),'.vhdr'), file_table(:,1), 'exact');
        xlswrite(fullfile(dbsroot, details.initials, [details.initials '.xlsx']), 0, 1,['E', num2str(excel_entry)]);
        xlswrite(fullfile(dbsroot, details.initials, [details.initials '.xlsx']), LED_offset_start, 1,['F', num2str(excel_entry)]);
        xlswrite(fullfile(dbsroot, details.initials, [details.initials '.xlsx']), LED_offset_end, 1,['G', num2str(excel_entry)]);
        save([strrep(files{5}, 'videos', 'signals'), '.mat'], 'LED_signal')
        else
            [LED_offset_start, LED_offset_end, LED_signal]=dbs_eeg_percept_determine_video_offset_LED([files{5},'.mp4'], files{3}, files{1});
            video_file.LED_offset_start=LED_offset_start;
            video_file.LED_offset_end=LED_offset_end;
            video_file.LED_signal=LED_signal;

        end


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
        [eeg_file, trl, offset_stamp_start, offset_stamp_end]=dbs_eeg_percept_synching_perceptstamp(eeg_file, dbs_file, trl, details,f);

    else
        cfg = [];
        cfg.dataset = files{1};
        eeg_file_temp=ft_preprocessing(cfg);
        [eeg_file, dbs_file]=dbs_eeg_percept_prepare_for_syncing_perceptstamp(eeg_file_temp, files{1}, files{2}, details, f);
        [eeg_file, trl, offset_stamp_start, offset_stamp_end]=dbs_eeg_percept_synching_perceptstamp(eeg_file, dbs_file, trl, details,f);
        
    end


    temp=strsplit(spm_file(files{3},'filename'),'_');
    if strcmp(temp(end-2),'REST')
        condition='R';
    else
        condition=temp{end-2};
    end
    save([details.initials '_rec_' num2str(details.rec_id) '_' condition '_' num2str(f) '_offsets.mat'],...
        'offset_stamp_start','offset_stamp_end')
    D=spm_eeg_ft2spm(eeg_file, [details.initials, '_synchPRstamp_', num2str(f),'.mat']);
    

%     S1 = [];
%     S1.D  = D;
%     S1.bc = 0;
%     S1.trl = [trl(:,1), trl(:,1)+mean(trl(:,2)-trl(:,1))];
%     S1.conditionlabels=trialinfo;
%     D_epoched = spm_eeg_epochs(S1);

    if details.process_logfiles==1 && ~isempty(files{3})
        S_trl=[];
        S_trl.trl=[trl(:,1), trl(:,2)];
        S_trl.conditionlabels=trialinfo;
        ev=dbs_eeg_percept_convert_logfile_to_event(S_trl, D, files{3});
        D = events(D, 1, {ev});
    end
else
    % never debugged this part, TODO!
    if details.process_logfiles==1 && ~isempty(files{3})
        S_trl=[];
        S_trl.trl=[trl(:,1), trl(:,2)];
        S_trl.conditionlabels=trialinfo;
        ev=dbs_eeg_percept_convert_logfile_to_event(S_trl, D1, files{3});
        D1 = events(D1, 1, {ev});
    end


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
    
            if ~keep delete(D1); end
    
            D1=spm_eeg_crop(S);
    
            S=[];
            S.D=D;
            S.channels=D.chanlabels(D.indchantype('LFP'));
            S.prefix='lfp';
            D2=spm_eeg_crop(S);
    
            if ~keep delete(S.D); end
        else
            % never debugged this part, TODO!!!!
            load(files{2})
            D2 = spm_eeg_ft2spm(data, [details.initials '_lfp.mat']); 
            if details.process_logfiles==1 && ~isempty(files{3})
                S_trl=[];
                S_trl.trl=[trl(:,1), trl(:,2)]; % TODO check why you wrote this bit
                S_trl.conditionlabels=trialinfo;
                ev=dbs_eeg_percept_convert_logfile_to_event(S_trl, D2, files{3});
                D2 = events(D2, 1, {ev});
            end
        end
        
        S = [];
        S.D1 = D1;
        S.D2 = D2;
        S.ref1 = details.eeg_ref{f};
        S.ref2 = details.lfp_ref;
        D= dbs_eeg_percept_noise_merge(S); 
    
        evs=D.events;
        for i=numel(evs):-1:1
            if strcmp(evs(i).type, 'trial')
                evs(i)=[];
            end
        end
        D = events(D, 1, {evs});
    
    
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
    
    %     S_trl=[];
    %     S_trl.trl=[trl(:,1), trl(:,1)+mean(trl(:,2)-trl(:,1))];
    %     S_trl.conditionlabels=trialinfo;
    end

save(D);
if ~keep delete(D1); end

S = [];
S.D = D;
temp=strsplit(spm_file(files{3},'filename'),'_');
% if strcmp(temp(end-3),'OFF')
%     rec_id=1;
% elseif strcmp(temp(end-3),'ON')
%     rec_id=2;
% end

if strcmp(temp(end-2),'REST')
    condition='R';
else
    condition=temp{end-2};
end



D = copy(S.D, [details.initials '_rec_' num2str(details.rec_id) '_' condition '_' num2str(f) '_preproc']);

delete(S.D)
% D = spm_eeg_ft2spm(eeg_file, S.outfile);

end

