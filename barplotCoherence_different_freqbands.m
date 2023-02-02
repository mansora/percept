function barplotCoherence_different_freqbands(condition)

    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};

     [files_, seq, root, details] = dbs_subjects(initials{1}, 1);
     cd(fullfile(root, condition));

    try
        files = spm_select('FPList','.', ['^.' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials{1} '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    
    D = spm_eeg_load(files);


     for i=1:numel(initials)
        

       
        sub_condition=5;
        subcondition =D.condlist{sub_condition};% 'foot_L_up';
    
        [files_, seq, root, details] = dbs_subjects(initials{i}, 1);
        cd(fullfile(root, condition));
    
        files = spm_select('FPList','.', ['C_', condition, '_', subcondition, '.', initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', condition, '_', subcondition, initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
        end
        try
        Dc_off=spm_eeg_load(files);
        D_off(i,:)=squeeze(mean(Dc_off(:,:,1,11),1));
        catch
        end
    
        [files_, seq, root, details] = dbs_subjects(initials{i}, 2);
        cd(fullfile(root, condition));

        files = spm_select('FPList','.', ['C_', condition, '_', subcondition, '.', initials{i} '_rec_' num2str(2) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', condition, '_', subcondition, initials{i} '_rec_' num2str(2) '_' condition '\w*.mat']);
        end
        try
        Dc_on=spm_eeg_load(files);
        D_on(i,:)=squeeze(mean(Dc_on(:,:,1,11),1));
        catch
        end

       
     end

     D_on(3,:)=[];
     D_off(3,:)=[];


%      D_on=mean(D_on,2);
%      D_off=mean(D_off,2);

     theta     = mean(D_off(:,4:7),2);
     alpha     = mean(D_off(:,8:12),2);
     beta      = mean(D_off(:,13:30),2);
     lowgamma  = mean(D_off(:,31:48),2);
     highgamma = mean(D_off(:,52:90),2);

     datapoints_D_off=[theta', alpha', beta', lowgamma', highgamma'];

     theta     = mean(D_on(:,4:7),2);
     alpha     = mean(D_on(:,8:12),2);
     beta      = mean(D_on(:,13:30),2);
     lowgamma  = mean(D_on(:,31:48),2);
     highgamma = mean(D_on(:,52:90),2);

     datapoints_D_on=[theta', alpha', beta', lowgamma', highgamma'];
  

     n=6;
     k=5;
     cgroupdata=[ones(1,n*k), zeros(1,n*k)];
     x1=repmat(1:k,n,1)-0.4;
     x2=repmat(1:k,n,1)+0.4;
     figure('units','normalized','outerposition',[0 0 1 1]),
     boxchart([x1(:);x2(:)], [datapoints_D_off, datapoints_D_on], 'GroupByColor',cgroupdata, 'BoxWidth', 0.5, 'LineWidth', 3)
     legend({'on', 'off'})
     xticklabels({'', 'theta','alpha','beta','lowgamma','highgamma'})
     xlabel('frequency bands', 'FontSize', 20, 'FontWeight','bold')
     ylabel('Coherence', 'FontSize', 20, 'FontWeight','bold')
     a = get(gca,'XTickLabel');  
     set(gca,'linewidth',5)
     set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')

disp(i)
            
        
end