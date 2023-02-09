function dbs_percept_rawdata_plot(initials, condition)

    
    [files_, seq, root, details] = dbs_subjects_percept(initials, 1);
    cd(fullfile(root, condition));
    
    try
        files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end

    try
        D1 = spm_eeg_load(files);
    catch
        warning(['patient ', initials, ' Off stim does not have', condition])
    end

    [files_, seq, root, details] = dbs_subjects_percept(initials, 2);
    cd(fullfile(root, condition));
    
    try
        files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
    end

    try
        D2= spm_eeg_load(files);
    catch
        warning(['patient ', initials, ' On stim does not have', condition])
    end


        if (exist('D1', 'var') && exist('D2', 'var'))
            trial_num=randi([1 min(size(D1,3),size(D2,3))]);
    
            figure('units','normalized','outerposition',[0 0 1 1]),
            lfpchan = D1.indchantype('LFP');
            titl_fig=[condition, '_LFP_rawdata'];
            if numel(lfpchan)==1
                plot(D2.time, squeeze(D2(lfpchan,:,trial_num)),'LineWidth',3)
                hold on, plot(D1.time, squeeze(D1(lfpchan,:,trial_num)),'--','LineWidth',3)
                legend(append(details.chan{1}(end-3), ' on'),append(details.chan{1}(end-3), ' off'))
                title(D1.chanlabels(lfpchan))
                set(gca,'FontSize',18)
                set(gca,'LineWidth',3)
            else
                scale_max=ceil(max([squeeze(D2(lfpchan(1),:,trial_num)) squeeze(D1(lfpchan(1),:,trial_num)) squeeze(D2(lfpchan(2),:,trial_num)) squeeze(D1(lfpchan(2),:,trial_num))]));
                scale_min=ceil(min([squeeze(D2(lfpchan(1),:,trial_num)) squeeze(D1(lfpchan(1),:,trial_num)) squeeze(D2(lfpchan(2),:,trial_num)) squeeze(D1(lfpchan(2),:,trial_num))]));
    
    
                subplot(2,1,1), plot(D2.time, squeeze(D2(lfpchan(1),:,trial_num)),'LineWidth',3)
                hold on, plot(D1.time, squeeze(D1(lfpchan(1),:,trial_num)),'--','LineWidth',3)
                legend(append(D1.chanlabels{lfpchan(1)}(end-3), ' on'),append(D1.chanlabels{lfpchan(1)}(end-3), ' off'))
                title(D1.chanlabels(lfpchan(1)))
                set(gca,'FontSize',18)
                set(gca,'LineWidth',3)
                ylim([scale_min scale_max])
    
                subplot(2,1,2), plot(D2.time, squeeze(D2(lfpchan(2),:,trial_num)),'LineWidth',3)
                hold on, plot(D1.time, squeeze(D1(lfpchan(2),:,trial_num)),'--','LineWidth',3)
                legend(append(D1.chanlabels{lfpchan(2)}(end-3), ' on'),append(D1.chanlabels{lfpchan(2)}(end-3), ' off'))
                title(D1.chanlabels(lfpchan(2)))
                set(gca,'FontSize',18)
                set(gca,'LineWidth',3)
                ylim([scale_min scale_max])
    
            end

        
        elseif exist('D2', 'var')

            trial_num=randi([1 size(D2,3)]);

            figure('units','normalized','outerposition',[0 0 1 1]),
            lfpchan = D2.indchantype('LFP');
            titl_fig=[condition, '_LFP_rawdata'];
            if numel(lfpchan)==1
                plot(D2.time, squeeze(D2(lfpchan,:,trial_num)),'LineWidth',3)
                legend(append(details.chan{1}(end-3), ' on'))
                title(D2.chanlabels(lfpchan))
                set(gca,'FontSize',18)
                set(gca,'LineWidth',3)
            else
                scale_max=ceil(max([squeeze(D2(lfpchan(1),:,trial_num))  squeeze(D2(lfpchan(2),:,trial_num)) ]));
                scale_min=ceil(min([squeeze(D2(lfpchan(1),:,trial_num))  squeeze(D2(lfpchan(2),:,trial_num)) ]));
    
                subplot(2,1,1), plot(D2.time, squeeze(D2(lfpchan(1),:,trial_num)),'LineWidth',3)
                legend(append(D2.chanlabels{lfpchan(1)}(end-3), ' on'))
                title(D2.chanlabels(lfpchan(1)))
                set(gca,'FontSize',18)
                set(gca,'LineWidth',3)
                ylim([scale_min scale_max])
    
                subplot(2,1,2), plot(D2.time, squeeze(D2(lfpchan(2),:,trial_num)),'LineWidth',3)
                legend(append(D2.chanlabels{lfpchan(2)}(end-3), ' on'))
                title(D2.chanlabels(lfpchan(2)))
                set(gca,'FontSize',18)
                set(gca,'LineWidth',3)
                ylim([scale_min scale_max])

            end


        elseif exist('D1', 'var')

            trial_num=randi([1 size(D1,3)]);

            figure('units','normalized','outerposition',[0 0 1 1]),
            lfpchan = D1.indchantype('LFP');
            titl_fig=[condition, '_LFP_rawdata'];
            if numel(lfpchan)==1
                plot(D1.time, squeeze(D1(lfpchan,:,trial_num)),'LineWidth',3)
                legend(append(details.chan{1}(end-3), ' off'))
                title(D1.chanlabels(lfpchan))
                set(gca,'FontSize',18)
                set(gca,'LineWidth',3)
            else
                scale_max=ceil(max([squeeze(D1(lfpchan(1),:,trial_num))  squeeze(D1(lfpchan(2),:,trial_num)) ]));
                scale_min=ceil(min([squeeze(D1(lfpchan(1),:,trial_num))  squeeze(D1(lfpchan(2),:,trial_num)) ]));
    
                subplot(2,1,1), plot(D1.time, squeeze(D1(lfpchan(1),:,trial_num)),'LineWidth',3)
                legend(append(D1.chanlabels{lfpchan(1)}(end-3), ' off'))
                title(D1.chanlabels(lfpchan(1)))
                set(gca,'FontSize',18)
                set(gca,'LineWidth',3)
                ylim([scale_min scale_max])
    
                subplot(2,1,2), plot(D1.time, squeeze(D1(lfpchan(2),:,trial_num)),'LineWidth',3)
                legend(append(D1.chanlabels{lfpchan(2)}(end-3), ' off'))
                title(D1.chanlabels(lfpchan(2)))
                set(gca,'FontSize',18)
                set(gca,'LineWidth',3)
                ylim([scale_min scale_max])

            end



        end

        spm_mkdir(['D:\home\results Percept Project\', initials]);
        saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_lfp_rawdata', condition, '.png'])



       



    

end