function [offset_start, offset_end, n2]=dbs_eeg_percept_determine_video_offset_LED(filename_LED_video, input_logfile, eegfile)
videoIn = VideoReader(filename_LED_video);

% numFrame=1;
% frame = read(videoIn,1);
% imshow(frame)
% title(['Please select several points to detect LED'])
% [x,y] = getpts;
% x=round(x);
% y=round(y);

% change sampling rate back to 2 percent
n_sampling=floor(0.1*(videoIn.Height*videoIn.Width)); % sample 2% of the pixels 
y=randi([1,videoIn.Height],1,n_sampling);
x=randi([1,videoIn.Width],1,n_sampling);

header_info=ft_read_header(eegfile);
temp=load(input_logfile);
OutputFile=temp.OutputFile;   
t=find(strcmp(OutputFile(:,1), 'InitPulses'));
endsequence=0;
if ~isempty(t)
    stamp_time=cell2mat(OutputFile(t,3));
    stamp_value=cell2mat(OutputFile(t,2));
    stamp_time=stamp_time(find(stamp_value~=0));
    temp_stamp_time=stamp_time(1);
    stamp_time=stamp_time-temp_stamp_time;
    
    t=find(strcmp(OutputFile(:,1), 'EndPulses'));
    if ~isempty(t)
        endsequence=1;
        endstamp_time=cell2mat(OutputFile(t,3));
        endstamp_value=cell2mat(OutputFile(t,2));
        endstamp_time=endstamp_time(find(endstamp_value~=0));
        endstamp_time=endstamp_time-temp_stamp_time;
        stamp_time=[stamp_time; endstamp_time];
    end
    
    timeline_LED=linspace( 0, videoIn.Duration, videoIn.NumFrames)';
    k=dsearchn(timeline_LED, stamp_time);
    reconstruct_LED=zeros(1,videoIn.NumFrames);
    reconstruct_LED(1,k)=1;

%     % or when video is cut in half you can use this
%     timeline_LED=linspace( 0, header_info.nSamples/header_info.Fs, ...
%     header_info.nSamples*(videoIn.FrameRate/header_info.Fs))';
%     k=dsearchn(timeline_LED, stamp_time);
%     reconstruct_LED=zeros(1,42530);
%     reconstruct_LED(1,k)=1;
% %     figure, plot(reconstruct_LED)
% to fix LN_PR_D001, PMT, 2: LED_signal=[LED_signal_part1, linspace(LED_signal_part1(end), LED_signal_part2(1), 173),LED_signal_part2];
    
