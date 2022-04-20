function D = dbs_eeg_percept_noise_merge(S)
% Fuse simultaneously recorded EEG and Percept datasets based on 
% the cardiac signal
% FORMAT  D = dbs_eeg_percept_noise_merge(S);
%
% S           - input structure (optional)
% (optional) fields of S:
%   S.D1       - EEG dataset
%   S.D2       - LFP dataset
%   S.ref1     - name of the reference channel in EEG dataset
%   S.ref2     - name of the reference channel in MEG dataset
%
% D        - MEEG object (also written to disk, with a 'u' prefix)
%__________________________________________________________________________
% Copyright (C) 2011 Wellcome Trust Centre for Neuroimaging
%
% Vladimir Litvak
% $Id: dbs_meg_brainamp_preproc.m 176 2019-04-09 15:46:36Z vladimir $

SVNrev = '$Rev: 176 $';

%-Startup
%--------------------------------------------------------------------------
spm('FnBanner', mfilename, SVNrev);
spm('FigName','Percept merge'); spm('Pointer','Watch');

D1 = spm_eeg_load(S.D1);
D2 = spm_eeg_load(S.D2);


if ~isfield(S, 'ref1')
    S.ref1 = 'StimSync';
end

if ~isfield(S, 'ref2')
    S.ref2 = 'UADC001';
end


if isempty(D1.indchannel(S.ref1))
   error('No reference channel found in the EEG dataset')
end

if isempty(D2.indchannel(S.ref2))
   error('No reference channel found in the LFP dataset')
end


if D2.fsample<D1.fsample
    S1 = [];
    S1.D = D1;
    S1.fsample_new = D2.fsample;
    D1 = spm_eeg_downsample(S1);
end

n1 = D1(D1.indchannel(S.ref1), :);
n1 = ft_preproc_highpassfilter(n1, D1.fsample, 0.5, 4, 'but','twopass', 'reduce');
n1 = ft_preproc_lowpassfilter(n1, D1.fsample, 45, 4, 'but','twopass', 'reduce');
n1 = zscore(n1);
n1(abs(n1)>3) = 0;


n2 = D2(D2.indchannel(S.ref2), :);
n2 = ft_preproc_highpassfilter(n2, D2.fsample, 0.5, 4, 'but', 'twopass', 'reduce');
n2 = ft_preproc_lowpassfilter(n2, D2.fsample, 45, 4, 'but', 'twopass', 'reduce');
n2 = zscore(n2);
n2(abs(n2)>3) = 0;

minl = min(length(n1), length(n2));

[c, lags] = xcorr(n1(1:minl), n2(1:minl), 'coeff');

[mc, mci] = max(abs(c));
if mc/median(abs(c)) < 25
    noisematch = 0;
else
    noisematch = 1;
end

offset = lags(mci);

lfptrl = 1:2*D2.fsample:D2.nsamples;

lfptrl = [lfptrl(1:(end-1))' lfptrl(2:(end))'-1];

eegtrl = lfptrl(:, 1:2)+offset;

if size(lfptrl, 2)>2
    eegtrl = [eegtrl lfptrl(:, 3:end)];
end

inbounds1 = (eegtrl(:,1)>=1 & eegtrl(:, 2)<=D1.nsamples);
inbounds2 = (lfptrl(:,1)>=1 & lfptrl(:, 2)<=D2.nsamples);

rejected = find(~(inbounds1 & inbounds2));
rejected = rejected(:)';

if ~isempty(rejected)
    eegtrl(rejected, :) = [];
    lfptrl(rejected, :) = [];
    warning(['Events ' num2str(rejected) ' not extracted - out of bounds']);
end

if noisematch
    V = nan(1, size(lfptrl, 1));
    for i = 1:size(lfptrl, 1)
        cn1 = n1(eegtrl(i, 1):eegtrl(i, 2));
        cn2 = n2(lfptrl(i, 1):lfptrl(i, 2));
        
        [c, lags] = xcorr(cn1, cn2, 'coeff');
        [mc mci] = max(abs(c(find(abs(lags)<20))));
        mci = mci - find(lags(find(abs(lags)<20)) == 0);
        
        if mc>0.2
            V(i) = mci;               
        end
    end  

    fV = medfilt1(V, 16, 'omitnan');
    fV = medfilt1(round(fV), 16);

    dfV = diff(fV);
    i = 1;
    while any(dfV(i:(i+10)))
        i = i+1;
    end
    fV(1:i) = fV(i+1);
    
    i = length(dfV);
    while any(dfV((i-9):i))
        i = i-1;
    end
    fV(i:end) = fV(i-1);
  
    Fgraph   = spm_figure('GetWin','Graphics'); figure(Fgraph); clf
    plot(mean(lfptrl(:, 1:2), 2), V, '.');
    hold on;
    plot(mean(lfptrl(:, 1:2), 2), fV, 'r-');
end

shifts = fV;

eegtrl(:, 1:2) = eegtrl(:, 1:2) + [shifts(:) shifts(:)];


%%
inbounds1 = (eegtrl(:,1)>=1 & eegtrl(:, 2)<=D1.nsamples);
inbounds2 = (lfptrl(:,1)>=1 & lfptrl(:, 2)<=D2.nsamples);

rejected = find(~(inbounds1 & inbounds2));
rejected = rejected(:)';

if ~isempty(rejected)
    eegtrl(rejected, :) = [];
    lfptrl(rejected, :) = [];
    shifts(rejected) = [];
    warning(['Events ' num2str(rejected) ' not extracted - out of bounds']);
end

%%
S1 = [];
S1.D  = D1;
S1.bc = 0;
S1.trl = eegtrl;
D1e = spm_eeg_epochs(S1);

%delete(D1);

S1.D = D2;
S1.trl = lfptrl;
D2e = spm_eeg_epochs(S1);

%delete(D2);
%%
S1 = [];
S1.D = char(fullfile(D1e), fullfile(D2e));
D = spm_eeg_fuse(S1);
D.shifts = shifts;
save(D);

delete(D1e);
delete(D2e);

S1 = [];
S1.mode = 'continuous';
S1.checkboundary = 0;
S1.dataset = fullfile(D);
Dn = spm_eeg_convert(S1);

delete(D);
D = Dn;

save(D);

