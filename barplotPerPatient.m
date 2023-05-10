function barplotPerPatient(freq_range)

initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
figure('units','normalized','outerposition',[0 0 1 1]),

for sub=1:7

tasks={'R', 'ACT', 'PMT', 'SST', 'HPT', 'POUR', 'WALK', 'SPEAK', 'WRITE', 'SGT'};
tasks_all_off={};
tasks_all_on={};
ind_=1;

clear D1_LFP_all D2_LFP_all
for t=1:numel(tasks)

    [files_, seq, root, details] = dbs_subjects_percept(initials{sub}, 1);
    cd(fullfile(root, tasks{t}));
    try
        files = spm_select('FPList','.', ['LFP_spect_', '.', initials{sub} '_rec_' num2str(1) '_' tasks{t} '_[0-9]*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['LFP_spect_', initials{sub} '_rec_' num2str(1) '_' tasks{t} '_[0-9]*.mat']);
        end
        D1_LFP = spm_eeg_load(files);
        switch t
            case {2, 3}
                D1_LFP_all(:,:,ind_)=mean(D1_LFP(:,:,1,:),4);
            case 4 
                D1_LFP_all(:,:,ind_)=mean(D1_LFP(:,:,1,[1,4]),4);
            case {1, 5 , 6 , 7 , 8 , 9 , 10}
                D1_LFP_all(:,:,ind_)=D1_LFP(:,:,1,1);
        end
        tasks_all_off{ind_}=tasks{t};




        [files_, seq, root, details] = dbs_subjects_percept(initials{sub}, 2);
        cd(fullfile(root, tasks{t}));
        
        try
            files = spm_select('FPList','.', ['LFP_spect_', '.', initials{sub} '_rec_' num2str(2) '_' tasks{t} '_[0-9]*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['LFP_spect_', initials{sub} '_rec_' num2str(2) '_' tasks{t} '_[0-9]*.mat']);
            end
            D2_LFP = spm_eeg_load(files);
    
            switch t
                
                case {2 , 3}
                    D2_LFP_all(:,:,ind_)=mean(D2_LFP(:,:,1,:),4);
                case 4 
                    D2_LFP_all(:,:,ind_)=mean(D2_LFP(:,:,1,[1,4]),4);
                case {1, 5 , 6 , 7 , 8 , 9 , 10}
                    D2_LFP_all(:,:,ind_)=D2_LFP(:,:,1,1);
            end
    
            tasks_all_on{ind_}=tasks{t};
            ind_=ind_+1;
        
            
            
        catch
            warning(['patient ', initials{sub}, ' On stim does not have', tasks{t}])
        end
        
    catch
        warning(['patient ', initials{sub}, ' Off stim does not have', tasks{t}])
    end

    

end








 
    
    indmin = find(min(abs(D2_LFP.frequencies-freq_range(1)))==abs(D2_LFP.frequencies-freq_range(1)));
    indmax = find(min(abs(D2_LFP.frequencies-freq_range(2)))==abs(D2_LFP.frequencies-freq_range(2)));


%     freq_range=[6 14];
    D_diff=squeeze(mean(D2_LFP_all(:,indmin:indmax,:),2))-squeeze(mean(D1_LFP_all(:,indmin:indmax,:),2));
%     D_diff=zscore(D_diff, [], 2);
    subplot(2,4,sub)
    boxchart(D_diff', 'LineWidth', 5)
%     ylim([-0.5 5])
%     bh=boxplot(D_diff')
%     set(bh,'LineWidth', 5);
    
    if sub==1
        ylabel(['PSD On-Off ', num2str(freq_range(1)), '-',num2str(freq_range(2)), 'Hz '], 'FontSize', 30, 'FontWeight','bold')
    end

    

    xlabel(initials{sub}(7:10), 'FontSize', 30, 'FontWeight','bold')
    
    a = get(gca,'XTickLabel');  
    set(gca,'linewidth',5)
    set(gca,'XTickLabel',a,'fontsize',20,'FontWeight','bold')     
    
    if size(D2_LFP_all,1)==1
%         legend({'right'})
        xticklabels({'right'})
        hold on, plot(1, D_diff', 'o', 'MarkerSize', 10, 'LineWidth', 5,'HandleVisibility','off')
        text(ones(ceil(size(D_diff,1)/2),1)+0.3,D_diff(1:2:end), tasks_all_off(1:2:end), 'FontWeight', 'bold', 'FontSize', 10)
        text(ones(floor(size(D_diff,1)/2),1)+0.6,D_diff(2:2:end), tasks_all_off(2:2:end), 'FontWeight', 'bold', 'FontSize', 10)

    else
%         legend({'left', 'right'})
        xticklabels({'left', 'right'})
        hold on, plot(1, D_diff(1,:)', 'o', 'MarkerSize', 10, 'LineWidth', 5,'HandleVisibility','off')
        text(ones(ceil(size(D_diff,2)/2),1)-0.5,D_diff(1,1:2:end), tasks_all_off(1:2:end), 'FontWeight', 'bold', 'FontSize', 10)
        text(ones(floor(size(D_diff,2)/2),1)-0.9,D_diff(1,2:2:end), tasks_all_off(2:2:end), 'FontWeight', 'bold', 'FontSize', 10)

        hold on, plot(2, D_diff(2,:)', 'o', 'MarkerSize', 10, 'LineWidth', 5,'HandleVisibility','off')
        text(2*ones(ceil(size(D_diff,2)/2),1)+0.3,D_diff(2,1:2:end), tasks_all_off(1:2:end), 'FontWeight', 'bold', 'FontSize', 10)
        text(2*ones(floor(size(D_diff,2)/2),1)+0.6,D_diff(2,2:2:end), tasks_all_off(2:2:end), 'FontWeight', 'bold', 'FontSize', 10)
    end



    spm_mkdir(['D:\dystonia project\IamBrain\permutationstats']);
    saveas(gcf, ['D:\dystonia project\IamBrain\permutationstats\',  'barplotPersubject','_', 'PSD On-Off ', num2str(freq_range(1)), '-',num2str(freq_range(2)), 'Hz ', '.png'])
    
end

end


