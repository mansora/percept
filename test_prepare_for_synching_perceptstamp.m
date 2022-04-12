
[files, seq, root, details] =dbs_subjects_percept('LN_PR_D005',1);

bad_fs=[];
for f=setdiff(1:size(files,1),3)
    clear dbs_file eeg_file
    try
    [eeg_file dbs_file]=dbs_eeg_percept_prepare_for_syncing_perceptstamp(files{f,1}, files{f,1}, files{f,2}, details, f);

    if size(dbs_file.time{1},2)==size(eeg_file.time{1},2)
        figure, subplot(2,1,1), plot(eeg_file.time{1}, eeg_file.trial{1}(41,:))
        subplot(2,1,2), plot(dbs_file.time{1}-dbs_file.time{1}(1), dbs_file.trial{1}(1,:))
    end
    catch
       bad_fs=[bad_fs, f];
    end
end


[files, seq, root, details] =dbs_subjects_percept('LN_PR_D003',1);

bad_fs=[];
figure,
for f=1:size(files,1)
    clear dbs_file eeg_file
    cfg=[];
    cfg.dataset = files{f,1};
    dataEEG=ft_preprocessing(cfg);
%     subplot(9,1,f), plot(dataEEG.trial{1}(35,:))

end


cfg          = [];
cfg.method   = 'channel';
dummy        = ft_rejectvisual(cfg,dataEEG);

[files, seq, root, details] =dbs_subjects_percept('LN_PR_D005',2);

for f=1:size(files,1)
cfg=[];
cfg.dataset =files{f,1};
eeg_file=ft_preprocessing(cfg);
temp=load(files{f,2});
dbs_file=temp.data;
figure, 
subplot(2,1,1), plot(eeg_file.time{1}, eeg_file.trial{1}(41,:))
subplot(2,1,2), plot(dbs_file.time{1}-dbs_file.time{1}(1), dbs_file.trial{1}(1,:))
end
