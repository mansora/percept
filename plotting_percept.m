freq=3:98;
figure, 
subplot(1,3,1), plot(freq, squeeze(D_spect_write_on(:,2:end,1,1)),'LineWidth',3)
hold on, plot(freq, squeeze(D_spect_write_off(:,2:end,1,1)),'--','LineWidth',3)
legend('L DBS on','R DBS on', 'L DBS off', 'R DBS off')
title('rest')
set(gca,'FontSize',18)
set(gca,'LineWidth',3)


subplot(1,3,2), plot(freq, squeeze(D_spect_write_on(:,2:end,1,2)),'LineWidth',3)
hold on, plot(freq, squeeze(D_spect_write_off(:,2:end,1,2)),'--','LineWidth',3)
legend('L DBS on','R DBS on', 'L DBS off', 'R DBS off')
title('right')
set(gca,'FontSize',18)
set(gca,'LineWidth',3)


subplot(1,3,3), plot(freq, squeeze(D_spect_write_on(:,2:end,1,3)),'LineWidth',3)
hold on, plot(freq, squeeze(D_spect_write_off(:,2:end,1,3)),'--','LineWidth',3)
legend('L DBS on','R DBS on', 'L DBS off', 'R DBS off')
title('left')
set(gca,'FontSize',18)
set(gca,'LineWidth',3)


D_PMT_off=spm_eeg_load('D:\home\Data\DBS-MEG\LN_PR_D006\rec1\PMT\rmtf_eLN_PR_D006_rec_1_PMT_2');
D_PMT_on=spm_eeg_load('D:\home\Data\DBS-MEG\LN_PR_D006\rec2\PMT\rmtf_eLN_PR_D006_rec_2_PMT_2');

figure, 
for i=1:25
subplot(5,5,i), imagesc(squeeze(D_PMT_on(40+i,:,:,1)))
title(D_PMT_on.chanlabels(40+i))
end

figure, 
for i=1:25
subplot(5,5,i), imagesc(squeeze(D_PMT_off(40+i,:,:,1)))
title(D_PMT_on.chanlabels(40+i))
end


%%
D_PMT_off=spm_eeg_load('D:\home\Data\DBS-MEG\LN_PR_D006\rec1\PMT\rmtf_eLN_PR_D006_rec_1_PMT_2');
D_PMT_on=spm_eeg_load('D:\home\Data\DBS-MEG\LN_PR_D006\rec2\PMT\rmtf_eLN_PR_D006_rec_2_PMT_2');




D_PMT_off=spm_eeg_load('D:\home\Data\DBS-MEG\LN_PR_D006\rec1\ACT\rmtf_eLN_PR_D006_rec_1_ACT_3');
D_PMT_on=spm_eeg_load('D:\home\Data\DBS-MEG\LN_PR_D006\rec2\ACT\rmtf_eLN_PR_D006_rec_2_ACT_3');

cond=5;

for cond=1:8
figure('units','normalized','outerposition',[0 0 1 1]),

titl_fig=['PMT ' D_PMT_on.conditions{cond}];

sgtitle(titl_fig)
subplot(2,3,1), imagesc(D_PMT_on.time, D_PMT_on.frequencies, squeeze(D_PMT_on(65,:,:,cond)))
title(D_PMT_on.chanlabels(65))
xlabel('time (s)')
ylabel('freq (Hz)')


subplot(2,3,2), imagesc(D_PMT_on.time, D_PMT_on.frequencies, squeeze(D_PMT_on(66,:,:,cond)))
title(D_PMT_on.chanlabels(66))
xlabel('time (s)')
ylabel('freq (Hz)')

subplot(2,3,3), imagesc(D_PMT_on.time, D_PMT_on.frequencies, squeeze(mean(D_PMT_on(1:64,:,:,cond),1)))
title('Average all EEG channels')
xlabel('time (s)')
ylabel('freq (Hz)')

subplot(2,3,4), imagesc(D_PMT_off.time, D_PMT_off.frequencies, squeeze(D_PMT_off(65,:,:,cond)))
title(D_PMT_off.chanlabels(65))
xlabel('time (s)')
ylabel('freq (Hz)')


subplot(2,3,5), imagesc(D_PMT_off.time, D_PMT_off.frequencies, squeeze(D_PMT_off(66,:,:,cond)))
title(D_PMT_off.chanlabels(66))
xlabel('time (s)')
ylabel('freq (Hz)')

subplot(2,3,6), imagesc(D_PMT_off.time, D_PMT_off.frequencies, squeeze(mean(D_PMT_off(1:64,:,:,cond),1)))
title('Average all EEG channels')
xlabel('time (s)')
ylabel('freq (Hz)')


saveas(gcf, ['D:\home\results Percept Project\powspctrm' titl_fig, '.png'])
end

%%

figure('units','normalized','outerposition',[0 0 1 1]),
sgtitle('right GPi ACT')
for cond=1:8
subplot(2,8,cond), imagesc(D1.time, D1.frequencies, squeeze(mean(D1(:,:,:,cond),1)))
title([D1.conditions{cond}, ' off'])
xlabel('time (s)')
ylabel('freq (Hz)')
subplot(2,8,8+cond),  imagesc(D2.time, D2.frequencies, squeeze(mean(D2(:,:,:,cond),1)))
title([D1.conditions{cond}, ' on'])
xlabel('time (s)')
ylabel('freq (Hz)')
end


