function [trl trialinfo]=dbs_eeg_percept_logfiles_prepare(eegfile, input_logfile)
% .events - this is a structure array describing events related to
% each trial.
%
% Subfields of .events
%
% .type - string (e.g. 'front panel trigger')
% .value - number or string, can be empty (e.g. 'Trig 1').
% .time - in seconds in terms of the original file
% .duration - in seconds
%




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
 
    events_exp=ft_read_event(eegfile); 
    events_exp=squeeze(struct2cell(events_exp));
    if strcmp(eegfile, '\\piazzolla\vlad_shared\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_00120.vhdr')
        events_exp=events_exp(:,142:end);
    end
    header_info=ft_read_header(eegfile);

    markers_match=0;

    if num_markers-2==size(events_exp,2)-1
        % looking at total number of events
        markers_match=1;
        eventstart=2+size(initstamp_time,1);
    elseif or(num_stimulus-2==size(find(strcmp(events_exp(1,:), 'Stimulus')),2),...
            size(find(strcmp(events_exp(2,:), 'T  2')),2)+size(find(strcmp(events_exp(2,:), 'S  1')),2))
            
        % looking at only stimulation markers 
        % (which are called Stimulus in file as opposed to LED which are called Toggle for some reason)
        markers_match=1;
        xx=find(strcmp(events_exp(1,:), 'Toggle'));
        eventstart=xx(1);
        missing_LEDs=LED_markers-size(find(strcmp(events_exp(1,:), 'Toggle')),2);
        disp(['your EEG file is missing ', num2str(missing_LEDs), ' LED markers'])
