function trl=dbs_eeg_percept_logfiles_prepare(eegfile, input_logfile)
    % read LED events from logfile
    temp=load(input_logfile);
    OutputFile=temp.OutputFile;
    num_markers=size(OutputFile,1);
    num_stimulus=size(OutputFile,1);
    LED_markers=0;

    x=find(strcmp(OutputFile(:,1), 'InitPulses'));
    if ~isempty(x)
        initstamp_time=cell2mat(OutputFile(x,3));
        initstamp_value=cell2mat(OutputFile(x,2));
        initstamp_time=initstamp_time(find(initstamp_value~=0));
        initstamp_time=initstamp_time-initstamp_time(1);
        num_markers=num_markers-(size(initstamp_value,1)-size(initstamp_time,1));
        num_stimulus=num_stimulus-size(initstamp_value,1);
        LED_markers=LED_markers+size(initstamp_time,1);
    end
    
    x=find(strcmp(OutputFile(:,1), 'EndPulses'));
    if ~isempty(x)
        endstamp_time=cell2mat(OutputFile(x,3));
        endstamp_value=cell2mat(OutputFile(x,2));
        endstamp_time=endstamp_time(find(endstamp_value~=0));
        endstamp_time=endstamp_time-endstamp_time(1);
        num_markers=num_markers-(size(endstamp_value,1)-size(endstamp_time,1));
        num_stimulus=num_stimulus-size(endstamp_value,1);
        LED_markers=LED_markers+size(endstamp_time,1);
    end


    % read LED event from eegfile
 
    events=ft_read_event(eegfile); 
    events=squeeze(struct2cell(events));
    header_info=ft_read_header(eegfile);

    markers_match=0;

    if num_markers-2==size(events,2)-1
        % looking at total number of events
        markers_match=1;
        eventstart=2;
    elseif num_stimulus-2==size(find(strcmp(events(1,:), 'Stimulus')),2)
        % looking at only stimulation markers 
        % (which are called Stimulus in file as opposed to LED which are called Toggle for some reason)
        markers_match=1;
        xx=find(strcmp(events(1,:), 'Toggle'));
        eventstart=xx(1);
        missing_LEDs=LED_markers-size(find(strcmp(events(1,:), 'Toggle')),2);
        disp(['your EEG file is missing ', num2str(missing_LEDs), ' LED markers'])
    else
        disp('markers in logfile and eegfile do not match. Attempting to find match based on LED sequence')
        for i=1:size(events,2)-size(initstamp_time,1)+1
        events_temp=cell2mat(events(3,i:end));
        events_temp=((events_temp-events_temp(1))/header_info.Fs)'; %% TODO change 1000 to cfg.samplerate
            % correspondence between logfile stamps and eeg markers are very
            % good corr should be really close to 1
            if 1-corr(events_temp(1:size(initstamp_time,1)), initstamp_time)< 0.000001
                 eventstart=i;
            end
        end
        if ~isempty(eventstart)
            markers_match=1;
        end

    end
    
    if markers_match
    %% TODO check if there is only one i (only one match between the EEG and LED sequence)
    OutputFile_temp=OutputFile;
    OutputFile_temp(find(strcmp(OutputFile(:,1), 'InitPulses')),:)=[];
    %% TODO add code for the pauses
    %% TODO for all these tasks you should also add the rest pieces (or at least make sure we can use them as baseline)
    if ~isempty(strfind(input_logfile, 'REST'))

        
        trl(1,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'Start Rest'))-3));
        trl(1,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'End Rest'))-3));
        trl(1,3)=0;
        trl(1,4)=1;

    elseif strfind(input_logfile, 'PMT')

        trl1(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'right hand up'))-3))';
        trl1(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'right hand down'))-3))';
        trl1(:,3)=0;
        trl1(:,4)=1;

        trl2(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'left hand up'))-3))';
        trl2(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'left hand down'))-3))';
        trl2(:,3)=0;
        trl2(:,4)=2;

        trl3(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'right leg up'))-3))';
        trl3(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'right leg down'))-3))';
        trl3(:,3)=0;
        trl3(:,4)=3;

        trl4(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'left leg up'))-3))';
        trl4(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'left leg down'))-3))';
        trl4(:,3)=0;
        trl4(:,4)=4;

        trl=[trl1; trl2; trl3; trl4];

    elseif strfind(input_logfile, 'ACT')

        trl1(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'right hand up'))-3))';
        trl1(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'right hand down'))-3))';
        trl1(:,3)=0;
        trl1(:,4)=1;

        trl2(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'left hand up'))-3))';
        trl2(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'left hand down'))-3))';
        trl2(:,3)=0;
        trl2(:,4)=2;

        trl3(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'right leg up'))-3))';
        trl3(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'right leg down'))-3))';
        trl3(:,3)=0;
        trl3(:,4)=3;

        trl4(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'left leg up'))-3))';
        trl4(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'left leg down'))-3))';
        trl4(:,3)=0;
        trl4(:,4)=4;

        trl=[trl1; trl2; trl3; trl4];

    elseif strfind(input_logfile, 'DPT')
        %% TODO add markers for this

    elseif strfind(input_logfile, 'SST')

        trl1(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'sensory stimulation task right on'))-3))';
        trl1(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'sensory stimulation task right off'))-3))';
        trl1(:,3)=0;
        trl1(:,4)=1;

        trl2(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'sensory stimulation task left on'))-3))';
        trl2(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'sensory stimulation task right off'))-3))';
        trl2(:,3)=0;
        trl2(:,4)=2;

        trl=[trl1; trl2];
    elseif strfind(input_logfile, 'SGT')

        trl(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'geste on'))-3))';
        trl(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'geste off'))-3))';
        trl(:,3)=0;
        trl(:,4)=1;

    elseif strfind(input_logfile, 'HPT')

        trl(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'arms up'))-3))';
        trl(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'arms down'))-3))';
        trl(:,3)=0;
        trl(:,4)=1;

    elseif strfind(input_logfile, 'WRITE')
        %% TODO add markers for this

    elseif strfind(input_logfile, 'POUR')

        trl(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'pour'))-3))';
        trl(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'pause pouring'))-3))';
        trl(:,3)=0;
        trl(:,4)=1;

    elseif strfind(input_logfile, 'SPEAK')
        
        trl(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'speak'))-3))';
        trl(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'pause speaking'))-3))';
        trl(:,3)=0;
        trl(:,4)=1;

    elseif strfind(input_logfile, 'WALK')

        trl1(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'walk forward'))-3))';
        trl1(:,2)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'stand still'))-3))';
        trl1(:,3)=0;
        trl1(:,4)=1;

        trl2(:,1)=cell2mat(events(3,eventstart+size(initstamp_time,1)+find(strcmp(OutputFile_temp(:,1), 'stand still'))-3))';
        ind_end=find(strcmp(OutputFile_temp(:,1), 'walk forward'));
        trl2(:,2)=[cell2mat(events(3,eventstart+size(initstamp_time,1)+ind_end(2:end)-3)), trl2(end,1)+10*1000]'; 
        % this is bad, I don't have a marker to indicate the end of the
        % last stand still trial so I just cut the last 10 seconds. Would
        % be good to add a marker in the logfile or else keep track of the
        % duration of that trial for different subjects
        trl2(:,3)=0;
        trl2(:,4)=2;


        trl=[trl1; trl2];
        
    else disp('no match found')
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
    
%     for i=1:size(events,2)-size(endstamp_time,1)+1
%         events_temp=cell2mat(events(3,i:end));
%         events_temp=((events_temp-events_temp(1))/1000)'; %% TODO change 1000 to cfg.samplerate
%         
%         % correspondence between logfile stamps and eeg markers are very
%         % good corr should be really close to 1
%         if 1-corr(events_temp(1:size(endstamp_time,1)), endstamp_time) < 0.0005
%             disp(i)
%         end
%         x(i)=corr(events_temp(1:size(endstamp_time,1)), endstamp_time);
%           
%     end


end