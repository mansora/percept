function dbs_eeg_evoked_tf_plot_all(condition)
initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005', 'LN_PR_D007','LN_PR_D008','LN_PR_D009'};

for sub=1:numel(initials)

    try
        [files_, seq, root, details] = dbs_subjects(initials{sub}, 1);
        cd(fullfile(root, condition));
        
        files = spm_select('FPList','.', ['rmtf_', '.', initials{sub} '_rec_' num2str(1) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['rmtf_', initials{sub} '_rec_' num2str(1) '_' condition '\w*.mat']);
        end
        D_off = spm_eeg_load(files);
    catch
        warning(['patient ', initials{sub}, ' Off stim does not have', condition])
    end

    [files_, seq, root, details] = dbs_subjects(initials{sub}, 2);
    cd(fullfile(root, condition));
    
    try
        files = spm_select('FPList','.', ['rmtf_', '.', initials{sub} '_rec_' num2str(2) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['rmtf_', initials{sub} '_rec_' num2str(2) '_' condition '\w*.mat']);
        end
        D_on = spm_eeg_load(files);
    catch
        warning(['patient ', initials{sub}, ' On stim does not have', condition])
    end

end


end
