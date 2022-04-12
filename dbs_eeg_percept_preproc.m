function [eeg_file, logfile] = dbs_eeg_percept_preproc(files, details, f)
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
[eeg_file, dbs_file, logfile, stim] = dbs_eeg_percept_prepare_allfiles(S.dataset);

if details.process_logfiles==1 && ~isempty(files{3})
    disp('Preparing logfile...')
    logfile=dbs_eeg_percept_logfiles_prepare(files{1}, files{3});
else
    disp('no logfile available for this EEG dataset')
    logfile=[];
end


% TODO in the very rare case where you do have LED (video) files
% available but something happened to the logfile, you can always
% try synching the video directly with the EEG. Not sure if that's
% even useful since you will also have lost the markers from your
% experiment, but if you have extra time you could try adding that
% feature to this piece of code

if details.process_videos==1 && ~isempty(files)
    disp('Preparing and synchronizing video file with EEG')
    video_file=dbs_eeg_percept_videofiles_prepare(files{1}, fullfile(files{4}, '\'), spm_file(files{4}, 'filename'));
    
    if strcmp(details.vidoffset_tocompute{f}, 'no')
        [LED_offset_start LED_offset_end]=details.vidoffset(:,f);
        video_file.LED_offset_start=LED_offset_start;
        video_file.LED_offset_end=LED_offset_end;
        
    else
        [LED_offset_start, LED_offset_end, LED_signal]=detect_offset_LED([files{5},'.mp4'], files{3});
        video_file.LED_offset_start=LED_offset_start;
        video_file.LED_offset_end=LED_offset_end;
        video_file.LED_signal=LED_signal;
        % TODO write outputs of the video offset to the excel file
        % note that you may have to do this not now but after
        % dbs_eeg_percept_synchronise as it corrects stuff there, but then
        % you'll have to look in the code to change some stuff
       
    end

    eeg_file_withvid=dbs_eeg_percept_synchronise_video(video_file, eegfile);

else
    disp('no motion tracking data added to this EEG dataset')
    video_file=[];

end

if details.synch_ecg==0 && details.synch_percept_stamp==1
    if ~isempty(video_file)
        [eeg_file dbs_file]=dbs_eeg_percept_prepare_for_syncing_perceptstamp(eeg_file_withvid, files{1}, files{2}, details, f)

    else
%         [eeg_file dbs_file]=prepare_dbs_eeg_file(eeg_file_withvid, files{1}, details.freqrange, files{2})
    end
    
    


    if ~any(strcmp(eeg_file.label, 'StimArt_filtered'))
        warning('No stimulator channel found')
        noisematch = 0;
    else
        noisematch = 1;
    end
    
    
    %% Sunchronizing the EEG and the Percept PC file
    cfg=[];
    cfg.channel='StimArt_filtered';
    eeg_stim=ft_preprocessing(cfg, eeg_file);

    cfg=[];
    cfg.channel=details.lfp_ref;
    dbs_stim=ft_preprocessing(cfg, dbs_file);
    
    if noisematch
        
        n1 = detrend(eeg_stim.trial{1});
        n2 = detrend(dbs_stim.trial{1});
        
%         if stim==0
            TF1=(abs(n1)>mean(n1)+3*std(n1));
            TF2=(abs(n2)>mean(n2)+4*std(n2)); 
            
            temp1=find(TF1(1:floor(size(TF1,2)/2)));
            temp2=find(TF2(1:floor(size(TF2,2)/2)));

            if isempty(temp1) temp1=1; end
            if isempty(temp2) temp2=1; end

            size_window_start=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
            
            temp1=find(TF1(floor(size(TF1,2)/2):end));
            temp2=find(TF2(floor(size(TF2,2)/2):end));
            temp_TF= floor(size(TF1,2)/2);

            incr_=1;
            while isempty(temp1) || isempty(temp2)
                temp1=find(TF1(floor(size(TF1,2)/2)-10*incr_*eeg_stim.fsample:end));
                temp2=find(TF2(floor(size(TF2,2)/2)-10*incr_*dbs_file.fsample:end));
                temp_TF=temp_TF-10*incr_*dbs_file.fsample;
                incr_=incr_+1;
            end

            size_window_end=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
            
%             if max(temp1(end), temp2(end))+floor(size(TF1,2)/2)<size(n1,2) && max(temp1(end), temp2(end))+floor(size(TF2,2)/2)<size(n2,2)
%                 size_window_end=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
% 
%             elseif max(temp1(end), temp2(end))+floor(size(TF2,2)/2)>size(n2,2)
%                 size_window_end=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
%                 
%             end

            
            [c, lags] = xcorr(n1(size_window_start(1):size_window_start(2)), n2(size_window_start(1):size_window_start(2)), 'coeff');
            [mc, mci] = max(abs(c));
            
            
            offset_stamp_start=lags(mci);
            
            %% TODO: add checks to see if there is good crosscorrelation
            % issue with that is that you have to first figure out what a good
            % value is because it is generally lower than what vladimir has in his
            % data
            
%             temp_=min([size(TF1,2)  size(TF2,2)]);

            [c, lags] = xcorr(n1(size_window_end(1)+temp_TF:size_window_end(2)+temp_TF-1), ...
                n2(size_window_end(1)+temp_TF:size_window_end(2)+temp_TF-1), 'coeff');
            
            [mc, mci] = max(abs(c));
        
            offset_stamp_end=lags(mci);
    
%         elseif stim==1
%     
%             TF1=(abs(n1)>mean(n1)+3*std(n1));
%             TF2=(abs(n2)>mean(n2)+2*std(n2)); 
%             
%             temp1=find(TF1(1:floor(size(TF1,2)/2)));
%             temp2=find(TF2(1:floor(size(TF2,2)/2)));
%             
%             size_window_start=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
%             
%             temp1=find(TF1(floor(size(TF1,2)/2):end));
%             temp2=find(TF2(floor(size(TF2,2)/2):end));
%             
%             size_window_end=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
%             
%             [c, lags] = xcorr(TF1(size_window_start(1):size_window_start(2)), TF2(size_window_start(1):size_window_start(2)), 'coeff');
%             [mc, mci] = max(abs(c));
%             
%             offset_stamp_start=lags(mci);
%             
%             %% TODO: add checks to see if there is good crosscorrelation
%             % issue with that is that you have to first figure out what a good
%             % value is because it is generally lower than what vladimir has in his
%             % data
%         
%             [c, lags] = xcorr(TF1(size_window_end(1)+floor(size(TF1,2)/2):size_window_end(2)+floor(size(TF1,2)/2)), ...
%                 TF2(size_window_end(1)+floor(size(TF2,2)/2):size_window_end(2)+floor(size(TF2,2)/2)), 'coeff');
%             
%             [mc, mci] = max(abs(c));
%         
%             offset_stamp_end=lags(mci);
%     
%         end
        
        
    end
    
    if offset_stamp_start < 0
        % this is usually what's going to happen because we start the EEG
        % recording first
        ref_channel= eeg_file;
        oth_channel= dbs_file;
    elseif offset_stamp_start > 0
        ref_channel= dbs_file;
        oth_channel= eeg_file;
    end
    
    reftrl = linspace(0, size(ref_channel.time{1},2)/ref_channel.fsample, size(ref_channel.time{1},2));
    
    trl_offset  = zeros(1, size(oth_channel.time{1},2));
    trl_offset= trl_offset + (abs(offset_stamp_start))*(fliplr(reftrl)/reftrl(end)) + (abs(offset_stamp_end))*(reftrl/reftrl(end));
    trl_offset=round(trl_offset);
    
    temp_ind=(1:size(oth_channel.trial{1},2))+trl_offset;
    x=find(temp_ind>size(oth_channel.trial{1},2),1);
    
    
    synched=oth_channel.trial{1}(:,temp_ind(1:x-1));
    reftrl=reftrl(1:x-1);
    
    cfg=[];
    cfg.begsample=1;
    cfg.endsample=x-1;
    eeg_file=ft_redefinetrial(cfg, eeg_file); 
    
    % however you change the timing of the EEG file apply the same change to the logfile too
    %% TODO not a 100% sure this is doing the right thing, check with video synchs later
    logfile(:,1:2)=logfile(:,1:2)-eeg_file.time{1,1}(1)*eeg_file.fsample;
    eeg_file.time={reftrl};
    
    if offset_stamp_start < 0
        % this is usually what's going to happen because we start the EEG
        % recording first
        eeg_file.trial{1}(end+1,:)=synched;
        eeg_file.label{end+1}='LFP';
    elseif offset_stamp_start > 0
        eeg_file.trial{1}=synched;
        eeg_file.trial{1}(end+1,:)=ref_channel.trial{1}(1:x-1);
        eeg_file.label{end+1}='LFP';
    end

end

% D = spm_eeg_ft2spm(eeg_file, S.outfile);

