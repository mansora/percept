function ind_patient=plotConnectivityAfterPermutation(condition, Coh_state, channs, freq_range)
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
%         EEGchannels=[Dchan.indchannel('C4') Dchan.indchannel('C4') Dchan.indchannel('Cz')];
%         EEGchannels=[Dchan.indchannel('PO3') Dchan.indchannel('PO4') Dchan.indchannel('Oz')];
%         EEGchannels=[2,3, 10,15, 16, 17, 20, 22, 30, 34, 35, 39, 45, 46, 47, 49, 50, 51, 55, 58, 62, 63, 64];
        EEGchannels=channs;

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


    if find(strcmp({'ACTx','PMTx'},condition))


        limb_list={'hand', 'foot'};
        for limb=1:2
    
            D_on_left=squeeze(mean(D_on_left_temp(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D_off_left=squeeze(mean(D_off_left_temp(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D_on_right=squeeze(mean(D_on_right_temp(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D_off_right=squeeze(mean(D_off_right_temp(:,:,1+4*(limb-1):4+4*(limb-1)),3));

             % left movement
            D_on_left   =squeeze(mean(D_on_left_temp(:,:,1+4*(limb-1):4+4*(limb-1)-2,:),3));
            D_off_left  =squeeze(mean(D_off_left_temp(:,:,1+4*(limb-1):4+4*(limb-1)-2,:),3));
            D_on_right  =squeeze(mean(D_on_right_temp(:,:,1+4*(limb-1):4+4*(limb-1)-2,:),3));
            D_off_right =squeeze(mean(D_off_right_temp(:,:,1+4*(limb-1):4+4*(limb-1)-2,:),3));   

%             % right movement
%             D_on_left   =squeeze(mean(D_on_left_temp(:,:,1+4*(limb-1)+2:4+4*(limb-1)-2,:),3));
%             D_off_left  =squeeze(mean(D_off_left_temp(:,:,1+4*(limb-1)+2:4+4*(limb-1)-2,:),3));
%             D_on_right  =squeeze(mean(D_on_right_temp(:,:,1+4*(limb-1)+2:4+4*(limb-1)-2,:),3));
%             D_off_right =squeeze(mean(D_off_right_temp(:,:,1+4*(limb-1)+2:4+4*(limb-1)-2,:),3));   
 
        
    
            %% Both
    
            D_off = [D_off_left;D_off_right];
            D_on  = [D_on_left;D_on_right];
    
            D_diff=D_on-D_off;
            indmin = find(min(abs(Dc_on.frequencies-freq_range(1)))==abs(Dc_on.frequencies-freq_range(1)));
            indmax = find(min(abs(Dc_on.frequencies-freq_range(2)))==abs(Dc_on.frequencies-freq_range(2)));
    
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
            hold on, h1=plot(freqs, meanD_diff, 'k', 'LineWidth', 10);
            hold on, yline(0, 'k--', 'LineWidth', 5)
            sizestar=40;
            size_font=100;
            y1 = ylim;
            LiWidthMlines=10;
%             hold on, xline(indmin, 'm--', 'LineWidth', LiWidthMlines)
%             xline(indmax, 'm--', 'LineWidth', LiWidthMlines)
%             a = fill([indmin indmin indmax indmax], [y1(1) y1(2) y1(2) y1(1)], 'm');
%             a.FaceAlpha = 0.1;
%             a.EdgeColor='none';
           
        
    
            box off
%             axis off
            xlabel('frequency', 'FontSize', 40, 'FontWeight','bold')
            ylabel('On - Off (95%CI)', 'FontSize', 40, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',20,'FontWeight','bold')
    %         title([Coh_state, 'Difference',' ', limb_list{limb}],  'FontSize', 10)
            xlim([7 80])
            % figure, shadedErrorBar([],mean(D_diff,1),flipud(CI));
    
            spm_mkdir(['D:\dystonia project\IamBrain\permutationstats']);
            saveas(gcf, ['D:\dystonia project\IamBrain\permutationstats\', Coh_state,  'DifferenceWithInterval','_', condition, limb_list{limb}, '.png'])
    

        end
    else

            D_on_left=squeeze(mean(D_on_left_temp(:,:,:),3));
            D_off_left=squeeze(mean(D_off_left_temp(:,:,:),3));
            D_on_right=squeeze(mean(D_on_right_temp(:,:,:),3));
            D_off_right=squeeze(mean(D_off_right_temp(:,:,:),3));
    
    
            D_off = [D_off_left;D_off_right];
            D_on  = [D_on_left;D_on_right];
    
           

            D_diff=D_on-D_off;
            indmin = find(min(abs(Dc_on.frequencies-freq_range(1)))==abs(Dc_on.frequencies-freq_range(1)));
            indmax = find(min(abs(Dc_on.frequencies-freq_range(2)))==abs(Dc_on.frequencies-freq_range(2)));

            
            

            
          
    
            
    
        
    
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
            hold on, h1=plot(freqs, meanD_diff, 'k', 'LineWidth', 10);
            hold on, yline(0, 'k--', 'LineWidth', 5)
            sizestar=40;
            size_font=80;
            y1 = ylim;
            LiWidthMlines=10;
%             hold on, xline(indmin, 'm--', 'LineWidth', LiWidthMlines)
%             hold on, xline(indmax, 'm--', 'LineWidth', LiWidthMlines)
%             a = fill([indmin indmin indmax indmax], [y1(1) y1(2) y1(2) y1(1)], 'm');
%             a.FaceAlpha = 0.1;
%             a.EdgeColor='none';
           


        
    
            box off
%             axis off
            xlabel('frequency', 'FontSize', 40, 'FontWeight','bold')
            ylabel('On - Off (95%CI)', 'FontSize', 40, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',20,'FontWeight','bold')
    %         title([Coh_state, 'Difference',' ', limb_list{limb}],  'FontSize', 10)
            xlim([7 80])
            % figure, shadedErrorBar([],mean(D_diff,1),flipud(CI));
    
            spm_mkdir(['D:\dystonia project\IamBrain\permutationstats']);
            saveas(gcf, ['D:\dystonia project\IamBrain\permutationstats\', Coh_state,  'Average','_', condition '.png'])
    
    
        

    end



    
        