else
    disp('no initializing LED sequence found in logfile, attempting to reconstruct from eegfile')
    eventss=ft_read_event(eegfile); 
    eventss=squeeze(struct2cell(eventss));
    if contains(eegfile, 'LN_PR_D005_20220401_00120.vhdr')
        eventss=eventss(:,142:end);
        eventss(3,:)=num2cell(cell2mat(eventss(3,:))-eventss{3,1});
    elseif contains(eegfile, 'LN_PR_D005_20220401_0012.vhdr')
        eventss=eventss(:,1:141);
    end
    % TODO this needs to change for patient D006 onwards
    stamp_time=cell2mat(eventss(3,find(strcmp(eventss(1,:), 'Toggle'))))/header_info.Fs;
    timeline_LED=linspace( 0, videoIn.Duration, videoIn.NumFrames)';
    k=dsearchn(timeline_LED, stamp_time');
    reconstruct_LED=zeros(1,videoIn.NumFrames);
    reconstruct_LED(1,k)=1;
end


% parfor f=1:videoIn.NumFrames
%     videoFrame=read(videoIn,f);
%     LED_condition(:,:,f)=[videoFrame(sub2ind(size(videoFrame), y, x, ones(1,n_sampling)))',...
%                           videoFrame(sub2ind(size(videoFrame), y, x, 2*ones(1,n_sampling)))',...
%                           videoFrame(sub2ind(size(videoFrame), y, x, 3*ones(1,n_sampling)))'];
% 
% %     R=double(videoFrame(y,x,1));
% %     LED_conditionR(:,f)=R(:);
% end
% poolobj = gcp('nocreate');
% delete(poolobj);

for f=1:videoIn.NumFrames
    videoFrame=read(videoIn,f);
    LED_condition(:,:,f)=[videoFrame(sub2ind(size(videoFrame), y, x, ones(1,n_sampling)))',...
                          videoFrame(sub2ind(size(videoFrame), y, x, 2*ones(1,n_sampling)))',...
                          videoFrame(sub2ind(size(videoFrame), y, x, 3*ones(1,n_sampling)))'];

%     R=double(videoFrame(y,x,1));
%     LED_conditionR(:,f)=R(:);
end

LED_conditionR=double(squeeze(LED_condition(:,1,:)));
% LED_conditionR=squeeze(mean(LED_condition(:,:,:),3)/3);
% LED_conditionR=double(LED_conditionR);
LED_conditionR=LED_conditionR-mean(LED_conditionR,2);
reconstruct_LED=reconstruct_LED/max(reconstruct_LED);
% reconstruct_LED=max(LED_conditionR(:))*reconstruct_LED;

% temp=LED_conditionR;
% temp(find(temp<std(temp,[],2)))=0;
% for i=1:size(LED_conditionR,1)     
% %     [c, lags] = xcorr(temp(i,:), reconstruct_LED, 'coeff');
%     [c, lags] = xcorr(LED_conditionR(i,:), reconstruct_LED, 'coeff');
%     [mc, mci] = max(abs(c));
%     max_crosscorr(i)=mc/median(abs(c));
%     lag_crosscorr(i)=lags(mci);
% end

% first get rid of all the obviously bad frames, which have more than 95%
% values that are below 1
nn=1;
ind_badpixels=[];
for i=1:size(LED_conditionR,1)
    if size(find(abs(LED_conditionR(i,:))<10),2)/size(LED_conditionR,2)>0.9
        ind_badpixels(nn)=i;
        nn=nn+1;
    elseif size(find((LED_conditionR(i,:))>50),2)/size(LED_conditionR,2)<0.03
        ind_badpixels(nn)=i;
        nn=nn+1;
    end

end

if ~isempty(ind_badpixels)
    LED_conditionR(ind_badpixels,:)=[];
end

nn=1;
good_pixels=[];
for i=1:size(LED_conditionR,1)
    if size(find((LED_conditionR(i,:))>50),2)/size(LED_conditionR,2)>0.03 && size(find(abs(LED_conditionR(i,:))<25),2)/size(LED_conditionR,2)>0.8
        good_pixels(nn)=i;
        nn=nn+1;
    end
end

if ~isempty(good_pixels)
    LED_conditionR=LED_conditionR(good_pixels,:);
end



for i=1:size(LED_conditionR,1)     
%     [c, lags] = xcorr(temp(i,:), reconstruct_LED, 'coeff');
    [c, lags] = xcorr(LED_conditionR(i,:), reconstruct_LED*max(LED_conditionR(i,:)), 'coeff');
    [mc, mci] = max(abs(c));
    max_crosscorr(i)=mc/median(abs(c));
    lag_crosscorr(i)=lags(mci);
end


[~, best_pixel]=max(max_crosscorr);


%% upsampling both data files to the sampling rate of EEG
reconstruct_LED=(reconstruct_LED-min(reconstruct_LED))/(max(reconstruct_LED)-min(reconstruct_LED));

reconstruct_LED_fieldtrip.label={'reconstruct_LED'};
reconstruct_LED_fieldtrip.time={linspace(0,size(reconstruct_LED,2)/videoIn.FrameRate, size(reconstruct_LED,2))};
reconstruct_LED_fieldtrip.trial={reconstruct_LED};
reconstruct_LED_fieldtrip.fsample=videoIn.FrameRate;



cfg=[];
cfg.resamplefs= header_info.Fs;
reconstruct_LED_fieldtrip = ft_resampledata(cfg, reconstruct_LED_fieldtrip);


% LED_conditionR_fieldtrip.label=cellstr(string(1:size(LED_conditionR,1)))';
LED_conditionR_fieldtrip.label={'LED_conditionR_bestpixel'};
LED_conditionR_fieldtrip.time={linspace(0,size(LED_conditionR,2)/videoIn.FrameRate, size(LED_conditionR,2))};
LED_conditionR_fieldtrip.trial={LED_conditionR(best_pixel,:)};
LED_conditionR_fieldtrip.fsample=videoIn.FrameRate;

cfg=[];
cfg.resamplefs= header_info.Fs;
LED_conditionR_fieldtrip = ft_resampledata(cfg, LED_conditionR_fieldtrip);


% if there is not LED sequence at the end of the file, synching is only
% done based on the first sequence
if endsequence==0
    
    n1 = detrend(reconstruct_LED_fieldtrip.trial{1});
    n2 = detrend(LED_conditionR_fieldtrip.trial{1});

    TF1=(abs(n1)>mean(n1)+4*std(n1));
    TF2=(abs(n2)>mean(n2)+4*std(n2)); 

    [c, lags] = xcorr(n1, n2, 'coeff');
    [mc, mci] = max(abs(c));
    
    
    offset_start=lags(mci);
    offset_end=offset_start;

elseif endsequence==1
    
    n1 = detrend(reconstruct_LED_fieldtrip.trial{1});
    n2 = detrend(LED_conditionR_fieldtrip.trial{1});

    TF1=(abs(n1)>mean(n1)+3*std(n1));
    TF2=(abs(n2)>mean(n2)+3*std(n2)); 
    
    temp1=find(TF1(1:floor(size(TF1,2)/2)));
    temp2=find(TF2(1:floor(size(TF2,2)/2)));

    if isempty(temp1) || isempty(temp2)
        offset_start=[];
    else
        size_window_start=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];
        
        [c, lags] = xcorr(n1(size_window_start(1):size_window_start(2)), n2(size_window_start(1):size_window_start(2)), 'coeff');
        [mc, mci] = max(abs(c));

        offset_start=lags(mci);
    end
    
    temp1=find(TF1(floor(size(TF1,2)/2):end));
    temp2=find(TF2(floor(size(TF2,2)/2):end));

    if isempty(temp1) || isempty(temp2)
        offset_end=0;
    else
        
        
        size_window_end=[min(temp1(1), temp2(1)), max(temp1(end), temp2(end))];

        %% TODO: add checks to see if there is good crosscorrelation
        % issue with that is that you have to first figure out what a good
        % value is because it is generally lower than what vladimir has in his
        % data
    
        [c, lags] = xcorr(n1(size_window_end(1)+floor(size(TF1,2)/2):size_window_end(2)+floor(size(TF1,2)/2)), ...
            n2(size_window_end(1)+floor(size(TF2,2)/2):size_window_end(2)+floor(size(TF2,2)/2)), 'coeff');
        
        [mc, mci] = max(abs(c));

        offset_end=lags(mci);
    end

    if isempty(offset_end) || offset_end==0
        offset_end=offset_start;
    end

    if isempty(offset_start) || offset_start==0
        offset_start=offset_end;
    end
end

% TODO convert offsets to the sampling rate of EEG 
% (by either upsampling before or after you calculate the offset)

% figure, plot(LED_conditionR(best_pixel,:))
% % 
% itr_=1*100;
% figure, 
% for i=1+itr_:100+itr_
% subplot(10,10,i-itr_), plot(double(squeeze(LED_conditionR(i,:,1))))
% end
