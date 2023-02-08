function dbs_percept_EEG_spectra_plot(initials, condition, freqband)
    
    [files_, seq, root, details] = dbs_subjects_percept(initials, 1);
    cd(fullfile(root, condition));
    
    
    files = spm_select('FPList','.', ['EEG_spect_', '.', initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    if isempty(files)
        files = spm_select('FPList','.', ['EEG_spect_', initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    D1_EEG = spm_eeg_load(files);

    

    [files_, seq, root, details] = dbs_subjects_percept(initials, 2);
    cd(fullfile(root, condition));
    
   
    files = spm_select('FPList','.', ['EEG_spect_', '.', initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
    if isempty(files)
        files = spm_select('FPList','.', ['EEG_spect_', initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
    end
    D2_EEG = spm_eeg_load(files);


    ind1 = find(min(abs(D1_EEG.frequencies-freqband(1)))==abs(D1_EEG.frequencies-freqband(1)));
    ind2 = find(min(abs(D1_EEG.frequencies-freqband(2)))==abs(D1_EEG.frequencies-freqband(2)));

    Data1_EEG=D1_EEG(D1_EEG.indchantype('EEG'), ind1:ind2, 1, :);

    for i=1:numel(D1_EEG.conditions)

        spm_eeg_plotScalpData(squeeze(Data1_EEG(:,1,1,i)), D1_EEG.coor2D(D1_EEG.indchantype('EEG')), D1_EEG.chanlabels(D1_EEG.indchantype('EEG')));
        title(['EEG power plot Off ' num2str(freqband)])
    
        spm_mkdir(['D:\home\results Percept Project\', initials]);
        saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'EEG power plot Off', condition,...
           '_', D1_EEG.conditions{i} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])
    end


    ind1 = find(min(abs(D2_EEG.frequencies-freqband(1)))==abs(D2_EEG.frequencies-freqband(1)));
    ind2 = find(min(abs(D2_EEG.frequencies-freqband(2)))==abs(D2_EEG.frequencies-freqband(2)));

   Data2_EEG=D2_EEG(D2_EEG.indchantype('EEG'), ind1:ind2, 1, :);

    for i=1:numel(D2_EEG.conditions)

        spm_eeg_plotScalpData(squeeze(Data2_EEG(:,1,1,i)), D2_EEG.coor2D(D2_EEG.indchantype('EEG')), D2_EEG.chanlabels(D2_EEG.indchantype('EEG')));
        title(['EEG power plot On ' num2str(freqband)])
    
        spm_mkdir(['D:\home\results Percept Project\', initials]);
        saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'EEG power plot On', condition,...
           '_', D2_EEG.conditions{i} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])
    end




end
