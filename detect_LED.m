
%% TODO: automatically pick the video that corresponds to the EEG recording
clear
close all
videoIn = VideoReader('X:\LN_PR_D001\raw_MotionCapture\Part_1\GH010171.mp4');
numFrame=1;

frame = read(videoIn,1);
imshow(frame)
% title('Please draw a rectangle to indicate the area of the LED')
% roi = drawrectangle;
% bbox=round(roi.Position);
% videoFrame = insertShape(frame, 'FilledRectangle', bbox);
% imshow(videoFrame)

title('Please select point 1 to detect LED')
[x1,y1] = getpts;
x1=round(x1);
y1=round(y1);

title('Please select point 2 to detct LED')
[x2,y2] = getpts;
x2=round(x2);
y2=round(y2);

title('Please select point 3 to detect LED')
[x3,y3] = getpts;
x3=round(x3);
y3=round(y3);




% while hasFrame(videoIn)
% videoFrame = readFrame(videoIn);
for f=1:videoIn.NumFrames
videoFrame=read(videoIn,f);

% temp_1=randperm(bbox(3));
% temp_2=randperm(bbox(4));

% frame_temp=videoFrame(bbox(2)+temp_2(1), bbox(1)+temp_2(1),:);
% for i=2:5
%     frame_temp=frame_temp+videoFrame(bbox(2)+temp_2(1), bbox(1)+temp_2(1),:);
% end

% LED_condition1(numFrame,:)=frame_temp/5;    
% LED_condition2(numFrame,:)=videoFrame(bbox(2), bbox(1),:);
% LED_condition(numFrame,:)=LED_condition(numFrame,:)/num_points;   

LED_condition1(numFrame,:)=videoFrame(y1, x1,:);
LED_condition2(numFrame,:)=videoFrame(y2, x2,:);
LED_condition3(numFrame,:)=videoFrame(y3, x3,:);
numFrame=numFrame+1;
end

LED_condition_grayscale=mean(LED_condition1,2)/3;
figure, plot(LED_condition_grayscale);
thresh_=prctile(LED_condition_grayscale,95);
hold on, yline(thresh_);
LED_condition_binary=LED_condition_grayscale>thresh_;

LED_condition_grayscale=mean(LED_condition2,2)/3;
figure, plot(LED_condition_grayscale);
thresh_=prctile(LED_condition_grayscale,96.5);
hold on, yline(thresh_);
LED_condition_binary=LED_condition_grayscale>thresh_;
% LED sequence is too fast to be a good match with video--> is best to go
% slower next time.

LED_condition_grayscale=mean(LED_condition3,2)/3;
figure, plot(LED_condition_grayscale);
thresh_=prctile(LED_condition_grayscale,95);
hold on, yline(thresh_);
LED_condition_binary=LED_condition_grayscale>thresh_;


x_temp=find(LED_condition_binary);
start_first_sequence=x_temp(1)/videoIn.FrameRate;
end_second_sequence=x_temp(end)/videoIn.FrameRate;

% videoIn = VideoReader('X:\LN_PR_D001\raw_MotionCapture\Part_1\GH010169.mp4');
% numFrame=1;
% while hasFrame(videoIn)
% videoFrame = readFrame(videoIn);
%     if LED_condition_binary(numFrame)
% %         videoFrame = insertMarker(videoFrame, [bbox(2), bbox(1)], 'o', ...
% %          'Color', 'white', 'Size', 50); 
%         videoFrame=insertShape(videoFrame, 'FilledRectangle', bbox, 'Opacity',0.1);
%     end
% numFrame=numFrame+1;
% imshow(videoFrame);
% end

% for i=1:size(LED_condition_binary,1)
% fname = ['D:\MotionCapture\openpose\output_jsons\GH010031_cut_',num2str(i-1,'%012.f'),'_keypoints.json'];
% fid = fopen(fname);
% raw = fread(fid,inf);
% str = char(raw');
% fclose(fid);
% val = jsondecode(str);
% val_armpoint3(i)=val.people.pose_keypoints_2d(8);
% val_armpoint4(i)=val.people.pose_keypoints_2d(11);
% val_armpoint6(i)=val.people.pose_keypoints_2d(17);
% val_armpoint7(i)=val.people.pose_keypoints_2d(20);
% end
% 
% figure,
% plot(val_armpoint3)
% hold on,
% plot(val_armpoint4)
% hold on,
% plot(val_armpoint6)
% hold on,
% plot(val_armpoint7)
