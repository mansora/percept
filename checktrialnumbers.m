function output=checktrialnumbers(condition)


    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005', 'LN_PR_D006','LN_PR_D007','LN_PR_D008','LN_PR_D009'};

    for i=1:numel(initials)

    [files_, seq, root, details] = dbs_subjects_percept(initials{i}, 1);
    cd(fullfile(root, condition));
    
    try
        files = spm_select('FPList','.', ['^.' initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials{i} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end

    try
        D1 = spm_eeg_load(files);
        for k=1:numel(D1.condlist)
            output.trialsoff(i,k,:)=numel(find(strcmp(D1.conditions,D1.condlist{k})));
            output.condlist=D1.condlist;
        end
    catch
        warning(['patient ', initials{i}, ' Off stim does not have', condition])
    end

    [files_, seq, root, details] = dbs_subjects_percept(initials{i}, 2);
    cd(fullfile(root, condition));
    
    try
        files = spm_select('FPList','.', ['^.' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
    end

    try
        D2= spm_eeg_load(files);
        for k=1:numel(D2.condlist)
            output.trialson(i,k,:)=numel(find(strcmp(D2.conditions,D2.condlist{k})));
            output.condlist=D2.condlist;
        end
    catch
        warning(['patient ', initials{i}, ' On stim does not have', condition])
    end


    end
  




end