%         initstamp_time=cell2mat(events(3,find(strcmp(events(2,1:find(strcmp(events(1,:), 'Stimulus'),1)), 'T  2'))));
        eventstart=eventstart+size(cell2mat(events_exp(3,find(strcmp(events_exp(1,1:find(strcmp(events_exp(1,:), 'Stimulus'),1)), 'Toggle')))),2);
        

    else
        disp('markers in logfile and eegfile do not match. Attempting to find match based on LED sequence')
        for i=1:size(events_exp,2)-size(initstamp_time,1)+1
        events_temp=cell2mat(events_exp(3,i:end));
        events_temp=((events_temp-events_temp(1))/header_info.Fs)'; %% TODO change 1000 to cfg.samplerate
            % correspondence between logfile stamps and eeg markers are very
            % good corr should be really close to 1
            if 1-corr(events_temp(1:size(initstamp_time,1)), initstamp_time)< 0.000001
                 eventstart=i+size(initstamp_time,1);
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

        
        trl(1,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'Start Rest'))-3));
        trl(1,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'End Rest'))-3));
        trl(1,3)=0;
        trl(1,4)=1;

        trialinfo{1}='Rest trial';
        



    elseif ~isempty(strfind(input_logfile, 'PMT'))
        
        if ~isempty(strfind(input_logfile, 'LN_PR_D008_OFF_PMT_repetition2_PerceptPC.mat'))

            trl(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'left leg up'))-3))';
            trl(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'left leg down'))-3))';
            trl(:,3)=0;
            trl(:,4)=4;
    
            
            trialinfo=repelem({'left leg'},[size(trl,1)])';
        else
            trl1(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'right hand up'))-3))';
            trl1(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'right hand down'))-3))';
            trl1(:,3)=0;
            trl1(:,4)=1;
    
            trl2(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'left hand up'))-3))';
            trl2(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'left hand down'))-3))';
            trl2(:,3)=0;
            trl2(:,4)=2;
    
            trl3(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'right leg up'))-3))';
            trl3(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'right leg down'))-3))';
            trl3(:,3)=0;
            trl3(:,4)=3;
    
            trl4(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'left leg up'))-3))';
            trl4(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'left leg down'))-3))';
            trl4(:,3)=0;
            trl4(:,4)=4;
    
            trl=[trl1; trl2; trl3; trl4];
            
            trialinfo=repelem([{'right hand'}, {'left hand'}, {'right leg'}, {'left leg'}], ...
                [size(trl1,1) size(trl2,1) size(trl3,1) size(trl4,1)])';
        end
    

    elseif ~isempty(strfind(input_logfile, 'ACT'))

        trl1(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'right hand up'))-3))';
        trl1(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'right hand down'))-3))';
        trl1(:,3)=0;
        trl1(:,4)=1;

        trl2(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'left hand up'))-3))';
        trl2(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'left hand down'))-3))';
        trl2(:,3)=0;
        trl2(:,4)=2;

        trl3(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'right leg up'))-3))';
        trl3(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'right leg down'))-3))';
        trl3(:,3)=0;
        trl3(:,4)=3;

        trl4(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'left leg up'))-3))';
        trl4(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'left leg down'))-3))';
        trl4(:,3)=0;
        trl4(:,4)=4;

        trl=[trl1; trl2; trl3; trl4];

        trialinfo=repelem([{'right hand'}, {'left hand'}, {'right leg'}, {'left leg'}], ...
            [size(trl1,1) size(trl2,1) size(trl3,1) size(trl4,1)])';

    elseif ~isempty(strfind(input_logfile, 'DPT'))
        %% TODO add markers for this

    elseif ~isempty(strfind(input_logfile, 'SST'))

        trl1(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'sensory stimulation task right on'))-3))';
        trl1(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'sensory stimulation task right off'))-3))';
        trl1(:,3)=0;
        trl1(:,4)=1;

        trl2(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'sensory stimulation task left on'))-3))';
        trl2(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'sensory stimulation task left off'))-3))';
        trl2(:,3)=0;
        trl2(:,4)=2;

        trl=[trl1; trl2];

        trialinfo=repelem([{'SST right'}, {'SST left'}], ...
            [size(trl1,1) size(trl2,1)])';
        
    elseif ~isempty(strfind(input_logfile, 'SGT'))

        trl(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'geste on'))-3))';
        trl(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'geste off'))-3))';
        trl(:,3)=0;
        trl(:,4)=1;

        trialinfo=repelem([{'geste'}], [size(trl,1)])';

    elseif ~isempty(strfind(input_logfile, 'HPT'))

        trl(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'arms up'))-3))';
        trl(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'arms down'))-3))';
        trl(:,3)=0;
        trl(:,4)=1;

        trialinfo=repelem([{'arms up'}], [size(trl,1)])';

    elseif ~isempty(strfind(input_logfile, 'WRITE'))
        if ~isempty(strfind(input_logfile, 'LN_PR_D006'))
            trl1(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'write right'))-3))';
            x_temp=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'pause writing'))-3))';
            trl1(:,2)=x_temp(1:size(trl1(:,1),1));
            trl1(:,3)=0;
            trl1(:,4)=1;
    
            trl2(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'write left'))-3))';
            trl2(:,2)=x_temp(size(trl1(:,1),1)+1:end);
            trl2(:,3)=0;
            trl2(:,4)=2;
    
            trl=[trl1; trl2];
    
            trialinfo=repelem([{'write right'}, {'write left'}], ...
                [size(trl1,1) size(trl2,1)])';
        else
            trl(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'write'))-3))';
            trl(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'pause writing'))-3))';
            trl(:,3)=0;
            trl(:,4)=1;
    
            trialinfo=repelem([{'write'}], [size(trl,1)])';
        end
        

    elseif ~isempty(strfind(input_logfile, 'POUR'))

        trl(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'pour'))-3))';
        trl(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'pause pouring'))-3))';
        trl(:,3)=0;
        trl(:,4)=1;

        trialinfo=repelem([{'pour'}], [size(trl,1)])';

    elseif ~isempty(strfind(input_logfile, 'SPEAK'))
        
        trl(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'speak'))-3))';
        trl(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'pause speaking'))-3))';
        trl(:,3)=0;
        trl(:,4)=1;

        trialinfo=repelem([{'speak'}], [size(trl,1)])';

    elseif ~isempty(strfind(input_logfile, 'WALK'))
        if ~isempty(strfind(input_logfile, 'LN_PR_D006'))
            trl1(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'standing'))-3))';
            trl1(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'stand still'))-3))';
            trl1(:,3)=0;
            trl1(:,4)=1;
    
            trl2(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'stand still'))-3))';
            ind_end=find(strcmp(OutputFile_temp(:,1), 'standing'));
            trl2(:,2)=[cell2mat(events_exp(3,eventstart+ind_end(2:end)-3)), trl2(end,1)+mean(cell2mat(events_exp(3,eventstart+ind_end(2:end)-3))'-trl2(1:end-1,1))]'; 
            trl2(:,3)=0;
            trl2(:,4)=2;
    
    
            trl=[trl1; trl2];
    
            trialinfo=repelem([{'stand'}, {'sit'}], [size(trl1,1) size(trl2,1)])';

        else
            trl1(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'walk forward'))-3))';
            trl1(:,2)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'stand still'))-3))';
            trl1(:,3)=0;
            trl1(:,4)=1;
    
            trl2(:,1)=cell2mat(events_exp(3,eventstart+find(strcmp(OutputFile_temp(:,1), 'stand still'))-3))';
            ind_end=find(strcmp(OutputFile_temp(:,1), 'walk forward'));
            trl2(:,2)=[cell2mat(events_exp(3,eventstart+ind_end(2:end)-3)), trl2(end,1)+mean(cell2mat(events_exp(3,eventstart+ind_end(2:end)-3))'-trl2(1:end-1,1))]'; 
            trl2(:,3)=0;
            trl2(:,4)=2;
    
    
            trl=[trl1; trl2];
    
            trialinfo=repelem([{'walk'}, {'stand'}], [size(trl1,1) size(trl2,1)])';

        end
        
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