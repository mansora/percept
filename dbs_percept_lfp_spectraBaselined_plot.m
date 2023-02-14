function dbs_percept_lfp_spectraBaselined_plot(initials, condition)
     close all
    [files_, seq, root, details] = dbs_subjects_percept(initials, 1);
    cd(fullfile(root, condition));
    try
        files = spm_select('FPList','.', ['LFP_spect_', '.', initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['LFP_spect_', initials '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
        end
        D1_LFP_temp = spm_eeg_load(files);
    
       
    catch
        warning(['patient ', initials, ' Off stim does not have', condition])
    end

    if ~strcmp(condition, 'R')
            cd(fullfile(root, 'R'));
            files = spm_select('FPList','.', ['LFP_spect_', '.', initials '_rec_' num2str(1) '_R_[0-9]*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['LFP_spect_', initials '_rec_' num2str(1) '_R_[0-9]*.mat']);
            end
            D1_LFP_baseline = spm_eeg_load(files);
            D1_LFP_baseline=squeeze(D1_LFP_baseline(:,:,1,:));
    else
            D1_LFP_baseline=ones(2,97);
    end


    [files_, seq, root, details] = dbs_subjects_percept(initials, 2);
    cd(fullfile(root, condition));
    
    try
        files = spm_select('FPList','.', ['LFP_spect_', '.', initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['LFP_spect_', initials '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        end
        D2_LFP_temp = spm_eeg_load(files);
    
        
    catch
        warning(['patient ', initials, ' On stim does not have', condition])
    end

    if ~strcmp(condition, 'R')
            cd(fullfile(root, 'R'));
            files = spm_select('FPList','.', ['LFP_spect_', '.', initials '_rec_' num2str(2) '_R_[0-9]*.mat']);
            if isempty(files)
                files = spm_select('FPList','.', ['LFP_spect_', initials '_rec_' num2str(2) '_R_[0-9]*.mat']);
            end
            D2_LFP_baseline = spm_eeg_load(files);
            D2_LFP_baseline=squeeze(D2_LFP_baseline(:,:,1,:));
   else
            D2_LFP_baseline=ones(2,97);
    end

    lfpchan = D2_LFP_temp.indchantype('LFP');

     for condz=1:numel(D1_LFP_temp.conditions)
        %% 

        D1_LFP_all(:,:,condz)=log(squeeze(D1_LFP_temp(1,:,1,condz))) - log(D1_LFP_baseline);
        D2_LFP_all(:,:,condz)=log(squeeze(D2_LFP_temp(1,:,1,condz))) - log(D2_LFP_baseline);

        if strcmp(D1_LFP_temp.chanlabels{lfpchan(1)}(end-3),'L')
            D1_LFP_1_all(:, condz)=log(squeeze(D1_LFP_temp(1,:,1,condz))) - log(D1_LFP_baseline(1,:));
        else
            D1_LFP_2_all(:, condz)=log(squeeze(D1_LFP_temp(1,:,1,condz))) - log(D1_LFP_baseline(1,:));
        end
        if numel(lfpchan)>1
            if strcmp(D1_LFP_temp.chanlabels{lfpchan(2)}(end-3),'L')
                D1_LFP_1_all(:, condz)=log(squeeze(D1_LFP_temp(2,:,1,condz))) - log(D1_LFP_baseline(2,:));
            else
                D1_LFP_2_all(:, condz)=log(squeeze(D1_LFP_temp(2,:,1,condz))) - log(D1_LFP_baseline(2,:));
            end
        end

        if strcmp(D2_LFP_temp.chanlabels{lfpchan(1)}(end-3),'L')
            D2_LFP_1_all(:, condz)=log(squeeze(D2_LFP_temp(1,:,1,condz))) - log(D2_LFP_baseline(1,:));
        else
            D2_LFP_2_all(:, condz)=log(squeeze(D2_LFP_temp(1,:,1,condz))) - log(D2_LFP_baseline(1,:));
        end
        if numel(lfpchan)>1
            if strcmp(D2_LFP_temp.chanlabels{lfpchan(2)}(end-3),'L')
                D2_LFP_1_all(:, condz)=log(squeeze(D2_LFP_temp(2,:,1,condz))) - log(D2_LFP_baseline(2,:));
            else
                D2_LFP_2_all(:, condz)=log(squeeze(D2_LFP_temp(2,:,1,condz))) - log(D2_LFP_baseline(2,:));
            end
        end

     end






        if exist('D2_LFP_temp', 'var') && exist('D1_LFP_temp', 'var')

            figure('units','normalized','outerposition',[0 0 1 1]),
            for cond=1:numel(D2_LFP_temp.conditions)
                titl_fig=[condition, '' , strsplit(D2_LFP_temp.conditions{cond},'_')];
                titl_fig_save=[condition, '' , D2_LFP_temp.conditions{cond}];
                
                subplot(1, numel(D2_LFP_temp.conditions),cond), plot(D2_LFP_temp.frequencies, squeeze(D2_LFP_all(:,:,cond)),'b','LineWidth',3)
                hold on, plot(D1_LFP_temp.frequencies, squeeze(D1_LFP_all(:,:,cond)),'r--','LineWidth',3)
                if numel(details.chan)==1
                    legend(append(details.chan{1}(end-3), ' on'),append(details.chan{1}(end-3), ' off'))
                else
                    legend('L on','R on', 'L off', 'R off')
                end
                title(titl_fig)
                set(gca,'FontSize',18)
                set(gca,'LineWidth',3)
                
            end
    
            spm_mkdir(['D:\home\results Percept Project\', initials]);
            saveas(gcf, ['D:\home\results Percept Project\', initials,'\',initials,'_lfp_spectraBaselined', condition ,'.png'])
        end

       

        

    
   


   


   


end