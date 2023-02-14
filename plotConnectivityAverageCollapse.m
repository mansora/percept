function ind_patient=plotConnectivityAverageCollapse(condition, Coh_state)
    close all
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
    ind_patient={};

     [files_, seq, root, details] = dbs_subjects(initials{1}, 1);
     cd(fullfile(root, condition));

    try
        files = spm_select('FPList','.', ['^.' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    
    D = spm_eeg_load(files);
   

    switch Coh_state
        case 'Coherence'
            Coh_state_num=1;
            start_ind=1;
        case 'ShuffledCoherence'
            Coh_state_num=11;
            start_ind=1;
        case 'GrangerfromEEG'
            Coh_state_num=4;
            start_ind=1;
        case 'GrangertoEEG'
            Coh_state_num=4;
            start_ind=2;
        case 'ReversedGrangerfromEEG'
            Coh_state_num=9;
            start_ind=1;
        case 'ReversedGrangertoEEG'
            Coh_state_num=9;
            start_ind=2;
    end



    for sub_condition=1:numel(D.condlist)
        subcondition =D.condlist{sub_condition};% 'foot_L_up';

     for i=1:numel(initials)
        
        z=1;
       
        
    
        [files_, seq, root, details] = dbs_subjects(initials{i}, 2);
        cd(fullfile(root, condition));


         try
            files = spm_select('FPList','.', ['^.' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        catch
            files = spm_select('FPList','.', ['regexp_.*c|.*' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        end
        
        if isempty(files)
            files = spm_select('FPList','.', ['^' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        end
        
        Dchan = spm_eeg_load(files);
        lfpchan=Dchan.indchantype('LFP');
        %EEGchannels=D_on_R.indchantype('EEG');
        EEGchannels=[Dchan.indchannel('C3') Dchan.indchannel('C4') Dchan.indchannel('Cz')];

        [files_, seq, root, details] = dbs_subjects(initials{i}, 1);
        cd(fullfile(root, condition));
    
        files = spm_select('FPList','.', ['C_', condition, '_', subcondition, '.', initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', condition, '_', subcondition, initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
        end
        try
        Dc_off=spm_eeg_load(files);
        

        if numel(lfpchan)>1
            if strcmp(Dchan.chanlabels{lfpchan(2)}(end-3),'L')
                temp=squeeze((Dc_off(start_ind:4:end,:,1,Coh_state_num)));
                D_off_left(i,:, sub_condition)=mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp=squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_right(i,:, sub_condition)=mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp = squeeze((Dc_off(start_ind:4:end,:,1,Coh_state_num)));
                D_off_right(i,:, sub_condition) = mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp = squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_left(i,:, sub_condition) = mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp = squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_left(i,:, sub_condition)= mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp= squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_right(i,:, sub_condition)=  mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        end

        catch
            warning(['patient ', initials{i}, ' Off stim does not have', condition])
        end
    
        [files_, seq, root, details] = dbs_subjects(initials{i}, 2);
        cd(fullfile(root, condition));

        files = spm_select('FPList','.', ['C_', condition, '_', subcondition, '.', initials{i} '_rec_' num2str(2) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', condition, '_', subcondition, initials{i} '_rec_' num2str(2) '_' condition '\w*.mat']);
        end
        try
        Dc_on=spm_eeg_load(files);
       

        if numel(lfpchan)>1
            if strcmp(Dchan.chanlabels{lfpchan(2)}(end-3),'L')
                temp=squeeze((Dc_on(start_ind:4:end,:,1,Coh_state_num)));
                D_on_left(i,:, sub_condition) = mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp= squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_right(i,:, sub_condition)= mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp =squeeze((Dc_on(start_ind:4:end,:,1,Coh_state_num)));
                D_on_right(i,:, sub_condition) = mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp=squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_left(i,:, sub_condition)=mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp =squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_left(i,:, sub_condition)=mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp=squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_right(i,:, sub_condition)=mean(temp(EEGchannels, :),1);
                [~,ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        end

        catch
            warning(['patient ', initials{i}, ' On stim does not have', condition])
        end

       ind_patient{i}=ind;
     end
    end

 
    for kk=size(D_on_left,1):-1:1
        if numel(find(D_on_left(kk,:, :)==0))==numel(D_on_left(1,:,:)) || numel(find(D_off_left(kk,:,:)==0))==numel(D_off_left(1,:,:))
            D_on_left(kk,:,:)=[];
            D_off_left(kk,:,:)=[];
        end

        if numel(find(D_on_right(kk,:,:)==0))==numel(D_on_right(1,:,:)) || numel(find(D_off_right(kk,:,:)==0))==numel(D_off_right(1,:,:))
            D_on_right(kk,:,:)=[];
            D_off_right(kk,:,:)=[];
        end
    end

    D_on_left_temp=D_on_left;
    D_off_left_temp=D_off_left;
    D_on_right_temp=D_on_right;
    D_off_right_temp=D_off_right;


    if find(strcmp({'ACT','PMT'},condition))


        limb_list={'hand', 'foot'};
        for limb=1:2
    
            D_on_left=squeeze(mean(D_on_left_temp(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D_off_left=squeeze(mean(D_off_left_temp(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D_on_right=squeeze(mean(D_on_right_temp(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D_off_right=squeeze(mean(D_off_right_temp(:,:,1+4*(limb-1):4+4*(limb-1)),3));
        
    
            %% Both
    
            D_off = [D_off_left;D_off_right];
            D_on  = [D_on_left;D_on_right];
    
            figure('units','normalized','outerposition',[0 0 1 1]),
    %         plot(Dc_on.frequencies(1:80), D_on(:, 1:80), 'b--', 'LineWidth', 2)
    %         hold on, plot(Dc_on.frequencies(1:80), D_off(:, 1:80), 'r--', 'LineWidth', 2)
            h1=plot(Dc_on.frequencies(1:80), mean(D_on(:, 1:80)), 'b', 'LineWidth', 8)
            hold on
            h2=plot(Dc_on.frequencies(1:80), mean(D_off(:, 1:80)), 'r--', 'LineWidth', 8)
    
    %         legend([h1, h2],{'on', 'off'})
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('Connectivity', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
    %         title([Coh_state, 'Average',' ', limb_list{limb}],  'FontSize', 50)
            xlim([0 90])
            
            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', Coh_state,  'Average','_', condition, limb_list{limb}, '.png'])
    
    
            D_diff=D_on-D_off;
            ind4 = find(min(abs(Dc_on.frequencies-4))==abs(Dc_on.frequencies-4));
            ind7 = find(min(abs(Dc_on.frequencies-7))==abs(Dc_on.frequencies-7));
            ind8 = find(min(abs(Dc_on.frequencies-8))==abs(Dc_on.frequencies-8));
            ind12 = find(min(abs(Dc_on.frequencies-12))==abs(Dc_on.frequencies-12));
            ind13 = find(min(abs(Dc_on.frequencies-13))==abs(Dc_on.frequencies-13));
            ind30 = find(min(abs(Dc_on.frequencies-30))==abs(Dc_on.frequencies-30));
            ind31 = find(min(abs(Dc_on.frequencies-31))==abs(Dc_on.frequencies-31));
            ind48 = find(min(abs(Dc_on.frequencies-48))==abs(Dc_on.frequencies-48));
            ind52 = find(min(abs(Dc_on.frequencies-52))==abs(Dc_on.frequencies-52));
            ind80 = find(min(abs(Dc_on.frequencies-80))==abs(Dc_on.frequencies-80));
    
            [h_theta ,    p_theta]= ttest(mean(D_diff(:,ind4:ind7),2));
            [h_alpha ,    p_alpha]= ttest(mean(D_diff(:,ind8:ind12),2));
            [h_beta ,     p_beta]= ttest(mean(D_diff(:,ind13:ind30),2));
            [h_lowgamma,  p_lowgamma]= ttest(mean(D_diff(:,ind31:ind48),2));
            [h_highgamma, p_highgamma]= ttest(mean(D_diff(:,ind52:ind80),2));
            
    
            D_diff=D_diff(:,1:80);
            SEM = std(D_diff,[],1)/sqrt(size(D_diff,1));     % Standard Error
            ts = tinv([0.025  0.975],size(D_diff,1)-1);      % T-Score
            CI = mean(D_diff,1)+ts'.*SEM;   
    
            figure('units','normalized','outerposition',[0 0 1 1]),
            freqs=Dc_on.frequencies(1:80);
            meanD_diff=mean(D_diff),10;
            x2 = [freqs, fliplr(freqs)];
            inBetween = [CI(1,:), fliplr(CI(2,:))];
            fill(x2, inBetween, 'k', 'FaceAlpha', 0.3, 'LineStyle','none'); % , 'FaceAlpha', 1
            hold on, h1=plot(freqs, meanD_diff, 'k', 'LineWidth', 3);
            hold on, yline(0, 'k--', 'LineWidth', 3)
            sizestar=100;
            size_font=100;
            y1 = ylim;
            hold on, xline(ind4, 'm--', 'LineWidth', 3)
            if h_theta==1 
    %             plot((ind4+ind8)/2, 0.003, 'k*', 'MarkerSize', sizestar), 
                text((ind4+ind8)/2, 0.005, num2str(round(p_theta*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'), 
                a = fill([ind4 ind4 ind8 ind8], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(ind8, 'm--', 'LineWidth', 3)
            if h_alpha==1 
    %             plot((ind8+ind12)/2, 0.003, 'k*', 'MarkerSize', sizestar), 
                text((ind8+ind12)/2, 0.005, num2str(round(p_alpha*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'),
                a = fill([ind8 ind8 ind12 ind12], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(ind12, 'm--', 'LineWidth', 3)
            if h_beta==1 
    %             plot((ind12+ind31)/2, 0.003, 'k*', 'MarkerSize', sizestar), 
                text((ind12+ind31)/2, 0.005, num2str(round(p_beta*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'),
                a = fill([ind12 ind12 ind31 ind31], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(ind31, 'm--', 'LineWidth', 3)
            if h_lowgamma==1 
    %             plot((ind31+ind52)/2, 0.003, 'k*', 'MarkerSize', sizestar),
                text((ind31+ind52)/2, 0.005, num2str(round(p_lowgamma*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'),
                a = fill([ind31 ind31 ind52 ind52], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(ind52, 'm--', 'LineWidth', 3)
            if h_highgamma==1 
    %             plot((ind52+ind80)/2, 0.003, 'k*', 'MarkerSize', sizestar),
                text((ind52+ind80)/2, 0.005, num2str(round(p_highgamma*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'), 
                a = fill([ind52 ind52 ind80 ind80], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
        
    
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('On - Off (95%CI)', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
    %         title([Coh_state, 'Difference',' ', limb_list{limb}],  'FontSize', 10)
            xlim([0 80])
            % figure, shadedErrorBar([],mean(D_diff,1),flipud(CI));
    
            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', Coh_state,  'DifferenceWithInterval','_', condition, limb_list{limb}, '.png'])
    

        end
    else

            D_on_left=squeeze(mean(D_on_left_temp(:,:,:),3));
            D_off_left=squeeze(mean(D_off_left_temp(:,:,:),3));
            D_on_right=squeeze(mean(D_on_right_temp(:,:,:),3));
            D_off_right=squeeze(mean(D_off_right_temp(:,:,:),3));
    
    
            D_off = [D_off_left;D_off_right];
            D_on  = [D_on_left;D_on_right];
    
            figure('units','normalized','outerposition',[0 0 1 1]),
    %         plot(Dc_on.frequencies(1:80), D_on(:, 1:80), 'b--', 'LineWidth', 2)
    %         hold on, plot(Dc_on.frequencies(1:80), D_off(:, 1:80), 'r--', 'LineWidth', 2)
            h1=plot(Dc_on.frequencies(1:80), mean(D_on(:, 1:80)), 'b', 'LineWidth', 8)
            hold on
            h2=plot(Dc_on.frequencies(1:80), mean(D_off(:, 1:80)), 'r--', 'LineWidth', 8)
    
    %         legend([h1, h2],{'on', 'off'})
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('Connectivity', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
    %         title([Coh_state, 'Average',' ', limb_list{limb}],  'FontSize', 50)
            xlim([0 90])
            
            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', Coh_state,  'Average','_', condition '.png'])
    
    
            D_diff=D_on-D_off;
            ind4 = find(min(abs(Dc_on.frequencies-4))==abs(Dc_on.frequencies-4));
            ind7 = find(min(abs(Dc_on.frequencies-7))==abs(Dc_on.frequencies-7));
            ind8 = find(min(abs(Dc_on.frequencies-8))==abs(Dc_on.frequencies-8));
            ind12 = find(min(abs(Dc_on.frequencies-12))==abs(Dc_on.frequencies-12));
            ind13 = find(min(abs(Dc_on.frequencies-13))==abs(Dc_on.frequencies-13));
            ind30 = find(min(abs(Dc_on.frequencies-30))==abs(Dc_on.frequencies-30));
            ind31 = find(min(abs(Dc_on.frequencies-31))==abs(Dc_on.frequencies-31));
            ind48 = find(min(abs(Dc_on.frequencies-48))==abs(Dc_on.frequencies-48));
            ind52 = find(min(abs(Dc_on.frequencies-52))==abs(Dc_on.frequencies-52));
            ind80 = find(min(abs(Dc_on.frequencies-80))==abs(Dc_on.frequencies-80));
    
            [h_theta ,    p_theta]= ttest(mean(D_diff(:,ind4:ind7),2));
            [h_alpha ,    p_alpha]= ttest(mean(D_diff(:,ind8:ind12),2));
            [h_beta ,     p_beta]= ttest(mean(D_diff(:,ind13:ind30),2));
            [h_lowgamma,  p_lowgamma]= ttest(mean(D_diff(:,ind31:ind48),2));
            [h_highgamma, p_highgamma]= ttest(mean(D_diff(:,ind52:ind80),2));
            
    
            D_diff=D_diff(:,1:80);
            SEM = std(D_diff,[],1)/sqrt(size(D_diff,1));     % Standard Error
            ts = tinv([0.025  0.975],size(D_diff,1)-1);      % T-Score
            CI = mean(D_diff,1)+ts'.*SEM;   
    
            figure('units','normalized','outerposition',[0 0 1 1]),
            freqs=Dc_on.frequencies(1:80);
            meanD_diff=mean(D_diff),10;
            x2 = [freqs, fliplr(freqs)];
            inBetween = [CI(1,:), fliplr(CI(2,:))];
            fill(x2, inBetween, 'k', 'FaceAlpha', 0.3, 'LineStyle','none'); % , 'FaceAlpha', 1
            hold on, h1=plot(freqs, meanD_diff, 'k', 'LineWidth', 3);
            hold on, yline(0, 'k--', 'LineWidth', 3)
            sizestar=100;
            size_font=80;
            y1 = ylim;
            hold on, xline(ind4, 'm--', 'LineWidth', 3)
            if h_theta==1 
    %             plot((ind4+ind8)/2, 0.003, 'k*', 'MarkerSize', sizestar), 
                text((ind4+ind8)/2-2, -0.004, num2str(round(p_theta*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'), 
                a = fill([ind4 ind4 ind8 ind8], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(ind8, 'm--', 'LineWidth', 3)
            if h_alpha==1 
    %             plot((ind8+ind12)/2, 0.003, 'k*', 'MarkerSize', sizestar), 
                text((ind8+ind12)/2-2, 0.012, num2str(round(p_alpha*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'),
                a = fill([ind8 ind8 ind12 ind12], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(ind12, 'm--', 'LineWidth', 3)
            if h_beta==1 
    %             plot((ind12+ind31)/2, 0.003, 'k*', 'MarkerSize', sizestar), 
                text((ind12+ind31)/2, 0.004, num2str(round(p_beta*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'),
                a = fill([ind12 ind12 ind31 ind31], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(ind31, 'm--', 'LineWidth', 3)
            if h_lowgamma==1 
    %             plot((ind31+ind52)/2, 0.003, 'k*', 'MarkerSize', sizestar),
                text((ind31+ind52)/2, -0.009, num2str(round(p_lowgamma*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'),
                a = fill([ind31 ind31 ind52 ind52], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(ind52, 'm--', 'LineWidth', 3)
            if h_highgamma==1 
    %             plot((ind52+ind80)/2, 0.003, 'k*', 'MarkerSize', sizestar),
                text((ind52+ind80)/2, 0.004, num2str(round(p_highgamma*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'), 
                a = fill([ind52 ind52 ind80 ind80], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
        
    
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('On - Off (95%CI)', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
    %         title([Coh_state, 'Difference',' ', limb_list{limb}],  'FontSize', 10)
            xlim([0 80])
            % figure, shadedErrorBar([],mean(D_diff,1),flipud(CI));
    
            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', Coh_state,  'DifferenceWithInterval','_', condition, '.png'])
    
        

    end



    
        
end