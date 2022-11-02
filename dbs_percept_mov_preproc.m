function D = dbs_percept_mov_preproc(S)

D = spm_eeg_load(S.D);

Do = D;
%%
keep = 0;
%%
S = [];
S.D = D;
S.channels = D.chanlabels(D.selectchannels({['regexp_.*hand|.*foot|.*head|.*thumb|.*index'...
    '|.*index|.*middle|.*ring|.*pinkie']}));
D = spm_eeg_crop(S);
%%
D = chantype(D, ':', 'PHYS');
save(D);
%%
S = [];
S.D = D;
S.type = 'butterworth';
S.band = 'high';
S.freq = 0.01;
S.dir = 'twopass';
S.order = 5;
D = spm_eeg_filter(S);
%%
if ~keep, delete(S.D);  end

S = [];
S.D = D;
S.prefix = 'R';
S.channels = {'regexp_.*hand_R|.*thumb_R|.*index_R|.*index_R|.*middle_R|.*ring_R|.*pinkie_R'};
S.method = 'pca';
S.settings.ncomp = 1;
S.settings.threshold = 0;
S.keepothers = true;
S.keeporig = false;
S.conditions.all = 1;
S.timewin = [-Inf Inf];
D = spm_eeg_reduce(S);

if ~keep, delete(S.D);  end

D = chanlabels(D, D.indchannel('comp1'), 'hand_R');

S.channels = {'regexp_.*hand_L|.*thumb_L|.*index_L|.*index_L|.*middle_L|.*ring_L|.*pinkie_L'};
S.D = D;
D = spm_eeg_reduce(S);

if ~keep, delete(S.D);  end

D = chanlabels(D, D.indchannel('comp1'), 'hand_L');

S.channels = {'regexp_.*foot_R'};
S.D = D;
D = spm_eeg_reduce(S);

if ~keep, delete(S.D);  end

D = chanlabels(D, D.indchannel('comp1'), 'foot_R');

S.channels = {'regexp_.*foot_L'};
S.D = D;
D = spm_eeg_reduce(S);

if ~keep, delete(S.D);  end

D = chanlabels(D, D.indchannel('comp1'), 'foot_L');

S.channels = {'regexp_.*head'};
S.D = D;
D = spm_eeg_reduce(S);

if ~keep, delete(S.D);  end

D = chanlabels(D, D.indchannel('comp1'), 'head');

save(D);
%%
S = [];
S.D = D;
S.type = 'butterworth';
S.band = 'low';
S.freq = 1;
S.dir = 'twopass';
S.order = 5;
D = spm_eeg_filter(S);

if ~keep, delete(S.D);  end

%spm_eeg_review(D)
%%
S = [];
S.D = char(fullfile(Do), fullfile(D));
D   = spm_eeg_fuse(S);
%%
if ~keep
    delete(spm_eeg_load(S.D(1, :)));
    delete(spm_eeg_load(S.D(2, :)));
end
