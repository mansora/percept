D = spm_eeg_load;
%%
lfpind = D.indchantype('LFP');
for i = 1:length(lfpind)
    S = [];
    S.D = D;
    S.pretrig = D.time(1, 'ms');
    S.posttrig = D.time(D.nsamples, 'ms');
    S.timewin = 400;
    S.timestep = 50;
    S.freqwin = [0 90];
    S.robust = 'no';
    S.chancomb = [D.chanlabels(D.indchantype('EEG', 'GOOD'))' repmat(D.chanlabels(lfpind(i)), length(D.indchantype('EEG', 'GOOD')), 1)];
    Dc = spm_eeg_ft_multitaper_coherence(S);
    
    Dc = chanlabels(Dc, ':', S.chancomb(:, 1));
    Dc = chantype(Dc, ':', 'EEG');
    Dc = type(Dc, 'evoked');
    save(Dc);
    
    S = [];
    S.D = Dc;
    S.task = 'project3D';
    S.modality = 'EEG';
    S.updatehistory = 0;
    S.save = 1;
    
    Dc = spm_eeg_prep(S);
    
    Dc = move(Dc, ['COH_sensors_' char(D.chanlabels(lfpind(i)))]);   
    
    S = [];
    S.D = Dc;
    S.method = 'Rel';
    S.timewin = [-Inf 0];
    Dc = spm_eeg_tf_rescale(S);
%     
%     S    = [];
%     S.D  = Dc;
%     S.mode = 'scalp x time';
%     S.freqwin = [55 65];%*********
%     
%     spm_eeg_convert2images(S);
end
%%
return
%%
D = spm_eeg_load;


for i = 1:D.ntrials
    figure
    %subplot(D.ntrials, 1, i);
    imagesc(D.time, D.frequencies, squeeze(mean(D(:, :, :, i), 1)));
    axis xy
    caxis(120*[-1 1]);
    xlabel('time (sec)')
    ylabel('frequency (Hz)')
    title(char(D.conditions(i)));
    colormap jet
    colorbar
end
%%