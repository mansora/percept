function anonymize_videos_for_LED(name_vid)
    % file to  cut out oly LED section in the videos and discard the rest
    % This needs to be run only once for every patients
    filename_video='Z:\LN_PR_D001\processed_MotionCapture\LED_videos\';
%     name_vid='GH010165.mp4';
    videoIn = VideoReader([filename_video,name_vid]);
    
    frame = read(videoIn,1);
    imshow(frame)
    title('Please draw a rectangle to indicate the area of the LED')
    roi = drawrectangle;
    bbox=round(roi.Position);

    videoOut = VideoWriter(['D:\MotionCapture\LED_', name_vid],'MPEG-4');
    videoOut.FrameRate=videoIn.FrameRate;
%     videoOut.Duration=videoIn.Duration;
    open(videoOut);
    videoIn = VideoReader([filename_video, name_vid]);
    while hasFrame(videoIn)
        frame = readFrame(videoIn);
%         videoFrame = insertShape(frame, 'FilledRectangle', bbox);
%         imshow(videoFrame)
        videoFrame=imcrop(frame, bbox);
        writeVideo(videoOut,videoFrame);      
    end
    close(videoOut)
end

% videoIn2 = VideoReader(['D:\MotionCapture\LED_', name_vid]);