function dbs_eeg_percept_blur_faces(name_patient)
    path_patient= ['\\piazzolla\vlad_shared\', name_patient];
    path_jsons = '\processed_MotionCapture\jsons';
    path_originalvideo= '\raw_MotionCapture\';

    name_videos=dir([path_patient, path_jsons, '\GH*']);

    original_videos=dir(fullfile(path_patient, path_originalvideo, '*.MP4'));

    if ~isempty(strfind(path_patient,'LN_PR_D001'))
        framerate=23.976043137696813;
    else
        % I changed framerate to 25 from the first patient onward
        framerate=25;
    end

    for k=1:size(name_videos,1)
        
        jsonfileList=dir(fullfile(path_patient, path_jsons, name_videos(k).name ,[name_videos(k).name, '*.json']));

        for i=1:size(jsonfileList,1)
            fname = [jsonfileList(i).folder, '\', jsonfileList(i).name];
            fid = fopen(fname);
            raw = fread(fid,inf);
            str = char(raw');
            fclose(fid);
            val = jsondecode(str);
        
            people(i)=size(val.people,1);
        
            for num_ppl=1:people(i)
                Person{num_ppl}.pose_keypoints(i,:)=val.people(num_ppl).pose_keypoints_2d;
            end  
        
        end
        

        % check which Person is the patient
videoIn=VideoReader(fullfile(original_videos(k).folder, original_videos(k).name));

goodframe_found=0;
fr_start=1;
while goodframe_found==0
    videoFrame=read(videoIn,fr_start);

    
    imshow(videoFrame);
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



for fr=fr_start+1:size(jsonfileList,1)
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
        
        
        %% face 
        %if you want to anonymize only the patient face thatn you can use
        %interpolate_frames, otherwise I wouldn't use the same function but
        %maybe write another one, or just use the signal without any
        %interpolating. This is because other than the patient the other
        %people are constantly popping in and out of the video and
        %therefore interpolating missed frames doesn't make sense
        face(:,:,k)=interpolate_frames(Person_patient.pose_keypoints(:,1:2),framerate);
%         video_file.face2=interpolate_frames(Person2.pose_keypoints(:,1:2),framerate);
%         video_file.face3=interpolate_frames(Person3.pose_keypoints(:,1:2),framerate);
%         video_file.face4=interpolate_frames(Person4.pose_keypoints(:,1:2),framerate);
%         video_file.face5=interpolate_frames(Person5.pose_keypoints(:,1:2),framerate);

    end
        
        for k=1:size(name_videos,1)
    
        videoIn = VideoReader(fullfile(original_videos(k).folder, original_videos(k).name));
        videoOut = VideoWriter([fullfile(original_videos(k).folder, 'blurred', name_videos(k).name), '_blurred'],'MPEG-4');
        videoOut.FrameRate=videoIn.FrameRate;
        open(videoOut);
        for f=1:videoIn.NumFrames
            frame = read(videoIn,f);
            bbox=[round(face(f,:,k))-150,300,300];
            videoFrame_cropped=imcrop(frame, bbox);
            videoFrame_blurred=MyBlur(videoFrame_cropped,15);
%             videoFrame = insertShape(frame, 'FilledRectangle', bbox, 'Color','black', 'Opacity',1);
            frame(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:)=videoFrame_blurred;
            writeVideo(videoOut,frame);      
        end
        close(videoOut)
       
        end
    
    

end

function blurredRGBImage = MyBlur(rgbImage, windowWidth)
    % Split into separate color channels.
    [redChannel, greenChannel, blueChannel] = imsplit(rgbImage);
    % Blur each color channel independently.
    blurredR = blur(redChannel, windowWidth);
    blurredG = blur(greenChannel, windowWidth);
    blurredB = blur(blueChannel, windowWidth);
    % Recombine into a single RGB image.
    blurredRGBImage = cat(3, blurredR, blurredG, blurredB);
end

function [output] = blur(A,w)
    [row col] = size(A);
    A=uint8(A);
    B=nan(size(A) + (2*w));
    B(w+1:end-w,w+1:end-w)=A;
    output = 0*A;
    for i=w+1:row+w
      for j=w+1:col+w
        tmp=B(i-w:i+w,j-w:j+w);
        output(i-w,j-w)=mean(tmp(~isnan(tmp)));
      end
    end
    output=uint8(output);
end