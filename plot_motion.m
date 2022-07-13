figure, 
plot(D(find(strcmp(D.chanlabels, 'hand_R1_x')),:,1))
hold on, plot(D(find(strcmp(D.chanlabels, 'hand_R1_y')),:,1))


figure, 
plot(D(find(strcmp(D.chanlabels, 'hand_L1_x')),:,1))
hold on, plot(D(find(strcmp(D.chanlabels, 'hand_L1_y')),:,1))

figure, 
plot(D(find(strcmp(D.chanlabels, 'hand_R1_y')),:,1))
hold on, plot(D(find(strcmp(D.chanlabels, 'hand_L1_y')),:,1))
hold on, plot(D(find(strcmp(D.chanlabels, 'foot_R_y')),:,1))
hold on, plot(D(find(strcmp(D.chanlabels, 'foot_L_y')),:,1))
legend({'right hand','left hand','right foot','left foot'})
% hold on, xline(trl(find(strcmp(trialinfo,'right leg'))))
figure
subplot(3,1,1)
hold on, plot(D(find(strcmp(D.chanlabels, 'EMG1')),:,1))
hold on, xline(trl(find(strcmp(trialinfo,'left leg'))))
subplot(3,1,2), plot(D(find(strcmp(D.chanlabels, 'foot_L_y')),:,1))
hold on, plot(D(find(strcmp(D.chanlabels, 'foot_L_x')),:,1))
hold on, xline(trl(find(strcmp(trialinfo,'left leg'))))
subplot(3,1,3), plot(D(find(strcmp(D.chanlabels, 'foot_R_y')),:,1))
hold on, plot(D(find(strcmp(D.chanlabels, 'foot_R_x')),:,1))
hold on, xline(trl(find(strcmp(trialinfo,'left leg'))))


figure
subplot(3,1,1)
hold on, plot(D(find(strcmp(D.chanlabels, 'EMG1')),:,1))
hold on, xline(trl(find(strcmp(trialinfo,'right hand'))))
legend({'right hand EMG'})

subplot(3,1,2), plot(D(find(strcmp(D.chanlabels, 'hand_R1_y')),:,1))
hold on, plot(D(find(strcmp(D.chanlabels, 'hand_R1_x')),:,1))
hold on, xline(trl(find(strcmp(trialinfo,'right hand'))))
legend({'right hand motion tracking y', 'right hand motion tracking x'})


subplot(3,1,3), plot(D(find(strcmp(D.chanlabels, 'hand_L1_y')),:,1))
hold on, plot(D(find(strcmp(D.chanlabels, 'hand_L1_x')),:,1))
hold on, xline(trl(find(strcmp(trialinfo,'left hand'))))
legend({'left hand motion tracking y', 'left hand motion tracking x'})


