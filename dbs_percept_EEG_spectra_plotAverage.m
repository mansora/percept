function dbs_percept_EEG_spectra_plotAverage(condition, freqband)

    close all
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
    

    chanlabels= {'Fp1', 'Fz', 'F3','F7','FT9','FC5','FC1','C3','T7','TP9','CP5','CP1',...
            'Pz','P3','P7','O1','Oz','O2','P4','P8','TP10','CP6','CP2','Cz',...
            'C4','T8','FT10','FC6','FC2','F4','F8', 'Fp2'};


    for i=1:numel(initials)
    [files_, seq, root, details] = dbs_subjects_percept(initials{i}, 1);
    cd(fullfile(root, condition));
    
    try
        files = spm_select('FPList','.', ['EEG_spect_', '.', initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['EEG_spect_', initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
        end
        D1_EEG = spm_eeg_load(files);
        EEGchannels=cellfun(@(s) find(strcmp(D1_EEG.chanlabels, s)), chanlabels);

        for condz=1:numel(D1_EEG.conditions)
            D1_EEG_all(:,:,i, condz)=squeeze(D1_EEG(EEGchannels,:,1,condz));
        end

    catch
        warning(['patient ', initials{i}, ' Off stim does not have', condition])
    end

    

    [files_, seq, root, details] = dbs_subjects_percept(initials{i}, 2);
    cd(fullfile(root, condition));
    
   try
        files = spm_select('FPList','.', ['EEG_spect_', '.', initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['EEG_spect_', initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        end
        D2_EEG = spm_eeg_load(files);

        EEGchannels=cellfun(@(s) find(strcmp(D2_EEG.chanlabels, s)), chanlabels);

        for condz=1:numel(D2_EEG.conditions)
            D2_EEG_all(:,:,i, condz)=squeeze(D2_EEG(EEGchannels,:,1,condz));
        end
   catch
       warning(['patient ', initials{i}, ' On stim does not have', condition])
   end

    end

   for kk=size(D2_EEG_all,3):-1:1
        if numel(find(D2_EEG_all(:,:,kk,:)==0))==numel(D2_EEG_all(:,:,kk,:)) || numel(find(D1_EEG_all(:,:,kk,:)==0))==numel(D1_EEG_all(:,:,kk,:))
            D1_EEG_all(:,:,kk,:)=[];
            D2_EEG_all(:,:,kk,:)=[];
        end
    end


    



    limb_list={'hand', 'foot'};
    for limb=1:2
    
        ind1 = find(min(abs(D1_EEG.frequencies-freqband(1)))==abs(D1_EEG.frequencies-freqband(1)));
        ind2 = find(min(abs(D1_EEG.frequencies-freqband(2)))==abs(D1_EEG.frequencies-freqband(2)));
    
        Data1_EEG=squeeze(mean(mean(D1_EEG_all(:,ind1:ind2,:,1+4*(limb-1):4+4*(limb-1)),4),2));
    
        
    
        spm_eeg_plotScalpData(mean(Data1_EEG,2), D1_EEG.coor2D(EEGchannels), D1_EEG.chanlabels(EEGchannels));
%         title(['Average EEG power plot Off ' num2str(freqband)])
    
        spm_mkdir(['D:\home\results Percept Project\ForBRST']);
        saveas(gcf, ['D:\home\results Percept Project\ForBRST\Average EEG power plot Off', condition,...
           '_', limb_list{limb} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])
  
    


   
        ind1 = find(min(abs(D2_EEG.frequencies-freqband(1)))==abs(D2_EEG.frequencies-freqband(1)));
        ind2 = find(min(abs(D2_EEG.frequencies-freqband(2)))==abs(D2_EEG.frequencies-freqband(2)));
    
        Data2_EEG=squeeze(mean(mean(D2_EEG_all(:,ind1:ind2,:,1+4*(limb-1):4+4*(limb-1)),4),2));
    
        
    
        spm_eeg_plotScalpData(mean(Data2_EEG,2), D2_EEG.coor2D(EEGchannels), D2_EEG.chanlabels(EEGchannels));
%         title(['Average EEG power plot On ' num2str(freqband)])
    
        spm_mkdir(['D:\home\results Percept Project\ForBRST']);
        saveas(gcf, ['D:\home\results Percept Project\ForBRST\Average EEG power plot On', condition,...
           '_', limb_list{limb} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])
        



        ind1 = find(min(abs(D2_EEG.frequencies-freqband(1)))==abs(D2_EEG.frequencies-freqband(1)));
        ind2 = find(min(abs(D2_EEG.frequencies-freqband(2)))==abs(D2_EEG.frequencies-freqband(2)));
    
        Data_EEG=Data2_EEG-Data1_EEG;
    
        
    
        spm_eeg_plotScalpData(mean(Data_EEG,2), D2_EEG.coor2D(EEGchannels), D2_EEG.chanlabels(EEGchannels));
%         title(['Average EEG power plot On - Off' num2str(freqband)])
    
        spm_mkdir(['D:\home\results Percept Project\ForBRST']);
        saveas(gcf, ['D:\home\results Percept Project\ForBRST\Average EEG power plot On-Off', condition,...
           '_', limb_list{limb} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])
    





    end

    




end
