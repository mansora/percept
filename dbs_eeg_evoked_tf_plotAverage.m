function dbs_eeg_evoked_tf_plotAverage(condition)

     close all
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
  
    for i=1:numel(initials)

    
        [files_, seq, root, details] = dbs_subjects(initials{i}, 1);
        cd(fullfile(root, condition));
        try
            files = spm_select('FPList','.', ['rmtf_', '.', initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['rmtf_', initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
            end
            D_off = spm_eeg_load(files);
            lfpchan=D_off.indchantype('LFP');
            EEGchannels=[D_off.indchannel('P3') D_off.indchannel('P4') D_off.indchannel('Pz')];
            D1_EEG_all(i,:,:,:)=mean(D_off(EEGchannels,:,:,:),1);
    
            indbaseline  = find(min(abs(D_off.time-0))==abs(D_off.time-0));
            if strcmp(D_off.chanlabels{lfpchan(1)}(end-3),'L')
                D1_LFP_1_all(i,:,:,:)=D_off(lfpchan(1),:,:,:) - mean(D_off(lfpchan(1),:,1:indbaseline,:),3);
            else
                D1_LFP_2_all(i,:,:,:)=D_off(lfpchan(1),:,:,:) - mean(D_off(lfpchan(1),:,1:indbaseline,:),3);
            end
            if numel(lfpchan)>1
                if strcmp(D_off.chanlabels{lfpchan(2)}(end-3),'L')
                    D1_LFP_1_all(i,:,:,:)=D_off(lfpchan(2),:,:,:) - mean(D_off(lfpchan(2),:,1:indbaseline,:),3);
                else
                    D1_LFP_2_all(i,:,:,:)=D_off(lfpchan(2),:,:,:) - mean(D_off(lfpchan(2),:,1:indbaseline,:),3);
                end
            end
    
    
        catch
            warning(['patient ', initials{i}, ' Off stim does not have', condition])
       end

    [files_, seq, root, details] = dbs_subjects(initials{i}, 2);
    cd(fullfile(root, condition));
    
        try
            files = spm_select('FPList','.', ['rmtf_', '.', initials{i} '_rec_' num2str(2) '_' condition '\w*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['rmtf_', initials{i} '_rec_' num2str(2) '_' condition '\w*.mat']);
            end
            D_on = spm_eeg_load(files);
            lfpchan=D_on.indchantype('LFP');
            EEGchannels=[D_on.indchannel('P3') D_on.indchannel('P4') D_on.indchannel('Pz')];
            D2_EEG_all(i,:,:,:)=mean(D_on(EEGchannels,:,:,:),1);
    
            indbaseline  = find(min(abs(D_on.time-0))==abs(D_on.time-0));
            if strcmp(D_on.chanlabels{lfpchan(1)}(end-3),'L')
                D2_LFP_1_all(i,:,:,:)=D_on(lfpchan(1),:,:,:) - mean(D_on(lfpchan(1),:,1:indbaseline,:),3);
            else
                D2_LFP_2_all(i,:,:,:)=D_on(lfpchan(1),:,:,:) - mean(D_on(lfpchan(1),:,1:indbaseline,:),3);
            end
            if numel(lfpchan)>1
                if strcmp(D_on.chanlabels{lfpchan(2)}(end-3),'L')
                    D2_LFP_1_all(i,:,:,:)=D_on(lfpchan(2),:,:,:) - mean(D_on(lfpchan(2),:,1:indbaseline,:),3);
                else
                    D2_LFP_2_all(i,:,:,:)=D_on(lfpchan(2),:,:,:) - mean(D_on(lfpchan(2),:,1:indbaseline,:),3);
                end
            end
        catch
            warning(['patient ', initials{i}, ' On stim does not have', condition])
        end

    end


    for kk=size(D1_EEG_all,1):-1:1
        if numel(find(D1_EEG_all(kk,:,:,:)==0))==numel(D1_EEG_all(kk,:,:,:)) || numel(find(D2_EEG_all(kk,:,:,:)==0))==numel(D2_EEG_all(kk,:,:,:)) 
            D1_EEG_all(kk,:,:,:)=[];
            D2_EEG_all(kk,:,:,:)=[];
        end
    end

    for kk=size(D1_LFP_1_all,1):-1:1
        % left side
        if numel(find(D1_LFP_1_all(kk,:,:,:)==0))==numel(D1_LFP_1_all(kk,:,:,:)) || numel(find(D2_LFP_1_all(kk,:,:,:)==0))==numel(D2_LFP_1_all(kk,:,:,:)) 
            D1_LFP_1_all(kk,:,:,:)=[];
            D2_LFP_1_all(kk,:,:,:)=[];
        end

        % right side
        if numel(find(D1_LFP_2_all(kk,:,:,:)==0))==numel(D1_LFP_2_all(kk,:,:,:)) || numel(find(D2_LFP_2_all(kk,:,:,:)==0))==numel(D2_LFP_2_all(kk,:,:,:)) 
            D1_LFP_2_all(kk,:,:,:)=[];
            D2_LFP_2_all(kk,:,:,:)=[];
        end
    end


   limb_list={'hand', 'foot'};
        for limb=1:2
    
            D1_EEG=mean(D1_EEG_all(:,:,:,1+4*(limb-1):4+4*(limb-1)),4);
            D2_EEG=mean(D2_EEG_all(:,:,:,1+4*(limb-1):4+4*(limb-1)),4);

            D1_EEG=squeeze(mean(D1_EEG,1));
            D2_EEG=squeeze(mean(D2_EEG,1));

            D1_LFP_1=mean(D1_LFP_1_all(:,:,:,1+4*(limb-1):4+4*(limb-1)),4);
            D2_LFP_1=mean(D2_LFP_1_all(:,:,:,1+4*(limb-1):4+4*(limb-1)),4);

            D1_LFP_2=mean(D1_LFP_2_all(:,:,:,1+4*(limb-1):4+4*(limb-1)),4);
            D2_LFP_2=mean(D2_LFP_2_all(:,:,:,1+4*(limb-1):4+4*(limb-1)),4);


          
            D1 = cat( 1, D1_LFP_1, D1_LFP_2);
            D1 = squeeze(mean(D1,1));
            D2  = cat( 1, D2_LFP_1, D2_LFP_2);
            D2  = squeeze(mean(D2,1));

            figure('units','normalized','outerposition',[0 0 1 1]),
        %         sgtitle([' GPi ', condition])
            
                   
            subplot(1,2,1), imagesc(D_on.time, D_on.frequencies, D1_EEG)
            axis xy
            title([limb_list{limb}, ' off'])
            colorbar('fontsize',25,'FontWeight','bold', 'linewidth',5)
            
%             caxis([-15 15])
            xlabel('time (s)', 'FontSize', 20, 'FontWeight','bold')
            ylabel('freq (Hz)', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca, 'fontsize',25,'FontWeight','bold')
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
        
            subplot(1,2,2),  imagesc(D_on.time, D_on.frequencies, D2_EEG)
            axis xy
            title([limb_list{limb}, ' on'])
            colorbar('fontsize',25,'FontWeight','bold', 'linewidth',5)
%             caxis([-15 15])
            xlabel('time (s)', 'FontSize', 20, 'FontWeight','bold')
            ylabel('freq (Hz)', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca, 'fontsize',25,'FontWeight','bold')
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')

            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', 'evokedTF_EEG','_', condition, limb_list{limb}, '.png'])



             figure('units','normalized','outerposition',[0 0 1 1]),
            imagesc(D_on.time, D_on.frequencies, D2_EEG-D1_EEG)
            axis xy
            title([limb_list{limb}, ' On - Off'])
            colorbar('fontsize',25,'FontWeight','bold', 'linewidth',5)
%             caxis([-15 15])
            xlabel('time (s)', 'FontSize', 20, 'FontWeight','bold')
            ylabel('freq (Hz)', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca, 'fontsize',25,'FontWeight','bold')
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')




            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', 'evokedTF_EEGONOFF','_', condition, limb_list{limb}, '.png'])

 
            figure('units','normalized','outerposition',[0 0 1 1]),
        %         sgtitle([' GPi ', condition])
            
                   
            subplot(1,2,1), imagesc(D_on.time, D_on.frequencies, D1)
            axis xy
            title([limb_list{limb}, ' off'])
            colorbar('fontsize',25,'FontWeight','bold', 'linewidth',5)
            
%             caxis([-15 15])
            xlabel('time (s)', 'FontSize', 20, 'FontWeight','bold')
            ylabel('freq (Hz)', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca, 'fontsize',25,'FontWeight','bold')
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
        
            subplot(1,2,2),  imagesc(D_on.time, D_on.frequencies, D2)
            axis xy
            title([limb_list{limb}, ' on'])
            colorbar('fontsize',25,'FontWeight','bold', 'linewidth',5)
%             caxis([-15 15])
            xlabel('time (s)', 'FontSize', 20, 'FontWeight','bold')
            ylabel('freq (Hz)', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca, 'fontsize',25,'FontWeight','bold')
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')

            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', 'evokedTF_GPi','_', condition, limb_list{limb}, '.png'])


            figure('units','normalized','outerposition',[0 0 1 1]),
            imagesc(D_on.time, D_on.frequencies, D2-D1)
            axis xy
            title([limb_list{limb}, ' On - Off'])
            colorbar('fontsize',25,'FontWeight','bold', 'linewidth',5)
%             caxis([-15 15])
            xlabel('time (s)', 'FontSize', 20, 'FontWeight','bold')
            ylabel('freq (Hz)', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca, 'fontsize',25,'FontWeight','bold')
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')




            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', 'evokedTF_GPiONOFF','_', condition, limb_list{limb}, '.png'])
    
                    
            
        

        end
    

    



end