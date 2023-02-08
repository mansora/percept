function barplotCoherence_different_freqbands(condition, Coh_state)

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
        

       
        
    
        [files_, seq, root, details] = dbs_subjects(initials{i}, 1);
        cd(fullfile(root, condition));


         try
            files = spm_select('FPList','.', ['^.' initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
        catch
            files = spm_select('FPList','.', ['regexp_.*c|.*' initials{i} '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
        end
        
        if isempty(files)
            files = spm_select('FPList','.', ['^' initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
        end
        
        Dchan = spm_eeg_load(files);
        lfpchan=Dchan.indchantype('LFP');
    
        files = spm_select('FPList','.', ['C_', condition, '_', subcondition, '.', initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', condition, '_', subcondition, initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
        end
        try
        Dc_off=spm_eeg_load(files);

        if numel(lfpchan)>1
            if strcmp(Dchan.chanlabels{lfpchan(2)}(end-3),'L')
                D_off_left(i,:)=squeeze(mean(Dc_off(start_ind:4:end,:,1,Coh_state_num),1));
                D_off_right(i,:)=squeeze(mean(Dc_off(start_ind+2:4:end,:,1,Coh_state_num),1));
            else
                D_off_right(i,:)=squeeze(mean(Dc_off(start_ind:4:end,:,1,Coh_state_num),1));
                D_off_left(i,:)=squeeze(mean(Dc_off(start_ind+2:4:end,:,1,Coh_state_num),1));
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                D_off_left(i,:)=squeeze(mean(Dc_off(start_ind:2:end,:,1,Coh_state_num),1));
            else
                D_off_right(i,:)=squeeze(mean(Dc_off(start_ind:2:end,:,1,Coh_state_num),1));
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
                D_on_left(i,:)=squeeze(mean(Dc_on(start_ind:4:end,:,1,Coh_state_num),1));
                D_on_right(i,:)=squeeze(mean(Dc_on(start_ind+2:4:end,:,1,Coh_state_num),1));
            else
                D_on_right(i,:)=squeeze(mean(Dc_on(start_ind:4:end,:,1,Coh_state_num),1));
                D_on_left(i,:)=squeeze(mean(Dc_on(start_ind+2:4:end,:,1,Coh_state_num),1));
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                D_on_left(i,:)=squeeze(mean(Dc_on(start_ind:2:end,:,1,Coh_state_num),1));
            else
                D_on_right(i,:)=squeeze(mean(Dc_on(start_ind:2:end,:,1,Coh_state_num),1));
            end

        end

        catch
            warning(['patient ', initials{i}, ' On stim does not have', condition])
        end

       
     end


 
    for kk=size(D_on_left,1):-1:1
        if numel(find(D_on_left(kk,:)==0))==size(D_on_left,2) || numel(find(D_off_left(kk,:)==0))==size(D_off_left,2)
            D_on_left(kk,:)=[];
            D_off_left(kk,:)=[];
        end

        if numel(find(D_on_right(kk,:)==0))==size(D_on_right,2) || numel(find(D_off_right(kk,:)==0))==size(D_off_right,2)
            D_on_right(kk,:)=[];
            D_off_right(kk,:)=[];
        end
    end

        
     ind4 = find(min(abs(Dc_off.frequencies-4))==abs(Dc_off.frequencies-4));
     ind7 = find(min(abs(Dc_off.frequencies-7))==abs(Dc_off.frequencies-7));
     ind8 = find(min(abs(Dc_off.frequencies-8))==abs(Dc_off.frequencies-8));
     ind12 = find(min(abs(Dc_off.frequencies-12))==abs(Dc_off.frequencies-12));
     ind13 = find(min(abs(Dc_off.frequencies-13))==abs(Dc_off.frequencies-13));
     ind30 = find(min(abs(Dc_off.frequencies-30))==abs(Dc_off.frequencies-30));
     ind31 = find(min(abs(Dc_off.frequencies-31))==abs(Dc_off.frequencies-31));
     ind48 = find(min(abs(Dc_off.frequencies-48))==abs(Dc_off.frequencies-48));
     ind52 = find(min(abs(Dc_off.frequencies-52))==abs(Dc_off.frequencies-52));
     ind90 = find(min(abs(Dc_off.frequencies-90))==abs(Dc_off.frequencies-90));

     %% LEFT
     theta     = mean(D_off_left(:,ind4:ind7),2);
     alpha     = mean(D_off_left(:,ind8:ind12),2);
     beta      = mean(D_off_left(:,ind13:ind30),2);
     lowgamma  = mean(D_off_left(:,ind31:ind48),2);
     highgamma = mean(D_off_left(:,ind52:ind90),2);

     datapoints_D_off=[theta', alpha', beta', lowgamma', highgamma'];

     theta     = mean(D_on_left(:,ind4:ind7),2);
     alpha     = mean(D_on_left(:,ind8:ind12),2);
     beta      = mean(D_on_left(:,ind13:ind30),2);
     lowgamma  = mean(D_on_left(:,ind31:ind48),2);
     highgamma = mean(D_on_left(:,ind52:ind90),2);

     datapoints_D_on=[theta', alpha', beta', lowgamma', highgamma'];
  

     n=size(D_on_left,1);
     k=5;
     cgroupdata=[ones(1,n*k), zeros(1,n*k)];
     x1=repmat(1:k,n,1)-0.4;
     x2=repmat(1:k,n,1)+0.4;
     figure('units','normalized','outerposition',[0 0 1 1]),
     boxchart([x1(:);x2(:)], [datapoints_D_off, datapoints_D_on], 'GroupByColor',cgroupdata, 'BoxWidth', 0.5, 'LineWidth', 8)
     legend({'. On .', '. Off .'}, 'FontSize', 50)
     xticklabels({'', 'theta','alpha','beta','lowgamma','highgamma'})
     xlabel('frequency bands', 'FontSize', 50, 'FontWeight','bold')
     ylabel('Coherence', 'FontSize', 50, 'FontWeight','bold')
     a = get(gca,'XTickLabel');  
     set(gca,'linewidth',8)
     set(gca,'XTickLabel',a,'fontsize',30,'FontWeight','bold')
     title([Coh_state, ' LEFT ', condition,  ' ', subcondition], 'FontSize', 50)

     spm_mkdir(['D:\home\results Percept Project\Summary']);
     saveas(gcf, ['D:\home\results Percept Project\Summary\', 'barplotCoherence_', Coh_state, '_LEFT_', condition,  '_', subcondition, '.png'])


     %% RIGHT

     theta     = mean(D_off_right(:,ind4:ind7),2);
     alpha     = mean(D_off_right(:,ind8:ind12),2);
     beta      = mean(D_off_right(:,ind13:ind30),2);
     lowgamma  = mean(D_off_right(:,ind31:ind48),2);
     highgamma = mean(D_off_right(:,ind52:ind90),2);

     datapoints_D_off=[theta', alpha', beta', lowgamma', highgamma'];

     theta     = mean(D_on_right(:,ind4:ind7),2);
     alpha     = mean(D_on_right(:,ind8:ind12),2);
     beta      = mean(D_on_right(:,ind13:ind30),2);
     lowgamma  = mean(D_on_right(:,ind31:ind48),2);
     highgamma = mean(D_on_right(:,ind52:ind90),2);

     datapoints_D_on=[theta', alpha', beta', lowgamma', highgamma'];
  

     n=size(D_on_right,1);
     k=5;
     cgroupdata=[ones(1,n*k), zeros(1,n*k)];
     x1=repmat(1:k,n,1)-0.4;
     x2=repmat(1:k,n,1)+0.4;
     figure('units','normalized','outerposition',[0 0 1 1]),
     boxchart([x1(:);x2(:)], [datapoints_D_off, datapoints_D_on], 'GroupByColor',cgroupdata, 'BoxWidth', 0.5, 'LineWidth', 8)
     legend({'. On .', '. Off .'}, 'FontSize', 50)
     xticklabels({'', 'theta','alpha','beta','lowgamma','highgamma'})
     xlabel('frequency bands', 'FontSize', 50, 'FontWeight','bold')
     ylabel('Coherence', 'FontSize', 50, 'FontWeight','bold')
     a = get(gca,'XTickLabel');  
     set(gca,'linewidth',8)
     set(gca,'XTickLabel',a,'fontsize',30,'FontWeight','bold')
     title([Coh_state, ' RIGHT ', condition,  ' ', subcondition], 'FontSize', 50)

     spm_mkdir(['D:\home\results Percept Project\Summary']);
     saveas(gcf, ['D:\home\results Percept Project\Summary\', 'barplotCoherence_', Coh_state, '_RIGHT_', condition,  '_', subcondition, '.png'])

    
     %% BOTH

     D_off = [D_off_left;D_off_right];
     D_on  = [D_on_left;D_on_right];

     theta     = mean(D_off(:,ind4:ind7),2);
     alpha     = mean(D_off(:,ind8:ind12),2);
     beta      = mean(D_off(:,ind13:ind30),2);
     lowgamma  = mean(D_off(:,ind31:ind48),2);
     highgamma = mean(D_off(:,ind52:ind90),2);

     datapoints_D_off=[theta', alpha', beta', lowgamma', highgamma'];

     theta     = mean(D_on(:,ind4:ind7),2);
     alpha     = mean(D_on(:,ind8:ind12),2);
     beta      = mean(D_on(:,ind13:ind30),2);
     lowgamma  = mean(D_on(:,ind31:ind48),2);
     highgamma = mean(D_on(:,ind52:ind90),2);

     datapoints_D_on=[theta', alpha', beta', lowgamma', highgamma'];
  

     n=size(D_on,1);
     k=5;
     cgroupdata=[ones(1,n*k), zeros(1,n*k)];
     x1=repmat(1:k,n,1)-0.4;
     x2=repmat(1:k,n,1)+0.4;
     figure('units','normalized','outerposition',[0 0 1 1]),
     boxchart([x1(:);x2(:)], [datapoints_D_off, datapoints_D_on], 'GroupByColor',cgroupdata, 'BoxWidth', 0.5, 'LineWidth', 8)
     legend({'. On .', '. Off .'}, 'FontSize', 50)
     xticklabels({'', 'theta','alpha','beta','lowgamma','highgamma'})
     xlabel('frequency bands', 'FontSize', 50, 'FontWeight','bold')
     ylabel('Coherence', 'FontSize', 50, 'FontWeight','bold')
     a = get(gca,'XTickLabel');  
     set(gca,'linewidth',8)
     set(gca,'XTickLabel',a,'fontsize',30,'FontWeight','bold')
     title([Coh_state, ' BOTH ', condition,  ' ', subcondition], 'FontSize', 50)

     spm_mkdir(['D:\home\results Percept Project\Summary']);
     saveas(gcf, ['D:\home\results Percept Project\Summary\', 'barplotCoherence_', Coh_state, '_BOTH_', condition,  '_', subcondition , '.png'])





    end
        
end