function plotdifferenceACTPMTwithrest(condition)
     close all
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};

    for i=1:numel(initials)
        

        [files_, seq, root, details] = dbs_subjects_percept(initials{i}, 1);
        cd(fullfile(root, condition));

        try
        
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

        
            cd(fullfile(root, 'R'));
            files = spm_select('FPList','.', ['LFP_spect_', '.', initials{i} '_rec_' num2str(1) '_R_[0-9]*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['LFP_spect_', initials{i} '_rec_' num2str(1) '_R_[0-9]*.mat']);
            end
            D1_LFP_baseline = spm_eeg_load(files);


            cd(fullfile(root, 'R'));
            files = spm_select('FPList','.', ['EEG_spect_', '.', initials{i} '_rec_' num2str(1) '_R_[0-9]*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['EEG_spect_', initials{i} '_rec_' num2str(1) '_R_[0-9]*.mat']);
            end
            D1_EEG_baseline = spm_eeg_load(files);
            
       

        
    
        [files_, seq, root, details] = dbs_subjects_percept(initials{i}, 2);
        cd(fullfile(root, condition));

        try
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

        
            cd(fullfile(root, 'R'));
            files = spm_select('FPList','.', ['LFP_spect_', '.', initials{i} '_rec_' num2str(2) '_R_[0-9]*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['LFP_spect_', initials{i} '_rec_' num2str(2) '_R_[0-9]*.mat']);
            end
            D2_LFP_baseline = spm_eeg_load(files);
            
            cd(fullfile(root, 'R'));
            files = spm_select('FPList','.', ['EEG_spect_', '.', initials{i} '_rec_' num2str(2) '_R_[0-9]*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['EEG_spect_', initials{i} '_rec_' num2str(2) '_R_[0-9]*.mat']);
            end
            D2_EEG_baseline = spm_eeg_load(files);
            
        
        
        
        

        for condz=1:numel(D1_LFP_temp.conditions)
        %% 

        if strcmp(D1_LFP_temp.chanlabels{lfpchan(1)}(end-3),'L')
            D1_LFP_1_all(i,:, condz)=(squeeze(D1_LFP_temp(1,:,1,condz))) ;
            D1_LFP_baseline_1_all(i,:,1)=(squeeze(D1_LFP_baseline(1,:,1,:)));
        else
            D1_LFP_2_all(i,:, condz)=(squeeze(D1_LFP_temp(1,:,1,condz))) ;
             D1_LFP_baseline_2_all(i,:,1)=(squeeze(D1_LFP_baseline(1,:,1,:)));
        end
        if numel(lfpchan)>1
            if strcmp(D1_LFP_temp.chanlabels{lfpchan(2)}(end-3),'L')
                D1_LFP_1_all(i,:, condz)=(squeeze(D1_LFP_temp(2,:,1,condz))) ;
                 D1_LFP_baseline_1_all(i,:,1)=(squeeze(D1_LFP_baseline(2,:,1,:)));
            else
                D1_LFP_2_all(i,:, condz)=(squeeze(D1_LFP_temp(2,:,1,condz))) ;
                D1_LFP_baseline_2_all(i,:,1)=(squeeze(D1_LFP_baseline(2,:,1,:)));
            end
        end
    
        %         EEGchannels=D1_EEG_temp.indchantype('EEG');
        EEGchannels=[D1_EEG_temp.indchannel('C3') D1_EEG_temp.indchannel('C4'), D1_EEG_temp.indchannel('Cz')];
        D1_EEG_all(i,:, condz)=mean((squeeze(D1_EEG_temp(EEGchannels,:,1,condz))),1);
        D1_EEG_baseline_all(i,:,1)=mean(squeeze(D1_EEG_baseline(EEGchannels,:,1,:)),1);


        if strcmp(D2_LFP_temp.chanlabels{lfpchan(1)}(end-3),'L')
            D2_LFP_1_all(i,:, condz)=(squeeze(D2_LFP_temp(1,:,1,condz))) ;
            D2_LFP_baseline_1_all(i,:,1)=(squeeze(D2_LFP_baseline(1,:,1,:)));
        else
            D2_LFP_2_all(i,:, condz)=(squeeze(D2_LFP_temp(1,:,1,condz))) ;
            D2_LFP_baseline_2_all(i,:,1)=(squeeze(D2_LFP_baseline(1,:,1,:)));
        end
        if numel(lfpchan)>1
            if strcmp(D2_LFP_temp.chanlabels{lfpchan(2)}(end-3),'L')
                D2_LFP_1_all(i,:, condz)=(squeeze(D2_LFP_temp(2,:,1,condz))) ;
                D2_LFP_baseline_1_all(i,:,1)=(squeeze(D2_LFP_baseline(2,:,1,:)));
            else
                D2_LFP_2_all(i,:, condz)=(squeeze(D2_LFP_temp(2,:,1,condz)));
                D2_LFP_baseline_2_all(i,:,1)=(squeeze(D2_LFP_baseline(2,:,1,:)));
            end
        end

        %         EEGchannels=D2_EEG_temp.indchantype('EEG');
        EEGchannels=[D2_EEG_temp.indchannel('C3') D2_EEG_temp.indchannel('C4'), D2_EEG_temp.indchannel('Cz')];
        D2_EEG_all(i,:, condz)=mean((squeeze(D2_EEG_temp(EEGchannels,:,1,condz))),1);
        D2_EEG_baseline_all(i,:,1)=mean(squeeze(D2_EEG_baseline(EEGchannels,:,1,:)),1);


       
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


    %%
    for kk=size(D1_EEG_baseline_all,1):-1:1
        if numel(find(D1_EEG_baseline_all(kk,:,1)==0))==size(D1_EEG_baseline_all,2) || numel(find(D2_EEG_baseline_all(kk,:,1)==0))==size(D2_EEG_baseline_all,2) 
            D1_EEG_baseline_all(kk,:,:)=[];
            D2_EEG_baseline_all(kk,:,:)=[];
        end
    end

    for kk=size(D1_LFP_baseline_1_all,1):-1:1
        % left side
        if numel(find(D1_LFP_baseline_1_all(kk,:,1)==0))==size(D1_LFP_baseline_1_all,2) || numel(find(D2_LFP_baseline_1_all(kk,:,1)==0))==size(D2_LFP_baseline_1_all,2) 
            D1_LFP_baseline_1_all(kk,:,:)=[];
            D2_LFP_baseline_1_all(kk,:,:)=[];
        end

        % right side
        if numel(find(D1_LFP_baseline_2_all(kk,:,1)==0))==size(D1_LFP_baseline_2_all,2) || numel(find(D2_LFP_baseline_2_all(kk,:,1)==0))==size(D2_LFP_baseline_2_all,2) 
            D1_LFP_baseline_2_all(kk,:,:)=[];
            D2_LFP_baseline_2_all(kk,:,:)=[];
        end


    end






        limb_list={'hand', 'foot'};
        for limb=1:2
            
            D1_LFP_1=squeeze(mean(D1_LFP_1_all(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D1_LFP_2=squeeze(mean(D1_LFP_2_all(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D2_LFP_1=squeeze(mean(D2_LFP_1_all(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D2_LFP_2=squeeze(mean(D2_LFP_2_all(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D1_EEG=squeeze(mean(D1_EEG_all(:,:,1+4*(limb-1):4+4*(limb-1)),3));
            D2_EEG=squeeze(mean(D2_EEG_all(:,:,1+4*(limb-1):4+4*(limb-1)),3));


            %% EEG
            figure('units','normalized','outerposition',[0 0 1 1]),
%             plot(D1_EEG_temp.frequencies, D2_EEG, 'b--', 'LineWidth', 2)
%             hold on, plot(D1_EEG_temp.frequencies, D1_EEG, 'r--', 'LineWidth', 2)
            hold on
            h1=plot(D1_EEG_temp.frequencies, mean(D2_EEG), 'b', 'LineWidth', 8)
            h2=plot(D1_EEG_temp.frequencies, mean(D1_EEG), 'b--', 'LineWidth', 8)

%             legend([h1, h2],{'on', 'off'})
            xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
            ylabel('EEG', 'FontSize', 20, 'FontWeight','bold')
            a = get(gca,'XTickLabel');  
            set(gca,'linewidth',5)
            set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            title(['EEG ', condition, ' ', D1_EEG_temp.conditions{condz}],  'FontSize', 50)
            xlim([0 80])


            LiWidthMlines=10;
            xline(find(D1_EEG_temp.frequencies==4), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==8), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==12), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==31), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==50), 'm--', 'LineWidth', LiWidthMlines)

            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', 'LogSpectraBaselined_EEG_', condition, '_',limb_list{limb}, '.png'])
        



            %% Difference EEG

            D_diff=(D2_EEG)-(D1_EEG);

            D_diff=D_diff(:,10:80);
            SEM = std(D_diff,[],1)/sqrt(size(D_diff,1));     % Standard Error
            ts = tinv([0.025  0.975],size(D_diff,1)-1);      % T-Score
            CI = mean(D_diff,1)+ts'.*SEM;   
    
            figure('units','normalized','outerposition',[0 0 1 1]),
            freqs=D1_EEG_temp.frequencies(10:80);
            meanD_diff=mean(D_diff);
            x2 = [freqs, fliplr(freqs)];
            inBetween = [CI(1,:), fliplr(CI(2,:))];
            fill(x2, inBetween, 'k', 'FaceAlpha', 0.2, 'LineStyle','none'); % , 'FaceAlpha', 1
            hold on, h1=plot(freqs, meanD_diff, 'k', 'LineWidth', 10);
            hold on, yline(0, 'k--', 'LineWidth', 5)
    
%             xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
%             ylabel('On - Off (95%CI)', 'FontSize', 20, 'FontWeight','bold')
%             a = get(gca,'XTickLabel');  
%             set(gca,'linewidth',5)
%             set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
%             title(['EEGLogSpectraDifference',' ', limb_list{limb}],  'FontSize', 10)
            xlim([10 80])

            % figure, shadedErrorBar([],mean(D_diff,1),flipud(CI));
%             box off
%             axis off

            [h_theta ,    p_theta]= ttest(mean(D_diff(:,find(D1_EEG_temp.frequencies==4):find(D1_EEG_temp.frequencies==7)),2));
            [h_alpha ,    p_alpha]= ttest(mean(D_diff(:,find(D1_EEG_temp.frequencies==8):find(D1_EEG_temp.frequencies==12)),2));
            [h_beta ,     p_beta]= ttest(mean(D_diff(:,find(D1_EEG_temp.frequencies==13):find(D1_EEG_temp.frequencies==30)),2));
            [h_lowgamma,  p_lowgamma]= ttest(mean(D_diff(:,find(D1_EEG_temp.frequencies==31):find(D1_EEG_temp.frequencies==48)),2));
            [h_highgamma, p_highgamma]= ttest(mean(D_diff(:,find(D1_EEG_temp.frequencies==52):find(D1_EEG_temp.frequencies==70)),2));

            sizestar=40;
            size_font=100;
            y1 = ylim;
            LiWidthMlines=10;
            hold on, xline(find(D1_EEG_temp.frequencies==4), 'm--', 'LineWidth', LiWidthMlines)
            if h_theta==1 
                if p_theta<0.01
                    plot(5, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),  plot(5, y1(2)-0.1, 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines)
                else
                    plot(5, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),
                end
%                 plot(5, 0.05, 'k*', 'MarkerSize', sizestar) 
%                 text(5, 0.1, num2str(round(p_theta*1000)/1000), 'FontSize', size_font, 'FontWeight','bold')
                a = fill([find(D1_EEG_temp.frequencies==4) find(D1_EEG_temp.frequencies==4) find(D1_EEG_temp.frequencies==8) find(D1_EEG_temp.frequencies==8)], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(find(D1_EEG_temp.frequencies==8), 'm--', 'LineWidth', LiWidthMlines)
            if h_alpha==1 
                if p_alpha<0.01
                    plot(9, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),  plot(9, y1(2)-0.1, 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines)
                else
                    plot(9, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),
                end
%                 plot(9, 0.05, 'k*', 'MarkerSize', sizestar), 
%                 text(9, 0.2, num2str(round(p_alpha*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'),
                a = fill([find(D1_EEG_temp.frequencies==8) find(D1_EEG_temp.frequencies==8) find(D1_EEG_temp.frequencies==12) find(D1_EEG_temp.frequencies==12)], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(find(D1_EEG_temp.frequencies==12), 'm--', 'LineWidth', LiWidthMlines)
            if h_beta==1 
                if p_beta<0.01
                    plot(20.5, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),  plot(20.5, y1(2)-0.1, 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines)
                else
                    plot(20.5, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),
                end
%                 plot(20.5, 0.05, 'k*', 'MarkerSize', sizestar), 
%                 text(20.5, 0.1, num2str(round(p_beta*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'), 
                a = fill([find(D1_EEG_temp.frequencies==12) find(D1_EEG_temp.frequencies==12) find(D1_EEG_temp.frequencies==31) find(D1_EEG_temp.frequencies==31)], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(find(D1_EEG_temp.frequencies==31), 'm--', 'LineWidth', LiWidthMlines)
            if h_lowgamma==1 
                if p_lowgamma<0.01
                    plot(40, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),  plot(40, y1(2)-0.1, 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines)
                else
                    plot(40, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),
                end
%                 plot(40, 0.05, 'k*', 'MarkerSize', sizestar), 
%                 text(40, 0.2, num2str(round(p_lowgamma*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'), 
                a = fill([find(D1_EEG_temp.frequencies==31) find(D1_EEG_temp.frequencies==31) find(D1_EEG_temp.frequencies==50) find(D1_EEG_temp.frequencies==50)], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(find(D1_EEG_temp.frequencies==50), 'm--', 'LineWidth', LiWidthMlines)
            if h_highgamma==1 
                if p_highgamma<0.01
                    plot(60, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),  plot(60, y1(2)-0.1, 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines)
                else
                    plot(60, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),
                end
%                 plot(60, 0.05, 'k*', 'MarkerSize', sizestar),
%                 text(60, 0.1, num2str(round(p_highgamma*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'),  
                a = fill([find(D1_EEG_temp.frequencies==50) find(D1_EEG_temp.frequencies==50) find(D1_EEG_temp.frequencies==80) find(D1_EEG_temp.frequencies==80)], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end


        


            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\','LogSpectraBaselined_EEG_DifferenceWithInterval', condition, '_',limb_list{limb}, '.png'])




            %% left GPis
            figure('units','normalized','outerposition',[0 0 1 1]),
%             plot(D1_EEG_temp.frequencies, D2_LFP_1, 'b--', 'LineWidth', 2)
%             hold on, plot(D1_EEG_temp.frequencies, D1_LFP_1, 'r--', 'LineWidth', 2)
            hold on,
            h1=plot(D1_EEG_temp.frequencies, mean(D2_LFP_1), 'b', 'LineWidth', 10)
            h2=plot(D1_EEG_temp.frequencies, mean(D1_LFP_1), 'b--', 'LineWidth', 10)

%             legend([h1, h2],{'on', 'off'})
%             xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
%             ylabel('LEFT GPis', 'FontSize', 20, 'FontWeight','bold')
%             a = get(gca,'XTickLabel');  
%             set(gca,'linewidth',5)
%             set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
%             title(['LEFT GPis ', condition, ' ', D1_EEG_temp.conditions{condz}],  'FontSize', 50)
            
            xlim([0 90])
            box off
            axis off
            LiWidthMlines=10;
            xline(find(D1_EEG_temp.frequencies==4), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==8), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==12), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==31), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==50), 'm--', 'LineWidth', LiWidthMlines)


            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', 'LogSpectraBaselined_leftGPi_', condition, '_',limb_list{limb}, '.png'])
        

            %% right GPis
            figure('units','normalized','outerposition',[0 0 1 1]),
%             plot(D1_EEG_temp.frequencies, D2_LFP_2, 'b--', 'LineWidth', 2)
%             hold on, plot(D1_EEG_temp.frequencies, D1_LFP_2, 'r--', 'LineWidth', 2)
            hold on, 
            h1=plot(D1_EEG_temp.frequencies, mean(D2_LFP_2), 'b', 'LineWidth', 10)
            h2=plot(D1_EEG_temp.frequencies, mean(D1_LFP_2), 'b--', 'LineWidth', 10)

%             legend([h1, h2],{'on', 'off'})
%             xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
%             ylabel('LEFT GPis', 'FontSize', 20, 'FontWeight','bold')
%             a = get(gca,'XTickLabel');  
%             set(gca,'linewidth',5)
%             set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
%             title(['Right GPis ', condition, ' ', D1_EEG_temp.conditions{condz}],  'FontSize', 50)
            xlim([0 90])
            box off
            axis off
            LiWidthMlines=10;
            xline(find(D1_EEG_temp.frequencies==4), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==8), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==12), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==31), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==50), 'm--', 'LineWidth', LiWidthMlines)

            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', 'LogSpectraBaselined_RightGPi_', condition, '_',limb_list{limb}, '.png'])
        

            % both GPis

            D1_total_LFP=[D1_LFP_1; D1_LFP_2];
            D2_total_LFP=[D2_LFP_1; D2_LFP_2];

            figure('units','normalized','outerposition',[0 0 1 1]),
%             plot(D1_EEG_temp.frequencies, D2_total_LFP, 'b--', 'LineWidth', 2)
%             hold on, plot(D1_EEG_temp.frequencies, D1_total_LFP, 'r--', 'LineWidth', 2)
            hold on,
            h1=plot(D1_EEG_temp.frequencies, mean(D2_total_LFP), 'b', 'LineWidth', 10)
            h2=plot(D1_EEG_temp.frequencies, mean(D1_total_LFP), 'b--', 'LineWidth', 10)

%             legend([h1, h2],{'on', 'off'})
%             xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
%             ylabel('Both GPis', 'FontSize', 20, 'FontWeight','bold')
%             a = get(gca,'XTickLabel');  
%             set(gca,'linewidth',5)
%             set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
%             title(['Both GPis ', condition, ' ', D1_EEG_temp.conditions{condz}],  'FontSize', 50)
            xlim([0 90])
            box off
            axis off
            LiWidthMlines=10;
            xline(find(D1_EEG_temp.frequencies==4), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==8), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==12), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==31), 'm--', 'LineWidth', LiWidthMlines)
            xline(find(D1_EEG_temp.frequencies==50), 'm--', 'LineWidth', LiWidthMlines)


            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\', 'LogSpectraBaselined_BothGPi_', condition, '_',limb_list{limb}, '.png'])


            %% Difference LFP

            D_diff=D2_total_LFP-D1_total_LFP;


            [h_theta ,    p_theta]= ttest(mean(D_diff(:,find(D1_EEG_temp.frequencies==4):find(D1_EEG_temp.frequencies==7)),2));
            [h_alpha ,    p_alpha]= ttest(mean(D_diff(:,find(D1_EEG_temp.frequencies==8):find(D1_EEG_temp.frequencies==12)),2));
            [h_beta ,     p_beta]= ttest(mean(D_diff(:,find(D1_EEG_temp.frequencies==13):find(D1_EEG_temp.frequencies==30)),2));
            [h_lowgamma,  p_lowgamma]= ttest(mean(D_diff(:,find(D1_EEG_temp.frequencies==31):find(D1_EEG_temp.frequencies==48)),2));
            [h_highgamma, p_highgamma]= ttest(mean(D_diff(:,find(D1_EEG_temp.frequencies==52):find(D1_EEG_temp.frequencies==80)),2));
        

            
            D_diff=D_diff(:,1:80);
            SEM = std(D_diff,[],1)/sqrt(size(D_diff,1));     % Standard Error
            ts = tinv([0.025  0.975],size(D_diff,1)-1);      % T-Score
            CI = mean(D_diff,1)+ts'.*SEM;   
    
            figure('units','normalized','outerposition',[0 0 1 1]),
            freqs=D1_EEG_temp.frequencies(1:80);
            meanD_diff=mean(D_diff);
            x2 = [freqs, fliplr(freqs)];
            inBetween = [CI(1,:), fliplr(CI(2,:))];
            fill(x2, inBetween, 'k', 'FaceAlpha', 0.3, 'LineStyle','none'); % , 'FaceAlpha', 1
            hold on, h1=plot(freqs, meanD_diff, 'k', 'LineWidth', 10);
            hold on, yline(0, 'k--', 'LineWidth', 5)
            sizestar=40;
            size_font=100;
            y1 = ylim;
            LiWidthMlines=10;
            hold on, xline(find(D1_EEG_temp.frequencies==4), 'm--', 'LineWidth', LiWidthMlines)
            if h_theta==1 
                if p_theta<0.01
                    plot(5, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),  plot(5, y1(2)-0.06, 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines)
                else
                    plot(5, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),
                end
%                 plot(5, 0.05, 'k*', 'MarkerSize', sizestar) 
%                 text(5, 0.1, num2str(round(p_theta*1000)/1000), 'FontSize', size_font, 'FontWeight','bold')
                a = fill([find(D1_EEG_temp.frequencies==4) find(D1_EEG_temp.frequencies==4) find(D1_EEG_temp.frequencies==8) find(D1_EEG_temp.frequencies==8)], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(find(D1_EEG_temp.frequencies==8), 'm--', 'LineWidth', LiWidthMlines)
            if h_alpha==1 
                if p_alpha<0.01
                    plot(9, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),  plot(9, y1(2)-0.06, 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines)
                else
                    plot(9, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),
                end
%                 plot(9, 0.05, 'k*', 'MarkerSize', sizestar), 
%                 text(9, 0.2, num2str(round(p_alpha*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'),
                a = fill([find(D1_EEG_temp.frequencies==8) find(D1_EEG_temp.frequencies==8) find(D1_EEG_temp.frequencies==12) find(D1_EEG_temp.frequencies==12)], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(find(D1_EEG_temp.frequencies==12), 'm--', 'LineWidth', LiWidthMlines)
            if h_beta==1 
                if p_beta<0.01
                    plot(20.5, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),  plot(20.5, y1(2)-0.06, 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines)
                else
                    plot(20.5, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),
                end
%                 plot(20.5, 0.05, 'k*', 'MarkerSize', sizestar), 
%                 text(20.5, 0.1, num2str(round(p_beta*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'), 
                a = fill([find(D1_EEG_temp.frequencies==12) find(D1_EEG_temp.frequencies==12) find(D1_EEG_temp.frequencies==31) find(D1_EEG_temp.frequencies==31)], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(find(D1_EEG_temp.frequencies==31), 'm--', 'LineWidth', LiWidthMlines)
            if h_lowgamma==1 
                if p_lowgamma<0.01
                    plot(40, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),  plot(40, y1(2)-0.06, 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines)
                else
                    plot(40, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),
                end
%                 plot(40, 0.05, 'k*', 'MarkerSize', sizestar), 
%                 text(40, 0.2, num2str(round(p_lowgamma*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'), 
                a = fill([find(D1_EEG_temp.frequencies==31) find(D1_EEG_temp.frequencies==31) find(D1_EEG_temp.frequencies==50) find(D1_EEG_temp.frequencies==50)], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
            xline(find(D1_EEG_temp.frequencies==50), 'm--', 'LineWidth', LiWidthMlines)
            if h_highgamma==1 
                if p_highgamma<0.01
                    plot(60, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),  plot(60, y1(2)-0.06, 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines)
                else
                    plot(60, y1(2), 'k*', 'MarkerSize', sizestar, 'LineWidth', LiWidthMlines),
                end
%                 plot(60, 0.05, 'k*', 'MarkerSize', sizestar),
%                 text(60, 0.1, num2str(round(p_highgamma*1000)/1000), 'FontSize', size_font, 'FontWeight','bold'),  
                a = fill([find(D1_EEG_temp.frequencies==50) find(D1_EEG_temp.frequencies==50) find(D1_EEG_temp.frequencies==80) find(D1_EEG_temp.frequencies==80)], [y1(1) y1(2) y1(2) y1(1)], 'm');
                a.FaceAlpha = 0.1;
                a.EdgeColor='none';
            end
    
%             xlabel('frequency', 'FontSize', 20, 'FontWeight','bold')
%             ylabel('On - Off (95%CI)', 'FontSize', 20, 'FontWeight','bold')
%             a = get(gca,'XTickLabel');  
%             set(gca,'linewidth',5)
%             set(gca,'XTickLabel',a,'fontsize',25,'FontWeight','bold')
            box off
            axis off
%             title(['LogSpectraDifference',' ', limb_list{limb}],  'FontSize', 10)
            xlim([0 80])
            % figure, shadedErrorBar([],mean(D_diff,1),flipud(CI));
    
            spm_mkdir(['D:\home\results Percept Project\ForBRST']);
            saveas(gcf, ['D:\home\results Percept Project\ForBRST\','LogSpectraBaselined_BothGPi_DifferenceWithInterval', condition, '_',limb_list{limb}, '.png'])


        


        


        end
    
        

    
   


   


   


end