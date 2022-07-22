function [Person people]=dbs_eeg_percept_read_json(filename_video, videoname);
    
    fileList = dir(fullfile(filename_video, [videoname, '*.json']));

    for i=1:size(fileList,1)
        fname = [filename_video fileList(i).name];
        fid = fopen(fname);
        raw = fread(fid,inf);
        str = char(raw');
        fclose(fid);
        val = jsondecode(str);
    
        people(i)=size(val.people,1);
        
        for num_ppl=1:people(i)
            %% TODO add the hand key points to the data later too
           Person{num_ppl}.pose_keypoints(i,:)=val.people(num_ppl).pose_keypoints_2d;
            if ~isempty(val.people(num_ppl).hand_left_keypoints_2d)
            Person{num_ppl}.hand_left_keypoints(i,:)=val.people(num_ppl).hand_left_keypoints_2d;
            end
            if ~isempty(val.people(num_ppl).hand_right_keypoints_2d)
            Person{num_ppl}.hand_right_keypoints(i,:)=val.people(num_ppl).hand_right_keypoints_2d;
            end 
        end    
    
    end


end