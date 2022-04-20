function [eeg_file, logfile]=dbs_eeg_percept_synching_perceptstamp(eeg_file, dbs_file, logfile, details)
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
    
    %% TODO this is horrible coding improve as soon as possible
    if offset_stamp_start < 0
        % this is usually what's going to happen because we start the EEG
        % recording first
        eeg_file.trial{1}(end+1:end+size(synched,1),:)=synched;
        for ll=1:size(synched,1)
        eeg_file.label{end+1}=dbs_file.label{ll};
        end
    elseif offset_stamp_start > 0
        eeg_file.trial{1}=synched;
        eeg_file.trial{1}(end+1:end+size(synched,1),:)=ref_channel.trial{1}(:,1:x-1);
        for ll=1:size(synched,1)
        eeg_file.label{end+1}=dbs_file.label{ll};
        end
    end

end