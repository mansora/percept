D=spm_eeg_load('LN_PR_D008_rec_2_R_1_cont');
lfpchan=D.indchantype('LFP');
signal=squeeze(D(lfpchan(1),:,1));


Y=fft(signal);

Fs = D.fsample; 
L  = size(signal,2);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
figure, plot(f,P1) 
% subplot(2,1,1), plot(f,P1) 
title("LFP signal")
xlabel("f (Hz)")
ylabel("|P1(f)|")


EEGchan=D.indchantype('EEG');
signal=(squeeze(D(EEGchan(1),:,1)));

Y=fft(signal);

Fs = 1000; 
L  = size(signal,2);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);




f = Fs*(0:(L/2))/L;
figure, plot(f,P1) 
% subplot(3,1,2), plot(f,P1) 
title("EEG signal")
xlabel("f (Hz)")
ylabel("|P1(f)|")

D2=spm_eeg_load('LN_PR_D008_rec_2_R_1')