function dbs_percept_stand_analyse(initials, rec_id, cond)


    keep=0;
    % analysis of WALK, POUR, REACH, and HPT condition assuming these as
    % evoked tasks. Analysis starts from the continuous data (I think)
    try
    [   files_, seq, root, details] = dbs_subjects(initials, rec_id);
    catch
        return;
    end

    cd(fullfile(root, cond));

    % files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*', '_cont.mat']);
    files = spm_select('FPList','.', ['^' initials '_rec_' num2str(rec_id) '_' cond '_[0-9]*', '_cont.mat']);

    
%     try
%         files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' cond '_[0-9]*', '_cont.mat']);
%     catch
%         files = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(rec_id) '_' cond '_[0-9]*', '_cont.mat']);
%     end
%     
%     if isempty(files)
%         files = spm_select('FPList','.', ['^' initials '_rec_' num2str(rec_id) '_' cond '_[0-9]*', '_cont.mat']);
%     end

%     if ~exist(fullfile(root, cond, ['rmtf_' details.initials '_rec_' num2str(rec_id) '_' cond '.mat']), 'file') 
%      
        if 1
            
        fD = {};
        for f=1:size(files,1)

            D = spm_eeg_load(files(f,:));
    %%
    % cond = 'POUR';%'HPT';%'REACH'; %'WALK';%'STAND'
    %%
            S = [];
            S.D = D;
            switch cond
                case 'WALK'
                    if sctrmp(initials, 'LN_PR_D006')
                        S.timewin = [-1000 2000];
                        S.trialdef(1).conditionlabel = 'sit';
                        S.trialdef(1).eventtype = 'sit';
                        S.trialdef(1).eventvalue = 1;        
                        S.trialdef(2).conditionlabel = 'stand';
                        S.trialdef(2).eventtype = 'stand';
                        S.trialdef(2).eventvalue = 1;        
                    else
    %                     S.timewin = [-1000 2000];
    %                     S.trialdef(1).conditionlabel = 'walk';
    %                     S.trialdef(1).eventtype = 'walk';
    %                     S.trialdef(1).eventvalue = 1;        
    %                     S.trialdef(2).conditionlabel = 'stand';
    %                     S.trialdef(2).eventtype = 'stand';
    %                     S.trialdef(2).eventvalue = 1;
                    end
                case 'POUR'
                    S.timewin = [-2000 10000];
                    S.trialdef(1).conditionlabel = 'start';
                    S.trialdef(1).eventtype = 'pour';
                    S.trialdef(1).eventvalue = 'start';
                    S.trialdef(2).conditionlabel = 'stop';
                    S.trialdef(2).eventtype = 'pour';
                    S.trialdef(2).eventvalue = 'stop';
                case 'HPT'
                    S.timewin = [-1000 2000];
                    S.trialdef(1).conditionlabel = 'up';
                    S.trialdef(1).eventtype = 'up';
                    S.trialdef(1).eventvalue = 1;        
                    S.trialdef(2).conditionlabel = 'down';
                    S.trialdef(2).eventtype = 'down';
                    S.trialdef(2).eventvalue = 1; 
                case 'REACH'
                    S.timewin = [-2000 2000];
                    S.trialdef(1).conditionlabel = 'right';
                    S.trialdef(1).eventtype = 'reachpeak';
                    S.trialdef(1).eventvalue = 'right';
                    S.trialdef(2).conditionlabel = 'left';
                    S.trialdef(2).eventtype = 'reachpeak';
                    S.trialdef(2).eventvalue = 'left';
                case 'SPEAK'
                    S.timewin = [-2000 2000];
            end
            
            S.bc = 1;
            S.prefix = 'e';
            S.eventpadding = 0;
            fD{f} = spm_eeg_epochs(S);
            
            %%
            %%
        end
        fD(cellfun('isempty', fD)) = [];

        if numel(fD)>1
            S = [];
            S.D = fname(fD{1});
            for f = 2:numel(fD)
                S.D = strvcat(S.D, fname(fD{f}));
            end
            S.recode = 'same';
            De = spm_eeg_merge(S);

            if ~keep
                delete(S.D);  
                for f=1:numel(fD)
                    delete(fD{f});
                end
            end
        else
            De = fD{1};
        end

        freq = 1:2.5:100;
        res  = 2.5*ones(size(freq));
        res(freq>25) = 0.1*freq(freq>25);
        res(freq>50) = 5;
        
        S = [];
        S.D = De;
        S.channels = {'EEG', 'LFP'};
        S.frequencies = freq;
        S.timewin = [-Inf Inf];
        S.phase = 0;
        S.method = 'mtmconvol';
        S.settings.taper = 'dpss';
        S.settings.timeres = 400;%;200;
        S.settings.timestep = 50;%25;
        S.settings.freqres = res;%5;%
        D = spm_eeg_tf(S);
        
        S = [];
        S.D = D;
        S.robust.bycondition = 0;
        S.robust.ks = 20;
        D = spm_eeg_average(S);

        if ~keep, delete(S.D);  end

        S = [];
        S.D = D;
        S.method = 'LogR';
        if ismember(cond, {'REACH'})
            S.timewin = [-Inf Inf];
        else
            S.timewin = [-Inf 0];
        end
        S.prefix = 'r';
        D = spm_eeg_tf_rescale(S);

        if ~keep, delete(S.D);  end

        S = [];
        S.D = D;
        D = move(S.D, ['rmtf_' details.initials '_rec_' num2str(rec_id) '_' cond]);
        if ~keep, delete(S.D);  end



        D=De;
        lfpind = D.indchantype('LFP');
        for i = 1:length(lfpind)
            S = [];
            S.D = D;
            S.pretrig = D.time(1, 'ms');
            S.posttrig = D.time(D.nsamples, 'ms');
            S.timewin = 400;
            S.timestep = 50;
            S.freqwin = [0 90];
            S.robust.bycondition = 0;
            S.robust.ks = 20;
            S.chancomb = [D.chanlabels(D.indchantype('EEG', 'GOOD'))' repmat(De.chanlabels(lfpind(i)), length(D.indchantype('EEG', 'GOOD')), 1)];
            Dc = spm_eeg_ft_multitaper_coherence(S);
            
            Dc = chanlabels(Dc, ':', S.chancomb(:, 1));
            Dc = chantype(Dc, ':', 'EEG');
            Dc = type(Dc, 'evoked');
            save(Dc);

            
            S = [];
            S.D = Dc;
            S.task = 'project3D';
            S.modality = 'EEG';
            S.updatehistory = 0;
            S.save = 1;
            
            Dc = spm_eeg_prep(S);
            Dc = move(Dc, ['COH_sensors_' char(De.chanlabels(lfpind(i)))]);   

            if ~keep, delete(S.D);  end
            
            S = [];
            S.D = Dc;
            S.method = 'Rel';
            S.timewin = [-Inf 0];
            D = spm_eeg_tf_rescale(S);

            if ~keep, delete(S.D);  end
            %     
            %     S    = [];
            %     S.D  = Dc;
            %     S.mode = 'scalp x time';
            %     S.freqwin = [55 65];%*********
            %     
            %     spm_eeg_convert2images(S);
        end
        if ~keep, delete(De);  end

    
    end

end