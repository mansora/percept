function [eeg_file dbs_file, logfile, stim] = dbs_eeg_percept_prepare_allfiles(eegfile)
% Requirements to run this script is an excel files that contains the name
% of eeg files, percept PC files (after converting from json to .mat),
% logfiles and video files

%% TODO also add your dbs_eeg_percept_3dscan_prepare code to this code
patients={'LN_PR_D001',...
          'LN_PR_D003',...
          'LN_PR_D004',...
    };

num_patient=cell2mat(arrayfun( @(x) contains(eegfile, patients(x)), [1:size(patients,2)] , 'UniformOutput', false));

if any(num_patient)

    name_patient=patients{find(num_patient)};
    filename_base=fullfile(spm_file(spm_file(eegfile, 'path'), 'path'));
    [~, strings, ~]= xlsread([filename_base, '\',  name_patient, '.xlsx']);
    x=find(strcmp(strings(:,1), spm_file(eegfile, 'basename')));

    if ~isempty(x) 

    if ~isempty(strings{x,4})
        disp('Preparing logfile...')
        filename_logfile=[filename_base, '\raw_Logfiles\', strings{x,4}, '.mat'];
        logfile=dbs_eeg_percept_logfiles_prepare(eegfile, filename_logfile);
        % TODO preproc file will change the timing of the EEG file you should also adjust it for the trl file

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
    if ~isempty(strings{x,3}) && ~isempty(strings{x,4})
        disp('Preparing and synchronizing video file with EEG, this could take a while...')

        filename_video=[filename_base, '\processed_MotionCapture\jsons\', strings{x,3}, '\'];
        filename_LED_video=[filename_base, '\processed_MotionCapture\LED_videos\LED_',strings{x,3}, '.mp4'];

        video_file=dbs_eeg_percept_videofiles_prepare(eegfile, filename_video, strings{x,3});

        [LED_offset_start, LED_offset_end, LED_signal]=detect_offset_LED(filename_LED_video, filename_logfile);

        video_file.LED_offset_start=LED_offset_start;
        video_file.LED_offset_end=LED_offset_end;
        video_file.LED_signal=LED_signal;

        eeg_file_withvid=dbs_eeg_percept_synchronise_video(video_file, eegfile);

    else
        disp('no motion tracking data or synching information available for this EEG dataset')
        video_file=[];
    end

        
    disp('Preparing EEG files for synchronization with the Percept data...')
    % checking if stimulation is on or off. this will be usefull for
    % when you are trying to synchronize LFP data with EEG but actually
    % it is likely that won't be necessary anymore because I've added
    % taking the envelope of the stimArt instead which makes the signal
    % so that you can use the same code for stim on and off in
    % dbs_eeg_percept_preproc TODO you do have to check this thoroughly
    % though and once you're sure remove it all from the code
    if ~isempty(strfind(filename_logfile, 'OFF'))
        stim=0;
    elseif ~isempty(strfind(filename_logfile, 'ON'))
        stim=1;
    else
        str = input('No information on stim condition available. Was stimulation on for this dataset? y/n ','s');
        if strcmp(str,'y')
            stim=1;
        elseif strcmp(str,'n')
            stim=0;
        end
    end



    %% TODO this will likely have to change for future patients see how artifact will be processed
    if strcmp(name_patient, 'LN_PR_D001') && stim==1
            freqrange=[170 190];
    elseif strcmp(name_patient, 'LN_PR_D001') && stim==0
            freqrange=[65 75];
    elseif strcmp(name_patient, 'LN_PR_D003')
       freqrange=[70 90];
       % TODO check if it works better with [75 85]
    end

    if ~isempty(strings{x,2})
        filename_dbs=[filename_base, '\raw_LFP', strings{x,2}];
        [eeg_file dbs_file]=prepare_dbs_eeg_file(eeg_file_withvid, eegfile, freqrange, filename_dbs)
    else
        disp('no Percept data available for this EEG dataset')
        dbs_file=[];
    end


        
    else disp('cannot find this file in the patient log')
    
    end

end

% note: for LN_PR_D001_0=20220107_0007
% the first percept stamp is not recorded completely in EEG and so synching is going to have issues.
% this block (pouring) was also repeated and is not so vital anyway

end


    





