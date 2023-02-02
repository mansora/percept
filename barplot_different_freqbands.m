function barplot_different_freqbands(condition)

    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};

    for i=1:numel(initials)
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
        
        

        for condz=1:numel(D1_LFP_temp.conditions)
        %% 

        if strcmp(D1_LFP_temp.chanlabels{lfpchan(1)}(end-3),'L')
            D1_LFP_1_all(i,:, condz)=squeeze(D1_LFP_temp(1,:,1,condz));
        else
            D1_LFP_2_all(i,:, condz)=squeeze(D1_LFP_temp(1,:,1,condz));
        end
        if numel(lfpchan)>1
            if strcmp(D1_LFP_temp.chanlabels{lfpchan(2)}(end-3),'L')
                D1_LFP_1_all(i,:, condz)=squeeze(D1_LFP_temp(2,:,1,condz));
            else
                D1_LFP_2_all(i,:, condz)=squeeze(D1_LFP_temp(2,:,1,condz));
            end
        end

        D1_EEG_all(i,:, condz)=mean(squeeze(D1_EEG_temp(:,:,1,condz)),1);


        if strcmp(D2_LFP_temp.chanlabels{lfpchan(1)}(end-3),'L')
            D2_LFP_1_all(i,:, condz)=squeeze(D2_LFP_temp(1,:,1,condz));
        else
            D2_LFP_2_all(i,:, condz)=squeeze(D2_LFP_temp(1,:,1,condz));
        end
        if numel(lfpchan)>1
            if strcmp(D2_LFP_temp.chanlabels{lfpchan(2)}(end-3),'L')
                D2_LFP_1_all(i,:, condz)=squeeze(D2_LFP_temp(2,:,1,condz));
            else
                D2_LFP_2_all(i,:, condz)=squeeze(D2_LFP_temp(2,:,1,condz));
            end
        end

        D2_EEG_all(i,:, condz)=mean(squeeze(D2_EEG_temp(:,:,1,condz)),1);


       
        end
    end

        for condz=1:numel(D1_LFP_temp.conditions)
            
            D1_LFP_1=squeeze(D1_LFP_1_all(:,:,condz));
            D1_LFP_2=squeeze(D1_LFP_2_all(:,:,condz));
            D2_LFP_1=squeeze(D2_LFP_1_all(:,:,condz));
            D2_LFP_2=squeeze(D2_LFP_2_all(:,:,condz));
            D1_EEG=squeeze(D1_EEG_all(:,:,condz));
            D2_EEG=squeeze(D2_EEG_all(:,:,condz));


             %% plot data
            theta     = mean(D1_EEG(:,find(D1_EEG_temp.frequencies==4):find(D1_EEG_temp.frequencies==7)),2);
            alpha     = mean(D1_EEG(:,find(D1_EEG_temp.frequencies==8):find(D1_EEG_temp.frequencies==12)),2);
            beta      = mean(D1_EEG(:,find(D1_EEG_temp.frequencies==13):find(D1_EEG_temp.frequencies==30)),2);
            lowgamma  = mean(D1_EEG(:,find(D1_EEG_temp.frequencies==31):find(D1_EEG_temp.frequencies==48)),2);
            highgamma = mean(D1_EEG(:,find(D1_EEG_temp.frequencies==52):find(D1_EEG_temp.frequencies==90)),2);
        
            datapoints_D1_EEG=[theta', alpha', beta', lowgamma', highgamma'];
        
            theta     = mean(D2_EEG(:,find(D2_EEG_temp.frequencies==4):find(D2_EEG_temp.frequencies==7)),2);
            alpha     = mean(D2_EEG(:,find(D2_EEG_temp.frequencies==8):find(D2_EEG_temp.frequencies==12)),2);
            beta      = mean(D2_EEG(:,find(D2_EEG_temp.frequencies==13):find(D2_EEG_temp.frequencies==30)),2);
            lowgamma  = mean(D2_EEG(:,find(D2_EEG_temp.frequencies==31):find(D2_EEG_temp.frequencies==48)),2);
            highgamma = mean(D2_EEG(:,find(D2_EEG_temp.frequencies==52):find(D2_EEG_temp.frequencies==90)),2);
        
            datapoints_D2_EEG=[theta', alpha', beta', lowgamma', highgamma'];
            n=7;
            x1=repmat(1:5,n,1)-0.4;
            x2=repmat(1:5,n,1)+0.4;
            cgroupdata=[ones(1,n*5), zeros(1,n*5)]; % note that because cgroupdata is specified like this legend is the other way around! Do not confuse
            figure('units','normalized','outerposition',[0 0 1 1]),
            boxchart([x1(:);x2(:)], [datapoints_D1_EEG, datapoints_D2_EEG], 'GroupByColor',cgroupdata, 'BoxWidth', 0.5, 'LineWidth', 3)
            hold on, plot([x1(:)+0.1;x2(:)-0.1], [datapoints_D1_EEG, datapoints_D2_EEG], 'o', 'MarkerSize', 15, 'LineWidth', 3,'HandleVisibility','off')
            for kk=1:5
                temp_x=[x1(:,kk)+0.1; x2(:,kk)-0.1]';
                temp_y=[datapoints_D1_EEG(n*(kk-1)+1:n*(kk)),datapoints_D2_EEG(n*(kk-1)+1:n*(kk))];
                for rr=1:size(temp_x,2)/2
                plot([temp_x(rr), temp_x(size(temp_x,2)/2+rr)],[temp_y(rr),temp_y(size(temp_x,2)/2+rr)],...
                     'k', 'LineStyle', '--', 'LineWidth', 1,'HandleVisibility','off')
                end
            end
        
            legend({'on', 'off'})
            xticklabels({'', 'theta','alpha','beta','lowgamma','highgamma'})
            xlabel('frequency bands', 'FontSize', 20, 'FontWeight','bold')
            ylabel('EEG', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', 'barplot_EEG_', condition, '_',D1_LFP_temp.conditions{condz}, '.png'])
        
        
        
           %% left GPis
        
            D1_LFP_1=D1_LFP_1(4:7,:);
            D2_LFP_1=D2_LFP_1(4:7,:);
            n=4; % because there are only 4 left GPis
        
            theta     = mean(D1_LFP_1(:,find(D1_LFP_temp.frequencies==4):find(D1_LFP_temp.frequencies==7)),2);
            alpha     = mean(D1_LFP_1(:,find(D1_LFP_temp.frequencies==8):find(D1_LFP_temp.frequencies==12)),2);
            beta      = mean(D1_LFP_1(:,find(D1_LFP_temp.frequencies==13):find(D1_LFP_temp.frequencies==30)),2);
            lowgamma  = mean(D1_LFP_1(:,find(D1_LFP_temp.frequencies==31):find(D1_LFP_temp.frequencies==48)),2);
            highgamma = mean(D1_LFP_1(:,find(D1_LFP_temp.frequencies==52):find(D1_LFP_temp.frequencies==90)),2);
        
            datapoints_D1_LFP=[theta', alpha', beta', lowgamma', highgamma'];
        
            theta     = mean(D2_LFP_1(:,find(D2_LFP_temp.frequencies==4):find(D2_LFP_temp.frequencies==7)),2);
            alpha     = mean(D2_LFP_1(:,find(D2_LFP_temp.frequencies==8):find(D2_LFP_temp.frequencies==12)),2);
            beta      = mean(D2_LFP_1(:,find(D2_LFP_temp.frequencies==13):find(D2_LFP_temp.frequencies==30)),2);
            lowgamma  = mean(D2_LFP_1(:,find(D2_LFP_temp.frequencies==31):find(D2_LFP_temp.frequencies==48)),2);
            highgamma = mean(D2_LFP_1(:,find(D2_LFP_temp.frequencies==52):find(D2_LFP_temp.frequencies==90)),2);
        
            datapoints_D2_LFP=[theta', alpha', beta', lowgamma', highgamma'];
        
            x1=repmat(1:5,n,1)-0.4;
            x2=repmat(1:5,n,1)+0.4;
            cgroupdata=[ones(1,n*5), zeros(1,n*5)];
            figure('units','normalized','outerposition',[0 0 1 1]),
            boxchart([x1(:);x2(:)], [datapoints_D1_LFP, datapoints_D2_LFP], 'GroupByColor',cgroupdata, 'BoxWidth', 0.5, 'LineWidth', 3)
            hold on, plot([x1(:)+0.1;x2(:)-0.1], [datapoints_D1_LFP, datapoints_D2_LFP], 'o', 'MarkerSize', 15, 'LineWidth', 3,'HandleVisibility','off')
            for kk=1:5
                temp_x=[x1(:,kk)+0.1; x2(:,kk)-0.1]';
                temp_y=[datapoints_D1_LFP(n*(kk-1)+1:n*(kk)),datapoints_D2_LFP(n*(kk-1)+1:n*(kk))];
                for rr=1:size(temp_x,2)/2
                plot([temp_x(rr), temp_x(size(temp_x,2)/2+rr)],[temp_y(rr),temp_y(size(temp_x,2)/2+rr)],...
                     'k', 'LineStyle', '--', 'LineWidth', 1,'HandleVisibility','off')
                end
            end
        
            legend('Left on','Left off')
            xticklabels({'', 'theta','alpha','beta','lowgamma','highgamma'})
            xlabel('frequency bands', 'FontSize', 20, 'FontWeight','bold')
            ylabel('LEFT GPi', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
        
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', 'barplot_Left_', condition,  '_',D1_LFP_temp.conditions{condz}, '.png'])
        
            
        
            %% right GPis
        
            
            theta     = mean(D1_LFP_2(:,find(D1_LFP_temp.frequencies==4):find(D1_LFP_temp.frequencies==7)),2);
            alpha     = mean(D1_LFP_2(:,find(D1_LFP_temp.frequencies==8):find(D1_LFP_temp.frequencies==12)),2);
            beta      = mean(D1_LFP_2(:,find(D1_LFP_temp.frequencies==13):find(D1_LFP_temp.frequencies==30)),2);
            lowgamma  = mean(D1_LFP_2(:,find(D1_LFP_temp.frequencies==31):find(D1_LFP_temp.frequencies==48)),2);
            highgamma = mean(D1_LFP_2(:,find(D1_LFP_temp.frequencies==52):find(D1_LFP_temp.frequencies==90)),2);
        
            datapoints_D1_LFP=[theta', alpha', beta', lowgamma', highgamma'];
        
            theta     = mean(D2_LFP_2(:,find(D2_LFP_temp.frequencies==4):find(D2_LFP_temp.frequencies==7)),2);
            alpha     = mean(D2_LFP_2(:,find(D2_LFP_temp.frequencies==8):find(D2_LFP_temp.frequencies==12)),2);
            beta      = mean(D2_LFP_2(:,find(D2_LFP_temp.frequencies==13):find(D2_LFP_temp.frequencies==30)),2);
            lowgamma  = mean(D2_LFP_2(:,find(D2_LFP_temp.frequencies==31):find(D2_LFP_temp.frequencies==48)),2);
            highgamma = mean(D2_LFP_2(:,find(D2_LFP_temp.frequencies==52):find(D2_LFP_temp.frequencies==90)),2);
        
            datapoints_D2_LFP=[theta', alpha', beta', lowgamma', highgamma'];
            n=7;
            x1=repmat(1:5,n,1)-0.4;
            x2=repmat(1:5,n,1)+0.4;
            cgroupdata=[ones(1,n*5), zeros(1,n*5)];
            figure('units','normalized','outerposition',[0 0 1 1]),
            boxchart([x1(:);x2(:)], [datapoints_D1_LFP, datapoints_D2_LFP], 'GroupByColor',cgroupdata, 'BoxWidth', 0.5, 'LineWidth', 3)
            hold on, plot([x1(:)+0.1;x2(:)-0.1], [datapoints_D1_LFP, datapoints_D2_LFP], 'o', 'MarkerSize', 15, 'LineWidth', 3,'HandleVisibility','off')
            for kk=1:5
                temp_x=[x1(:,kk)+0.1; x2(:,kk)-0.1]';
                temp_y=[datapoints_D1_LFP(n*(kk-1)+1:n*(kk)),datapoints_D2_LFP(n*(kk-1)+1:n*(kk))];
                for rr=1:size(temp_x,2)/2
                plot([temp_x(rr), temp_x(size(temp_x,2)/2+rr)],[temp_y(rr),temp_y(size(temp_x,2)/2+rr)],...
                     'k', 'LineStyle', '--', 'LineWidth', 1,'HandleVisibility','off')
                end
            end
        
            legend('Right on','Right off')
            xticklabels({'', 'theta','alpha','beta','lowgamma','highgamma'})
            xlabel('frequency bands', 'FontSize', 20, 'FontWeight','bold')
            ylabel('RIGHT GPi', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            
        
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', 'barplot_Right_', condition,  '_',D1_LFP_temp.conditions{condz}, '.png'])
        
        
            %% Both Left and Right combined
            D1_total_LFP=[D1_LFP_1; D1_LFP_2];
            D2_total_LFP=[D2_LFP_1; D2_LFP_2];
            n=11;
        
            theta     = mean(D1_total_LFP(:,find(D1_LFP_temp.frequencies==4):find(D1_LFP_temp.frequencies==7)),2);
            alpha     = mean(D1_total_LFP(:,find(D1_LFP_temp.frequencies==8):find(D1_LFP_temp.frequencies==12)),2);
            beta      = mean(D1_total_LFP(:,find(D1_LFP_temp.frequencies==13):find(D1_LFP_temp.frequencies==30)),2);
            lowgamma  = mean(D1_total_LFP(:,find(D1_LFP_temp.frequencies==31):find(D1_LFP_temp.frequencies==48)),2);
            highgamma = mean(D1_total_LFP(:,find(D1_LFP_temp.frequencies==52):find(D1_LFP_temp.frequencies==90)),2);
        
            datapoints_D1_LFP=[theta', alpha', beta', lowgamma', highgamma'];
        
            theta     = mean(D2_total_LFP(:,find(D2_LFP_temp.frequencies==4):find(D2_LFP_temp.frequencies==7)),2);
            alpha     = mean(D2_total_LFP(:,find(D2_LFP_temp.frequencies==8):find(D2_LFP_temp.frequencies==12)),2);
            beta      = mean(D2_total_LFP(:,find(D2_LFP_temp.frequencies==13):find(D2_LFP_temp.frequencies==30)),2);
            lowgamma  = mean(D2_total_LFP(:,find(D2_LFP_temp.frequencies==31):find(D2_LFP_temp.frequencies==48)),2);
            highgamma = mean(D2_total_LFP(:,find(D2_LFP_temp.frequencies==52):find(D2_LFP_temp.frequencies==90)),2);
        
            datapoints_D2_LFP=[theta', alpha', beta', lowgamma', highgamma'];
        
            x1=repmat(1:5,n,1)-0.4;
            x2=repmat(1:5,n,1)+0.4;
            cgroupdata=[ones(1,n*5), zeros(1,n*5)];
            figure('units','normalized','outerposition',[0 0 1 1]),
            boxchart([x1(:);x2(:)], [datapoints_D1_LFP, datapoints_D2_LFP], 'GroupByColor',cgroupdata, 'BoxWidth', 0.5, 'LineWidth', 3)
            hold on, plot([x1(:)+0.1;x2(:)-0.1], [datapoints_D1_LFP, datapoints_D2_LFP], 'o', 'MarkerSize', 15, 'LineWidth', 3,'HandleVisibility','off')
            for kk=1:5
                temp_x=[x1(:,kk)+0.1; x2(:,kk)-0.1]';
                temp_y=[datapoints_D1_LFP(n*(kk-1)+1:n*(kk)),datapoints_D2_LFP(n*(kk-1)+1:n*(kk))];
                for rr=1:size(temp_x,2)/2
                plot([temp_x(rr), temp_x(size(temp_x,2)/2+rr)],[temp_y(rr),temp_y(size(temp_x,2)/2+rr)],...
                     'k', 'LineStyle', '--', 'LineWidth', 1,'HandleVisibility','off')
                end
            end
            
            legend('ALL on','ALL off')
            xticklabels({'', 'theta','alpha','beta','lowgamma','highgamma'})
            xlabel('frequency bands', 'FontSize', 20, 'FontWeight','bold')
            ylabel('GPi combined', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
        
            spm_mkdir(['D:\home\results Percept Project\Summary']);
            saveas(gcf, ['D:\home\results Percept Project\Summary\', 'barplot_LFPcombined_', condition,  '_',D1_LFP_temp.conditions{condz}, '.png'])

        end
    
        

    
   


   


   


end