initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};


condition='R';
figure('units','normalized','outerposition',[0 0 1 1]),

for subs=1:7
    
    [files_, seq, root, details] = dbs_subjects_percept(initials{subs}, 1);
    cd(fullfile(root, condition));
   
    files = spm_select('FPList','.', ['LFP_spect_', '.', initials{subs} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    if isempty(files)
        files = spm_select('FPList','.', ['LFP_spect_', initials{subs} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    D1_LFP = spm_eeg_load(files);

    
   
    [files_, seq, root, details] = dbs_subjects_percept(initials{subs}, 2);
    cd(fullfile(root, condition));
    
    
    files = spm_select('FPList','.', ['LFP_spect_', '.', initials{subs} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
    if isempty(files)
        files = spm_select('FPList','.', ['LFP_spect_', initials{subs} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
    end
    D2_LFP = spm_eeg_load(files);

    



       
            
            
       if numel(details.chan)==1   
            
            subplot(4, 2, subs), plot(D2_LFP.frequencies, squeeze(D2_LFP(:,:,1,1)), 'b','LineWidth',3)
            hold on, plot(D1_LFP.frequencies, squeeze(D1_LFP(:,:,1,1)),'b--','LineWidth',3)
%             legend(append(details.chan{1}(end-3), ' on'),append(details.chan{1}(end-3), ' off'))
       else
            newcolors = {'red','blue'};
            colororder(newcolors)
            subplot(4, 2, subs), plot(D2_LFP.frequencies, squeeze(D2_LFP(:,:,1,1)),'LineWidth',3)
            hold on, plot(D1_LFP.frequencies, squeeze(D1_LFP(:,:,1,1)),'--','LineWidth',3)
%             legend('L on','R on', 'L off', 'R off')
        end

        title(initials{subs}(7:end))
        set(gca,'FontSize',18)
        set(gca,'FontWeight','bold')
        set(gca,'LineWidth',4)
        a = get(gca,'XTickLabel');  
        set(gca,'linewidth',4)
        if subs==6
            set(gca,'XTickLabel',a,'fontsize',18,'FontWeight','bold')
        else
            set(gca,'XTickLabel','')
        end

                
            
    
           
        

        

    

end