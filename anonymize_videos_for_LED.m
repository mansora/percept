function anonymize_videos_for_LED(patient_name)
    % file to  cut out oly LED section in the videos and discard the rest
    % This needs to be run only once for every patients
    filename_video=['Z:\', patient_name,'\processed_MotionCapture\LED_videos\'];
    vids=dir(fullfile(filename_video, 'GH*.MP4'));
    for nv=1:size(vids,1)
        videoIn{nv} = VideoReader(fullfile(vids(nv).folder, vids(nv).name));
        frame = read(videoIn{nv},1);
        imshow(frame)
        title('Please draw a rectangle to indicate the area of the LED')
        roi = drawrectangle;
        bbox(nv,:)=round(roi.Position);
    end  

    for nv=1:size(vids,1)
        
    
        videoOut = VideoWriter(['Z:\', patient_name,'\processed_MotionCapture\LED_videos\LED_', vids(nv).name],'MPEG-4');
        videoOut.FrameRate=videoIn{nv}.FrameRate;
    %     videoOut.Duration=videoIn.Duration;
        open(videoOut);
        videoIn{nv} = VideoReader(fullfile(vids(nv).folder, vids(nv).name));
        while hasFrame(videoIn{nv})
            frame = readFrame(videoIn{nv});
    %         videoFrame = insertShape(frame, 'FilledRectangle', bbox);
    %         imshow(videoFrame)
            videoFrame=imcrop(frame, bbox(nv,:));
            writeVideo(videoOut,videoFrame);      
        end
        close(videoOut)
    end
end


% videoIn2 = VideoReader(['D:\MotionCapture\LED_', name_vid]);