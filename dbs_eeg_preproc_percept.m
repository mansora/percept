function Dout=dbs_eeg_preproc_percept(D, hampelfilter, correctheartbeat)

keep=0;

if nargin<2
    hampelfilter=1;
    correctheartbeat=1;
end


if hampelfilter
        wlen     = 5;
        ct       = 6;
    
        freqspan = linspace(0,D.fsample/2, size(D,2)/2+1);
    
        mind=@(a,b) min(abs(a-b));
        ind=[];
        [~, ind1]=mind(freqspan, 1000);
        ind=[ind 1:ind1];
        ind=unique(ind);
    
        lfpchan  = D.indchantype('LFP');
    
       
    
    
         %% Calculation
        % All LFP channels FFT
        multi_chan=fft(squeeze(D(lfpchan,:,1)), [], 2);
    
        % Process real and imaginary parts separately and reconstruct
        abstemp=hampelv(real(multi_chan),wlen,ct,ind,freqspan);
        imtemp=hampelv(imag(multi_chan),wlen,ct,ind,freqspan);
        cleaned=complex(abstemp,imtemp);
        
        % Correct complex conjugate so that ifft works
        szc=size(cleaned,2)/2;
        rev_cleaned=fliplr(cleaned(:,2:szc));
        cleaned(:,(szc+2):end)=conj(rev_cleaned);
        
        % Save cleaned data
        D(lfpchan,:,1)=ifft(cleaned, [], 2); 



        
        YY=fft(squeeze(D(lfpchan(1),:,1)));
        LL  = size(squeeze(D(lfpchan(1),:,1)),2);
        
        P2 = abs(YY/LL);
        P1 = P2(1:LL/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        
        freq_f = D.fsample*(0:(LL/2))/LL;

        %         figure, plot(freq_f,P1)
%         print(gcf,['D:\home\Data\', details.initials,'_',...
%         condition, '_', num2str(rec_id),'_hampelfilterEEG.jpg'],'-djpeg');
%         % subplot(2,1,1), plot(f,P1) 
%         title("EEG signal")
%         xlabel("f (Hz)")
%         ylabel("|P1(f)|")
    
        


end


S = [];
S.D = D;
S.type = 'butterworth';
S.band = 'high';
S.freq = 5;
S.dir = 'twopass';
S.order = 5;
D = spm_eeg_filter(S);
if ~keep, delete(S.D);  end

S = [];
S.D = D;
S.type = 'butterworth';
S.band = 'low';
S.freq = 95;
S.dir = 'twopass';
S.order = 5;
D = spm_eeg_filter(S);
if ~keep, delete(S.D);  end

S = [];
S.D = D;
S.type = 'butterworth';
S.band = 'stop';
S.freq = [48 52];
S.dir = 'twopass';
S.order = 5;
D = spm_eeg_filter(S);
if ~keep, delete(S.D);  end

if correctheartbeat
    lfpchan  = D.indchantype('LFP');
    xchan=1;

    S = [];
    S.D = D;
    S.mode = 'mark';
    S.badchanthresh = 0.1;
    S.methods.fun = 'heartbeat';
    S.methods.channels = D.chanlabels(lfpchan(xchan));
    S.methods.settings.excwin = 1;
    
    D = spm_eeg_artefact(S);
    if ~keep, delete(S.D);  end

    ev    = D.events(':');
    evv   = ev(strmatch('artefact_heartbeat', {ev.type}));
    ecg_times  = [evv(:).time];

    ecg_peak_indices = percept_fix_ecg_peaks(squeeze(D(lfpchan(xchan), :,1)), D.fsample, D.indsample(ecg_times), false);


    for i = 1:length(lfpchan)
        lfp       = D(lfpchan(i), :,1);

        lfp_peak_indices = percept_fix_ecg_peaks(squeeze(D(lfpchan(i), :,1)), D.fsample, ecg_peak_indices, true);

        % for PQRST
                pre_R_time = 0.25;
                post_R_time = 0.4;
                settings                        = [];
                settings.interactive            = 0;
                settings.art_width_search       = .1;
                settings.art_time_b4_peak       = pre_R_time;
                settings.art_time_after_peak    = post_R_time;
                settings.Fs                     = D.fsample;
                settings.polarity               = 1;
%                 settings.thr                    = 0.1;
                settings.ncomp                  = 2;
                settings.showfigs               = 1;
                settings.savefigs               = 1;

                % for left hemisphere:
                settings.label              = char(D.chanlabels(lfpchan(i)));
                [cleanlfp,proj_out] = continuous_ecgremoval_new(lfp,settings, D(lfpchan(xchan), :), lfp_peak_indices);
                ecg(i, :) = lfp-cleanlfp';
                D(lfpchan(i), :, 1) = cleanlfp';


    end


    ev    = D.events(':');
    trialength = 1000;
    trl = 1:round(1e-3*trialength*D.fsample):D.nsamples;
    trl = [trl(1:(end-1))' trl(2:end)'-1 0*trl(2:end)'];
 
    conditionlabels ='R'; 

    S = [];
    S.D = D;
    S.trl = trl;
    S.conditionlabels = conditionlabels(:);
    D = spm_eeg_epochs(S);

    if ~keep, delete(S.D);  end


    S = [];
    S.D = D;
    S.channels = D.chanlabels(lfpchan);
    S.frequencies = 2:98;
    S.timewin = [-Inf Inf];
    S.phase = 0;
    S.method = 'mtmfft';
    S.settings.taper = 'dpss';
    S.settings.freqres = 1;
    S.prefix = 'LFP_spect_';
    D = spm_eeg_tf(S);

    if ~keep, delete(S.D);  end

    S = [];
    S.D = D;
    S.robust = false;
    S.circularise = false;
    S.prefix = 'm';
    Dout = spm_eeg_average(S);

    if ~keep, delete(S.D);  end







end
