function keypoint_series_interp=interpolate_frames(keypoint_series, framerate)

    % this only makes sense for the the person who you know is always in
    % the video (the patient) otherwise people who are dissappearing also
    % get frames with value zero which you shouldn't be interpolating
    timeLine=linspace(1,size(keypoint_series,1)/framerate, size(keypoint_series,1));
    
    for k=1:size(keypoint_series,2)

%         figure, 
%         subplot(4,1,1), plot(timeLine, keypoint_series(:,k));
%         ylim([min(keypoint_series(:,k)) max(keypoint_series(:,k))])
    
        nullpoints=find(keypoint_series(:,k)==0);
        while size(nullpoints,1)>0
            stop_interp=find(keypoint_series(nullpoints(1):end,k)~=0);
            for points=0:stop_interp(1)-2
                if nullpoints(1)~=1
                    keypoint_series(nullpoints(1)+points,k)=...
                        (keypoint_series(nullpoints(1)-1,k)+keypoint_series(nullpoints(1)+stop_interp(1)-1,k))/2;
                else
%                     disp('first frame is zero do something about that')
%                     nullpoints=nullpoints(2:end);
                      keypoint_series(nullpoints(1)+points,k)=...
                          (0.001+keypoint_series(nullpoints(1)+stop_interp(1)-1,k))/2;
                end
            end
            nullpoints=find(keypoint_series(:,k)==0);
        end
    
%         subplot(4,1,2), plot(timeLine, keypoint_series(:,k));
%         ylim([min(keypoint_series(:,k)) max(keypoint_series(:,k))])
    
        TF= ischange(keypoint_series(:,k), 'mean','Threshold',1000);
        % I don't think it's very possible for TF to start with a 1, but if
        % it does you'll have to apply the same solution as is discused or
        % the section below
        TFF=diff(TF);
        start_interp=find(TFF==1);
    
        for i=1:size(find(TFF==1),1)
            stop_interp=find(TFF(start_interp(i):end)==-1);
            if ~isempty(stop_interp)
                for points=1:stop_interp(1)-1
                    keypoint_series(start_interp(i)+points,k)=...
                        (keypoint_series(start_interp(i),k)+keypoint_series(stop_interp(1)+start_interp(i),k))/2;
                end
            end
        end
        keypoint_series_temp(:,k)=keypoint_series(:,k);
    
%         subplot(4,1,3), plot(timeLine, keypoint_series_temp(:,k));
%         ylim([min(keypoint_series(:,k)) max(keypoint_series(:,k))])
    
        badframes=abs(keypoint_series_temp(:,k)-mean(keypoint_series_temp(:,k)))>2*std(keypoint_series_temp(:,k));
        % note that this code as it is now will get you in trouble if the
        % very first frame is bad. Quick fix is to not let that happen so:
        badframes(1)=0;
        % but in the future you'll have to find a better way, because now
        % you're not going to be fixing the first frame if that's bad. Not
        % a big issue as that is unlikely to happen anyway
        diff_badframes=diff(badframes);
        start_interp=find(diff_badframes==1);
        
    
        for i=1:size(find(diff_badframes==1),1)
            stop_interp=find(diff_badframes(start_interp(i):end)==-1);
            if ~isempty(stop_interp)
                for points=1:stop_interp(1)-1
                    keypoint_series_temp(start_interp(i)+points,k)=...
                        (keypoint_series_temp(start_interp(i),k)+keypoint_series_temp(stop_interp(1)+start_interp(i),k))/2;
                       %(keypoint_series_temp(start_interp(i))+keypoint_series_temp(stop_interp(1)+start_interp(i)))/2;
                end
            end
        end
    
        keypoint_series_interp(:,k)=keypoint_series_temp(:,k);
    
%         subplot(4,1,4), plot(timeLine, keypoint_series_interp(:,k));
%         ylim([min(keypoint_series(:,k)) max(keypoint_series(:,k))])
        
    end
    
        
end






