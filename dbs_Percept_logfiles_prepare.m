function dbs_eeg_percept_logfiles_prepare(Input_logfile)
    % read LED events from logfile
    temp=load(Input_logfile);
    OutputFile=temp.Ouputfile;

    x=find(strcmp(OutputFile(:,1), 'InitPulses'));
    initstamp_time=cell2mat(OutputFile(x,3));
    initstamp_value=cell2mat(OutputFile(x,2));
    initstamp_time=initstamp_time(find(initstamp_value~=0));
    initstamp_time=initstamp_time-initstamp_time(1);

    x=find(strcmp(OutputFile(:,1), 'EndPulses'));
    endstamp_time=cell2mat(OutputFile(x,3));
    endstamp_value=cell2mat(OutputFile(x,2));
    endstamp_time=endstamp_time(find(endstamp_value~=0));
    endstamp_time=endstamp_time-endstamp_time(1);


    % read LED event from eegfile
 
    events=ft_read_event(eegfile); 
    events=squeeze(struct2cell(events));


    for i=1:size(events,2)-size(initstamp_time,1)+1
        events_temp=cell2mat(events(3,i:end));
        events_temp=((events_temp-events_temp(1))/1000)'; %% TODO change 1000 to cfg.samplerate
        
        % correspondence between logfile stamps and eeg markers are very
        % good corr should be really close to 1
        if 1-corr(events_temp(1:size(initstamp_time,1)), initstamp_time)< 0.000001
            eventstart=i;
        end
    end

    


    % issue: the correlation between the first and last LED sequence is
    % (or dangerously as high) than the matching of the last LED sequence
    % to the EEG markers. So one option is to not use the last LED
    % sequence. I'm not really sure what we should use it for anyway as we
    % are not planning to do any resampling of the logfiles or video. Note
    % that this also means the matching between LED sequences of different
    % files (i.e. things that should not match) is also relatively high
    % with corr something like 0.997 or such. But for files that should
    % actually match (only first LED sequence) it is close to 1 on the
    % order of 0.000001
    
    for i=1:size(events,2)-size(endstamp_time,1)+1
        events_temp=cell2mat(events(3,i:end));
        events_temp=((events_temp-events_temp(1))/1000)'; %% TODO change 1000 to cfg.samplerate
        
        % correspondence between logfile stamps and eeg markers are very
        % good corr should be really close to 1
        if 1-corr(events_temp(1:size(endstamp_time,1)), endstamp_time) < 0.0005
            disp(i)
        end
        x(i)=corr(events_temp(1:size(endstamp_time,1)), endstamp_time);
          
    end

%     Time_line=0:1:(initstamp_time(end)-initstamp_time(1))*1000;

end