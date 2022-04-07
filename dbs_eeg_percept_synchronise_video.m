function eeg_file_withvid=dbs_eeg_percept_synchronise_video(video_file, eegfile)

    %% Synchronizing the EEG and the videofile
    % This code currently doesn't work because the video file and eeg file
    % aren't the same length
    % to make them the same length:

    cfg = [];
    cfg.dataset = eegfile;
    dataEEG=ft_preprocessing(cfg);

    events=ft_read_event(eegfile); 
    events=squeeze(struct2cell(events));
    LED_markersEEG=find(strcmp(events(1,:),'Toggle'));
    EEGmarker_start=cell2mat(events(3,LED_markersEEG(1)));
    EEGmarker_end=cell2mat(events(3,LED_markersEEG(end)));
    size_EEG=EEGmarker_end-EEGmarker_start;

%     n2=detrend(LED_conditionR_fieldtrip.trial{1});
    n2=detrend(video_file.LED_signal);
    TF= abs(n2) > (mean(n2)+3*std(n2)); 
    temp_start=find(TF(1:floor(size(TF,2)/2)));
    temp_end=find(TF(floor(size(TF,2)/2):end));

    cfg=[];
    cfg.begsample= temp_start(1);
    cfg.endsample= temp_end(end)+ceil(size(TF,2)/2);
    video_file=ft_redefinetrial(cfg, video_file);
 
%     offset_start=0;
    offset_end=video_file.LED_offset_end-video_file.LED_offset_start;
    offset_end=-offset_end;

    if (temp_end(end)+ceil(size(TF,2)/2)-temp_start(1))-size_EEG == offset_end
        disp('all is well')
    else
        disp('there is discrepancy between length of LED sequences in EEG data and in detect_offset_LED')
        disp('will change the offset based on the LED signal and event markers in EEG data')
        offset_end= (temp_end(end)+ceil(size(TF,2)/2)-temp_start(1))-size_EEG;
    end

    
    reftrl = linspace(0, size_EEG/dataEEG.fsample, size_EEG);
    
    trl_offset  = zeros(1, size(reftrl,2));
    trl_offset= trl_offset  + (offset_end)*(reftrl/reftrl(end));
    trl_offset=round(trl_offset);
    
    temp_ind=(1:size(reftrl,2))+trl_offset;
    
    synched=video_file.trial{1}(:,temp_ind);
    
    synched_padded=zeros(size(video_file.trial{1},1), size(dataEEG.trial{1},2));
    synched_padded(:,EEGmarker_start:EEGmarker_end-1)=synched;
    
    
    dataVideo=dataEEG;
    dataVideo.label=video_file.label;
    dataVideo.trial={synched_padded};

    cfg=[];
    eeg_file_withvid=ft_appenddata(cfg, dataEEG, dataVideo);


    
    
    


end