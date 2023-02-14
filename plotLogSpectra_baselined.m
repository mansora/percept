function plotLogSpectra_baselined(condition)
     close all
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};

    for i=1:numel(initials)
        try

        [files_, seq, root, details] = dbs_subjects_percept(initials{i}, 1);
        cd(fullfile(root, condition));
        
        files = spm_select('FPList','.', ['LFP_spect_', '.', initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['LFP_spect_', initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
        end
       
        D1_LFP_temp = spm_eeg_load(files);
        lfpchan = D1_LFP_temp.indchantype('LFP');
       

        files = spm_select('FPList','.', ['EEG_spect_', '.', initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['EEG_spect_', initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
        end

        D1_EEG_temp = spm_eeg_load(files);
        catch
            warning(['patient ', initials{i}, ' Off stim does not have', condition])
        end

        if ~strcmp(condition, 'R')
            cd(fullfile(root, 'R'));
            files = spm_select('FPList','.', ['LFP_spect_', '.', initials{i} '_rec_' num2str(1) '_R_[0-9]*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['LFP_spect_', initials{i} '_rec_' num2str(1) '_R_[0-9]*.mat']);
            end
            D1_LFP_baseline = spm_eeg_load(files);
            D1_LFP_baseline=squeeze(D1_LFP_baseline(:,:,1,:));
        else
            D1_LFP_baseline=ones(2,97);
        end

        try
    
        [files_, seq, root, details] = dbs_subjects_percept(initials{i}, 2);
        cd(fullfile(root, condition));

        files = spm_select('FPList','.', ['LFP_spect_', '.', initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['LFP_spect_', initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        end
        D2_LFP_temp = spm_eeg_load(files);
        lfpchan = D1_LFP_temp.indchantype('LFP');
        
        
        
        files = spm_select('FPList','.', ['EEG_spect_', '.', initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['EEG_spect_', initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        end
        D2_EEG_temp = spm_eeg_load(files);

        catch
            warning(['patient ', initials{i}, ' On stim does not have', condition])
        end

        if ~strcmp(condition, 'R')
            cd(fullfile(root, 'R'));
            files = spm_select('FPList','.', ['LFP_spect_', '.', initials{i} '_rec_' num2str(2) '_R_[0-9]*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['LFP_spect_', initials{i} '_rec_' num2str(2) '_R_[0-9]*.mat']);
            end
            D2_LFP_baseline = spm_eeg_load(files);
            D2_LFP_baseline=squeeze(D2_LFP_baseline(:,:,1,:));
        else
            D2_LFP_baseline=ones(2,97);
        end
        
        

        for condz=1:numel(D1_LFP_temp.conditions)
        %% 

        if strcmp(D1_LFP_temp.chanlabels{lfpchan(1)}(end-3),'L')
            D1_LFP_1_all(i,:, condz)=log(squeeze(D1_LFP_temp(1,:,1,condz))) - log(D1_LFP_baseline(1,:));
        else
            D1_LFP_2_all(i,:, condz)=log(squeeze(D1_LFP_temp(1,:,1,condz))) - log(D1_LFP_baseline(1,:));
        end
        if numel(lfpchan)>1
            if strcmp(D1_LFP_temp.chanlabels{lfpchan(2)}(end-3),'L')
                D1_LFP_1_all(i,:, condz)=log(squeeze(D1_LFP_temp(2,:,1,condz))) - log(D1_LFP_baseline(2,:));
            else
                D1_LFP_2_all(i,:, condz)=log(squeeze(D1_LFP_temp(2,:,1,condz))) - log(D1_LFP_baseline(2,:));
            end
        end
    
        %         EEGchannels=D1_EEG_temp.indchantype('EEG');
        EEGchannels=[D1_EEG_temp.indchannel('C3') D1_EEG_temp.indchannel('C4')];
        D1_EEG_all(i,:, condz)=mean(squeeze(D1_EEG_temp(EEGchannels,:,1,condz)),1);


        if strcmp(D2_LFP_temp.chanlabels{lfpchan(1)}(end-3),'L')
            D2_LFP_1_all(i,:, condz)=log(squeeze(D2_LFP_temp(1,:,1,condz))) - log(D2_LFP_baseline(1,:));
        else
            D2_LFP_2_all(i,:, condz)=log(squeeze(D2_LFP_temp(1,:,1,condz))) - log(D2_LFP_baseline(1,:));
        end
        if numel(lfpchan)>1
            if strcmp(D2_LFP_temp.chanlabels{lfpchan(2)}(end-3),'L')
                D2_LFP_1_all(i,:, condz)=log(squeeze(D2_LFP_temp(2,:,1,condz))) - log(D2_LFP_baseline(2,:));
            else
                D2_LFP_2_all(i,:, condz)=log(squeeze(D2_LFP_temp(2,:,1,condz))) - log(D2_LFP_baseline(2,:));
            end
        end

        %         EEGchannels=D2_EEG_temp.indchantype('EEG');
        EEGchannels=[D2_EEG_temp.indchannel('C3') D2_EEG_temp.indchannel('C4')];
        D2_EEG_all(i,:, condz)=mean(squeeze(D2_EEG_temp(EEGchannels,:,1,condz)),1);


       
        end
        
    end

    limit_=15;
    limit_LFP=1.5;


    for kk=size(D1_EEG_all,1):-1:1
        if numel(find(D1_EEG_all(kk,:,1)==0))==size(D1_EEG_all,2) || numel(find(D2_EEG_all(kk,:,1)==0))==size(D2_EEG_all,2) 
            D1_EEG_all(kk,:,:)=[];
            D2_EEG_all(kk,:,:)=[];
        end
    end

    for kk=size(D1_LFP_1_all,1):-1:1
        % left side
        if numel(find(D1_LFP_1_all(kk,:,1)==0))==size(D1_LFP_1_all,2) || numel(find(D2_LFP_1_all(kk,:,1)==0))==size(D2_LFP_1_all,2) 
            D1_LFP_1_all(kk,:,:)=[];
            D2_LFP_1_all(kk,:,:)=[];
        end

        % right side
        if numel(find(D1_LFP_2_all(kk,:,1)==0))==size(D1_LFP_2_all,2) || numel(find(D2_LFP_2_all(kk,:,1)==0))==size(D2_LFP_2_all,2) 
            D1_LFP_2_all(kk,:,:)=[];
            D2_LFP_2_all(kk,:,:)=[];
        end


    end





        for condz=1:numel(D1_LFP_temp.conditions)
            
            D1_LFP_1=squeeze(D1_LFP_1_all(:,:,condz));
            D1_LFP_2=squeeze(D1_LFP_2_all(:,:,condz));
            D2_LFP_1=squeeze(D2_LFP_1_all(:,:,condz));
            D2_LFP_2=squeeze(D2_LFP_2_all(:,:,condz));
            D1_EEG=squeeze(D1_EEG_all(:,:,condz));
            D2_EEG=squeeze(D2_EEG_all(:,:,condz));


            %% EEG
            figure('units','normalized','outerposition',[0 0 1 1]),
            plot(D1_EEG_temp.frequencies, D2_EEG, 'b--', 'LineWidth', 2)
            hold on, plot(D1_EEG_temp.frequencies, D1_EEG, 'r--', 'LineWidth', 2)
            h1=plot(D1_EEG_temp.frequencies, mean(D2_EEG), 'b', 'LineWidth', 5)
            h2=plot(D1_EEG_temp.frequencies, mean(D1_EEG), 'r', 'LineWidth', 5)

            legend([h1, h2],{'on', 'off'})
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('EEG', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            title(['EEG ', condition, ' ', D1_EEG_temp.conditions{condz}],  'FontSize', 50)
            
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', 'LogSpectraBaselined_EEG_', condition, '_',D1_EEG_temp.conditions{condz}, '.png'])
        


            %% left GPis
            figure('units','normalized','outerposition',[0 0 1 1]),
            plot(D1_EEG_temp.frequencies, D2_LFP_1, 'b--', 'LineWidth', 2)
            hold on, plot(D1_EEG_temp.frequencies, D1_LFP_1, 'r--', 'LineWidth', 2)
            h1=plot(D1_EEG_temp.frequencies, mean(D2_LFP_1), 'b', 'LineWidth', 5)
            h2=plot(D1_EEG_temp.frequencies, mean(D1_LFP_1), 'r', 'LineWidth', 5)

            legend([h1, h2],{'on', 'off'})
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('LEFT GPis', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            title(['LEFT GPis ', condition, ' ', D1_EEG_temp.conditions{condz}],  'FontSize', 50)
            
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', 'LogSpectraBaselined_leftGPi_', condition, '_',D1_EEG_temp.conditions{condz}, '.png'])
        

            %% right GPis
            figure('units','normalized','outerposition',[0 0 1 1]),
            plot(D1_EEG_temp.frequencies, D2_LFP_2, 'b--', 'LineWidth', 2)
            hold on, plot(D1_EEG_temp.frequencies, D1_LFP_2, 'r--', 'LineWidth', 2)
            h1=plot(D1_EEG_temp.frequencies, mean(D2_LFP_2), 'b', 'LineWidth', 5)
            h2=plot(D1_EEG_temp.frequencies, mean(D1_LFP_2), 'r', 'LineWidth', 5)

            legend([h1, h2],{'on', 'off'})
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('LEFT GPis', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            title(['Right GPis ', condition, ' ', D1_EEG_temp.conditions{condz}],  'FontSize', 50)
            
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', 'LogSpectraBaselined_RightGPi_', condition, '_',D1_EEG_temp.conditions{condz}, '.png'])
        

            % both GPis

            D1_total_LFP=[D1_LFP_1; D1_LFP_2];
            D2_total_LFP=[D2_LFP_1; D2_LFP_2];

            figure('units','normalized','outerposition',[0 0 1 1]),
            plot(D1_EEG_temp.frequencies, D2_total_LFP, 'b--', 'LineWidth', 2)
            hold on, plot(D1_EEG_temp.frequencies, D1_total_LFP, 'r--', 'LineWidth', 2)
            h1=plot(D1_EEG_temp.frequencies, mean(D2_total_LFP), 'b', 'LineWidth', 5)
            h2=plot(D1_EEG_temp.frequencies, mean(D1_total_LFP), 'r', 'LineWidth', 5)

            legend([h1, h2],{'on', 'off'})
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('Both GPis', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            title(['Both GPis ', condition, ' ', D1_EEG_temp.conditions{condz}],  'FontSize', 50)
            
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', 'LogSpectraBaselined_BothGPi_', condition, '_',D1_EEG_temp.conditions{condz}, '.png'])
        


        


        end
    
        

    
   


   


   


end