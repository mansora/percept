function [eeg_file, logfile, offset_stamp_start, offset_stamp_end]=dbs_eeg_percept_synching_perceptstamp(eeg_file, dbs_file, logfile, details,f)
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
        
        n1 = zscore(detrend(eeg_stim.trial{1}));
        n2 = zscore(detrend(dbs_stim.trial{1}));

        if isfield(details, 'switch_stimoff') && details.switch_stimoff(f)==1
            n1=diff(n1);
        elseif strcmp(details.initials, 'LN_PR_D005') && details.rec_id==4 && f==2
            n1=zscore(diff(detrend(eeg_stim.trial{1})));
        end
        
%         if stim==0
            TF1=(abs(n1)>mean(n1)+2.5*std(n1));
            TF2=(abs(n2)>mean(n2)+4*std(n2)); 
            
            temp1=find(TF1(1:floor(size(TF1,2)/2)));
            temp2=find(TF2(1:floor(size(TF2,2)/2)));
            
%             % not sure if this will also work for non-rest blocks or blocks
%             % where stim is turned on not off
%             if isfield(details, 'switch_stimoff') && details.switch_stimoff==1
%                 n1_temp=detrend(eeg_stim.trial{1}((1:max(temp1)-5)));
%                 TF1_temp=(abs(n1_temp)>mean(n1_temp)+2*std(n1_temp));
%                 temp1_temp=find(TF1_temp);
%                 temp1=[temp1_temp, temp1];
%                 temp1=unique(temp1);
%             end

            if isempty(temp1) temp1=1; end
            if isempty(temp2) temp2=1; end

            size_window_start=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
            
            if strcmp(details.initials, 'LN_PR_D009') && f==1
                n2_temp=n2;
                n2_temp(1,1:floor(size(n2,2)/2))=0;
                n2_temp=zscore(n2_temp);
                TF2=(abs(n2_temp)>7*std(n2_temp)); 
            end

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

            if temp_TF<0
                temp1=[-10 -5] + floor(size(TF1,2)/2);
                temp2=[-10 -5] + floor(size(TF2,2)/2);
                temp_TF= floor(size(TF1,2)/2);
            end

            size_window_end=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
            
%             if max(temp1(end), temp2(end))+floor(size(TF1,2)/2)<size(n1,2) && max(temp1(end), temp2(end))+floor(size(TF2,2)/2)<size(n2,2)
%                 size_window_end=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
% 
%             elseif max(temp1(end), temp2(end))+floor(size(TF2,2)/2)>size(n2,2)
%                 size_window_end=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
%                 
%             end

            
            
            [c, lags] = xcorr((n1(size_window_start(1):size_window_start(2))), (n2(size_window_start(1):size_window_start(2))), 'coeff');
            [mc, mci] = max(abs(c));

%             if mc/median(abs(c)) < 25
%                 offset_stamp_start=[];
%             else
                offset_stamp_start=lags(mci);
%             end
            
            %% TODO: add checks to see if there is good crosscorrelation
            % issue with that is that you have to first figure out what a good
            % value is because it is generally lower than what vladimir has in his
            % data
            
%             temp_=min([size(TF1,2)  size(TF2,2)]);
            
            
            [c, lags] = xcorr((n1(size_window_end(1)+temp_TF:size_window_end(2)+temp_TF-1)), ...
                (n2(size_window_end(1)+temp_TF:size_window_end(2)+temp_TF-1)), 'coeff');
            
            [mc, mci] = max(abs(c));
        

%             if mc/median(abs(c)) < 25
%                 offset_stamp_end=[];
%             else
                offset_stamp_end=lags(mci);
%             end
            


            if isempty(offset_stamp_end) || offset_stamp_end==0
                offset_stamp_end=offset_stamp_start;
            end

            if isempty(offset_stamp_start) || offset_stamp_start==0
                offset_stamp_start=offset_stamp_end;
            end

            if abs(offset_stamp_start-offset_stamp_end)>eeg_file.fsample*3
                if strcmp(details.initials,'LN_PR_D001')
                    warning('difference between offset and stamp is too much for LN_PR_D001')
                    offset_stamp_start=offset_stamp_end;
                elseif strcmp(details.initials,'LN_PR_D004') && f==1 % add details.rec_id
                    offset_stamp_end=offset_stamp_start;
                elseif strcmp(details.initials,'LN_PR_D007') && f==2 % add details.rec_id
                    offset_stamp_start=offset_stamp_end;
                else
                    error('difference between start and end offset of percept stamping is too large')
                end
            end

            if  abs(offset_stamp_start-offset_stamp_end)>eeg_file.fsample*2
                if strcmp(details.initials,'LN_PR_D005') && f==1
                    offset_stamp_end=offset_stamp_start;
                end
                    
            end


    
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
    
%     logfile_temp=logfile;
%     eeg_file_temp=eeg_file;
    % however you change the timing of the EEG file apply the same change to the logfile too
    if ~isempty(logfile)
%         logfile(:,1:2)=logfile(:,1:2)-eeg_file.time{1,1}(1)*eeg_file.fsample;
        if offset_stamp_start < 0
            logfile(:,1:2)=logfile(:,1:2)-eeg_file.time{1,1}(1)*eeg_file.fsample;
        elseif offset_stamp_start > 0
            logfile(:,1:2)=logfile(:,1:2)-trl_offset(ceil(logfile(:,1:2)))+oth_channel.time{1,1}(1)*oth_channel.fsample;
%             logfile(:,1:2)=logfile(:,1:2)+eeg_file.time{1,1}(1)*eeg_file.fsample;
        end

    end
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
        eeg_file.trial{1}(end+1:end+size(ref_channel.trial{1},1),:)=ref_channel.trial{1}(:,1:x-1);
        for ll=1:size(ref_channel.trial{1},1)
        eeg_file.label{end+1}=dbs_file.label{ll};
        end
    end

end