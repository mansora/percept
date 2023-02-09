function dbs_eeg_task_cohimages_plot(initials, condition)


    try
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
    catch
        warning(['patient ', initials, ' Off stim does not have', condition])
    end


    try
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
    catch
        warning(['patient ', initials, ' On stim does not have', condition])
    end
    

    try
        if exist('D_on_R', 'var')
            %EEGchannels=D_on_R.indchantype('EEG');
            EEGchannels=[D_on_R.indchannel('C3') D_on_R.indchannel('C4')];
            x_min=round(min(min(squeeze(mean(D_on_R(EEGchannels,:,:,1),1)))));
            x_max=round(max(max(squeeze(mean(D_on_R(EEGchannels,:,:,1),1)))));
        elseif exist('D_off_R', 'var')
            %EEGchannels=D_off_R.indchantype('EEG');
            EEGchannels=[D_off_R.indchannel('C3') D_off_R.indchannel('C4')];
            x_min=round(min(min(squeeze(mean(D_off_R(EEGchannels,:,:,1),1)))));
            x_max=round(max(max(squeeze(mean(D_off_R(EEGchannels,:,:,1),1)))));
        end
           

        figure('units','normalized','outerposition',[0 0 1 1]),
        sgtitle(['Right GPi ', condition])
        n_cond=numel(D_off_R.conditions);
        for cond=1:n_cond
                if exist('D_off_R', 'var')
                    subplot(2,n_cond,cond), imagesc(D_off_R.time, D_off_R.frequencies, squeeze(mean(D_off_R(EEGchannels,:,:,cond),1)))
                    title([D_off_R.conditions{cond}, ' off'])
                    colorbar
                    caxis([x_min x_max])
                    xlabel('time (s)')
                    ylabel('freq (Hz)')
                end
            
                if exist('D_on_R', 'var')
                    subplot(2,numel(D_on_R.conditions),n_cond+cond),  imagesc(D_on_R.time, D_on_R.frequencies, squeeze(mean(D_on_R(EEGchannels,:,:,cond),1)))
                    title([D_on_R.conditions{cond}, ' on'])
                    colorbar
                    caxis([x_min x_max])
                    xlabel('time (s)')
                    ylabel('freq (Hz)')
                end
            
        end
        
        spm_mkdir(['D:\home\results Percept Project\', initials]);
        saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Coherence_', condition, '_RightGPi.png'])
    catch
        warning('data has no right side')
    end

    try
        if exist('D_on_L', 'var')
            %EEGchannels=D_off_R.indchantype('EEG');
            EEGchannels=[D_on_L.indchannel('C3') D_on_L.indchannel('C4')];
            x_min=round(min(min(squeeze(mean(D_on_L(EEGchannels,:,:,1),1)))));
            x_max=round(max(max(squeeze(mean(D_on_L(EEGchannels,:,:,1),1)))));
        elseif exist('D_off_L', 'var')
            %EEGchannels=D_off_R.indchantype('EEG');
            EEGchannels=[D_off_L.indchannel('C3') D_off_L.indchannel('C4')];
            x_min=round(min(min(squeeze(mean(D_off_L(EEGchannels,:,:,1),1)))));
            x_max=round(max(max(squeeze(mean(D_off_L(EEGchannels,:,:,1),1)))));
        end

        figure('units','normalized','outerposition',[0 0 1 1]),
        sgtitle(['Left GPi ', condition])
        n_cond=numel(D_off_L.conditions);
        for cond=1:n_cond
            if exist('D_off_L', 'var')
                subplot(2,n_cond,cond), imagesc(D_off_L.time, D_off_L.frequencies, squeeze(mean(D_off_L(EEGchannels,:,:,cond),1)))
                title([D_off_L.conditions{cond}, ' off'])
                colorbar
                caxis([x_min x_max])
                xlabel('time (s)')
                ylabel('freq (Hz)')
            end
            if exist('D_on_L', 'var')
                subplot(2,numel(D_on_L.conditions),n_cond+cond),  imagesc(D_on_L.time, D_on_L.frequencies, squeeze(mean(D_on_L(EEGchannels,:,:,cond),1)))
                title([D_on_L.conditions{cond}, ' on'])
                colorbar
                caxis([x_min x_max])
                xlabel('time (s)')
                ylabel('freq (Hz)')
            end
        end
    
        spm_mkdir(['D:\home\results Percept Project\', initials]);
        saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Coherence_', condition, '_LeftGPi.png'])
    catch
        warning('data has no left side')
    end

   



    


end