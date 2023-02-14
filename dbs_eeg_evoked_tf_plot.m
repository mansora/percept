function dbs_eeg_evoked_tf_plot(initials, condition)

    try
        [files_, seq, root, details] = dbs_subjects(initials, 1);
        cd(fullfile(root, condition));
        
        files = spm_select('FPList','.', ['rmtf_', '.', initials '_rec_' num2str(1) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['rmtf_', initials '_rec_' num2str(1) '_' condition '\w*.mat']);
        end
        D_off = spm_eeg_load(files);
    catch
        warning(['patient ', initials, ' Off stim does not have', condition])
    end

    [files_, seq, root, details] = dbs_subjects(initials, 2);
    cd(fullfile(root, condition));
    
    try
        files = spm_select('FPList','.', ['rmtf_', '.', initials '_rec_' num2str(2) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['rmtf_', initials '_rec_' num2str(2) '_' condition '\w*.mat']);
        end
        D_on = spm_eeg_load(files);
    catch
        warning(['patient ', initials, ' On stim does not have', condition])
    end


    try
        c_EEG=round(max([max(max(squeeze(mean(D_on(D_on.indchantype('EEG'),:,:,1))))), abs(min(min(squeeze(mean(D_on(D_on.indchantype('EEG'),:,:,1),1)))))]));
        c_lfp=round(max([max(max(squeeze(mean(D_on(D_on.indchantype('LFP'),:,:,1))))), abs(min(min(squeeze(mean(D_on(D_on.indchantype('LFP'),:,:,1),1)))))]));
        n_cond=numel(D_on.conditions);
%         EEGchannels=D_on.indchantype('EEG');
        EEGchannels=[D_on.indchannel('C3') D_on.indchannel('C4'), D_on.indchannel('Cz')];
    catch
        c_EEG=round(max([max(max(squeeze(mean(D_off(D_off.indchantype('EEG'),:,:,1))))), abs(min(min(squeeze(mean(D_off(D_off.indchantype('EEG'),:,:,1),1)))))]));
        c_lfp=round(max([max(max(squeeze(mean(D_off(D_off.indchantype('LFP'),:,:,1))))), abs(min(min(squeeze(mean(D_off(D_off.indchantype('LFP'),:,:,1),1)))))]));
        n_cond=numel(D_off.conditions);
%         EEGchannels=D_off.indchantype('EEG');
        EEGchannels=[D_off.indchannel('C3') D_off.indchannel('C4') D_off.indchannel('Cz')];
    end

    

    for condd=1:n_cond
        figure('units','normalized','outerposition',[0 0 1 1]),

        if exist('D_off', 'var')
            subplot(2,3,1), imagesc(D_off.time, D_off.frequencies, squeeze(mean(D_off(EEGchannels,:,:,condd),1)))
            title([D_off.conditions{condd}, ' EEG off'])
            colorbar
            caxis([-c_EEG c_EEG])
            xlabel('time (s)')
            ylabel('freq (Hz)')
            
    
             indbaseline  = find(min(abs(D_off.time-0))==abs(D_off.time-0));
             Data_off1    = squeeze(D_off(D_off.indchannel(details.chan{1}),:,:,condd)-mean(D_off(D_off.indchannel(details.chan{1}),:,1:indbaseline,condd),3));
              
            if numel(details.chan)>1
    
                Data_off2    = squeeze(D_off(D_off.indchannel(details.chan{2}),:,:,condd)-mean(D_off(D_off.indchannel(details.chan{2}),:,1:indbaseline,condd),3));
    
                subplot(2,3,2), imagesc(D_off.time, D_off.frequencies, Data_off1)
                title([D_off.conditions{condd}, ' GPi L off'])
                colorbar
                caxis([-c_lfp c_lfp])
                xlabel('time (s)')
                ylabel('freq (Hz)')
        
                subplot(2,3,3), imagesc(D_off.time, D_off.frequencies, Data_off2)
                title([D_off.conditions{condd}, ' GPi R off'])
                colorbar
                caxis([-c_lfp c_lfp])
                xlabel('time (s)')
                ylabel('freq (Hz)')
            else
                subplot(2,3,2), imagesc(D_off.time, D_off.frequencies, Data_off1)
                title([D_off.conditions{condd}, 'GPi', details.chan{1}(end-3), 'off'])
                colorbar
                caxis([-c_lfp c_lfp])
                xlabel('time (s)')
                ylabel('freq (Hz)')
            end

        end



        if exist('D_on', 'var')
            subplot(2,3,4), imagesc(D_on.time, D_on.frequencies, squeeze(mean(D_on(EEGchannels,:,:,condd),1)))
            title([D_on.conditions{condd}, ' EEG on'])
            colorbar
            caxis([-c_EEG c_EEG])
            xlabel('time (s)')
            ylabel('freq (Hz)')
    
    
            indbaseline  = find(min(abs(D_on.time-0))==abs(D_on.time-0));
            Data_on1    = squeeze(D_on(D_on.indchannel(details.chan{1}),:,:,condd)-mean(D_on(D_on.indchannel(details.chan{1}),:,1:indbaseline,condd),3));
            
            
            if numel(details.chan)>1
    
                Data_on2    = squeeze(D_on(D_on.indchannel(details.chan{2}),:,:,condd)-mean(D_on(D_on.indchannel(details.chan{2}),:,1:indbaseline,condd),3));
    
                subplot(2,3,5), imagesc(D_on.time, D_on.frequencies, Data_on1)
                title([D_on.conditions{condd}, ' GPi L on'])
                colorbar
                caxis([-c_lfp c_lfp])
                xlabel('time (s)')
                ylabel('freq (Hz)')
        
                subplot(2,3,6), imagesc(D_on.time, D_on.frequencies, Data_on2)
                title([D_on.conditions{condd}, ' GPi R on'])
                colorbar
                caxis([-c_lfp c_lfp])
                xlabel('time (s)')
                ylabel('freq (Hz)')
            else
                subplot(2,3,5), imagesc(D_on.time, D_on.frequencies, Data_on1)
                title([D_on.conditions{condd}, 'GPi', details.chan{1}(end-3), 'on'])
                colorbar
                caxis([-c_lfp c_lfp])
                xlabel('time (s)')
                ylabel('freq (Hz)')
            end
        end

        if exist('D_on', 'var')
            spm_mkdir(['D:\home\results Percept Project\', initials]);
            saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Evoked_TF_', condition, '_' ,D_on.conditions{condd}, '.png'])
        elseif exist('D_off', 'var')
            spm_mkdir(['D:\home\results Percept Project\', initials]);
            saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Evoked_TF_', condition, '_' ,D_off.conditions{condd}, '.png'])
        end

    end




end