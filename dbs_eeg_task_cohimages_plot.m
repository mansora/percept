function dbs_eeg_task_cohimages_plot(initials, condition)

    [files, seq, root, details] = dbs_subjects(initials, 1);
    cd(fullfile(root, condition));
    
    D_off_L = spm_eeg_load('rCOH_sensors_LFP_Gpi_L_13');
    D_off_R = spm_eeg_load('rCOH_sensors_LFP_Gpi_R_13');


    [files, seq, root, details] = dbs_subjects(initials, 2);
    cd(fullfile(root, condition));
    
    D_on_L = spm_eeg_load('rCOH_sensors_LFP_Gpi_L_13');
    D_on_R = spm_eeg_load('rCOH_sensors_LFP_Gpi_R_13');

    x_min=round(min(min(squeeze(mean(D_off_L(:,:,:,1),1)))));
    x_max=round(max(max(squeeze(mean(D_off_L(:,:,:,1),1)))));

    figure('units','normalized','outerposition',[0 0 1 1]),
    sgtitle(['Left GPi ', condition])
    n_cond=numel(D_off_L.conditions);
    for cond=1:n_cond
        subplot(2,n_cond,cond), imagesc(D_off_L.time, D_off_L.frequencies, squeeze(mean(D_off_L(:,:,:,cond),1)))
        title([D_off_L.conditions{cond}, ' off'])
        colorbar
        caxis([x_min x_max])
        xlabel('time (s)')
        ylabel('freq (Hz)')
        subplot(2,numel(D_off_L.conditions),n_cond+cond),  imagesc(D_on_L.time, D_on_L.frequencies, squeeze(mean(D_on_L(:,:,:,cond),1)))
        title([D_on_L.conditions{cond}, ' on'])
        colorbar
        caxis([x_min x_max])
        xlabel('time (s)')
        ylabel('freq (Hz)')
    end

    saveas(gcf, ['D:\home\results Percept Project\Coherence_', condition, '_LeftGPi.png'])



    figure('units','normalized','outerposition',[0 0 1 1]),
    sgtitle(['Right GPi ', condition])
    for cond=1:n_cond
        subplot(2,n_cond,cond), imagesc(D_off_R.time, D_off_R.frequencies, squeeze(mean(D_off_R(:,:,:,cond),1)))
        title([D_off_R.conditions{cond}, ' off'])
        colorbar
        caxis([x_min x_max])
        xlabel('time (s)')
        ylabel('freq (Hz)')
        subplot(2,numel(D_on_R.conditions),n_cond+cond),  imagesc(D_on_R.time, D_on_R.frequencies, squeeze(mean(D_on_R(:,:,:,cond),1)))
        title([D_on_R.conditions{cond}, ' on'])
        colorbar
        caxis([x_min x_max])
        xlabel('time (s)')
        ylabel('freq (Hz)')
    end

    saveas(gcf, ['D:\home\results Percept Project\Coherence_', condition, '_RightGPi.png'])


end