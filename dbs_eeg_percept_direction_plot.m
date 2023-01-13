function dbs_eeg_percept_direction_plot(initials, condition, method)
    
%     method='Granger'; %Coherence
    [files, seq, root, details] = dbs_subjects(initials, 1);
    cd(fullfile(root, condition));

    try
        files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    
    D = spm_eeg_load(files);

    
    figure('units','normalized','outerposition',[0 0 1 1]),
    sgtitle([method, ' ' , condition])

    for sub_condition=1:numel(D.condlist)
        subcondition =D.condlist{sub_condition};% 'foot_L_up';
    
        [files, seq, root, details] = dbs_subjects(initials, 1);
        cd(fullfile(root, condition));
    
        files = spm_select('FPList','.', ['C_', condition, '_', subcondition, '.', initials '_rec_' num2str(1) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', condition, '_', subcondition, initials '_rec_' num2str(1) '_' condition '\w*.mat']);
        end

        Dc_off=spm_eeg_load(files);
    
        [files, seq, root, details] = dbs_subjects(initials, 2);
        cd(fullfile(root, condition));

        files = spm_select('FPList','.', ['C_', condition, '_', subcondition, '.', initials '_rec_' num2str(2) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', condition, '_', subcondition, initials '_rec_' num2str(2) '_' condition '\w*.mat']);
        end

        Dc_on=spm_eeg_load(files);
    
        ROI = D.chanlabels(D.indchantype('EEG'))';
        lfp = details.chan;
        
        
        %cnd = {'granger_orig', 'granger_reversed',  'granger_shifted'};%  Dc.condlist;%{'coh_orig', 'coh_shifted'};
        %cnd = {'instant_orig', 'instant_reversed',  'instant_shifted'};
        switch method
            case 'Granger'
                cnd = {'granger_orig', 'granger_reversed'};
            case 'Coherence'
                cnd = {'coh_orig', 'coh_shifted'};
        end
        %cnd = {'imagcoh_orig', 'imagcoh_shifted'}
        %cnd = {'realcoh_orig', 'realcoh_shifted'}
        
%         spm_figure('GetWin', [Dc_off.initials '_' cnd{1}]);clf;
        
        trialind = Dc_off.indtrial(cnd);
        
        
        for i = 1:size(ROI, 1)
            for j=1:numel(lfp)
                ind1_off(i,j) = strmatch([ROI{i, 1} '->' lfp{j}], Dc_off.chanlabels);
                ind2_off(i,j) = strmatch([lfp{j} '->' ROI{i, 1}], Dc_off.chanlabels);

                ind1_on(i,j) = strmatch([ROI{i, 1} '->' lfp{j}], Dc_on.chanlabels);
                ind2_on(i,j) = strmatch([lfp{j} '->' ROI{i, 1}], Dc_on.chanlabels);
            end
        end
        x_lim=50;
        switch method
            case 'Granger'

                % plotting directional coherence
                subplot(4,numel(D.condlist),1+sub_condition-1),
                plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind1_off(:,1), :, :, trialind(1)), 1)),'r','LineWidth',3);
                hold on, plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind1_on(:,1), :, :, trialind(1)), 1)),'b','LineWidth',3);
                plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind1_off(:,1), :, :, trialind(2)), 1)),'r--','LineWidth',3);
                plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind1_on(:,1), :, :, trialind(2)), 1)),'b--','LineWidth',3);
                xlim([5 x_lim]);
                title(['L Gpi ', subcondition])
                if sub_condition==1
                    legend('EEG -> LFP off','EEG -> LFP on','EEG -> LFP off reversed','EEG -> LFP on reversed')
                end
                
                if numel(lfp)>1
                    subplot(4,numel(D.condlist),numel(D.condlist)+sub_condition),
                    plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind1_off(:,2), :, :, trialind(1)), 1)),'r','LineWidth',3);
                    hold on, plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind1_on(:,2), :, :, trialind(1)), 1)),'b','LineWidth',3);
                    plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind1_off(:,2), :, :, trialind(2)), 1)),'r--','LineWidth',3);
                    plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind1_on(:,2), :, :, trialind(2)), 1)),'b--','LineWidth',3);
                    xlim([5 x_lim]);
                    title(['R Gpi ', subcondition])
    %                 legend('EEG -> LFP off','EEG -> LFP on','EEG -> LFP off reversed','EEG -> LFP on reversed')
    
                    subplot(4,numel(D.condlist),3*numel(D.condlist)+sub_condition),
                    plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind2_off(:,2), :, :, trialind(1)), 1)),'k','LineWidth',3);
                    hold on, plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind2_on(:,2), :, :, trialind(1)), 1)),'g','LineWidth',3);
                    plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind2_off(:,2), :, :, trialind(2)), 1)),'k--','LineWidth',3);
                    plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind2_on(:,2), :, :, trialind(2)), 1)),'g--','LineWidth',3);
                    xlim([5 x_lim]);
                    title(['R Gpi ', subcondition])
    %                 legend('LFP -> EEG off','LFP -> EEG on','LFP -> EEG off reversed','LFP -> EEG on reversed')
                end

                subplot(4,numel(D.condlist),2*numel(D.condlist)+sub_condition),
                plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind2_off(:,1), :, :, trialind(1)), 1)),'k','LineWidth',3);
                hold on, plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind2_on(:,1), :, :, trialind(1)), 1)),'g','LineWidth',3);
                plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind2_off(:,1), :, :, trialind(2)), 1)),'k--','LineWidth',3);
                plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind2_on(:,1), :, :, trialind(2)), 1)),'g--','LineWidth',3);
                xlim([5 x_lim]);
                title(['L Gpi ', subcondition])
                if sub_condition==1
                    legend('LFP -> EEG off','LFP -> EEG on','LFP -> EEG off reversed','LFP -> EEG on reversed')
                end
        
                
                
            case 'Coherence'
                
                % plotting nondirectional coherence
                subplot(2,numel(D.condlist),sub_condition),
                plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind1_off(:,1), :, :, trialind(1)), 1)),'r','LineWidth',3);
                hold on, plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind1_on(:,1), :, :, trialind(1)), 1)),'b','LineWidth',3);
                plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind1_off(:,1), :, :, trialind(2)), 1)),'r--','LineWidth',3);
                plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind1_on(:,1), :, :, trialind(2)), 1)),'b--','LineWidth',3);
                xlim([5 x_lim]);
                title(['L Gpi ', subcondition])
                if sub_condition==1
                    legend('EEG -> LFP off','EEG -> LFP on','EEG -> LFP off shifted','EEG -> LFP on shifted')
                end
                
                if numel(lfp)>1
                    subplot(2,numel(D.condlist),numel(D.condlist)+sub_condition),
                    plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind1_off(:,2), :, :, trialind(1)), 1)),'r','LineWidth',3);
                    hold on, plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind1_on(:,2), :, :, trialind(1)), 1)),'b','LineWidth',3);
                    plot(Dc_off.frequencies, squeeze(mean(Dc_off(ind1_off(:,2), :, :, trialind(2)), 1)),'r--','LineWidth',3);
                    plot(Dc_on.frequencies, squeeze(mean(Dc_on(ind1_on(:,2), :, :, trialind(2)), 1)),'b--','LineWidth',3);
                    xlim([5 x_lim]);
                    title(['R Gpi ', subcondition])
    %                 legend('EEG -> LFP off','EEG -> LFP on','EEG -> LFP off shifted','EEG -> LFP on shifted')
                end

        end
        



         
              
    end

    spm_mkdir(['D:\home\results Percept Project\', initials]);
    saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_Connectivity_', method, '_',condition, '.png'])


    end