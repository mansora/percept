function add_markers_to_tracked_video(initials, rec_id, condition)

    try
    [files, seq, root, details] = dbs_subjects_percept(initials, rec_id);
    catch
        D = [];
        return
    end

    for f = 1:size(files, 1)
        if ~isequal(condition, seq{f})
            continue;
        end
    
        files=files(f,:);
    end

    if details.process_logfiles==1 && ~isempty(files{3})
        disp('Preparing logfile...')
        [trl trialinfo]=dbs_eeg_percept_logfiles_prepare(files{1}, files{3});
    else
        disp('no logfile available for this EEG dataset')
        trl=[];
    end



    if details.process_videos==1 && ~isempty(files)
        disp('Preparing and synchronizing video file with EEG')
        video_file=dbs_eeg_percept_videofiles_prepare(files{1}, fullfile(files{4}, '\'), spm_file(files{4}, 'filename'));
    
    if strcmp(details.vidoffset_tocompute{f}, 'no')
        video_file.LED_offset_start=details.vidoffset(1,f);
        video_file.LED_offset_end=details.vidoffset(2,f);
        video_file.LED_signal=load(files{6}).LED_signal;
    else
        [LED_offset_start, LED_offset_end, LED_signal]=dbs_eeg_percept_determine_video_offset_LED([files{5},'.mp4'], files{3}, files{1});
        video_file.LED_offset_start=LED_offset_start;
        video_file.LED_offset_end=LED_offset_end;
        video_file.LED_signal=LED_signal;
        % TODO write outputs of the video offset to the excel file
        % note that you may have to do this not now but after
        % dbs_eeg_percept_synchronise as it corrects stuff there, but then
        % you'll have to look in the code to change some stuff
       
    end

    [eeg_file_withvid, offset_end]=dbs_eeg_percept_synchronise_video(video_file, files{1});

    
    filename_video=['Z:\', initials,'\processed_MotionCapture\videos\', spm_file(files{4}, 'filename'), '_tracked_anonym'];
    videoIn = VideoReader([filename_video, '.MP4']);

    
    
    videoOut = VideoWriter(['Z:\', initials,'\processed_MotionCapture\videos_marked\', spm_file(files{4}, 'filename'), '_tracked_anonym_marked'],'MPEG-4');
    videoOut.FrameRate=videoIn.FrameRate;
     open(videoOut);
     videoIn= VideoReader([filename_video, '.MP4']);
        while hasFrame(videoIn{nv})
            frame = readFrame(videoIn);
    %         videoFrame = insertShape(frame, 'FilledRectangle', bbox);
    %         imshow(videoFrame)
            videoFrame=imcrop(frame, bbox(nv,:));
            writeVideo(videoOut,videoFrame);      
        end
        close(videoOut)
    end
end


% videoIn2 = VideoReader(['D:\MotionCapture\LED_', name_vid]);

end