function [x1,x2]=dbs_percept_ofset_analysis(initials, condition)

    
    [files_, seq, root, details] = dbs_subjects_percept(initials, 1);
    cd(fullfile(root, condition));
    
    try
        files1 = spm_select('FPList','.', ['^.' initials '_rec_' num2str(1) '_' condition '_[0-9]*_offsets.mat']);
    catch
        files1 = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(1) '_' condition '_[0-9]*_offsets.mat']);
    end
    
    if isempty(files1)
        files1 = spm_select('FPList','.', ['^' initials '_rec_' num2str(1) '_' condition '_[0-9]*_offsets.mat']);
    end

    
   

    [files_, seq, root, details] = dbs_subjects_percept(initials, 2);
    cd(fullfile(root, condition));
    
    try
        files2 = spm_select('FPList','.', ['^.' initials '_rec_' num2str(2) '_' condition '_[0-9]*_offsets.mat']);
    catch
        files2 = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(2) '_' condition '_[0-9]*_offsets.mat']);
    end
    
    if isempty(files2)
        files2 = spm_select('FPList','.', ['^' initials '_rec_' num2str(2) '_' condition '_[0-9]*_offsets.mat']);
    end

    if size(files1,1)<2

        load(files1);
        off_offset_stamp_start=offset_stamp_start;
        off_offset_stamp_end=offset_stamp_end;
        x1=abs(off_offset_stamp_start-off_offset_stamp_end);
        load(files2);
        on_offset_stamp_start=offset_stamp_start;
        on_offset_stamp_end=offset_stamp_end;
        x2=abs(on_offset_stamp_start-on_offset_stamp_end);
    else
        for i=1:size(files1,1)
            D1 = load(files1{i,:});
            off_offset_stamp_start=offset_stamp_start;
            off_offset_stamp_end=offset_stamp_end;
            x1(i)=abs(off_offset_stamp_start-off_offset_stamp_end);
            D2 = load(files2{i,:});
            on_offset_stamp_start=offset_stamp_start;
            on_offset_stamp_end=offset_stamp_end;
            x2(i)=abs(on_offset_stamp_start-on_offset_stamp_end);
        end
        x1=mean(x1);
        x2=mean(x2);
    end






