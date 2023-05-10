function plotBoxplotsAfterPermutation(condition, Coh_state, channs, freq_range)
    close all
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
    ind_off_patient_left={};
    ind_off_patient_right={};

    ind_on_patient_left={};
    ind_on_patient_right={};

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
                ind_off_patient_left{i}=initials{i};

                temp=squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_right(i,:, sub_condition)=mean(temp(EEGchannels, :),1);
                ind_off_patient_right{i}=initials{i};
            else
                temp = squeeze((Dc_off(start_ind:4:end,:,1,Coh_state_num)));
                D_off_right(i,:, sub_condition) = mean(temp(EEGchannels, :),1);
                ind_off_patient_right{i}=initials{i};
                
                temp = squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_left(i,:, sub_condition) = mean(temp(EEGchannels, :),1);
                ind_off_patient_left{i}=initials{i};
                
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp = squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_left(i,:, sub_condition)= mean(temp(EEGchannels, :),1);
                ind_off_patient_left{i}=initials{i};
              
            else
                temp= squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_right(i,:, sub_condition)=  mean(temp(EEGchannels, :),1);
                ind_off_patient_right{i}=initials{i};
                
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
                ind_on_patient_left{i}=initials{i};
                
                temp= squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_right(i,:, sub_condition)= mean(temp(EEGchannels, :),1);
                ind_on_patient_right{i}=initials{i};
            else
                temp =squeeze((Dc_on(start_ind:4:end,:,1,Coh_state_num)));
                D_on_right(i,:, sub_condition) = mean(temp(EEGchannels, :),1);
                ind_on_patient_right{i}=initials{i};
                
                temp=squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_left(i,:, sub_condition)=mean(temp(EEGchannels, :),1);
                ind_on_patient_left{i}=initials{i};
               
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp =squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_left(i,:, sub_condition)=mean(temp(EEGchannels, :),1);
                ind_on_patient_left{i}=initials{i};
                
            else
                temp=squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_right(i,:, sub_condition)=mean(temp(EEGchannels, :),1);
                ind_on_patient_right{i}=initials{i};
                
            end

        end

        catch
            warning(['patient ', initials{i}, ' On stim does not have', condition])
        end

        

     end
    end

 
    

    for kk=size(D_on_left,1):-1:1
        if numel(find(D_on_left(kk,:, :)==0))==numel(D_on_left(1,:,:)) || numel(find(D_off_left(kk,:,:)==0))==numel(D_off_left(1,:,:))
            
            D_on_left(kk,:,:)=[];
            ind_on_patient_left(kk)=[];
            D_off_left(kk,:,:)=[];
            ind_off_patient_left(kk)=[];
        end

        if numel(find(D_on_right(kk,:,:)==0))==numel(D_on_right(1,:,:)) || numel(find(D_off_right(kk,:,:)==0))==numel(D_off_right(1,:,:))

            D_on_right(kk,:,:)=[];
            ind_on_patient_right(kk)=[];
            D_off_right(kk,:,:)=[];
            ind_off_patient_right(kk)=[];
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
    
            indmin = find(min(abs(Dc_on.frequencies-freq_range(1)))==abs(Dc_on.frequencies-freq_range(1)));
            indmax = find(min(abs(Dc_on.frequencies-freq_range(2)))==abs(Dc_on.frequencies-freq_range(2)));

            D_diff=D_on-D_off;
            D_diff=mean(D_diff(:,indmin:indmax),2);

            D_diff_left=D_on_left-D_off_left;
            D_diff_left=mean(D_diff_left(:,indmin:indmax),2);

            D_diff_right=D_on_right-D_off_right;
            D_diff_right=mean(D_diff_right(:,indmin:indmax),2);


           
            figure('units','normalized','outerposition',[0 0 1 1]),

            k1=size(D_diff,1);
            boxchart(ones(k1,1), D_diff, 'LineWidth', 8)
            hold on, plot([ones(k1,1)-0.3],D_diff', 'ko', 'MarkerSize', 25, 'LineWidth', 8,'HandleVisibility','off')
            

            for i=1:size(ind_off_patient_left,2)
                ind_left{i}=ind_off_patient_left{i}(7:10);
            end
            k2=size(D_diff_left,1);
            boxchart(2*ones(k2,1), D_diff_left, 'LineWidth', 8)
            hold on, plot([2*ones(k2,1)-0.3],D_diff_left', 'ko', 'MarkerSize', 25, 'LineWidth', 8,'HandleVisibility','off')
            text(2*ones(k2,1)-0.5, D_diff_left, ind_left, 'FontWeight', 'bold', 'FontSize', 20)


            for i=1:size(ind_off_patient_right,2)
                ind_right{i}=ind_off_patient_right{i}(7:10);
            end
            k3=size(D_diff_right,1);
            boxchart(3*ones(k3,1), D_diff_right, 'LineWidth', 8)
            hold on, plot([3*ones(k3,1)-0.3],D_diff_right', 'ko', 'MarkerSize', 25, 'LineWidth', 8,'HandleVisibility','off')
            text(3*ones(k3,1)-0.5, D_diff_right,ind_right, 'FontWeight', 'bold', 'FontSize', 20)


            legend({'Both sides', 'Left', 'Right', ''}, 'FontSize', 25)
            yline(0,'--', 'LineWidth', 8,'HandleVisibility','off')
            xticklabels({''})
            xlabel(['frequency band:', num2str(freq_range(1)), '-',num2str(freq_range(2)), 'Hz'], 'FontSize', 30, 'FontWeight','bold')
            ylabel([Coh_state, ' On-Off'], 'FontSize', 30, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',20,'FontWeight','bold')
    
            spm_mkdir(['D:\dystonia project\IamBrain\permutationstats']);
            saveas(gcf, ['D:\dystonia project\IamBrain\permutationstats\', Coh_state,  'barplotdifference','_', condition, limb_list{limb}, '.png'])
    

        end
    else

            D_on_left=squeeze(mean(D_on_left_temp(:,:,:),3));
            D_off_left=squeeze(mean(D_off_left_temp(:,:,:),3));
            D_on_right=squeeze(mean(D_on_right_temp(:,:,:),3));
            D_off_right=squeeze(mean(D_off_right_temp(:,:,:),3));
    
    
            D_off = [D_off_left;D_off_right];
            D_on  = [D_on_left;D_on_right];

            


    
           

            
            indmin = find(min(abs(Dc_on.frequencies-freq_range(1)))==abs(Dc_on.frequencies-freq_range(1)));
            indmax = find(min(abs(Dc_on.frequencies-freq_range(2)))==abs(Dc_on.frequencies-freq_range(2)));

            D_diff=D_on-D_off;
            D_diff=mean(D_diff(:,indmin:indmax),2);

            D_diff_left=D_on_left-D_off_left;
            D_diff_left=mean(D_diff_left(:,indmin:indmax),2);

            D_diff_right=D_on_right-D_off_right;
            D_diff_right=mean(D_diff_right(:,indmin:indmax),2);


           
            figure('units','normalized','outerposition',[0 0 1 1]),

            k1=size(D_diff,1);
            boxchart(ones(k1,1), D_diff, 'LineWidth', 8)
            hold on, plot([ones(k1,1)-0.3],D_diff', 'ko', 'MarkerSize', 25, 'LineWidth', 8,'HandleVisibility','off')
            

            for i=1:size(ind_off_patient_left,2)
                ind_left{i}=ind_off_patient_left{i}(7:10);
            end
            k2=size(D_diff_left,1);
            boxchart(2*ones(k2,1), D_diff_left, 'LineWidth', 8)
            hold on, plot([2*ones(k2,1)-0.3],D_diff_left', 'ko', 'MarkerSize', 25, 'LineWidth', 8,'HandleVisibility','off')
            text(2*ones(k2,1)-0.5, D_diff_left, ind_left, 'FontWeight', 'bold', 'FontSize', 20)


            for i=1:size(ind_off_patient_right,2)
                ind_right{i}=ind_off_patient_right{i}(7:10);
            end
            k3=size(D_diff_right,1);
            boxchart(3*ones(k3,1), D_diff_right, 'LineWidth', 8)
            hold on, plot([3*ones(k3,1)-0.3],D_diff_right', 'ko', 'MarkerSize', 25, 'LineWidth', 8,'HandleVisibility','off')
            text(3*ones(k3,1)-0.5, D_diff_right,ind_right, 'FontWeight', 'bold', 'FontSize', 20)


            legend({'Both sides', 'Left', 'Right'}, 'FontSize', 25)
            yline(0,'--', 'LineWidth', 8,'HandleVisibility','off')
            xticklabels({''})
            xlabel(['frequency band:', num2str(freq_range(1)), '-',num2str(freq_range(2)), 'Hz'], 'FontSize', 30, 'FontWeight','bold')
            ylabel([Coh_state, ' On-Off'], 'FontSize', 30, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
     
            


      
    
            spm_mkdir(['D:\dystonia project\IamBrain\permutationstats']);
            saveas(gcf, ['D:\dystonia project\IamBrain\permutationstats\', Coh_state,  'barplotdifference','_', condition '.png'])
    
    
        

    end



    
        
