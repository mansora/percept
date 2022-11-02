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

zthresh = 6;

if D2.fsample<D1.fsample
    S1 = [];
    S1.D = D1;
    S1.fsample_new = D2.fsample;
    D1 = spm_eeg_downsample(S1);
    delete(S1.D);
end


% S1 = [];
% S1.D = D1;
% S1.timewin = 1e3*[20 382];
% D1 = spm_eeg_crop(S1);
% 
% delete(S1.D);

n1 = D1(D1.indchannel(S.ref1), :);
n1 = ft_preproc_highpassfilter(n1, D1.fsample, 2, 4, 'but','twopass', 'reduce');
n1 = ft_preproc_lowpassfilter(n1, D1.fsample, 45, 4, 'but','twopass', 'reduce');
n1 = zscore(n1);
n1(abs(n1)>zthresh) = 0;


n2 = D2(D2.indchannel(S.ref2), :);
n2 = ft_preproc_highpassfilter(n2, D2.fsample, 2, 4, 'but', 'twopass', 'reduce');
n2 = ft_preproc_lowpassfilter(n2, D2.fsample, 45, 4, 'but', 'twopass', 'reduce');
n2 = zscore(n2);
ind   = find(abs(n2)>3);
onset = round(max(ind(ind<0.2*D2.nsamples)) + 0.5*D2.fsample);
if isempty(onset)
    onset = 1;
end

offset= round(min(ind(ind>0.8*D2.nsamples)) - 0.5*D2.fsample);

if isempty(offset)
    offset = length(n2);
end

n2(abs(n2)>zthresh) = 0;

n2cut = n2(onset:offset);
minl = min(length(n1), length(n2cut));

[c, lags] = xcorr(n1(1:minl), n2cut(1:minl), 'coeff');

Fgraph   = spm_figure('GetWin','Graphics'); figure(Fgraph); clf
subplot(2,1,1);
plot(lags, c);

[mc, mci] = max(abs(c));
if mc/median(abs(c)) < 11
    error('No match between the two signals');
end

% This code is useful to check heart rate time courses in case there is
% doubt that the files come from the same block.
%{
lfpdata = n2;
eegdata = n1;

ecg_lfp  = perceive_ecg(lfpdata,D2.fsample,1);


EEG = [];
EEG.data =  eegdata;
EEG.srate = D1.fsample;
ecg_surf = fmrib_qrsdetect(EEG,1);
%%
s1 = find(ecg_lfp.ecgbins);

% Alternative method
[PKS,LOCS]= findpeaks(lfpdata, "MinPeakHeight",2, "MinPeakProminence", 0.2);
figure;
plot(lfpdata);
hold on
plot(LOCS, PKS, 'ro');
s1 = LOCS;
%%
s1(find(diff(s1)<100)+1) = [];
ds1 = diff(s1);
fds1 = medfilt1(ds1, 10);
rfds1 = round(ds1./fds1);
trfds1 = nan(max(rfds1), size(rfds1, 2));
trfds1(1, :) = fds1;
for i = 2:size(trfds1, 1)
   trfds1(i, rfds1==i) = fds1(rfds1==i); 
end
trfds1 = reshape(trfds1, 1, []);
trfds1(isnan(trfds1 )) = [];
trfds1 = detrend(trfds1(5:end));
%%
s2   = ecg_surf;

% Alternative method
[PKS,LOCS]= findpeaks(eegdata, "MinPeakHeight",2, "MinPeakProminence", 0.2);
figure;
plot(eegdata);
hold on
plot(LOCS, PKS, 'ro');
s2 = LOCS;

ds2  = diff(s2);
fds2 = medfilt1(ds2, 10);
rfds2 = round(ds2./fds2);
trfds2 = nan(max(rfds2), size(rfds2, 2));
trfds2(1, :) = fds2;
for i = 2:size(trfds2, 1)
   trfds2(i, rfds2==i) = fds2(rfds2==i); 
end
trfds2 = reshape(trfds2, 1, []);
trfds2(isnan(trfds2 )) = [];
trfds2 = detrend(trfds2(5:end));
%%
ml = min(length(trfds1), length(trfds2));

[c, l] = xcorr(trfds1(1:ml), trfds2(1:ml), 200, 'coeff');
figure;plot(l, c)
%%
[~, ind] = max(c);
shift = l(ind);
%%
figure;
if shift>=0
    plot(trfds1((1+shift):end));
    hold on
    plot(trfds2, 'r');
else
    plot(trfds1);
    hold on
    plot(trfds2((-shift):end), 'r');
end
%%
tshift1 = shift*median([fds1, fds2]);


tdata1 = zscore(lfpdata);
tdata1(abs(tdata1)>3) = 0;


tdata2 = zscore(eegdata);
tdata2(abs(tdata2)>3) = 0;
%%
if shift>=0
    tdata1 = tdata1((1+tshift1):end);
else
    tdata2 = tdata2(-tshift1:end);
end
%%
ml = min(length(tdata1), length(tdata2));

[c, l] = xcorr(tdata1(1:ml), tdata2(1:ml), [], 'coeff');
figure;plot(l, abs(c))
%%
[~, ind] = max(c);
shift = l(ind);
%}


shift = lags(mci);

lfptrl = 1:2*D2.fsample:D2.nsamples;

lfptrl = [lfptrl(1:(end-1))' lfptrl(2:(end))'-1];

eegtrl = lfptrl(:, 1:2)-onset+shift;

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


V = nan(1, size(lfptrl, 1));
for i = 1:size(lfptrl, 1)
    cn1 = n1(eegtrl(i, 1):eegtrl(i, 2));
    cn2 = n2(lfptrl(i, 1):lfptrl(i, 2));

    [c, lags] = xcorr(cn1, cn2, 'coeff');
    [mc mci] = max(abs(c(find(abs(lags)<4))));
    mci = mci - find(lags(find(abs(lags)<4)) == 0);


    V(i) = mci;
end

fV = round(medfilt1(V, 16, 'omitnan'));

% Fix edges
dfV = diff(fV);
i = 1;
while any(dfV(i:(i+10)))
    i = i+1;

    if (i+10)>length(dfV)
        break;
    end
end
fV(1:i) = fV(i+1);

i = length(dfV);
while any(dfV((i-9):i))
    i = i-1;

    if i<0
        break;
    end
end
fV(i:end) = fV(i-1);

% Check for the general trend and if negative, invert
R = corrcoef(fV, 1:numel(fV));
if R(1,2)<0
    fV = -fV;
end

% Remove 'premature' jumps up.
dfV = diff(fV);
steps = [find(dfV>0) numel(fV)];
for i = 1:(numel(steps)-1)
    if mean(fV(steps(i):steps(i+1))>fV(steps(i)-1))<0.5
        fV(steps(i):steps(i+1)) = fV(steps(i)-1);
    end
end

% Remove jumps down (assume monotonicity).
dfV = diff(fV);
steps = [find(dfV~=0) numel(fV)];
for i = 1:(numel(steps)-1)
    if dfV(steps(i))<0
        fV(steps(i):steps(i+1)) = fV(steps(i)-1);
    end
end

% invert back
if R(1,2)<0
    fV = -fV;
end

figure(Fgraph);
subplot(2,1,2);
plot(mean(lfptrl(:, 1:2), 2), V, '.');
hold on;
plot(mean(lfptrl(:, 1:2), 2), fV, 'r-');


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

delete(D1);

S1.D = D2;
S1.trl = lfptrl;
D2e = spm_eeg_epochs(S1);

delete(D2);
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

