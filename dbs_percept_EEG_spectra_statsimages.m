function dbs_percept_EEG_spectra_statsimages(initials, condition, freqband)
    
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


    S=[];
    S.D=D1_EEG;
    S.mode='scalp';
    S.freqwin=freqband;
    [imag_,~]=spm_eeg_convert2images(S);
    for i=1:numel(D1_EEG.conditions)

        spm_image(imag_{i}(1:end-2))
    
        spm_mkdir(['D:\home\results Percept Project\', initials]);
        saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_eeg_off_', condition,...
           '_', D1_EEG.conditions{i} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])
    end

    S=[];
    S.D=D2_EEG;
    S.mode='scalp';
    S.freqwin=freqband;
    [imag_,~]=spm_eeg_convert2images(S);

    for i=1:numel(D2_EEG.conditions)

        spm_image(imag_{i}(1:end-2))
    
        spm_mkdir(['D:\home\results Percept Project\', initials]);
        saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_eeg_on_', condition,...
            '_', D2_EEG.conditions{i} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])
    end




end
