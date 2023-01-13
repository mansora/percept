function track_goodframe_save(initials)

    close all
    
    dbsroot = '\\piazzolla\vlad_shared';

    try
        [files_tot_off, ~, ~, ~] = dbs_subjects_percept(initials, 1);
        [files_tot_on, ~, ~, ~] = dbs_subjects_percept(initials, 2);
    catch
        D = [];
        return
    end

    files_tot=[files_tot_off; files_tot_on];
    for vids=1:size(files_tot,1)
        filename_video=fullfile(files_tot{vids,4}, '\');
        videoname=spm_file(files_tot{vids,4}, 'filename');
        filename_tracked=strrep(filename_video,'jsons', 'videos');
        filename_tracked=[filename_tracked(1:end-1), '_tracked_anonym.MP4'];
        videoIn=VideoReader(filename_tracked);

        goodframe_found=0;
        fr_start=1;

        while goodframe_found==0

            videoFrame=read(videoIn,fr_start);
    
            if exist((fullfile(filename_video, '\..\..\tracking_frame\', ['tracking_frame_' videoname,'.mat'])), 'file')
                data_temp=load(fullfile(filename_video, '\..\..\tracking_frame\', ['tracking_frame_' videoname,'.mat']));
                bbox=data_temp.bbox;
                fr_start=data_temp.fr_start;
                videoFrame=read(videoIn,fr_start);
                videoFrame_temp=insertShape(videoFrame,'Rectangle',bbox,'LineWidth',5);
                figure, imshow(videoFrame_temp);
                title('Previously saved tracking of first frame')
                goodframe_found=1;
            else
                figure, imshow(videoFrame);
                title('Draw a rectangle around the patients head, if patient is not visible make rectangle very big')
                roi = drawrectangle;
                bbox=round(roi.Position);
    
                if bbox(4)<size(videoFrame,1)-100
                    goodframe_found=1;
                else
                    fr_start=fr_start+1;
                    
                end
                    
            end
            
        end
    
        save(fullfile(filename_video, '\..\..\tracking_frame\', ['tracking_frame_' videoname,'.mat']), 'bbox', 'fr_start');
    end


end