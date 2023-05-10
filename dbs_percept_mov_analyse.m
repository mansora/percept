function dbs_percept_mov_analyse(initials, rec_id, condition)

    % analysis of ACT, PMT condition assuming these as
    % evoked tasks (they are only evoked and not induced). Analysis starts from the continuous data (I think)
    keep=0;
    
    try
    [files_, seq, root, details] = dbs_subjects(initials, rec_id);
    catch
        return;
    end

    cd(fullfile(root, condition));

    % files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    files = spm_select('FPList','.', ['^' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*', '_cont.mat']);

    
%     try
%         files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*', '_cont.mat']);
%     catch
%         files = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*', '_cont.mat']);
%     end
%     
%     if isempty(files)
%         files = spm_select('FPList','.', ['^' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*', '_cont.mat']);
%     end

%  if ~exist(fullfile(root, condition, ['rmtf_' details.initials '_rec_' num2str(rec_id) '_' condition '.mat']), 'file') 
   if 1
       
    fD = {};
    for f=1:size(files, 1)
        D = spm_eeg_load(files(f,:));


        %%
        movchan = D.selectchannels({['regexp_.*hand|.*foot|.*head|.*thumb|.*index'...
            '|.*index|.*middle|.*ring|.*pinkie']});
        %%
        figure;
        for i = 1:length(movchan)
            subplot(10, 4, i)
            plot(D.time, D(movchan(i), :, 1));
            title(char(D.chanlabels(movchan(i))));
        end
        %%
        ev = events(D, 1, 'samples');
        lbl = {
            'hand_L', 'left hand', 'middle_L_y';
            'hand_R', 'right hand', 'middle_R_y';
            'foot_L', 'left leg', 'foot_L_y';
            'foot_R', 'right leg', 'foot_R_y';
            };
        dirs = {'up', 'down'};
        
        trl = [];
        conditionlabels = {};
        
        S = [];
        S.D = D;
        S.timewin = [-997 2000];
%         S.timewin = [0 1000];
%         S.timewin = [0 1000];
        S.reviewtrials = 0;
        S.save = 0;
        for i = 1:size(lbl, 1)
            cmov = D(D.indchannel(lbl{i, 1}), :);
        
            figure;
            plot(cmov);
            hold on
            cev =  ev(strmatch(lbl{i, 2}, {ev(:).type}));
            plot([cev(strmatch('up', {cev(:).value})).sample], D(D.indchannel(lbl{i, 1}), [cev(strmatch('up', {cev(:).value})).sample]), 'r*');
            plot([cev(strmatch('down', {cev(:).value})).sample], D(D.indchannel(lbl{i, 1}), [cev(strmatch('down', {cev(:).value})).sample]), 'g*');
        
            for j = 1:numel(dirs)
                S.trialdef.conditionlabel = [lbl{i, 1} '_' dirs{j}];
                S.trialdef.eventtype      = lbl{i, 2};
                S.trialdef.eventvalue     = dirs{j};
        
                [ctrl, clbl] = spm_eeg_definetrial(S);

                

                if ~isempty(ctrl)
                    indrem=[];
                    indrem=[indrem find(ctrl(:,1)<0)];
                    indrem=[indrem find(ctrl(:,2)>size(cmov,2))];
                    if ~isempty(indrem)
                        ctrl(indrem,:)=[];
                        clbl(indrem)=[];
                    end
                    template = cmov(ctrl(1, 1):ctrl(1,2));
    
                    for m = 1:2
                        if m==1
                            ind = 0:mean(diff(ctrl(:, 1:2), [], 2));
                            ind = repmat(ind, size(ctrl, 1), 1)+repmat(ctrl(:, 1), 1, length(ind));
                            template = mean(cmov(ind));
                        end
                        maxshift = 150;
                        for k = 1:size(ctrl, 1)

                            cdat = cmov(ctrl(k, 1):ctrl(k,2));
                            [c, lags] = xcorr(template, cdat, 'coeff', D.fsample);
                            [mc mci] = max(c(find(abs(lags)<maxshift)));
                            mci = mci - find(lags(find(abs(lags)<maxshift)) == 0);
                            ctrl(k, 1:2) = ctrl(k, 1:2)-mci;
                            if ctrl(k,2)<size(cmov,2)
                                cdat = cmov(ctrl(k, 1):ctrl(k,2));
                                if m == 1
                                    template = ((k-1)*template+cdat)./k;
                                end
                            else
                               ctrl(k,:)=[];
                               clbl(k)=[];
                            end
                        end
                    end
                    trl = [trl;ctrl];
                    conditionlabels = [conditionlabels clbl];
%                     conditionlabels = [conditionlabels repmat({'move'}, size(clbl))];
                end
            end
        end
        %%
        S = [];
        S.D = D;
        S.trl = trl;
        S.conditionlabels = conditionlabels(:);
        D = spm_eeg_epochs(S);

        D=conditions(D, 1:D.ntrials, 'movement');
        save(D);


        S = [];
        S.D = D;
        S.badchanthresh = 0.3;
        S.methods(1).fun = 'events';
        S.methods(1).channels = {'EEG'};
        S.methods(1).settings.whatevents.artefacts = 1;
        S.methods(2).channels = {'EEG'};
        S.methods(2).fun = 'threshchan';
        S.methods(2).settings.threshold = 200;
        S.methods(2).settings.excwin = 200;
        Dorig = spm_eeg_artefact(S);

        if ~keep, delete(S.D);  end

        if numel(Dorig.badchannels)<30
            warning([num2str(numel(Dorig.badchannels)) ' bad channels, intrapolating...'])

            goodchannels=setdiff(1:Dorig.nchannels, Dorig.badchannels);
            badchannels=Dorig.badchannels;

            S=[];
            S.prefix='';
            S.dataset=Dorig.fname;
            S.channels=D.chanlabels(goodchannels);
            D=spm_eeg_convert(S);
            
        else 
            error('too many bad channels to intrapolate')

        end

        

        S = [];
        S.D = D;
        S.badchanthresh = 0.1;
        S.methods(1).fun = 'events';
        S.methods(1).channels = {'EEG'};
        S.methods(1).settings.whatevents.artefacts = 1;
        S.methods(2).channels = {'EEG'};
        S.methods(2).fun = 'threshchan';
        S.methods(2).settings.threshold = 200;
        S.methods(2).settings.excwin = 200;
        D = spm_eeg_artefact(S);

        if ~keep, delete(S.D);  end

        S = [];
        S.D = D;
        S.badchanthresh = 1;
        S.methods(1).channels = {'LFP'};
        S.methods(1).fun = 'zscore';
        S.methods(1).settings.threshold = 5;

        D = spm_eeg_artefact(S);

        if ~keep, delete(S.D);  end


        
        Dorig=badtrials(Dorig,1:Dorig.ntrials,0);
        save(Dorig)

        Dorig=badtrials(Dorig,D.badtrials,1);
        save(Dorig)
        S = [];
        S.D = Dorig;
        Dorig = spm_eeg_remove_bad_trials(S);
    
         if ~keep, delete(S.D);  end

        S = [];
        S.D = D;
        D = spm_eeg_remove_bad_trials(S);



%         evv=D.events(':');
%         condd=D.conditions;
%         trialonsetss=D.trialonset;
        D=dbs_eeg_percept_interpolate_channels(D, badchannels);
%         Dnew = events(Dnew, 1, {evv});
%         Dnew=conditions(Dnew, 1:D.ntrials, 'movement');
%         Dnew=trialonset(Dnew, 1:D.ntrials, trialonsetss);
%         Dnew=type(Dnew,'single');
%         Dnew=badchannels(Dnew,[]);
%         save(Dnew);

         Dnew = clone(Dorig, ['c' fname(Dorig)], [Dorig.nchannels Dorig.nsamples Dorig.ntrials]);
         Dnew(:)=D(:);
         save(Dnew);

        
        fD{f} = Dnew;

        if ~keep, delete(S.D);  end
        if ~keep, delete(Dorig);  end
        if ~keep, delete(D);  end

        %%
%         for i = 1:size(lbl, 1)
%             for j = 1:numel(dirs)
%                 figure;
%                 plot(D.time, squeeze(D(D.indchannel(lbl{i, 1}), :, D.indtrial([lbl{i, 1} '_' dirs{j}]))));
%             end
%         end
        %%

    end
    if numel(fD)>1
        S = [];
        S.D = fname(fD{1});
        for f = 2:numel(fD)
            S.D = strvcat(S.D, fname(fD{f}));
        end
        S.recode = 'same';
        S.prefix='';
        De= spm_eeg_merge(S);

        if ~keep, delete(S.D);  end
    else
        De = fD{1};
    end

    

    freq = 1:2.5:100;
    res  = 4*ones(size(freq));
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
    S.robust.ks = 20;
    S.robust.bycondition = 0;
    D = spm_eeg_average(S);

    if ~keep, delete(S.D);  end

    
    S = [];
    S.D = D;
    S.method = 'LogR';
    S.timewin = [-Inf 0];
    S.prefix = 'r';
    D = spm_eeg_tf_rescale(S);

    if ~keep, delete(S.D);  end

    save(D);
    S = [];
    S.D = D;
    
    D = move(S.D, ['rmtf_' details.initials '_rec_' num2str(rec_id) '_' condition]);

    delete(S.D)

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
        S.robust = 'no';
        S.chancomb = [D.chanlabels(D.indchantype('EEG', 'GOOD'))' repmat(D.chanlabels(lfpind(i)), length(D.indchantype('EEG', 'GOOD')), 1)];
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
        
        Dc = move(Dc, ['COH_sensors_' char(D.chanlabels(lfpind(i)))]);   
        
        S = [];
        S.D = Dc;
        S.method = 'Rel';
        S.timewin = [-Inf 0];
        Dc = spm_eeg_tf_rescale(S);

        if ~keep, delete(S.D);  end
    end

    S = [];
    S.D = De;

%     De = move(S.D, ['maintrials_' erase(S.D.fname, '_cont')]);
    De = move(S.D, [erase(S.D.fname, {'cra','_cont'})]);



end



    

end