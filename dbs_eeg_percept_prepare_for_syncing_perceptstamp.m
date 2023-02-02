function [eeg_file dbs_file]=dbs_eeg_percept_prepare_for_syncing_perceptstamp(dataEEG, eegfile, input, details, f)

        
        temp=load(input);
        dbs_file=temp.data;

        cfg=[];
        cfg.resamplefs= dataEEG.fsample;
        dbs_file = ft_resampledata(cfg, dbs_file);

        if contains(eegfile, 'LN_PR_D003_20220204_0001')
            cfg=[];
            cfg.begsample= 49441;
            cfg.endsample= size(dataEEG.time{1},2);
            dataEEG=ft_redefinetrial(cfg, dataEEG);
        elseif contains (eegfile, 'LN_PR_D008_20221014_0010')
            cfg=[];
            cfg.begsample= 8561;
            cfg.endsample= 300808;
            dataEEG=ft_redefinetrial(cfg, dataEEG);

        else
        
        % I don't like this here. But there are very few files that need to
        % be cleared up like this. Still maybe we can store that somewhere
        % in dbs_subjects_percept under details.cut_eegdata or something?
        % We will also need it for this one file n LN_PR_D005 where we
        % recorded two datasets in one eeg block
        if contains(eegfile, 'LN_PR_D003_20220204_0008')
            cfg=[];
            cfg.begsample= 1;
            cfg.endsample= 306250;
            dataEEG=ft_redefinetrial(cfg, dataEEG);
        end

        if contains(eegfile, 'LN_PR_D005_20220401_0019')
            cfg=[];
            cfg.begsample= 13*dataEEG.fsample;
            cfg.endsample= size(dataEEG.time{1},2);
            dataEEG=ft_redefinetrial(cfg, dataEEG);
        end

        if contains(eegfile, 'LN_PR_D009_20221021_0019')
            cfg=[];
            cfg.begsample= 743;
            cfg.endsample= 168802;
            dataEEG=ft_redefinetrial(cfg, dataEEG);
       end

        


        if contains(eegfile, 'LN_PR_D005_20220401_00120')
            % take second half of file
            cfg=[];
            cfg.begsample= 367768;
            cfg.endsample= size(dataEEG.time{1},2);
            dataEEG=ft_redefinetrial(cfg, dataEEG);
        elseif contains(eegfile, 'LN_PR_D005_20220401_0012')
            % take first half of file
            cfg=[];
            cfg.begsample= 1;
            cfg.endsample= 367768;
            dataEEG=ft_redefinetrial(cfg, dataEEG);
        end

       cfg=[];
       cfg.channel=details.lfp_ref;
       n1=ft_preprocessing(cfg, dbs_file);   
       n1=n1.trial{1};
       

       cfg=[];
       cfg.channel=  details.eeg_ref{f};
       cfg.bpfreq  = details.freqrange;
       cfg.bpfilter = 'yes';
       n2=ft_preprocessing(cfg, dataEEG);  
       n2=n2.trial{1};
       n2=envelope(n2);
       n2=n2-mean(n2);

       

       if isfield(details, 'switch_stimoff') && details.switch_stimoff(f)==1
           n2=diff(n2);
           cfg=[];
           cfg.begsample= 100;
           cfg.endsample= size(dataEEG.time{1},2)-100;
           dataEEG=ft_redefinetrial(cfg, dataEEG);
           n2=n2(100:end-100);
           if strcmp(details.initials, 'LN_PR_D009') && f==1
               cfg.begsample= 5000;
               cfg.endsample= size(dbs_file.time{1},2)+5000-1;
               dataEEG=ft_redefinetrial(cfg, dataEEG);
               n2=n2(5000:numel(n1)+5000-1);
           end

       end

       if details.removespikes==1
           % there are some spikes at the very end with this kind of
           % file for some reason, cutting the last and first 100 ms gets rid of
           % it (has to do with filtering edge artefact, 
           % figure out a smarter way to do this at some point)
           cfg=[];
           cfg.begsample= 100;
           cfg.endsample= size(dataEEG.time{1},2)-100;
           dataEEG=ft_redefinetrial(cfg, dataEEG);
           n2=n2(100:end-100);
           
        end

            
           
       % for the purpose in this file, it's not so bad if TF picks up
       % activity above the standard deviation that is not the
       % stimulation, because it is just looking for a window big enough 
       % to include everything and cut the data (some initial cutting)
       % so there's no real need to make the code
       % complicated and add stimulation condition as an input
       TF1= abs(n1) > (mean(n1)+3*std(n1));
       TF2= abs(n2) > (mean(n2)+2.9*std(n2)); 

       if contains(eegfile, 'LN_PR_D005_20220401_0009')
           TF2= abs(n2) > (mean(n2)+1.5*std(n2)); 
       elseif contains(eegfile, 'LN_PR_D005_20220401_0017')
           TF2= abs(n2) > (mean(n2)+2*std(n2)); 
       end
       temp1_start=find(TF1(1:floor(size(TF1,2)/2)));
       temp2_start=find(TF2(1:floor(size(TF2,2)/2)));

