function dbs_eeg_task_cohimages_plotAverage(condition)

     close all
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
  
     for i=1:numel(initials)

    try
        [files_, seq, root, details] = dbs_subjects(initials{i}, 1);
        cd(fullfile(root, condition));
        
        files = spm_select('FPList','.', ['rCOH_sensors_LFP_Gpi_\w*.mat']);
    
        for f=1:size(files,1)
            if strfind(files(f,:), 'Gpi_R')
                D_off_R = spm_eeg_load(files(f,:));
                EEGchannels=[D_off_R.indchannel('P3') D_off_R.indchannel('P4') D_off_R.indchannel('Pz')];
                D_off_R_temp(i,:,:,:)=squeeze(mean(D_off_R(EEGchannels,:,:,:),1));
            elseif strfind(files(f,:), 'Gpi_L')
                D_off_L = spm_eeg_load(files(f,:));
                EEGchannels=[D_off_L.indchannel('P3') D_off_L.indchannel('P4') D_off_L.indchannel('Pz')];
                D_off_L_temp(i,:,:,:)=squeeze(mean(D_off_L(EEGchannels,:,:,:),1));
            else
                error('datafile is wrong')
            end
        end
    catch
        warning(['patient ', initials{i}, ' Off stim does not have', condition])
    end


    try
        [files_, seq, root, details] = dbs_subjects(initials{i}, 2);
        cd(fullfile(root, condition));
    
        files = spm_select('FPList','.', ['rCOH_sensors_LFP_Gpi_\w*.mat']);
        
        for f=1:size(files,1)
            if strfind(files(f,:), 'Gpi_R')
                D_on_R = spm_eeg_load(files(f,:));
                EEGchannels=[D_on_R.indchannel('P3') D_on_R.indchannel('P4') D_on_R.indchannel('Pz')];
                D_on_R_temp(i,:,:,:)=squeeze(mean(D_on_R(EEGchannels,:,:,:),1));
            elseif strfind(files(f,:), 'Gpi_L')
                D_on_L = spm_eeg_load(files(f,:));
                EEGchannels=[D_on_L.indchannel('P3') D_on_L.indchannel('P4') D_on_L.indchannel('Pz')];
                D_on_L_temp(i,:,:,:)=squeeze(mean(D_on_L(EEGchannels,:,:,:),1));
            else
                error('datafile is wrong')
            end
        end
    catch
        warning(['patient ', initials, ' On stim does not have', condition])
    end

 


     end


     for kk=size(D_on_L_temp,1):-1:1
        if numel(find(D_on_L_temp(kk,:, :,:)==0))==numel(D_on_L_temp(1,:,:,:)) || numel(find(D_off_L_temp(kk,:,:,:)==0))==numel(D_off_L_temp(1,:,:,:))
            D_on_L_temp(kk,:,:,:)=[];
            D_off_L_temp(kk,:,:,:)=[];
        end

        if numel(find(D_on_R_temp(kk,:,:,:)==0))==numel(D_on_R_temp(1,:,:,:)) || numel(find(D_off_R_temp(kk,:,:,:)==0))==numel(D_off_R_temp(1,:,:,:))
            D_on_R_temp(kk,:,:,:)=[];
            D_off_R_temp(kk,:,:,:)=[];
        end
    end



        limb_list={'hand', 'foot'};
        for limb=1 %:2
    
%             D_on_left=squeeze(mean(D_on_L_temp(:,:,:,1+4*(limb-1):4+4*(limb-1)),4));
%             D_off_left=squeeze(mean(D_off_L_temp(:,:,:,1+4*(limb-1):4+4*(limb-1)),4));
%             D_on_right=squeeze(mean(D_on_R_temp(:,:,:,1+4*(limb-1):4+4*(limb-1)),4));
%             D_off_right=squeeze(mean(D_off_R_temp(:,:,:,1+4*(limb-1):4+4*(limb-1)),4));

            D_on_left=D_on_L_temp;
            D_off_left=D_off_L_temp;
            D_on_right=D_on_R_temp;
            D_off_right=D_off_R_temp;

            D_off = cat( 1, D_off_left, D_off_right);
            D_off = squeeze(mean(D_off,1));
            D_on  = cat( 1, D_on_left, D_on_right);
            D_on  = squeeze(mean(D_on,1));
 
            figure('units','normalized','outerposition',[0 0 1 1]),
        %         sgtitle([' GPi ', condition])
            
                   
            subplot(1,2,1), imagesc(D_off_R.time, D_off_R.frequencies, D_off)
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
        
            subplot(1,2,2),  imagesc(D_on_R.time, D_on_R.frequencies, D_on)
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
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', 'CohImages','_', condition, limb_list{limb}, '.png'])


            figure('units','normalized','outerposition',[0 0 1 1]),
            imagesc(D_on_R.time, D_on_R.frequencies, D_on-D_off)
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
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', 'CohImagesONOFF','_', condition, limb_list{limb}, '.png'])
    
                    
            
        

        end
        
     

   


   



    


end