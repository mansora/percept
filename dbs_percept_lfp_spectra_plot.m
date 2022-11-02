function dbs_percept_lfp_spectra_plot(initials, condition)

    
    [files, seq, root, details] = dbs_subjects(initials, 1);
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

    [files, seq, root, details] = dbs_subjects(initials, 2);
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



    
        figure('units','normalized','outerposition',[0 0 1 1]),
        for cond=1:numel(D1_LFP.conditions)
            titl_fig=[condition, '' , strsplit(D1_LFP.conditions{cond},'_')];
            titl_fig_save=[condition, '' , D1_LFP.conditions{cond}];
            
            subplot(1, numel(D1_LFP.conditions),cond), plot(D2_LFP.frequencies, squeeze(D2_LFP(:,:,1,cond)),'LineWidth',3)
            hold on, plot(D1_LFP.frequencies, squeeze(D1_LFP(:,:,1,cond)),'--','LineWidth',3)
            legend('L on','R on', 'L off', 'R off')
            title(titl_fig)
            set(gca,'FontSize',18)
            set(gca,'LineWidth',3)
            
        end
        saveas(gcf, ['D:\home\results Percept Project\lfp_spectra', condition, '.png'])

        

        

        figure('units','normalized','outerposition',[0 0 1 1]),
        for cond=1:numel(D1_EEG.conditions)
            titl_fig=[condition, '' , strsplit(D1_EEG.conditions{cond},'_')];
            titl_fig_save=[condition, '' , D1_EEG.conditions{cond}];
            
            x2_EEG=mean(squeeze(D2_EEG(:,:,1,cond)),1);
            x2_EEG_up=x2_EEG+2*std(squeeze(D2_EEG(:,:,1,1)),0,1);
            x2_EEG_down=x2_EEG-2*std(squeeze(D2_EEG(:,:,1,1)),0,1);

            x1_EEG=mean(squeeze(D1_EEG(:,:,1,cond)),1);
            x1_EEG_up=x1_EEG+2*std(squeeze(D1_EEG(:,:,1,1)),0,1);
            x1_EEG_down=x1_EEG-2*std(squeeze(D1_EEG(:,:,1,1)),0,1);

            subplot(1, numel(D1_EEG.conditions),cond), h1=plot(D2_EEG.frequencies, x2_EEG,'r', 'LineWidth',3)
%             hold on, p1=patch([D2_EEG.frequencies fliplr(D2_EEG.frequencies)], [x2_EEG_down fliplr(x2_EEG_up)], 'r')
%             p1.FaceAlpha = 0.2;
            hold on, h2=plot(D1_EEG.frequencies, x1_EEG,'b--','LineWidth',3)
%             hold on, p2=patch([D1_EEG.frequencies fliplr(D1_EEG.frequencies)], [x1_EEG_down fliplr(x1_EEG_up)], 'b')
%             p2.FaceAlpha = 0.2;
            legend([h1,h2], {'EEG on','EEG off'})
            title(titl_fig)
            set(gca,'FontSize',18)
            set(gca,'LineWidth',3)
            
        end
        saveas(gcf, ['D:\home\results Percept Project\eeg_spectra', condition, '.png'])



    

end