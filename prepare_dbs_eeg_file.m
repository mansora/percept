function [eeg_file dbs_file]=prepare_dbs_eeg_file(dataEEG, eegfile, freqrange, input)
% function [eeg_file dbs_file]=prepare_dbs_eeg_file(eegfile, freqrange, input, stim)
        
%         if varargin<4
%             disp('no information available on stimulation setting')
%             str = input('was stimulation on for this dataset? y/n ','s')
%             if strcmp(str,'y')
%                 stim=1;
%             elseif strcmp(str,'n')
%                 stim=0;
%             end
%         end
        
        temp=load(input);
        dbs_file=temp.data;

        cfg=[];
        cfg.resamplefs= 1000;
        dbs_file = ft_resampledata(cfg, dbs_file);


%         cfg = [];
%         cfg.dataset = eegfile;
%         dataEEG=ft_preprocessing(cfg);

        if contains(eegfile, 'LN_PR_D001_0=20220107_0019') 
            cfg=[];
            cfg.begsample= 1;
            cfg.endsample= size(dbs_file.time{1},2);
            dataEEG=ft_redefinetrial(cfg, dataEEG);
        elseif contains(eegfile, 'LN_PR_D001_0=20220107_0018') || contains(eegfile, 'LN_PR_D001_0=20220107_0017')
            cfg=[];
            cfg.begsample= 1;
            cfg.endsample= size(dataEEG.time{1},2);
            dbs_file=ft_redefinetrial(cfg, dbs_file);
        elseif contains(eegfile, 'LN_PR_D001_0=20220107_0016') || ...
                contains(eegfile, 'LN_PR_D003_20220204_0007') || ...
                contains(eegfile, 'LN_PR_D003_20220204_0008') 
            cfg=[];
            cfg.begsample= 7500;
            cfg.endsample= size(dataEEG.time{1},2);
            dataEEG=ft_redefinetrial(cfg, dataEEG);

            cfg=[];
            cfg.begsample= 1;
            cfg.endsample= size(dbs_file.time{1},2);
            dataEEG=ft_redefinetrial(cfg, dataEEG);

        % whenever this method works (files identified manually), I have made no attempt to use the same method I
        % have added below. that's becaus in some case it won't work
        % be easily added and do do exactly the same thing though TODO at
        % some point you should add it and also check that it works
        elseif contains(eegfile, 'LN_PR_D001') || ...
                contains(eegfile, 'LN_PR_D003_20220204_0001') ||...
                contains(eegfile, 'LN_PR_D003_20220204_0002') ||...
                contains(eegfile, 'LN_PR_D003_20220204_0010') ||...
                contains(eegfile, 'LN_PR_D003_20220204_0017') ||...
                contains(eegfile, 'LN_PR_D003_20220204_0018') 
                
                

            if size(dataEEG.time{1},2) < size(dbs_file.time{1},2)
                cfg=[];
                cfg.begsample= size(dbs_file.time{1},2)-size(dataEEG.time{1},2)+1;
                cfg.endsample=size(dbs_file.time{1},2);
                dbs_file=ft_redefinetrial(cfg, dbs_file);

            elseif size(dataEEG.time{1},2) > size(dbs_file.time{1},2)
                cfg=[];
                cfg.begsample= size(dataEEG.time{1},2)-size(dbs_file.time{1},2)+1;
                cfg.endsample=size(dataEEG.time{1},2);
                dataEEG=ft_redefinetrial(cfg, dataEEG);

            end

        else
           
           % TODO you can probably do everything with the code below, no
           % need for so many exceptions. I just haven't touched it because
           % it worked previously and I don't want to risk it. At some
           % point I should check all the files with this method below 
           % (as well as the envelop added for all of them) and if it works
           % remove all those extra stuff upstairs

           n1=dbs_file.trial{1}(1,:);

           
           if contains(eegfile, 'LN_PR_D003_20220204_0004') ||...
                   contains(eegfile, 'LN_PR_D003_20220204_0005') ||...
                   contains(eegfile, 'LN_PR_D003_20220204_0006') ||...
                   contains(eegfile, 'LN_PR_D003_20220204_0007') ||...
                   contains(eegfile, 'LN_PR_D003_20220204_0008') 
                  
               cfg=[];
               cfg.channel='P3';
               cfg.bpfreq  = freqrange;
               cfg.bpfilter = 'yes';
               n2=ft_preprocessing(cfg, dataEEG);   
               n2=n2.trial{1};

           elseif contains(eegfile, 'LN_PR_D003_20220204_0011') ||...
                   contains(eegfile, 'LN_PR_D003_20220204_0012') ||...
                   contains(eegfile, 'LN_PR_D003_20220204_0013') ||...
                   contains(eegfile, 'LN_PR_D003_20220204_0014') ||...
                   contains(eegfile, 'LN_PR_D003_20220204_0016')  
               
               cfg=[];
               cfg.channel='P3';
               cfg.bpfreq  = freqrange;
               cfg.bpfilter = 'yes';
               n2=ft_preprocessing(cfg, dataEEG);   
               n2=n2.trial{1};
               n2=envelope(n2);
               n2=n2-mean(n2);
                
               % there are some spikes at the very end with this kind of
               % file for some reason, cutting the last 200 ms gets rid of
               % it
               cfg=[];
               cfg.begsample= 100;
               cfg.endsample= size(dataEEG.time{1},2)-100;
               dataEEG=ft_redefinetrial(cfg, dataEEG);
               n2=n2(100:end-100);
           else
               cfg=[];
               cfg.channel='StimArt';
               cfg.bpfreq  = freqrange;
               cfg.bpfilter = 'yes';
               n2=ft_preprocessing(cfg, dataEEG);   
               n2=n2.trial{1};
           end

