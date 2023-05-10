function dbs_eeg_percept_convert_preprocessed2ft(initials, rec_id, condition)    

    try
        [files_, seq, root, details] = dbs_subjects(initials, rec_id);
    catch
        return;
    end
    
    if nargin<3
        condition = 'R';
    end
    
    
    cd(fullfile(root, condition));
    
    % files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    try
        files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
        
    end


    D = spm_eeg_load(files);

    rawLFP=D(D.indchantype('LFP'),:,:);

    save(['rawLFP_', D.fname], 'rawLFP')


    cfg = [];
    cfg.dataset = files;
    data = ft_preprocessing(cfg);

    save(['ft_', data.hdr.orig.fname], 'data')

    

end
