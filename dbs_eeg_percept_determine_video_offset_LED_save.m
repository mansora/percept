function dbs_eeg_percept_determine_video_offset_LED_save(initials, rec_id)


    dbsroot = '\\piazzolla\vlad_shared';

    if nargin <2
        rec_id = 1;
    end
    
    if nargin <3
        condition = 'R';
    end
    
    
    try
        [files_tot, seq, root, details] = dbs_subjects_percept(initials, rec_id);
    catch
        D = [];
        return
    end
    
    for f=1:size(files_tot,2)
        files=files_tot(f,:);

        [LED_offset_start, LED_offset_end, LED_signal]=...
            dbs_eeg_percept_determine_video_offset_LED([files{5},'.mp4'], files{3}, files{1});    
        
        file_table = readcell(fullfile(dbsroot, initials, [initials '.xlsx']));
        file_table(cellfun(@(x) any(ismissing(x)), file_table)) = {''};

        ind_file=find(strcmp(file_table(:,1), spm_file(files{1},'basename')));
%         file_table_array(ind_file-1,5)=0;
%         file_table_array(ind_file-1,6)=LED_offset_start;
%         file_table_array(ind_file-1,7)=LED_offset_end;
        
        file_table(ind_file,5)={0};
        file_table(ind_file,6)={LED_offset_start};
        file_table(ind_file,7)={LED_offset_end};

        save(fullfile(dbsroot, initials, 'processed_MotionCapture', 'LED_signals', ['LED_', file_table{ind_file, 3} '.mat']),...
            'LED_signal');
        
        writecell(file_table,fullfile(dbsroot, initials, [initials '.xlsx']))

    end



end