%            if stim==0
%                TF1=(abs(n1)>mean(n1)+4*std(n1));
%                TF2=(abs(n2)>mean(n2)+4*std(n2)); 
%            elseif stimm==1
%                TF1=(abs(n1)>mean(n1)+3*std(n1));
%                TF2=(abs(n2)>mean(n2)+2*std(n2)); 
%            end
            
            
           
           % for the purpose in this file, it's not so bad if TF picks up
           % activity above the standard deviation that is not the
           % stimulation, because it is just looking for a window big enough 
           % to include everything and cut the data (some initial cutting)
           % so there's no real need to make the code
           % complicated and add stimulation condition as an input
           TF1= abs(n1) > (mean(n1)+3*std(n1));
           TF2= abs(n2) > (mean(n2)+3*std(n2)); 
           
           temp1_start=find(TF1(1:floor(size(TF1,2)/2)));
           temp2_start=find(TF2(1:floor(size(TF2,2)/2)));
            
           temp1_end=find(TF1(floor(size(TF1,2)/2):end));
           temp2_end=find(TF2(floor(size(TF2,2)/2):end));
            
           size_wind1=size(temp1_start(1):temp1_end(end)+floor(size(TF1,2)/2),2);
           size_wind2=size(temp2_start(1):temp2_end(end)+floor(size(TF2,2)/2),2);

           if size_wind1 > size_wind2
               cfg=[];
               cfg.begsample= temp1_start(1);
               cfg.endsample= temp1_end(end)+floor(size(TF1,2)/2);
               dbs_file=ft_redefinetrial(cfg, dbs_file);
                
               % TODO this might still give an error if the second data
               % file isn't long enough (which should rarely happen but still check)
               cfg=[];
               cfg.begsample= temp2_start(1);
               cfg.endsample= temp2_end(end)+floor(size(TF2,2)/2)+(size_wind1-size_wind2);
               dataEEG=ft_redefinetrial(cfg, dataEEG);

           elseif size_wind1 < size_wind2

               cfg=[];
               cfg.begsample= temp2_start(1);
               cfg.endsample= temp2_end(end)+floor(size(TF2,2)/2);
               dataEEG=ft_redefinetrial(cfg, dataEEG);

               cfg=[];
               cfg.begsample= temp1_start(1);
               cfg.endsample= temp1_end(end)+floor(size(TF1,2)/2)+(size_wind2-size_wind1);
               dbs_file=ft_redefinetrial(cfg, dbs_file);

            end
        
        end
        cfg=[];
       % these are the files were the EMG was lost, checking the data
       % showed you could see te stimulation artifact quite well in P3
       % in all datafiles 
        if contains(eegfile, 'LN_PR_D003_20220204_0004') ||...
            contains(eegfile, 'LN_PR_D003_20220204_0005') ||...
            contains(eegfile, 'LN_PR_D003_20220204_0006') ||...
            contains(eegfile, 'LN_PR_D003_20220204_0007') ||...
            contains(eegfile, 'LN_PR_D003_20220204_0008') 
            
            cfg.channel='P3';
            cfg.bpfreq  = freqrange;
            cfg.bpfilter = 'yes';
            StimArt_filtered=ft_preprocessing(cfg, dataEEG);
            StimArt_filtered.label{1}='StimArt_filtered';


        elseif contains(eegfile, 'LN_PR_D003_20220204_0011') ||...
            contains(eegfile, 'LN_PR_D003_20220204_0012') ||...
            contains(eegfile, 'LN_PR_D003_20220204_0013') ||...
            contains(eegfile, 'LN_PR_D003_20220204_0014') ||...
            contains(eegfile, 'LN_PR_D003_20220204_0016')

            cfg.channel='P3';
            cfg.bpfreq  = freqrange;
            cfg.bpfilter = 'yes';
            StimArt_filtered=ft_preprocessing(cfg, dataEEG);
            StimArt_filtered.label{1}='StimArt_filtered';
            % TODO figure out if you're better off adding the envelope to
            % all datasets from now on and not just the stim on condition
            % from patient 3
            StimArt_filtered.trial{1}=envelope(StimArt_filtered.trial{1})-mean(envelope(StimArt_filtered.trial{1}));
        else

            cfg.channel='StimArt';
            cfg.bpfreq  = freqrange;
            cfg.bpfilter = 'yes';
            StimArt_filtered=ft_preprocessing(cfg, dataEEG);
            StimArt_filtered.label{1}='StimArt_filtered';

        end
        

        
        cfg = [];
        eeg_file =  ft_appenddata(cfg, dataEEG, StimArt_filtered);
end

