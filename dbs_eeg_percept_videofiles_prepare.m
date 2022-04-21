function video_file_fieldtrip=dbs_eeg_percept_videofiles_prepare(eegfile, filename_video, videoname);

fileList = dir(fullfile(filename_video, [videoname, '*.json']));
% if ~isempty(strfind(eegfile,'LN_PR_D001'))
% 
%     % note this has to be exactly the same in this script and the
%     % detect_offset_LED one otherwise the final number of datapoints after
%     % upsampling won't be the same, which will cause issues for the
%     % synchronization (the offset stamps will be based on a different file length)
%     framerate=23.976043137696813;
% else
%     % I changed framerate to 25 from the first patient onward 
%     % change to the exact number is not exactly 25
%     % actually it is apparently
%     framerate=25;
% end


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
        Person{num_ppl}.hand_left_keypoints(i,:)=val.people(1).hand_left_keypoints_2d;
        end
        if ~isempty(val.people(num_ppl).hand_right_keypoints_2d)
        Person{num_ppl}.hand_right_keypoints(i,:)=val.people(num_ppl).hand_right_keypoints_2d;
        end 
    end    

end

% check which Person is the patient
filename_tracked=strrep(filename_video,'jsons', 'videos');
filename_tracked=[filename_tracked(1:end-1), '_tracked_anonym.MP4'];
videoIn=VideoReader(filename_tracked);

goodframe_found=0;
fr_start=1;
while goodframe_found==0
    videoFrame=read(videoIn,fr_start);
%     for num_ppl=1:people(fr_start)
%         videoFrame=insertText(videoFrame, Person{num_ppl}.pose_keypoints(fr_start,1:2), num2str(num_ppl),...
%             'FontSize',18,'TextColor','white');
%     end
    
    figure, imshow(videoFrame);
    title('Draw a rectangle around the patients head, if patient is not visible make rectangle very big')
    roi = drawrectangle;
    bbox=round(roi.Position);

    if bbox(4)<size(videoFrame,1)-100
        for num_ppl=1:people(fr_start)
            if bbox(1)<Person{num_ppl}.pose_keypoints(fr_start,1) && ...
                   Person{num_ppl}.pose_keypoints(fr_start,1)<bbox(1)+bbox(3) &&...
                   bbox(2)<Person{num_ppl}.pose_keypoints(fr_start,2) && ...
                   Person{num_ppl}.pose_keypoints(fr_start,2)<bbox(2)+bbox(4)
                ind_patient=num_ppl;
            end
        end
        
        Person_patient.pose_keypoints(fr_start,:)=Person{ind_patient}.pose_keypoints(fr_start,:);
        goodframe_found=1;
    else
        fr_start=fr_start+1;
        Person_patient.pose_keypoints(fr_start,:)=zeros(size(Person{1}.pose_keypoints(fr_start,:)));
    end
end



for fr=fr_start+1:size(fileList,1)
%     videoFrame=read(videoIn,fr);
    clear ind_patient

    for num_ppl=1:people(fr)
%         videoFrame=insertText(videoFrame, Person{num_ppl}.pose_keypoints(fr,1:2), num2str(num_ppl),...
%             'FontSize',18,'TextColor','white');
        
        if bbox(1)<Person{num_ppl}.pose_keypoints(fr,1) && ...
           Person{num_ppl}.pose_keypoints(fr,1)<bbox(1)+bbox(3) &&...
           bbox(2)<Person{num_ppl}.pose_keypoints(fr,2) && ...
           Person{num_ppl}.pose_keypoints(fr,2)<bbox(2)+bbox(4)

            ind_patient=num_ppl;
        end
    
    end

    if exist('ind_patient', 'var')
%         videoFrame=insertText(videoFrame, Person{ind_patient}.pose_keypoints(fr,1:2)+10, 'P',...
%             'FontSize',18,'TextColor','white');

        Person_patient.pose_keypoints(fr,:)=Person{ind_patient}.pose_keypoints(fr,:);
    else
        for num_ppl=1:people(fr)
            if bbox(1)-10<Person{num_ppl}.pose_keypoints(fr,1) && ...
               Person{num_ppl}.pose_keypoints(fr,1)<bbox(1)+bbox(3)+10 &&...
               bbox(2)-10<Person{num_ppl}.pose_keypoints(fr,2) && ...
               Person{num_ppl}.pose_keypoints(fr,2)<bbox(2)+bbox(4)+10

                ind_patient=num_ppl;
                % update bbox
                bbox(1)=Person{ind_patient}.pose_keypoints(fr,1)-80;
                bbox(3)=160;
                bbox(2)=Person{ind_patient}.pose_keypoints(fr,2)-80;
                bbox(4)=160;

%                 videoFrame=insertText(videoFrame, Person{ind_patient}.pose_keypoints(fr,1:2)+10, 'P',...
%                'FontSize',18,'TextColor','white');

                Person_patient.pose_keypoints(fr,:)=Person{ind_patient}.pose_keypoints(fr,:);
            end
        end

        if ~exist('ind_patient', 'var')
%         videoFrame=insertText(videoFrame, [10,10], 'No Patient Detected!',...
%             'FontSize',18,'TextColor','white');
        Person_patient.pose_keypoints(fr,:)=zeros(size(Person{1}.pose_keypoints(fr,:)));
        end

    end
    
%     imshow(videoFrame);       
end

% the parts to track are the left and right hand, left and right foot, also
% the head I assume (to track tremor)
% anything else? TODO ask Vladimir


% TODO see if adding any of these body parts as a rigid body
% (combination of all points involved in hand movement for ex) increase the
% quality of the tracking. As it is now there are a lot of missing or
% jittered frames


framerate=videoIn.FrameRate;

trial=zeros(14,size(fileList,1));
temp_right_hand1=interpolate_frames(Person_patient.pose_keypoints(:,19:20), framerate);
trial(1:2,:)=temp_right_hand1(:,1:2)';
% right hand
if isfield(Person_patient, 'hand_right_keypoints')
    temp_right_hand2=interpolate_frames(Person_patient.hand_right_keypoints(:,1:2), framerate);
    trial(3:4,:)=temp_right_hand2(:,1:2)';
end


% figure, plot(video_file.right_hand1(:,3))
% figure, plot(video_file.right_hand2(:,3))


temp_left_hand1=interpolate_frames(Person_patient.pose_keypoints(:,10:11), framerate);
trial(5:6,:)=temp_left_hand1(:,1:2)';

% left hand
if isfield(Person_patient, 'hand_left_keypoints')
    temp_left_hand2=interpolate_frames(Person_patient.hand_left_keypoints(:,1:2), framerate);
    trial(7:8,:)=temp_left_hand2(:,1:2)';
end

% figure, plot(video_file.left_hand1(:,1))
% figure, plot(video_file.left_hand2(:,1))

% right foot
temp_right_foot=interpolate_frames(Person_patient.pose_keypoints(:,40:41), framerate);
trial(9:10,:)=temp_right_foot(:,1:2)';


% left foot
temp_left_foot=interpolate_frames(Person_patient.pose_keypoints(:,31:32), framerate);
trial(11:12,:)=temp_left_foot(:,1:2)';

% head
temp_head=interpolate_frames(Person_patient.pose_keypoints(:,1:2), framerate);
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

% D=spm_eeg_ft2spm(video_file_fieldtrip);

end