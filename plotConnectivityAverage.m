function ind_patient=plotConnectivityAverage(condition, Coh_state)

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
        EEGchannels=[Dchan.indchannel('C3') Dchan.indchannel('C4')];

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
                D_off_left(i,:)=mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp=squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_right(i,:)=mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp = squeeze((Dc_off(start_ind:4:end,:,1,Coh_state_num)));
                D_off_right(i,:) = mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp = squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_left(i,:) = mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp = squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_left(i,:)= mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp= squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_right(i,:)=  mean(temp(EEGchannels, :),1);
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
                D_on_left(i,:) = mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp= squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_right(i,:)= mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp =squeeze((Dc_on(start_ind:4:end,:,1,Coh_state_num)));
                D_on_right(i,:) = mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp=squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_left(i,:)=mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp =squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_left(i,:)=mean(temp(EEGchannels, :),1);
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp=squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_right(i,:)=mean(temp(EEGchannels, :),1);
                [~,ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        end

        catch
            warning(['patient ', initials{i}, ' On stim does not have', condition])
        end

       ind_patient{i}=ind;
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

        
     

     
            %% Left
            figure('units','normalized','outerposition',[0 0 1 1]),
            plot(Dc_on.frequencies, D_on_left, 'b--', 'LineWidth', 2)
            hold on, plot(Dc_on.frequencies, D_off_left, 'r--', 'LineWidth', 2)
            h1=plot(Dc_on.frequencies, mean(D_on_left), 'b', 'LineWidth', 5)
            h2=plot(Dc_on.frequencies, mean(D_off_left), 'r', 'LineWidth', 5)

            legend([h1, h2],{'on', 'off'})
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('Connectivity', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            title(['Left ', Coh_state, condition, ' ', subcondition],  'FontSize', 50)
            
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', Coh_state, '_LeftGPi_', condition,  '_', subcondition, '.png'])
        

            %% Right
            figure('units','normalized','outerposition',[0 0 1 1]),
            plot(Dc_on.frequencies, D_on_right, 'b--', 'LineWidth', 2)
            hold on, plot(Dc_on.frequencies, D_off_right, 'r--', 'LineWidth', 2)
            h1=plot(Dc_on.frequencies, mean(D_on_right), 'b', 'LineWidth', 5)
            h2=plot(Dc_on.frequencies, mean(D_off_right), 'r', 'LineWidth', 5)

            legend([h1, h2],{'on', 'off'})
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('Connectivity', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            title(['Right ',Coh_state, condition, ' ', subcondition],  'FontSize', 50)
            
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', Coh_state, '_RightGPi_', condition,  '_', subcondition, '.png'])
        

            %% Both

            D_off = [D_off_left;D_off_right];
            D_on  = [D_on_left;D_on_right];

            figure('units','normalized','outerposition',[0 0 1 1]),
            plot(Dc_on.frequencies, D_on, 'b--', 'LineWidth', 2)
            hold on, plot(Dc_on.frequencies, D_off, 'r--', 'LineWidth', 2)
            h1=plot(Dc_on.frequencies, mean(D_on), 'b', 'LineWidth', 5)
            h2=plot(Dc_on.frequencies, mean(D_off), 'r', 'LineWidth', 5)

            legend([h1, h2],{'on', 'off'})
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('Connectivity', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            title(['Both ', Coh_state, condition, ' ', subcondition],  'FontSize', 50)
            
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', Coh_state, '_bothGPi_', condition,  '_', subcondition, '.png'])
        

    




    end
        
end