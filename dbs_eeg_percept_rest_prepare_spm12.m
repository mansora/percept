function D = dbs_eeg_percept_rest_prepare_spm12(initials, rec_id)

if nargin <2
    rec_id = 1;
end

prefix = '';

keep = 0;

try
    [files, seq, root, details] = dbs_subjects_percept(initials, rec_id);
catch
    D = [];
    return
end
%%
spm_mkdir(root, 'dir')


cd(root);
res = mkdir('SPMrest');
cd('SPMrest');


fD = {};
aD = {};
%%
for f = 1:size(files,1)
    if ~isequal('R', seq{f}(1))
        continue;
    end
    
    % =============  Conversion =============================================
    S = [];
    S.dataset = files{f};
    S.outfile = ['spmeeg' num2str(f) '_' spm_file(S.dataset,'basename')];        
    
    [D S_trl]= dbs_eeg_percept_preproc(files(f,:), details, f); 
    
    
    D = chantype(D, D.indchannel(details.chan), 'LFP');
    
    if isfield(details, 'ecgchan') && ~isempty(details.ecgchan)
        D = chantype(D, D.indchannel(details.ecgchan), 'ECG');
    end
    
    save(D);
    
    S = [];
    S.D = D;
    S.type = 'butterworth';
    S.band = 'high';
    S.freq = 1;
    S.dir = 'twopass';
    S.order = 5;
    D = spm_eeg_filter(S);
    
    
    if ~keep, delete(S.D);  end
    
    
    S = [];
    S.D = D;
    S.mode = 'mark';
    S.badchanthresh = details.badchanthresh;
    
    S.methods(1).channels = {'EEG'};
    S.methods(1).fun = 'flat';    
    S.methods(1).settings.threshold = 0.01;
    S.methods(1).settings.seqlength = 10;
    S.methods(2).channels = {'EEG'};
    S.methods(2).fun = 'jump';
    S.methods(2).settings.threshold = 350;
    S.methods(2).settings.excwin = 200;   
    S.methods(3).channels = {'EEG'};
    S.methods(3).fun = 'threshchan';
    S.methods(3).settings.threshold = 350;
    S.methods(3).settings.excwin = 200;
    S.methods(4).fun = 'heartbeat';
    S.methods(4).channels = {'ECG'};
    S.methods(4).settings.excwin = 1;
    
    D = spm_eeg_artefact(S);
    
    %***** Breakpoint 1
    figure;imagesc(badsamples(D, D.indchantype('EEG'), ':', 1))
    % figure;plot(diff(D(D.indchannel('AG083'), :, 1)))
    
    if ~keep
        delete(S.D);
    end
    
    % Remove the synchronisation sequence
    b = mean(D.badsamples(D.indchantype('EEG'), ':', 1));
    ind   = find(b>0.25);
    onset = round(max(ind(ind<0.5*D.nsamples)) + 0.5*D.fsample);
    offset= round(min(ind(ind>0.5*D.nsamples)) - 0.5*D.fsample);
    
    if ~isempty(onset)
        if isempty(offset)
            offset = Inf;
        end
        
        S = [];
        S.D = D;
        S.timewin = [D.time(onset, 'ms') D.time(offset, 'ms')];
        D = spm_eeg_crop(S);
        
        if ~keep, delete(S.D);  end
    end
    
       
    eegchan  = D.indchantype('EEG');
    goodind  = D.indchantype('EEG', 'GOOD');
    
    goodind = find(ismember(eegchan, goodind));
    
    tra               =  eye(length(eegchan));
    tra(: ,goodind)   =  tra(:, goodind) - 1/length(goodind);  
    tra(end+[1:2], 1)     =  1;
    
    montage          = [];
    montage.labelorg = D.chanlabels(eegchan);
    montage.labelnew = [D.chanlabels(eegchan), {'ECG', 'event'}];
    montage.chantypenew = [repmat({'EEG'}, 1, length(D.indchantype('EEG'))), {'ECG', 'Other'}];         
    
    montage.tra      = tra;
    
    S = [];
    S.D = D;
    S.montage = montage;
    S.keepothers = 1;
    D = spm_eeg_montage(S);
    
    if ~keep, delete(S.D);  end
    
    
    event     = D.events(1, 'samples');
    eventdata = zeros(1, D.nsamples);
    
    if ~isempty(event) && isfield(details, 'eventtype')
        trigind  = find(strcmp(details.eventtype, {event.type}));
        eventdata([event(trigind).sample]) = 1;
    end
    
    D(D.indchannel('event'), :) = eventdata;
    
    D = chantype(D, D.indchannel('event'), 'Other');
    save(D);
    %%
    % Downsample =======================================================
    if D.fsample > 250
        
        S = [];
        S.D = D;
        S.fsample_new = 250;
        
        D = spm_eeg_downsample(S);
        
        if ~keep, delete(S.D);  end
    end      
    
    S = [];
    S.D = D;
    S.type = 'butterworth';
    S.band = 'stop';
    S.freq = [48 52];
    S.dir = 'twopass';
    S.order = 5;
    
    while S.freq(2)<min(600, (D.fsample/2))
        D = spm_eeg_filter(S);
        if ~keep, delete(S.D);  end
        
        S.D = D;
        S.freq = S.freq+50;
    end
           
    for i = 1:length(details.bandstop)
        S.D = D;
        S.freq = [-1 1]+details.bandstop(i);
        D = spm_eeg_filter(S);
        if ~keep, delete(S.D);  end
    end

    lfpchan = D.indchannel('LFP');
    ecg = zeros(length(lfpchan), D.nsamples);
    for i = 1:length(lfpchan)
         lfp       = D(lfpchan(i), :,1);
         ecg_out   = perceive_ecg(lfp, D.fsample,1);
         cleanlfp  = ecg_out.cleandata;
         ecg(i, :) = lfp-cleanlfp;
         D(lfpchan(i), :) = cleanlfp;
    end

    if size(ecg, 1)>1
            [u,s,u] = svd(ecg*ecg');
            s       = diag(s);
            u       = u(:,1);
            ecg       = ecg'*u/sqrt(s(1));
    end

    D(D.indchannel('ECG'), :) = ecg(:)';

    ecgind = [];
    if ~isempty(ecgind)  
        S   = [];
        S.D = D;
        S.timewin = [-100 200];
        S.trialdef.conditionlabel = 'heartbeat';
        S.trialdef.eventtype = 'artefact_heartbeat';
        S.trialdef.eventvalue = ecgchan;
        S.trialdef.trlshift = 0;
        S.reviewtrials = 0;
        S.save = 0;
        trl = spm_eeg_definetrial(S);
        
        ind = repmat(trl(:, 1), 1, mean(trl(:, 2)-trl(:, 1)));
        ind = ind+repmat(1:size(ind, 2), size(ind, 1), 1)-1;
        
        F = spm_figure('GetWin', 'LFP_correction');clf;
        for i = 1:length(details.chan)
            lfpdat = D(D.indchannel(details.chan(i)), :);
            lfpseg = lfpdat(ind);
            rejind = find(any(abs(lfpseg')>details.lfpthresh));
            lfpseg(rejind, :) = [];
            ind(rejind, :)    = [];
            
            subplot(numel(details.chan), 1, i);
            plot(mean(lfpseg));
            hold on;
            
            if max(abs(mean(lfpseg)))>6 %might need adaptive threshold
                [U, L, V] = spm_svd(lfpseg');
                U  = full(U(:, 1:2));
                clfpseg = ((eye(size(U, 1)) - U*pinv(U))*lfpseg')';
                
                clfpdat = lfpdat;
                clfpdat(ind) = clfpseg;
                D(D.indchannel(details.chan(i)), :) = clfpdat;
                plot(mean(clfpseg), 'r');
            end           
        end                    
        
        S = [];
        S.D = D;
        S.timewin = [-500 500];
        S.trialdef.conditionlabel = 'heartbeat';
        S.trialdef.eventtype = 'artefact_heartbeat';
        S.trialdef.eventvalue = ecgchan;
        S.trialdef.trlshift = 0;
        S.bc = 0;
        S.prefix = 'heartbeat_';
        S.eventpadding = 0;
        Da = spm_eeg_epochs(S);
    end
    
    % Epoching =========================================
    S = [];
    S.D = D;
    S.trialength = 1000;
    S.conditionlabels = seq{f}(isstrprop(seq{f}, 'alpha'));
    S.bc = 0;
    D = spm_eeg_epochs(S);
    
    if ~keep, delete(S.D);  end
    
    % Trial rejection =========================================
    S = [];
    S.D = D;
    S.badchanthresh = 1;
    S.methods(1).channels = {'LFP'};
    S.methods(1).fun = 'threshchan';
    S.methods(1).settings.threshold =  details.lfpthresh;
    
    S.methods(2).fun = 'events';
    S.methods(2).channels = {'EEG'};
    S.methods(2).settings.whatevents.artefacts = 1;
    
    D = spm_eeg_artefact(S);       
    
    if ~keep, delete(S.D);  end  
    
     if ~isempty(ecgind)  
         S.D = Da;
         Da = spm_eeg_artefact(S);   
         
         if ~keep, delete(S.D);  end  
     end
    
    %%
    S = [];
    S.D = D;
    fD{f} = spm_eeg_remove_bad_trials(S);
    
    if ~keep && ~isequal(fname(fD{f}), fname(S.D))
        delete(S.D);
    end
    
    if ~isempty(ecgind)
        S = [];
        S.D = Da;
        aD{f} = spm_eeg_remove_bad_trials(S);
        
        if ~keep && ~isequal(fname(aD{f}), fname(S.D))
            delete(S.D);
        end
    end        
    
    % ************ Breakpoint 2
    % ind = D.indchantype('LFP')
    % figure;plot(D.time, squeeze(D(ind(1), :, :)))
    
    %  details.badchanthresh = 0.02;
    %  S.badchanthresh = details.badchanthresh;
    %  D = spm_eeg_artefact(S);
end
%%
fD(cellfun('isempty', fD)) = [];

if ~isempty(ecgind)
    aD(cellfun('isempty', fD)) = [];
end
 
nf = numel(fD);

if numel(fD)>1
    S = [];
    S.D = fname(fD{1});
    for f = 2:numel(fD)
        S.D = strvcat(S.D, fname(fD{f}));
    end
    S.recode = 'same';
    D = spm_eeg_merge(S);
    
    if ~isempty(ecgind)
        S.D = fname(aD{1});
        for f = 2:numel(aD)
            S.D = strvcat(S.D, fname(aD{f}));
        end
        Da = spm_eeg_merge(S);
    end
    
    fileind =[];
    for f = 1:numel(fD)
        fileind = [fileind f*ones(1, ntrials(fD{f}))];
        D = events(D, find(fileind == f), events(fD{f}, ':'));
        D = trialonset(D, find(fileind == f), trialonset(fD{f}, ':'));
        
        if ~keep
            delete(fD{f});
        end
    end
    D.fileind = fileind;
    D.origheader = origheader;
elseif  numel(fD)==1
    D = fD{1};
    
    D.fileind = ones(1, ntrials(D));
    
    if ~isempty(ecgind)
        Da = aD{1};
    end
end
%{
S = [];
S.D = Da;
S.method = 'SVD';
S.timewin = [0
    100];
S.ncomp = 2;
Da = spm_eeg_spatial_confounds(S);

S = [];
S.D = D;
S.method = 'SPMEEG';
S.conffile = fullfile(Da);
D = spm_eeg_spatial_confounds(S);

S = [];
S.D = D;
S.correction = 'SSP';
D = spm_eeg_correct_sensor_data(S);

if ~keep, delete(S.D);  end

% Comment out to keep the heartbeat file for later examination
if ~keep, delete(Da);  end
%}
D.initials = initials;

D = dbs_eeg_headmodelling(D);
%%
D = D.move([prefix initials '_rec_' num2str(rec_id)]);

return

