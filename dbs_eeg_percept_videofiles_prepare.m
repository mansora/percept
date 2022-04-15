function video_file_fieldtrip=dbs_eeg_percept_videofiles_prepare(eegfile, filename_video, videoname);

fileList = dir(fullfile(filename_video, [videoname, '*.json']));
if ~isempty(strfind(eegfile,'LN_PR_D001'))

    % note this has to be exactly the same in this script and the
    % detect_offset_LED one otherwise the final number of datapoints after
    % upsampling won't be the same, which will cause issues for the
    % synchronization (the offset stamps will be based on a different file length)
    framerate=23.976043137696813;
else
    % I changed framerate to 25 from the first patient onward 
    % change to the exact number is not exactly 25
    % actually it is apparently
    framerate=25;
end


for i=1:size(fileList,1)
    fname = [filename_video fileList(i).name];
    fid = fopen(fname);
    raw = fread(fid,inf);
    str = char(raw');
    fclose(fid);
    val = jsondecode(str);

    people(i)=size(val.people,1);

    if size(val.people,1)>0
        Person1.pose_keypoints(i,:)=val.people(1).pose_keypoints_2d;
        if ~isempty(val.people(1).hand_left_keypoints_2d)
        Person1.hand_left_keypoints(i,:)=val.people(1).hand_left_keypoints_2d;
        end
        if ~isempty(val.people(1).hand_right_keypoints_2d)
        Person1.hand_right_keypoints(i,:)=val.people(1).hand_right_keypoints_2d;
        end
    end
%     if size(val.people,1)>1
%         Person2.pose_keypoints(i,:)=val.people(2).pose_keypoints_2d;
%         Person2.hand_left_keypoints(i,:)=val.people(2).hand_left_keypoints_2d;
%         Person2.hand_right_keypoints(i,:)=val.people(2).hand_right_keypoints_2d;
%     end
%     if size(val.people,1)>2
%         Person3.pose_keypoints(i,:)=val.people(3).pose_keypoints_2d;
%         Person3.hand_left_keypoints(i,:)=val.people(3).hand_left_keypoints_2d;
%         Person3.hand_right_keypoints(i,:)=val.people(3).hand_right_keypoints_2d;
%     end
%     if size(val.people,1)>3
%         Person4.pose_keypoints(i,:)=val.people(4).pose_keypoints_2d;
%         Person4.hand_left_keypoints(i,:)=val.people(4).hand_left_keypoints_2d;
%         Person4.hand_right_keypoints(i,:)=val.people(4).hand_right_keypoints_2d;
%     end

end

% the parts to track are the left and right hand, left and right foot, also
% the head I assume (to track tremor)
% anything else? TODO ask Vladimir


% TODO see if adding any of these body parts as a rigid body
% (combination of all points involved in hand movement for ex) increase the
% quality of the tracking. As it is now there are a lot of missing or
% jittered frames

trial=zeros(14,size(fileList,1));
temp_right_hand1=interpolate_frames(Person1.pose_keypoints(:,19:21), framerate);
trial(1:2,:)=temp_right_hand1(:,1:2)';
% right hand
if isfield(Person1, 'hand_right_keypoints')
    temp_right_hand2=interpolate_frames(Person1.hand_right_keypoints(:,1:3), framerate);
    trial(3:4,:)=temp_right_hand2(:,1:2)';
end


% figure, plot(video_file.right_hand1(:,3))
% figure, plot(video_file.right_hand2(:,3))


temp_left_hand1=interpolate_frames(Person1.pose_keypoints(:,10:12), framerate);
trial(5:6,:)=temp_left_hand1(:,1:2)';

% left hand
if isfield(Person1, 'hand_left_keypoints')
    temp_left_hand2=interpolate_frames(Person1.hand_left_keypoints(:,1:3), framerate);
    trial(7:8,:)=temp_left_hand2(:,1:2)';
end

% figure, plot(video_file.left_hand1(:,1))
% figure, plot(video_file.left_hand2(:,1))

% right foot
temp_right_foot=interpolate_frames(Person1.pose_keypoints(:,40:42), framerate);
trial(9:10,:)=temp_right_foot(:,1:2)';


% left foot
temp_left_foot=interpolate_frames(Person1.pose_keypoints(:,31:33), framerate);
trial(11:12,:)=temp_left_foot(:,1:2)';

% head
temp_head=interpolate_frames(Person1.pose_keypoints(:,1:3), framerate);
trial(13:14,:)=temp_head(:,1:2)';


% TODO check if the x y coordinate order is correct
label_video={'hand_R1_x', 'hand_R1_y', 'hand_R2_x', 'hand_R2_y', ...
    'hand_L1_x', 'hand_L1_y', 'hand_L2_x', 'hand_L2_y', ...
    'foot_R_x', 'foot_R_y', 'foot_L_x', 'foot_L_y', ...
    'head_x', 'head_y'}';

video_file_fieldtrip.label=label_video;
video_file_fieldtrip.time={linspace(0,size(fileList,1)/framerate, size(fileList,1))};

video_file_fieldtrip.trial={trial};
video_file_fieldtrip.fsample=framerate;

header_info=ft_read_header(eegfile);
cfg=[];
cfg.resamplefs= header_info.Fs;
video_file_fieldtrip = ft_resampledata(cfg, video_file_fieldtrip);

end