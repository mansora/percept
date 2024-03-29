n1=zscore(detrend(n1));
n2=zscore(detrend(n2));
figure, plot(diff(n2))
hold on, plot(TF2*max(n2))
figure, plot(n1)
hold on, plot(TF1*max(n1))

figure, plot(n1)
hold on, plot(n2)
hold on, figure, plot(TF1*mean(n1))

figure, plot(n1)
hold on, plot(n2(abs(offset_stamp_start)-3704:end)+15)


reftrl = linspace(0, size_EEG/dataEEG.fsample, size_EEG);
    
trl_offset  = zeros(1, size(reftrl,2));
trl_offset= trl_offset  + (offset_end)*(reftrl/reftrl(end));
trl_offset=round(trl_offset);

temp_ind=(1:size(reftrl,2))+trl_offset;

n2_synched=n2(:,temp_ind(temp_ind<size(n2,2)));
synched_padded=zeros(size(n2,1), size(dataEEG.trial{1},2));
synched_padded(:,EEGmarker_start:EEGmarker_start+size(n2_synched,2)-1)=n2_synched;


figure, plot(synched_padded)
hold on, plot(cell2mat(eventss(3,LED_markersEEG)), mean(n2_synched),'r*')

figure, plot(n2(offss:end)), hold on, yline(10)

hold on, plot([temp_start,temp_end], mean(n2), 'k*')
hold on, plot([EEGmarker_start,EEGmarker_end], mean(n2), 'r*')
hold on, plot([114693 415825], mean(n2), 'c*')

figure, 
hold on,
for i=1:20
%     plot(squeeze(D(i+74,:,1)))
%     plot(video_file.trial{1}(i,:))
%     plot(synched(i,:))
%     plot(synched_padded(i,:))
%     plot(dataVideo.trial{1}(i,:))
    plot(eeg_file_withvid.trial{1}(i+40,:))
end

hold on, plot(eeg_file_withvid.trial{1}(40,:))

hold on, plot(eeg_file_withvid.trial{1}(34:39,:))


%%
sigg=108;
figure, plot(squeeze(LED_conditionR(sigg,:,1)))

LED_signal_temp=squeeze(LED_conditionR(sigg,:,1));
LED_conditionR_fieldtrip.label={'LED_conditionR_bestpixel'};
LED_conditionR_fieldtrip.time={linspace(0,size(LED_signal_temp,2)/videoIn.FrameRate, size(LED_signal_temp,2))};
LED_conditionR_fieldtrip.trial={LED_signal_temp};
LED_conditionR_fieldtrip.fsample=videoIn.FrameRate;

cfg=[];
cfg.resamplefs= header_info.Fs;
LED_conditionR_fieldtrip = ft_resampledata(cfg, LED_conditionR_fieldtrip);
LED_signal=LED_conditionR_fieldtrip.trial{1};

figure, plot(LED_signal)
eventss=ft_read_event(eegfile); 
hold on, plot([eventss(2).sample, eventss(end).sample], mean(LED_signal),'*r')

LED_signal(225518-1000:225518+1000)=-2;
LED_signal(136258-1000:136258+1000)=-5;

figure,
for i=1:12
    subplot(6,2,i), plot(dbs_file.trial{1}(i,:))
    title(dbs_file.label{i})
end

figure, plot(eeg_file.trial{1}(72,:))


figure,
for i=1:12
    figure, plot(data.trial{1}(i,:))
    title(data.label{i})
end


figure,
for i=1:12
    subplot(6,2,i), plot(squeeze(D_ecg(i+106,:,1)))
%     hold on, plot(squeeze(Dpreproc(72,:,1)))
end

figure, 
subplot(2,1,1), plot(squeeze(D_tap(111,:,1)))
hold on, plot(squeeze(D_tap(72,:,1))/200)
title('patient 5 tap sync')

subplot(2,1,2), plot(squeeze(D_ecg(110,:,1)))
hold on, plot(squeeze(D_ecg(72,:,1))/200)
title('patient 5 ecg sync')




figure, plot(squeeze(D_ecg3(82,:,1))/10)
hold on, plot(squeeze(D_ecg3(40,:,1))/10-100)
title('patient 3 ecg sync')

figure, plot(squeeze(D_ecg4(81,:,1)))
hold on, plot(squeeze(D_ecg4(35,:,1))/10-100)
title('patient 4 ecg sync')

figure, plot(squeeze(D_ecg8(118,:,1)))
hold on, plot(squeeze(D_ecg8(72,:,1))/200)
title('patient 8 ecg sync')

figure, plot(squeeze(D_ecg9(112,:,1)))
% hold on, plot(squeeze(D_ecg9_removed(114,:,1)))
hold on, plot(squeeze(D_ecg9(72,:,1))/200)
title('patient 9 ecg sync')


figure, plot(squeeze(D_ecgL01(113,:,1)))
% hold on, plot(squeeze(D_ecg9_removed(114,:,1)))
hold on, plot(squeeze(D_ecgL01(72,:,1))/200)
title('patient 9 ecg sync')
