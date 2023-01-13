function [eeg_file_withvid offset_end]=dbs_eeg_percept_synchronise_video(video_file, eegfile)

    %% Synchronizing the EEG and the videofile
    % This code currently doesn't work because the video file and eeg file
    % aren't the same length
    % to make them the same length:

    cfg = [];
    cfg.dataset = eegfile;
    dataEEG=ft_preprocessing(cfg);

    eventss=ft_read_event(eegfile); 
    eventss=squeeze(struct2cell(eventss));
    if contains(eegfile, 'LN_PR_D005_20220401_00120.vhdr')
        eventss=eventss(:,142:end);
        eventss(3,:)=num2cell(cell2mat(eventss(3,:))-eventss{3,1});

    elseif contains(eegfile, 'LN_PR_D005_20220401_0012.vhdr')
        eventss=eventss(:,1:141);
    end
    LED_markersEEG=find(strcmp(eventss(1,:),'Toggle'));
    if ~isempty(find(strcmp(eventss(2,LED_markersEEG), 'T  2')))
        LED_markersEEG=find(strcmp(eventss(2,:),'T  2'));
    elseif ~isempty(find(strcmp(eventss(2,LED_markersEEG), 'T  1')))
        LED_markersEEG=find(strcmp(eventss(2,:),'T  1'));
    end

    xx=diff(cell2mat(eventss(3,LED_markersEEG)));
    figure, plot(xx,10,'*r')


    if cell2mat(eventss(3,LED_markersEEG(2)))-cell2mat(eventss(3,LED_markersEEG(1)))<6*dataEEG.fsample
        EEGmarker_start=cell2mat(eventss(3,LED_markersEEG(1)));
    else
        EEGmarker_start=cell2mat(eventss(3,LED_markersEEG(2)));
        warning('check markers!!!!!!')
    end
    if cell2mat(eventss(3,LED_markersEEG(end)))-cell2mat(eventss(3,LED_markersEEG(end-1)))<6*dataEEG.fsample
        EEGmarker_end=cell2mat(eventss(3,LED_markersEEG(end)));
    else
        EEGmarker_end=cell2mat(eventss(3,LED_markersEEG(end-1)));
        warning('check markers!!!!!!')
    end

    
    size_EEG=EEGmarker_end-EEGmarker_start;

    %     offset_start=0;
    offset_end=video_file.LED_offset_end-video_file.LED_offset_start;
    offset_end=-offset_end;

    if ~isempty(video_file.LED_signal)
    %     n2=detrend(LED_conditionR_fieldtrip.trial{1});
%         n2=detrend(video_file.LED_signal);
        n2=zscore(diff(video_file.LED_signal));
        thresh_=7;
        go_on=[];
        temp_start=[];
        while isempty(temp_start) && isempty(go_on)
            offss=500;
            TF= find(abs(n2(offss:end-1000)) > (mean(n2)+thresh_*std(n2))); 
            temp_start=round(min(TF(TF<0.4*size(n2,2))))-offss;
            thresh_=thresh_-0.5;
            if thresh_<3
                go_on=1;
            end
        end

        if isempty(temp_start) temp_start=offset_end; end  % temp_start=video_file.LED_offset_end

        thresh_=7;
        go_on=[];
        temp_end=[];
        while isempty(temp_end) && isempty(go_on)
            TF= find(abs(n2(1:end-1000)) > (mean(n2)+thresh_*std(n2))); 
            temp_end=round(max(TF(TF>0.6*size(n2,2))));
            thresh_=thresh_-0.5;
            if thresh_<3
                go_on=1;
            end
        end

        if contains(eegfile, 'LN_PR_D009_20221021_0019.vhdr')
            temp_end=EEGmarker_end+(temp_start-EEGmarker_start);
        elseif contains(eegfile, 'LN_PR_D001_0=20220107_0001.vhdr')
            temp_end=428764;
            EEGmarker_end=428764-abs(video_file.LED_offset_end);
        elseif contains(eegfile, 'LN_PR_D008_20221014_0016.vhdr')
             EEGmarker_start=cell2mat(eventss(3,LED_markersEEG(3)));
        end

        size_EEG=EEGmarker_end-EEGmarker_start;
    
        cfg=[];
        cfg.begsample= temp_start;
        if ~isempty(temp_end) && temp_end<size(video_file.trial{1},2)
            cfg.endsample= temp_end;

            if abs(abs(temp_end-temp_start-size_EEG)- abs(offset_end))<200
                disp('all is well')
            else
                disp('there is discrepancy between length of LED sequences in EEG data and in detect_offset_LED')
                disp('will change the offset based on the LED signal and event markers in EEG data')
                offset_end= abs(size_EEG -(temp_end-temp_start)); %(temp_end-temp_start)-size_EEG;
            end

        else
            cfg.endsample= size(video_file.trial{1},2); %size(n2,2);
        end
            
        video_file=ft_redefinetrial(cfg, video_file);
     
    end

    
    reftrl = linspace(0, size_EEG/dataEEG.fsample, size_EEG);
    
    trl_offset  = zeros(1, size(reftrl,2));
    trl_offset= trl_offset  + (abs(offset_end))*(reftrl/reftrl(end));
    trl_offset=round(trl_offset);
    
    temp_ind=(1:size(reftrl,2))+trl_offset;
    

%     synched=video_file.trial{1}(:,temp_start+temp_ind(temp_ind<size(video_file.trial{1},2)));
    synched=video_file.trial{1}(:,temp_ind(temp_ind<size(video_file.trial{1},2)));
    
%     % check synch
    n2_synched=n2(:,temp_start+temp_ind(temp_ind<size(n2,2)));
    synched_padded=zeros(size(n2,1), size(dataEEG.trial{1},2));
    synched_padded(:,EEGmarker_start:EEGmarker_start+size(n2_synched,2)-1)=n2_synched;
    figure, plot(synched_padded), hold on, plot(cell2mat(eventss(3,LED_markersEEG)), mean(n2_synched),'r*')
    print(gcf,['D:\home\Data\', 'xLED_synching', spm_file(eegfile,'basename'), '.jpg'],'-djpeg');
    %

    synched_padded=zeros(size(video_file.trial{1},1), size(dataEEG.trial{1},2));
%     synched_padded(:,EEGmarker_start:EEGmarker_end-1)=synched;
    if contains(eegfile, 'LN_PR_D005_20220401_00120')
        synched_padded(:,367768+EEGmarker_start:367768+EEGmarker_start+size(synched,2)-1)=synched;
    else
        synched_padded(:,EEGmarker_start:EEGmarker_start+size(synched,2)-1)=synched;
    end

    
    
    dataVideo=dataEEG;
    dataVideo.label=video_file.label;
    dataVideo.trial={synched_padded};

    cfg=[];
    eeg_file_withvid=ft_appenddata(cfg, dataEEG, dataVideo);


    
    
    


end