%        % not sure if this will also work for non-rest blocks or blocks
%             % where stim is turned on not off
%             if isfield(details, 'switch_stimoff') && details.switch_stimoff(f)==1
%                 TF2= abs(n2) > (mean(n2)+2*std(n2));
%                 n2_temp=detrend(n2((1:max(temp2_start)-5)));
%                 TF2_temp=(abs(n2_temp)>mean(n2_temp)+2*std(n2_temp));
%                 temp2_temp=find(TF2_temp);
%                 temp2_start=[temp2_temp, temp2_start];
%                 temp2_start=unique(temp2_start);
%                 details.switch_stimoff(f)=1;
%             end
        
       temp1_end=find(TF1(floor(size(TF1,2)/2):end));
       temp_TF1=floor(size(TF1,2)/2);
       temp2_end=find(TF2(floor(size(TF2,2)/2):end));
       temp_TF2=floor(size(TF2,2)/2);

       if contains(eegfile, 'LN_PR_D001_0=20220107_0011')
            temp1_end=688418-temp_TF1;
        end

       incr_=1;
       while isempty(temp1_end) || isempty(temp2_end)
           temp1_end=find(TF1(floor(size(TF1,2)/2)-10*incr_*dbs_file.fsample:end));
           temp2_end=find(TF2(floor(size(TF2,2)/2)-10*incr_*dataEEG.fsample:end));
           temp_TF1=temp_TF1-10*incr_*dbs_file.fsample;
           temp_TF2=temp_TF2-10*incr_*dataEEG.fsample;
           incr_=incr_+1;
       end

        if contains(eegfile, 'LN_PR_D009_20221021_0020')
            temp1_start=1;
        end
        
       size_wind1=size(temp1_start(1):temp1_end(end)+temp_TF1,2);
       size_wind2=size(temp2_start(1):temp2_end(end)+temp_TF2,2);


       if size_wind1 > size_wind2
           cfg=[];
           cfg.begsample= temp1_start(1);
           cfg.endsample= temp1_end(end)+temp_TF1-1;
           dbs_file=ft_redefinetrial(cfg, dbs_file);
            
           
           cfg=[];
           cfg.begsample= temp2_start(1);
           cfg.endsample= temp2_end(end)+temp_TF2+(size_wind1-size_wind2)-1;

           if cfg.endsample>size(dataEEG.time{1},2)
               time_temp=linspace(dataEEG.time{1}(end)-dataEEG.time{1}(1), cfg.endsample/dataEEG.fsample,cfg.endsample-size(dataEEG.time{1},2)+1);
               dataEEG.time{1}=[dataEEG.time{1}, time_temp(2:end)+dataEEG.time{1}(1)];
               dataEEG.trial{1}=[dataEEG.trial{1}, zeros(size(dataEEG.trial{1},1), size(time_temp(2:end),2))];
               dataEEG.sampleinfo(2)=cfg.begsample;
           end

           dataEEG=ft_redefinetrial(cfg, dataEEG);

       elseif size_wind1 < size_wind2

           cfg=[];
           cfg.begsample= temp2_start(1);
           cfg.endsample= temp2_end(end)+temp_TF2-1;
           dataEEG=ft_redefinetrial(cfg, dataEEG);

           cfg=[];
           cfg.begsample= temp1_start(1);
           cfg.endsample= temp1_end(end)+temp_TF1+(size_wind2-size_wind1)-1;

           if cfg.endsample>size(dbs_file.time{1},2)
               time_temp=linspace(dbs_file.time{1}(end)-dbs_file.time{1}(1), cfg.endsample/dbs_file.fsample,cfg.endsample-size(dbs_file.time{1},2)+1);
               dbs_file.time{1}=[dbs_file.time{1}, time_temp(2:end)+dbs_file.time{1}(end)];
               dbs_file.trial{1}=[zeros(size(dbs_file.trial{1},1), size(time_temp(2:end),2)), dbs_file.trial{1}];
           end

           dbs_file=ft_redefinetrial(cfg, dbs_file);
      
       
       end
        end
        
        cfg=[];
        cfg.channel=details.eeg_ref{f};
        cfg.bpfreq  = details.freqrange;
        cfg.bpfilter = 'yes';
        StimArt_filtered=ft_preprocessing(cfg, dataEEG);
        StimArt_filtered.label{1}='StimArt_filtered';
        % TODO figure out if you're better off adding the envelope to
%             % all datasets from now on and not just the stim on condition
%             % from patient 3
        StimArt_filtered.trial{1}=envelope(StimArt_filtered.trial{1})-mean(envelope(StimArt_filtered.trial{1}));
    
        cfg = [];
        eeg_file =  ft_appenddata(cfg, dataEEG, StimArt_filtered);
end

