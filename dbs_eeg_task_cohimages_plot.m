function dbs_eeg_task_cohimages_plot(initials, condition)

    [files_, seq, root, details] = dbs_subjects(initials, 1);
    cd(fullfile(root, condition));
    
    files = spm_select('FPList','.', ['rCOH_sensors_LFP_Gpi_\w*.mat']);

    for f=1:size(files,1)
        if strfind(files(f,:), 'Gpi_R')
            D_off_R = spm_eeg_load(files(f,:));
        elseif strfind(files(f,:), 'Gpi_L')
            D_off_L = spm_eeg_load(files(f,:));
        else
            error('datafile is wrong')
        end
     end



    [files_, seq, root, details] = dbs_subjects(initials, 2);
    cd(fullfile(root, condition));

    files = spm_select('FPList','.', ['rCOH_sensors_LFP_Gpi_\w*.mat']);
    
    for f=1:size(files,1)
        if strfind(files(f,:), 'Gpi_R')
            D_on_R = spm_eeg_load(files(f,:));
        elseif strfind(files(f,:), 'Gpi_L')
            D_on_L = spm_eeg_load(files(f,:));
        else
            error('datafile is wrong')
        end
     end
    

    try
        x_min=round(min(min(squeeze(mean(D_on_R(:,:,:,1),1)))));
        x_max=round(max(max(squeeze(mean(D_on_R(:,:,:,1),1)))));

        figure('units','normalized','outerposition',[0 0 1 1]),
        sgtitle(['Right GPi ', condition])
        n_cond=numel(D_off_R.conditions);
        for cond=1:n_cond
            subplot(2,n_cond,cond), imagesc(D_off_R.time, D_off_R.frequencies, squeeze(mean(D_off_R(6,:,:,cond),1)))
            title([D_off_R.conditions{cond}, ' off'])
            colorbar
            caxis([x_min x_max])
            xlabel('time (s)')
            ylabel('freq (Hz)')
            subplot(2,numel(D_on_R.conditions),n_cond+cond),  imagesc(D_on_R.time, D_on_R.frequencies, squeeze(mean(D_on_R(6,:,:,cond),1)))
            title([D_on_R.conditions{cond}, ' on'])
            colorbar
            caxis([x_min x_max])
            xlabel('time (s)')
            ylabel('freq (Hz)')
        end
        
        spm_mkdir(['D:\home\results Percept Project\', initials]);
        saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Coherence_', condition, '_RightGPi.png'])
    catch
        warning('data has no right side')
    end

    try
%         x_min=round(min(min(squeeze(mean(D_on_L(:,:,:,1),1)))));
%         x_max=round(max(max(squeeze(mean(D_on_L(:,:,:,1),1)))));

        figure('units','normalized','outerposition',[0 0 1 1]),
        sgtitle(['Left GPi ', condition])
        n_cond=numel(D_off_L.conditions);
        for cond=1:n_cond
            subplot(2,n_cond,cond), imagesc(D_off_L.time, D_off_L.frequencies, squeeze(mean(D_off_L(6,:,:,cond),1)))
            title([D_off_L.conditions{cond}, ' off'])
            colorbar
            caxis([x_min x_max])
            xlabel('time (s)')
            ylabel('freq (Hz)')
            subplot(2,numel(D_off_L.conditions),n_cond+cond),  imagesc(D_on_L.time, D_on_L.frequencies, squeeze(mean(D_on_L(6,:,:,cond),1)))
            title([D_on_L.conditions{cond}, ' on'])
            colorbar
            caxis([x_min x_max])
            xlabel('time (s)')
            ylabel('freq (Hz)')
        end
    
        spm_mkdir(['D:\home\results Percept Project\', initials]);
        saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Coherence_', condition, '_LeftGPi.png'])
    catch
        warning('data has no left side')
    end

   



    


end