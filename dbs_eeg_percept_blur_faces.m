function dbs_eeg_percept_blur_faces()
    path_patient= 'Z:\LN_PR_D001\';
    path_jsons = 'processed_MotionCapture\jsons';
    path_originalvideo= 'raw_MotionCapture\';

    name_videos=dir([path_patient, path_jsons, '\GH*']);

    original_videos=dir(fullfile(path_patient, path_originalvideo, '*.MP4'));

    if ~isempty(strfind(path_patient,'LN_PR_D001'))
        framerate=24;
    else
        % I changed framerate to 25 from the first patient onward
        framerate=25;
    end

    for k=2 % 1:size(name_videos,1)
        
        jsonfileList=dir(fullfile(path_patient, path_jsons, name_videos(k).name ,[name_videos(k).name, '*.json']));

        for i=1:size(jsonfileList,1)
            fname = [jsonfileList(i).folder, '\', jsonfileList(i).name];
            fid = fopen(fname);
            raw = fread(fid,inf);
            str = char(raw');
            fclose(fid);
            val = jsondecode(str);
        
            people(i)=size(val.people,1);
        
            if size(val.people,1)>0
                Person1.pose_keypoints(i,:)=val.people(1).pose_keypoints_2d;
            end
            if size(val.people,1)>1
                Person2.pose_keypoints(i,:)=val.people(2).pose_keypoints_2d;
            end
            if size(val.people,1)>2
                Person3.pose_keypoints(i,:)=val.people(3).pose_keypoints_2d;
           end
            if size(val.people,1)>3
                Person4.pose_keypoints(i,:)=val.people(4).pose_keypoints_2d;
            end
            if size(val.people,1)>4
                Person5.pose_keypoints(i,:)=val.people(5).pose_keypoints_2d;
            end
        
        end
        
        
        
        %% face 
        %if you want to anonymize only the patient face thatn you can use
        %interpolate_frames, otherwise I wouldn't use the same function but
        %maybe write another one, or just use the signal without any
        %interpolating. This is because other than the patient the other
        %people are constantly popping in and out of the video and
        %therefore interpolating missed frames doesn't make sense
        face=interpolate_frames(Person1.pose_keypoints(:,1:2),framerate);
%         video_file.face2=interpolate_frames(Person2.pose_keypoints(:,1:2),framerate);
%         video_file.face3=interpolate_frames(Person3.pose_keypoints(:,1:2),framerate);
%         video_file.face4=interpolate_frames(Person4.pose_keypoints(:,1:2),framerate);
%         video_file.face5=interpolate_frames(Person5.pose_keypoints(:,1:2),framerate);

        
        
    
        videoIn = VideoReader(fullfile(original_videos(k).folder, original_videos(k).name));
        videoOut = VideoWriter([fullfile(original_videos(k).folder, 'anonymized', name_videos(k).name), '_anonymized'],'MPEG-4');
        videoOut.FrameRate=videoIn.FrameRate;
        open(videoOut);
        for f=1:videoIn.NumFrames
            frame = read(videoIn,f);
            bbox=[round(face(f,:))-60,150,150];
            videoFrame_cropped=imcrop(frame, bbox);
            videoFrame_blurred=MyBlur(videoFrame_cropped,10);
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