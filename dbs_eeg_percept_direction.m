function dbs_eeg_percept_direction(initials, rec_id, condition)

% D = spm_eeg_load;
%%
keep = 0;

try
    [files_, seq, root, details] = dbs_subjects_percept(initials, rec_id);
catch
    return;
end

if nargin<3
    condition = 'R';
end


cd(fullfile(root, condition));

% files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
% try
%     files = spm_select('FPList','.', ['^' 'new_' '^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
% catch
%     files = spm_select('FPList','.', ['^' 'new_' 'regexp_.*c|.*' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
% end
% 
% if isempty(files)
%     files = spm_select('FPList','.', ['^' 'new_' ,'.', initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
% end

try
    files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
catch
    files = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
end

if isempty(files)
    files = spm_select('FPList','.', ['^' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
end

D = spm_eeg_load(files);

% D=conditions(D, 1:D.ntrials, 'movement');
% save(D);

for sub_condition=1:numel(D.condlist)
subcondition =D.condlist{sub_condition};% 'foot_L_up';
timewin = [-Inf Inf];% [0.3 2.3];

cd(D.path);

lfpchan = D.chanlabels(D.indchantype('LFP'));


%channelcmb = {'Cz', 'LFP_Gpi_R_13'};

    

channelcmb = {};
for i = D.selectchannels('EEG')%('regexp_^ROI')
    for j = 1:numel(lfpchan)       
        channelcmb = [channelcmb; D.chanlabels(i), lfpchan(j)];
    end
end

    
odata = D.fttimelock(sort(D.indchannel(unique(channelcmb))), D.indsample(timewin(1)):D.indsample(timewin(2)), D.indtrial(subcondition));
rdata = odata;
rdata.trial = rdata.trial(:, :, end:-1:1);
sdata = odata;

ind = spm_match_str(sdata.label, lfpchan);

sdata.trial(:, ind, :) = sdata.trial(randperm(size(sdata.trial, 1)), ind, :);%[2:end 1]
data = {odata, rdata, sdata};
%%
for i = 1:numel(data)
    
    fstep = 1/(D.nsamples/D.fsample);
    fstep = round(1/fstep)*fstep;
    
%     fstep = 1;
    
    foi     = 0:fstep:D.fsample/2;
    foi     = foi(1:(end-1));
    fres    = 0*foi+4;
    fres(fres>25) = 0.1*fres(fres>25);
    fres(fres>50) = 5;
    
    cfg = [];
    cfg.output ='fourier';
    cfg.channelcmb=channelcmb;
    
    if D.ntrials>80
        cfg.trials = randperm(D.ntrials,80);
    end
    cfg.keeptrials = 'yes';
    cfg.keeptapers='yes';
    cfg.taper = 'dpss';
    cfg.method          = 'mtmfft';
    cfg.foi     = foi;
    cfg.tapsmofrq = fres;
    %cfg.pad = 20;
    
    inp{i} = ft_freqanalysis(cfg, data{i});
    %
    cfg = [];
    cfg.channelcmb=channelcmb;
    cfg.method  = 'coh';
    cfg.jackknife = 'yes';
    
    res{1, i} = ft_connectivityanalysis(cfg, inp{i});
    
    %
    cfg.complex = 'imag';
    res{2, i} = ft_connectivityanalysis(cfg, inp{i});
    
    %
    cfg.complex = 'real';
    res{3, i} = ft_connectivityanalysis(cfg, inp{i});
    
    cfg = rmfield(cfg, 'complex');
    %
    cfg.method = 'granger';
    cfg.granger.init = 'rand';
    cfg.granger.stabilityfix = true;
    cfg.granger.sfmethod ='bivariate';  
    
    res{4, i} = ft_connectivityanalysis(cfg, inp{i});
    
    cfg.method = 'instantaneous_causality';
    res{5, i} = ft_connectivityanalysis(cfg, inp{i});
end
%%
Nchannels = 2*size(channelcmb, 1);
Nfrequencies = length(res{1, 1}.freq);
Ntrials = numel(res);

Dc = clone(D, ['C_', condition, '_', subcondition, D.fname], [Nchannels Nfrequencies 1 Ntrials]);
Dc = Dc.frequencies(':', res{1, 1}.freq);
Dc = timeonset(Dc, 0);
Dc = fsample(Dc, 1);
Dc = transformtype(Dc, 'TF');

reslabels = {'coh', 'coh', 'coh', 'granger', 'instant'};
outlabels = {'coh', 'imagcoh', 'realcoh', 'granger', 'instant'};
datalabels = {'orig', 'reversed', 'shifted'};
cl = {};
chanl = {};

for i = 1:numel(reslabels)
    for j = 1:numel(datalabels)
        trialind = sub2ind([numel(reslabels), numel(datalabels)], i, j);
        cl{trialind, 1} = [outlabels{i} '_' datalabels{j}];
        for k = 1:size(channelcmb, 1)            
            ind1 = intersect(strmatch(channelcmb{k, 1}, res{i, j}.labelcmb(:, 1)), ...
                strmatch(channelcmb{k, 2}, res{i, j}.labelcmb(:, 2)));
            ind2 = intersect(strmatch(channelcmb{k, 2}, res{i, j}.labelcmb(:, 1)), ...
                strmatch(channelcmb{k, 1}, res{i, j}.labelcmb(:, 2)));
            if isequal(reslabels{i}, 'coh') 
                ind1 = [ind1 ind2];
                ind2 = ind1;
            end                        
            
            Dc(2*k-1, :, :, trialind) = res{i, j}.([reslabels{i} 'spctrm'])(ind1, :);
            Dc(2*k, :, :, trialind)   = res{i, j}.([reslabels{i} 'spctrm'])(ind2, :);
            
            chanl{2*k-1, 1} = [channelcmb{k, 1} '->' channelcmb{k, 2}];
            chanl{2*k,   1} = [channelcmb{k, 2} '->' channelcmb{k, 1}];
        end
        
    end
end
Dc = chanlabels(Dc, ':', chanl);
Dc = conditions(Dc, ':', cl);

save(Dc);

end

end
%%

% return
%%

% ROI = {'Cz'};
% lfp = 'LFP_Gpi_R_13';
% 
% 
% %cnd = {'granger_orig', 'granger_reversed',  'granger_shifted'};%  Dc.condlist;%{'coh_orig', 'coh_shifted'};
% %cnd = {'instant_orig', 'instant_reversed',  'instant_shifted'};
% cnd = {'coh_orig', 'coh_shifted'};
% %cnd = {'imagcoh_orig', 'imagcoh_shifted'}
% %cnd = {'realcoh_orig', 'realcoh_shifted'}
% 
% spm_figure('GetWin', [Dc.initials '_' cnd{1}]);clf;
% 
% trialind = Dc.indtrial(cnd);
% 
% clf;
% for i = 1:size(ROI, 1)
%     ind1 = strmatch([ROI{i, 1} '->' lfp], Dc.chanlabels);
%     ind2 = strmatch([lfp '->' ROI{i, 1}], Dc.chanlabels);
%     
%     subplot(size(ROI, 1), 2, 2*i-1);
%     plot(Dc.frequencies, squeeze(mean(Dc(ind1, :, :, trialind), 1)));
%     
%     xlim([5 120]);
%     
%     if i == 1
%         legend(Dc.conditions(trialind), 'Interpreter', 'none')
%     end
%     
%     title([ROI{i, 1} '->LFP']);
%     
%     subplot(size(ROI, 1), 2, 2*i);
%     plot(Dc.frequencies, squeeze(mean(Dc(ind2, :, :, trialind), 1)));  
%     
%     xlim([5 120]);
%     title(['LFP->' ROI{i, 1}]);    
% end
% %%
% 
