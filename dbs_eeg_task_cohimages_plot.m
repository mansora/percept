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
    

%     try
%         if exist('D_on_R', 'var')
%             %EEGchannels=D_on_R.indchantype('EEG');
%             EEGchannels=[D_on_R.indchannel('C3') D_on_R.indchannel('C4') D_on_R.indchannel('Cz')];
%             x_min=round(min(min(squeeze(mean(D_on_R(EEGchannels,:,:,1),1)))));
%             x_max=round(max(max(squeeze(mean(D_on_R(EEGchannels,:,:,1),1)))));
%             x_min=-40;
%             x_max=40;
%         elseif exist('D_off_R', 'var')
%             %EEGchannels=D_off_R.indchantype('EEG');
%             EEGchannels=[D_off_R.indchannel('C3') D_off_R.indchannel('C4') D_off_R.indchannel('Cz')];
%             x_min=round(min(min(squeeze(mean(D_off_R(EEGchannels,:,:,1),1)))));
%             x_max=round(max(max(squeeze(mean(D_off_R(EEGchannels,:,:,1),1)))));
%             x_min=-40;
%             x_max=40;
%         end
%            
% 
%         figure('units','normalized','outerposition',[0 0 1 1]),
%         sgtitle(['Right GPi ', condition])
%         n_cond=numel(D_off_R.conditions);
%         for cond=1:n_cond
%                 if exist('D_off_R', 'var')
%                     subplot(2,n_cond,cond), imagesc(D_off_R.time(18:57), D_off_R.frequencies(1:32), squeeze(mean(D_off_R(EEGchannels,1:32,18:57,cond),1)))
%                     axis xy
%                     title([D_off_R.conditions{cond}, ' off'])
%                     colorbar
%                     caxis([x_min x_max])
%                     xlabel('time (s)')
%                     ylabel('freq (Hz)')
%                 end
%             
%                 if exist('D_on_R', 'var')
%                     subplot(2,numel(D_on_R.conditions),n_cond+cond),  imagesc(D_on_R.time(18:57), D_on_R.frequencies(1:32), squeeze(mean(D_on_R(EEGchannels,1:32,18:57,cond),1)))
%                     axis xy
%                     title([D_on_R.conditions{cond}, ' on'])
%                     colorbar
%                     caxis([x_min x_max])
%                     xlabel('time (s)')
%                     ylabel('freq (Hz)')
%                 end
%             
%         end
%         
%         spm_mkdir(['D:\home\results Percept Project\', initials]);
%         saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Coherence_', condition, '_RightGPi.png'])
%     catch
%         warning('data has no right side')
%     end
% 
%     try
%         if exist('D_on_L', 'var')
%             %EEGchannels=D_off_R.indchantype('EEG');
%             EEGchannels=[D_on_L.indchannel('C3') D_on_L.indchannel('C4') D_on_L.indchannel('Cz')];
%             x_min=round(min(min(squeeze(mean(D_on_L(EEGchannels,:,:,1),1)))));
%             x_max=round(max(max(squeeze(mean(D_on_L(EEGchannels,:,:,1),1)))));
%             x_min=-40;
%             x_max=40;
%         elseif exist('D_off_L', 'var')
%             %EEGchannels=D_off_R.indchantype('EEG');
%             EEGchannels=[D_off_L.indchannel('C3') D_off_L.indchannel('C4') D_off_L.indchannel('Cz')];
%             x_min=round(min(min(squeeze(mean(D_off_L(EEGchannels,:,:,1),1)))));
%             x_max=round(max(max(squeeze(mean(D_off_L(EEGchannels,:,:,1),1)))));
%             x_min=-40;
%             x_max=40;
%         end
% 
%         figure('units','normalized','outerposition',[0 0 1 1]),
%         sgtitle(['Left GPi ', condition])
%         n_cond=numel(D_off_L.conditions);
%         for cond=1:n_cond
%             if exist('D_off_L', 'var')
%                 subplot(2,n_cond,cond), imagesc(D_off_L.time(18:57), D_off_L.frequencies(1:32), squeeze(mean(D_off_L(EEGchannels,1:32,18:57,cond),1)))
%                 axis xy
%                 title([D_off_L.conditions{cond}, ' off'])
%                 colorbar
%                 caxis([x_min x_max])
%                 xlabel('time (s)')
%                 ylabel('freq (Hz)')
%             end
%             if exist('D_on_L', 'var')
%                 subplot(2,numel(D_on_L.conditions),n_cond+cond),  imagesc(D_on_L.time(18:57), D_on_L.frequencies(1:32), squeeze(mean(D_on_L(EEGchannels,1:32,18:57,cond),1)))
%                 axis xy
%                 title([D_on_L.conditions{cond}, ' on'])
%                 colorbar
%                 caxis([x_min x_max])
%                 xlabel('time (s)')
%                 ylabel('freq (Hz)')
%             end
%         end
%     
%         spm_mkdir(['D:\home\results Percept Project\', initials]);
%         saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Coherence_', condition, '_LeftGPi.png'])
%     catch
%         warning('data has no left side')
%     end


    if exist('D_on_L', 'var') && exist('D_on_R', 'var') && exist('D_off_L', 'var') && exist('D_off_R', 'var')
        EEGchannels=[D_on_L.indchannel('C3') D_on_L.indchannel('C4') D_on_L.indchannel('Cz')];
        x_min=round(min(min(squeeze(mean(D_on_L(EEGchannels,:,:,1),1)))))+10;
        x_max=round(max(max(squeeze(mean(D_on_L(EEGchannels,:,:,1),1)))))-10;

        figure('units','normalized','outerposition',[0 0 1 1]),

        D_on=mean(cat(1, D_on_L(EEGchannels,1:32,:,1:4), D_on_R(EEGchannels,1:32,:,1:4)),4);
        D_off=mean(cat(1, D_off_L(EEGchannels,1:32,:,1:4), D_off_R(EEGchannels,1:32,:,1:4)),4);

        subplot(2,2,1), imagesc(D_on_L.time, D_on_L.frequencies(1:32), squeeze(mean(D_on,1)))
        axis xy
        caxis([-50 50])
        subplot(2,2,3), imagesc(D_on_L.time, D_on_L.frequencies(1:32), squeeze(mean(D_off,1)))
        axis xy
%         title(['hand', ' on'])
%         colorbar
        caxis([-50 50])
%         xlabel('time (s)', 'FontSize', 20, 'FontWeight','bold')
%         ylabel('freq (Hz)', 'FontSize', 20, 'FontWeight','bold')

%         spm_mkdir(['D:\home\results Percept Project\', initials]);
%         saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Coherence_', condition, '_hand_bothGPi.png'])


        D_on=mean(cat(1, D_on_L(EEGchannels,1:32,:,5:8), D_on_R(EEGchannels,1:32,:,5:8)),4);
        D_off=mean(cat(1, D_off_L(EEGchannels,1:32,:,5:8), D_off_R(EEGchannels,1:32,:,5:8)),4);

%         figure('units','normalized','outerposition',[0 0 1 1]),
        subplot(2,2,2), imagesc(D_on_L.time, D_on_L.frequencies(1:32), squeeze(mean(D_on,1)))
        axis xy
        caxis([-50 50])
        subplot(2,2,4), imagesc(D_on_L.time, D_on_L.frequencies(1:32), squeeze(mean(D_off,1)))
        axis xy
%         title(['hand', ' on'])
%         colorbar
        caxis([-50 50])
%         xlabel('time (s)', 'FontSize', 20, 'FontWeight','bold')
%         ylabel('freq (Hz)', 'FontSize', 20, 'FontWeight','bold')



        spm_mkdir(['D:\home\results Percept Project\', initials]);
        saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Coherence_', condition, '_bothGPi.png'])


    end





   



    


end