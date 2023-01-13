function [res, freqs] = dbs_percept_spm_spectra_fooof(initials, rec_id, condition,prefix)



keep = 0;


[files, seq, root, details] = dbs_subjects_percept(initials, 1);
cd(fullfile(root, condition));

files = spm_select('FPList','.', ['LFP_spect_', '.', initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
if isempty(files)
    files = spm_select('FPList','.', ['LFP_spect_', initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
end
D1_LFP = spm_eeg_load(files);

files = spm_select('FPList','.', ['EEG_spect_', '.', initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
if isempty(files)
    files = spm_select('FPList','.', ['EEG_spect_', initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
end
D1_EEG = spm_eeg_load(files);

[files, seq, root, details] = dbs_subjects_percept(initials, 2);
cd(fullfile(root, condition));

files = spm_select('FPList','.', ['LFP_spect_', '.', initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
if isempty(files)
    files = spm_select('FPList','.', ['LFP_spect_', initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
end
D2_LFP = spm_eeg_load(files);

files = spm_select('FPList','.', ['EEG_spect_', '.', initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
if isempty(files)
    files = spm_select('FPList','.', ['EEG_spect_', initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
end
D2_EEG = spm_eeg_load(files);


S=[];
S.D=D1_LFP;
S.freq_range=[1 50];
S.peak_width_limits=[4 15];
S.max_peaks=10;
S.min_peak_height=0;
S.aperiodic_mode='knee';
S.peak_threshold=1;
S.peak_type='best';
S.power_line=50;
S.guess_weight='none';
S.proximity_threshold=2;
Dnew=spm_eeg_bst_fooof(S);







