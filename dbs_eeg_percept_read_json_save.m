function dbs_eeg_percept_read_json_save(initials,rec_id)

dbsroot = '\\piazzolla\vlad_shared';

    if nargin <2
        rec_id = 1;
    end
    
  
    try
        [files_tot, seq, root, details] = dbs_subjects_percept(initials, rec_id);
    catch
        D = [];
        return
    end
    
    for f=7:size(files_tot,1)
        files=files_tot(f,:);

        [Person, people]=dbs_eeg_percept_read_json(fullfile(files{4}, '\'), spm_file(files{4}, 'filename'));

        save(['Z:\LN_PR_D006\processed_MotionCapture\json_signals\json_signals_', spm_file(files{4}, 'filename'), '.mat'], 'people', 'Person')

    end

end
