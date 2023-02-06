function fD = dbs_eeg_percept_prepare_spm12(initials, rec_id, condition)
close all
if nargin <2
    rec_id = 1;
end

if nargin <3
    condition = 'R';
end


prefix = '';

keep = 0;

try
    [files, seq, root, details] = dbs_subjects_percept(initials, rec_id);
catch
    D = [];
    return
end
%%

spm_mkdir(root);


cd(root);
res = mkdir(condition);
cd(condition);


fD = {};
aD = {};
%%
for f = 1:size(files, 1)
    if ~isequal(condition, seq{f})
        continue;
    end

    % =============  Conversion =============================================
    try 
        D=spm_eeg_load(fullfile(root, condition, [initials, '_rec_', num2str(rec_id), '_' condition, '_' num2str(f), '_preproc','.mat']));
    catch
        D = dbs_eeg_percept_preproc(files(f,:), details, f);

        D = chantype(D, D.indchannel(details.chan), 'LFP');

        if isfield(details, 'ecgchan') && ~isempty(details.ecgchan)
            D = chantype(D, D.indchannel(details.ecgchan), 'ECG');
        end
    
        save(D);
    end

    


    S = [];
    S.D = D;
    S.type = 'butterworth';
    S.band = 'high';
    S.freq = 1;
    S.dir = 'twopass';
    S.order = 5;
    D = spm_eeg_filter(S);


%     if ~keep, delete(S.D);  end

    S = [];
    S.D = D;
    
    S.type = 'butterworth';
    S.band = 'low';
    S.freq = 95;
    S.dir = 'twopass';
    S.order = 5;
    D = spm_eeg_filter(S);

    if ~keep, delete(S.D);  end




    if details.removesync
        % Remove the synchronisation sequence
        lfpchan = D.indchantype('LFP');
        lfp = zscore(squeeze(D(D.indchantype('LFP'), :, :))');
        if numel(lfpchan)>1 lfp=lfp(:,1); end
        
        onset=[];
        tresh_=7;
        while isempty(onset) 
            ind   = find(abs(lfp)>tresh_);
            onset = round(max(ind(ind<0.5*D.nsamples)) + 0.5*D.fsample);
            tresh_=tresh_-0.5;
        end

        offset=[];
        tresh_=7;
        while isempty(offset) 
            ind   = find(abs(lfp)>tresh_);
            offset= round(min(ind(ind>0.5*D.nsamples)) - 0.5*D.fsample);
            tresh_=tresh_-0.5;
        end

%         if isempty(onset) 
%             onset=1; end
%         if isempty(offset) offset = D.nsamples; end


        figure, plot(lfp), hold on, xline(onset,'k'), xline(offset,'k')
        print(gcf,[details.initials,'_',...
        condition, '_', num2str(rec_id),'_removesynch.jpg'],'-djpeg');

        
        S = [];
        S.D = D;
        S.timewin = [D.time(onset, 'ms') D.time(offset, 'ms')];
        D = spm_eeg_crop(S);
        
        if ~keep, delete(S.D);  end

        figure, plot(lfp), hold on, xline(onset,'k'), xline(offset,'k')
        print(gcf,['D:\home\Data\', details.initials,'_',...
        condition, '_', num2str(rec_id),'_removesynch.jpg'],'-djpeg');
    end

   

    if details.hampelfilter
        wlen     = 5;
        ct       = 6;
    
        freqspan = linspace(0,D.fsample/2, size(D,2)/2+1);
    
        mind=@(a,b) min(abs(a-b));
        ind=[];
        [~, ind1]=mind(freqspan, 1000);
        ind=[ind 1:ind1];
        ind=unique(ind);
    
        eegchan  = D.indchantype('EEG');
        lfpchan  = D.indchantype('LFP');
    
        %% Calculation
        % All EEG channels FFT
        multi_chan=fft(squeeze(D(eegchan,:,1)), [], 2);
    
        % Process real and imaginary parts separately and reconstruct
        abstemp=hampelv(real(multi_chan),wlen,ct,ind,freqspan);
        imtemp=hampelv(imag(multi_chan),wlen,ct,ind,freqspan);
        cleaned=complex(abstemp,imtemp);
        
        % Correct complex conjugate so that ifft works
        szc=size(cleaned,2)/2;
        rev_cleaned=fliplr(cleaned(:,2:szc));
        cleaned(:,(szc+2):end)=conj(rev_cleaned);
        
        % Save cleaned data
        D(eegchan,:,1)=ifft(cleaned, [], 2); 
    
    
    
         %% Calculation
        % All EEG channels FFT
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



        signal=squeeze(D(lfpchan(1),:,1));
        Y=fft(signal);
        
        Fs = D.fsample; 
        L  = size(signal,2);
        
        P2 = abs(Y/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        
        f = Fs*(0:(L/2))/L;
        
        figure, plot(f,P1)
        print(gcf,['D:\home\Data\', details.initials,'_',...
        condition, '_', num2str(rec_id),'_hampelfilterLFP.jpg'],'-djpeg');
        % subplot(2,1,1), plot(f,P1) 
        title("LFP signal")
        xlabel("f (Hz)")
        ylabel("|P1(f)|")

    end





    
   


    eegchan  = D.indchantype('EEG');
    goodind  = D.indchantype('EEG', 'GOOD');

    goodind = find(ismember(eegchan, goodind));

    tra               =  eye(length(eegchan));
    tra(: ,goodind)   =  tra(:, goodind) - 1/length(goodind);
    tra(end+[1:2], 1)     =  1;

    montage          = [];
    montage.labelorg = D.chanlabels(eegchan);
    montage.labelnew = [D.chanlabels(eegchan), {'ECG', 'event'}];
    montage.chantypenew = [repmat({'EEG'}, 1, length(D.indchantype('EEG'))), {'ECG', 'Other'}];

    montage.tra      = tra;

    S = [];
    S.D = D;
    S.montage = montage;
    S.keepothers = 1;
    D = spm_eeg_montage(S);

    if ~keep, delete(S.D);  end


    


    %%
    % Downsample =======================================================
    % note that the trialdef file is not downsampled, you should include
    % this
    if D.fsample > 250

        S = [];
        S.D = D;
        S.fsample_new = 250;

        D = spm_eeg_downsample(S);

        if ~keep, delete(S.D);  end
    end

    S = [];
    S.D = D;
    S.type = 'butterworth';
    S.band = 'stop';
    S.freq = [48 52];
    S.dir = 'twopass';
    S.order = 5;

    while S.freq(2)<min(600, (D.fsample/2))
        D = spm_eeg_filter(S);
        if ~keep, delete(S.D);  end

        S.D = D;
        S.freq = S.freq+50;
    end

    if isfield(details, 'bandstop') && ~isempty(details.bandstop)
        for i = 1:length(details.bandstop)
            S.D = D;
            S.freq = [-1 1]+details.bandstop(i);
            D = spm_eeg_filter(S);
            if ~keep, delete(S.D);  end
        end
    end


    S = [];
    S.D = D;
    
    S.type = 'butterworth';
    S.band = 'low';
    S.freq = 95;
    S.dir = 'twopass';
    S.order = 5;
    D = spm_eeg_filter(S);

    if ~keep, delete(S.D);  end
 


%     if ~keep, delete(S.D);  end


 



    %% artefact detection=======================================================
    event     = D.events(1, 'samples');
    eventdata = zeros(1, D.nsamples);

    if ~isempty(event) && isfield(details, 'eventtype')
        trigind  = find(strcmp(details.eventtype, {event.type}));
        eventdata([event(trigind).sample]) = 1;
    end

    D(D.indchannel('event'), :) = eventdata;

    D(D.indchannel('ECG'), :)  = D(D.indchannel('StimArt'), :);

    D = chantype(D, D.indchannel('event'), 'Other');
    save(D);

    S = [];
    S.D = D;
    S.mode = 'mark';
    S.badchanthresh = details.badchanthresh;

    S.methods(1).channels = {'EEG'};
    S.methods(1).fun = 'flat';
    S.methods(1).settings.threshold = 0.01;
    S.methods(1).settings.seqlength = 10;
    S.methods(2).channels = {'EEG'};
    S.methods(2).fun = 'jump';
    S.methods(2).settings.threshold = 350;
    S.methods(2).settings.excwin = 200;
    S.methods(3).channels = {'EEG'};
    S.methods(3).fun = 'threshchan';
    S.methods(3).settings.threshold = 200;
    S.methods(3).settings.excwin = 200;
    
    if ~contains(files{f,3}, 'LN_PR_D008_ON_SST_repetition1')
        S.methods(4).fun = 'heartbeat';
        S.methods(4).channels = {'ECG'};
        S.methods(4).settings.excwin = 1;
    end
    
    D = spm_eeg_artefact(S);

    %***** Breakpoint 1
    figure;imagesc(badsamples(D, D.indchantype('EEG'), ':', 1))
    % figure;plot(diff(D(D.indchannel('AG083'), :, 1)))

    if ~keep
        delete(S.D);
    end





    ecgmethod = 'perceive';

    lfpchan = D.indchantype('LFP');
    ecg = zeros(length(lfpchan), D.nsamples);
    for i = 1:length(lfpchan)
        lfp       = D(lfpchan(i), :,1);
        switch ecgmethod
            case 'perceive'
                badsmpl = abs(zscore(lfp))>8;
                badsmpl = ~~conv(badsmpl, ones(1, round(D.fsample)), 'same');
                lfp_good  = lfp;
                lfp_good(badsmpl) = 0;
                ecg_out   = perceive_ecg(lfp_good, D.fsample,1);
                if ecg_out.detected
                    cleanlfp  = ecg_out.cleandata;
                    ecg(i, :) = lfp-cleanlfp;
                    D(lfpchan(i), :, 1) = cleanlfp;
                end
            case 'svd'
                ev    = D.events(':');
                evv   = ev(strmatch('artefact_heartbeat', {ev.type}));
                ecg_times  = [evv(:).time];

                figure, plot(D.time,  squeeze(D(lfpchan(i), :,1)))
                hold on, plot(ecg_times, mean(squeeze(D(lfpchan(i), :,1))), 'r*')
                hold on, plot(ecg_times-0.1630, mean(squeeze(D(lfpchan(i), :,1))), 'k*')


%                 ecg_times=ecg_times-0.2530;
%                 ecg_times=ecg_times-0.1630;
               
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
                settings.thr                    = 0.1;
                settings.ncomp                  = 2;
                settings.showfigs               = 1;
                settings.savefigs               = 1;

                % for left hemisphere:
                settings.label              = char(D.chanlabels(lfpchan(i)));
                [cleanlfp,proj_out] = continuous_ecgremoval_new(lfp,settings, D(D.indchannel('ECG'), :));
                ecg(i, :) = lfp-cleanlfp';
                D(lfpchan(i), :, 1) = cleanlfp';
        end
    end
    if size(ecg, 1)>1
        [u,s,u] = svd(ecg*ecg');
        s       = diag(s);
        u       = u(:,1);
        ecg       = ecg'*u/sqrt(s(1));
    end

    %D(D.indchannel('ECG'), :) = ecg(:)';

    ecgind = [];
    if ~isempty(ecgind)
        S   = [];
        S.D = D;
        S.timewin = [-100 200];
        S.trialdef.conditionlabel = 'heartbeat';
        S.trialdef.eventtype = 'artefact_heartbeat';
        S.trialdef.eventvalue = ecgchan;
        S.trialdef.trlshift = 0;
        S.reviewtrials = 0;
        S.save = 0;
        trl = spm_eeg_definetrial(S);

        ind = repmat(trl(:, 1), 1, mean(trl(:, 2)-trl(:, 1)));
        ind = ind+repmat(1:size(ind, 2), size(ind, 1), 1)-1;

        F = spm_figure('GetWin', 'LFP_correction');clf;
        for i = 1:length(details.chan)
            lfpdat = D(D.indchannel(details.chan(i)), :);
            lfpseg = lfpdat(ind);
            rejind = find(any(abs(lfpseg')>details.lfpthresh));
            lfpseg(rejind, :) = [];
            ind(rejind, :)    = [];

            subplot(numel(details.chan), 1, i);
            plot(mean(lfpseg));
            hold on;

            if max(abs(mean(lfpseg)))>6 %might need adaptive threshold
                [U, L, V] = spm_svd(lfpseg');
                U  = full(U(:, 1:2));
                clfpseg = ((eye(size(U, 1)) - U*pinv(U))*lfpseg')';

                clfpdat = lfpdat;
                clfpdat(ind) = clfpseg;
                D(D.indchannel(details.chan(i)), :) = clfpdat;
                plot(mean(clfpseg), 'r');
            end
        end

        S = [];
        S.D = D;
        S.timewin = [-500 500];
        S.trialdef.conditionlabel = 'heartbeat';
        S.trialdef.eventtype = 'artefact_heartbeat';
        S.trialdef.eventvalue = ecgchan;
        S.trialdef.trlshift = 0;
        S.bc = 0;
        S.prefix = 'heartbeat_';
        S.eventpadding = 0;
        Da = spm_eeg_epochs(S);
    end

    if condition~='R'
        S = [];
        S.D = D;
        D = dbs_percept_mov_preproc(S);
        if ~keep, delete(S.D);  end
    end

    epoch = true;
    ev    = D.events(':');
    switch condition
        case 'R'
            ev    = D.events(':');
            trialength = 1000;
            trl = 1:round(1e-3*trialength*D.fsample):D.nsamples;
            trl = [trl(1:(end-1))' trl(2:end)'-1 0*trl(2:end)'];
         
            conditionlabels = seq{f}(isstrprop(seq{f}, 'alpha'));           
%             conditionlabels = repmat({seq{f}(isstrprop(seq{f}, 'alpha'))},1,size(trl,1));    
%         case 'PMT' | 'ACT'
% 
%             limbs={'right hand', 'left hand', 'right leg', 'left leg'};
%                 
%             trl = [];
%             conditionlabels = {};
%             ev = [];
% 
%             for limb=1:4
%                 ev1 = D.events(':');
%                 evv = ev1(contains({ev1.type}, limbs{limb}));
% 
%                 start = D.indsample(min([evv.time]));
%                 stop = D.indsample(max([evv.time]));
% 
%                 temp=strsplit(limbs{limb});
%                 if strcmp(temp(2),'leg')
%                     temp{2}='foot';
%                 end
%                 cmov  = D(D.indchannel([ temp{2} '_' upper(temp{1}(1))]), :);
% 
%                 [~, onsets]= findpeaks(zscore(diff(cmov)), "MinPeakHeight",2.5, "MinPeakProminence", 1);
%                 [~, offsets]= findpeaks(-zscore(diff(cmov)), "MinPeakHeight", 2, "MinPeakProminence", 1);
% 
%                 onsets = onsets(onsets>(start-5) & onsets<(stop+5));
%                 offsets = offsets(offsets>(start-5) & offsets<(stop+5));
% 
%                 if length(onsets)~=length(offsets)
%                     error('mismatch');
%                 end
% 
%                 epochlength = round(D.fsample);
% 
%                 
%                 for i = 1:length(onsets)
%                     ctrl = round(onsets(i)+epochlength/2):epochlength:round(offsets(i)-epochlength/2);
%                     trl = [trl; ctrl(:) ctrl(:)+epochlength 0*ctrl(:)];
%                     conditionlabels = [conditionlabels; repmat({['hold_' hands{k}]}, length(ctrl), 1)];
% 
%                     if i<length(onsets)
%                         ctrl = round(offsets(i)+epochlength/2):epochlength:round(offsets(i+1)-epochlength/2);
%                     else
%                         ctrl = round(offsets(i)+epochlength/2)+(0:(n-1))*epochlength;
%                     end
%                     n    = length(ctrl);
%                     trl = [trl; ctrl(:) ctrl(:)+epochlength 0*ctrl(:)];
%                     conditionlabels = [conditionlabels; repmat({'rest'}, n, 1)];
% 
%                     ev = spm_cat_struct(ev, struct('type', 'up', 'value', 1, 'time', D.time(onsets(i))));
%                     ev = spm_cat_struct(ev, struct('type', 'down', 'value', 1, 'time', D.time(offsets(i))));
%                 end
% 
% 
%             end
            
            
            


            

        case 'HPT'
            hands = {'right'};%'left'

            ev = D.events(':');
            evv = ev(strmatch('arms', {ev.type}));

            start = D.indsample(min([evv.time]));
            stop = D.indsample(max([evv.time]));


            for k = 1:numel(hands)
                cmov  = D(D.indchannel(['hand_' upper(hands{k}(1))]), :);
                
                thresh1=2;
                stop_loop=0;
                onsets=[];
                
                while (length(onsets)<5 && stop_loop==0)
                    [~, onsets]= findpeaks(zscore(diff(cmov)), "MinPeakHeight",thresh1, "MinPeakProminence", 1);
                    thresh1=thresh1-0.1;
                    if thresh1<1.5
                        stop_loop=1;
                        error('threshold is too low')
                    end
                end

                thresh2=2;
                stop_loop=0;
                offsets=[];
                while (length(offsets)<5 && stop_loop==0)
                    [~, offsets]= findpeaks(-zscore(diff(cmov)), "MinPeakHeight", thresh2, "MinPeakProminence", 1);
                    thresh2=thresh2-0.05;
                    if thresh2<1.5
                        stop_loop=1;
                        error('threshold is too low')
                    end
                end

                if strcmp(details.initials, 'LN_PR_D005') && f==2
                        [~, onsets]= findpeaks(zscore(diff(cmov)), "MinPeakHeight",1.5, "MinPeakProminence", 1);
                        [~, offsets]= findpeaks(-zscore(diff(cmov)), "MinPeakHeight", 1.5, "MinPeakProminence", 1);
                end

                    
                    
                onsets = onsets(onsets>(start-1000) & onsets<(stop+5));
                offsets = offsets(offsets>(start-5) & offsets<(stop+1000));
                
                if length(onsets)>length(offsets)
                    if (onsets(1)<offsets(1) && onsets(2)<offsets(1))
                        onsets(1)=[];
                    elseif onsets(end)>offsets(end)
                        onsets(end)=[];
                    end
                elseif length(onsets)<length(offsets)
                    if (onsets(end)<offsets(end) && onsets(end)<offsets(end-1))
                        offsets(end)=[];
                    elseif offsets(1)<onsets(1)
                        offsets(1)=[];
                    end
                end

                   
                
                if length(onsets)~=length(offsets)
                    figure, plot(cmov)
                    hold on, plot(zscore(diff(cmov))*std(cmov))
                    plot(onsets, mean(zscore(diff(cmov))), '*g') 
                    plot(offsets, mean(zscore(diff(cmov))), '*r')
                    plot([start, stop], mean(zscore(diff(cmov))), '*k')
                    error('mismatch, manual intervention needed');
                end

                epochlength = round(D.fsample);

                trl = [];
                conditionlabels = {};
                ev = [];

                for i = 1:length(onsets)
                    ctrl = round(onsets(i)+epochlength/2):epochlength:round(offsets(i)-epochlength/2);
                    trl = [trl; ctrl(:) ctrl(:)+epochlength 0*ctrl(:)];
                    conditionlabels = [conditionlabels; repmat({['hold_' hands{k}]}, length(ctrl), 1)];

                    if i<length(onsets)
                        ctrl = round(offsets(i)+epochlength/2):epochlength:round(offsets(i+1)-epochlength/2);
                    else
                        ctrl = round(offsets(i)+epochlength/2)+(0:(n-1))*epochlength;
                    end
                    n    = length(ctrl);
                    trl = [trl; ctrl(:) ctrl(:)+epochlength 0*ctrl(:)];
                    conditionlabels = [conditionlabels; repmat({'rest'}, n, 1)];

                    ev = spm_cat_struct(ev, struct('type', 'up', 'value', 1, 'time', D.time(onsets(i))));
                    ev = spm_cat_struct(ev, struct('type', 'down', 'value', 1, 'time', D.time(offsets(i))));
                end
            end
        case 'REACH'
            ev    = D.events(':');
            evv   = ev(strmatch('arms', {ev.type}));
            start = D.indsample(min([evv.time]'));
            stop  = D.indsample(max([evv.time]')+5);

            hands = {'right', 'left'};

            trl = [];
            conditionlabels = {};
            ev = [];

            for k = 1:numel(hands)
                handY    = detrend(D(D.indchannel(['hand_' upper(hands{k}(1)) '1_y']), start:stop), 'constant');
                lift     = round(medfilt1(double(handY < 0), 10));
                up       = find(diff(lift)>0)+start;
                down     = find(diff(lift)<0)+start;


                if length(up)~=length(down)
                    error('up/down numbers mismatch');
                end

                for i = 1:length(up)
                    ctrl = up(i):D.fsample:down(i);
                    if length(ctrl)>3
                        ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:(end-1))'];
                        conditionlabels = [conditionlabels, repmat({['reach ' hands{k}]}, 1, size(ctrl, 1))];
                        trl  = [trl; ctrl];
                        figure;
                        handX    = detrend(D(D.indchannel(['hand_' upper(hands{k}(1)) '1_x']), up(i):down(i)), 'constant');
                        plot(handX, 'k');
                        hold on
                        handX    = conv(handX, ones(1, 200)./200, 'same');
                        plot(handX, 'r');
                        [~, reachpeaks]= findpeaks(handX, "MinPeakHeight",30, "MinPeakProminence", 20);
                        xline(reachpeaks);
                        for j=1:length(reachpeaks)
                            ev = spm_cat_struct(ev, struct('type', 'reachpeak', 'value', hands{k}, 'time', D.time(up(i)+reachpeaks(j)-1)));
                        end
                    end
                    if i<length(up)
                        ctrl = down(i):D.fsample:up(i+1);
                        if length(ctrl)>3
                            ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:(end-1))'];
                            conditionlabels = [conditionlabels, repmat({'rest'}, 1, size(ctrl, 1))];
                            trl  = [trl; ctrl];
                        end
                    end                    
                end
            end

        case 'POUR'
            ev  = D.events(':');
            evv = ev(strmatch('pour', {ev.type}));
            pourstart = [evv(strmatch('start', {evv.value})).time]+5;
            pourstop  = [evv(strmatch('stop', {evv.value})).time];
            reststart = [5 pourstop+5];
            reststop  = [pourstart-10 D.time(end)-5];

            trl = [];
            conditionlabels = {};

            if length(pourstart)~=length(pourstop)
                error('start/stop numbers mismatch');
            end
            for i = 1:length(pourstart)
                ctrl = D.indsample(pourstart(i)):D.fsample:D.indsample(pourstop(i));
                if length(ctrl)>3
                    ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:(end-1))'];
                    conditionlabels = [conditionlabels, repmat({'pour'}, 1, size(ctrl, 1))];
                    trl  = [trl; ctrl];
                end
            end
            if length(reststart)~=length(reststop)
                error('start/stop numbers mismatch');
            end
            for i = 1:length(reststart)
                ctrl = D.indsample(reststart(i)):D.fsample:D.indsample(reststop(i));
                if length(ctrl)>3
                    ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:(end-1))'];
                    conditionlabels = [conditionlabels, repmat({'rest'}, 1, size(ctrl, 1))];
                    trl  = [trl; ctrl];
                end
            end
        case 'WRITE'
            ev  = D.events(':');
            evv = spm_cat_struct(ev(strmatch('write', {ev.type})),...
                ev(strmatch('pause write', {ev.type})));

            [~, ind] = unique([evv.time]);

            evv = evv(ind);

            trl = [];
            conditionlabels = {};
            state = 'rest';
            for i = 1:numel(evv)
                if isequal(state, 'rest')
                    if ~isequal(evv(i).type, 'write')
                        error('wrong event sequence')
                    end
                    if i == 1
                        ctrl = D.indsample(5):D.fsample:D.indsample(evv(i).time);
                    else
                        ctrl = D.indsample(evv(i-1).time+5):D.fsample:D.indsample(evv(i).time);
                    end
                    ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:(end-1))'];
                    conditionlabels = [conditionlabels, repmat({'rest'}, 1, size(ctrl, 1))];
                    trl  = [trl; ctrl];
                    state = evv(i).value;
                else
                    if ~(isequal(evv(i).type, 'pause write') && isequal(evv(i).value, state))
                        error('wrong event sequence')
                    end
                    ctrl = D.indsample(evv(i-1).time+5):D.fsample:D.indsample(evv(i).time);
                    ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:(end-1))'];
                    conditionlabels = [conditionlabels, repmat({state}, 1, size(ctrl, 1))];
                    trl  = [trl; ctrl];
                    state = 'rest';
                end
            end
            ctrl = D.indsample(evv(end).time+5):D.fsample:D.indsample(D.time(end)-5);
            ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:(end-1))'];
            conditionlabels = [conditionlabels, repmat({'rest'}, 1, size(ctrl, 1))];
            trl  = [trl; ctrl];


        case 'SPEAK'
            ev  = D.events(':');
            evv = ev(strmatch('speak', {ev.type}));
            speakstart = [evv(strmatch('start', {evv.value})).time]+5;
            speakstop  = [evv(strmatch('stop', {evv.value})).time];
            reststart = [5 speakstop+5];
            reststop  = [speakstart-10 D.time(end)-5];

            trl = [];
            conditionlabels = {};

            if length(speakstart)~=length(speakstop)
                error('start/stop numbers mismatch');
            end
            for i = 1:length(speakstart)
                ctrl = D.indsample(speakstart(i)):D.fsample:D.indsample(speakstop(i));
                if length(ctrl)>3
                    ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:(end-1))'];
                    conditionlabels = [conditionlabels, repmat({'speak'}, 1, size(ctrl, 1))];
                    trl  = [trl; ctrl];
                end
            end
            if length(reststart)~=length(reststop)
                error('start/stop numbers mismatch');
            end
            for i = 1:length(reststart)
                ctrl = D.indsample(reststart(i)):D.fsample:D.indsample(reststop(i));
                if length(ctrl)>3
                    ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:(end-1))'];
                    conditionlabels = [conditionlabels, repmat({'rest'}, 1, size(ctrl, 1))];
                    trl  = [trl; ctrl];
                end
            end



        case 'WALK'

            headY = detrend(D(D.indchannel('head_y'), :), 'constant');
            
            if strcmp(details.initials, 'LN_PR_D006')
           
                sit      = headY > 50;
                standing = find(diff(sit)<0);
                standing = standing(standing>0.05*length(sit) & standing<0.95*length(sit));
                standing = unique([standing length(sit)]);
                sitting  = find(diff(sit)>0);
                sitting  = sitting(sitting>0.05*length(sit) & sitting<0.95*length(sit));
                sitting = unique([1 sitting]);
    
                if length(sitting)~=length(standing)
                    figure, plot(headY)
                    hold on, plot(diff(sit)*100)
                    hold on, plot(sitting, mean(headY), 'r*')
                    plot(standing, mean(headY), 'k*')
                    error('sitting/standing numbers mismatch');
                end
    
                ev  = [];
                trl = [];
                conditionlabels = {};
                for i = 1:length(sitting)
                    if i>1
                        ev = spm_cat_struct(ev, struct('type', 'sit', 'value', 1, 'time', D.time(sitting(i))));
                    end
                    ctrl = sitting(i):D.fsample:standing(i);
                    if length(ctrl)>3
                        ctrl = [ctrl(2:(end-2))' ctrl(3:(end-1))' 0*ctrl(2:(end-2))'];
                        conditionlabels = [conditionlabels, repmat({'sit'}, 1, size(ctrl, 1))];
                        trl  = [trl; ctrl];
                    end
                    if i<length(sitting)
                        ctrl = standing(i):D.fsample:sitting(i+1);
                        if length(ctrl)>3
                            ctrl = [ctrl(2:(end-2))' ctrl(3:(end-1))' 0*ctrl(2:(end-2))'];
                            conditionlabels = [conditionlabels, repmat({'stand'}, 1, size(ctrl, 1))];
                            trl  = [trl; ctrl];
                        end
                        ev = spm_cat_struct(ev, struct('type', 'stand', 'value', 1, 'time', D.time(standing(i))));
                    end
                end
            else
                ev= D.events(':');
                evv_walk = ev(strmatch('walk', {ev.type}));
                evv_stand = ev(strmatch('stand', {ev.type}));
                
                start = D.indsample(min([evv_walk.time]));
                stop = D.indsample(max([evv_walk.time]));
                
                [~,onsets1,widthz1]= findpeaks(zscore(diff(smooth(headY(start:stop),100))),...
                    "MinPeakHeight", 2, "MinPeakProminence", 3, 'MinPeakDistance', 5*D.fsample);
                onsets1=onsets1+start;
                [~,onsets2,widthz2]= findpeaks(-zscore(diff(smooth(headY(start:stop),100))),...
                    "MinPeakHeight", 2, "MinPeakProminence", 3, 'MinPeakDistance', 5*D.fsample);
                onsets2=onsets2+start;
                onsets=[onsets1;onsets2];
                widthz=[widthz1;widthz2];
                [onsets,ind_p]=sort(onsets, 'ascend');
                widthz=widthz(ind_p);

                
                k=[]; m=1;
                for i=1:numel(onsets)-1
                    if abs(onsets(i)-onsets(i+1))<5*D.fsample
                        k(m)=i;
                        m=m+1;
                    end
                end

%                 idx=kmeans(onsets',10);
                

                if numel(onsets)-numel(k)~=5
                    figure, plot((diff(headY)))
                    hold on, plot(headY)
                    plot(onsets, mean(headY), '*k')
                    plot(onsets(k), mean(headY), '*r')
%                     color={'r','g','k','y','c','r','g','k','y','c'};
%                     for i=1:10
%                     plot(onsets(find(idx==i)), mean(headY), '*', 'Color',color{i})
%                     end
                    warning("walking numbers don't match number of 5 trials");
                end
                
                epochlength = round(D.fsample);
                
                trl = [];
                conditionlabels = {};
                ev = [];
                
                i=1;
                while i<numel(onsets)+1
                    if ismember(i,k)
                        ctrl = round(onsets(i)-2*epochlength):epochlength:round(onsets(i+1)+2*epochlength);
                        ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:end-1)'];
                        conditionlabels = [conditionlabels, repmat({'walk'}, 1, size(ctrl, 1))];
                        trl=[trl; ctrl];
                        i=i+2;
                    else
                        ctrl = round(onsets(i)-epochlength):epochlength:round(onsets(i)+epochlength);
                        ctrl = [ctrl(1:(end-1))' ctrl(2:end)' 0*ctrl(1:end-1)'];
                        conditionlabels = [conditionlabels, repmat({'walk'}, 1, size(ctrl, 1))];
                        trl=[trl; ctrl];
                        i=i+1;
                    end 
                end
                
                 ev = arrayfun(@(x) ...
                     spm_cat_struct(ev, struct('type', 'walk', 'value', 1, 'time', D.time(trl(x,1)))), [1:size(trl,1)]);
                
                 start = D.indsample(min([evv_stand.time]));
                 stop = D.indsample(max([evv_stand.time]));
                 trl_stand=[(start:epochlength:stop-epochlength)'  ...
                     (start+epochlength:epochlength:stop)' 0*(start:epochlength:stop-epochlength)'];
                 delete_trials=[];
                 for i=1:numel(trl_stand(:,1))
                     check_overlap=ismember(trl_stand(i,1):trl_stand(i,2), ...
                             cell2mat(arrayfun(@(x) trl(x,1):trl(x,2), [1:size(trl,1)], 'UniformOutput', false))');
                     if any(check_overlap(2:end-2))
                         delete_trials=[delete_trials, i];
                     end
                 end 
                 trl_stand(delete_trials,:)=[];

                 ev_temp=[];
                 ev_temp = arrayfun(@(x) ...
                     spm_cat_struct(ev_temp, struct('type', 'stand', 'value', 1, 'time', D.time(trl_stand(x,1)))),...
                     [1:size(trl_stand,1)]);

                 ev=spm_cat_struct(ev,ev_temp);

                 conditionlabels = [conditionlabels, repmat({'stand'}, 1, size(trl_stand, 1))];
                 trl=[trl; trl_stand];
                                

        end
        otherwise
            epoch = false;
    end
    
    S = [];
    S.D = D;
    Dcont = copy(S.D, [prefix initials '_rec_' num2str(rec_id) '_' condition '_' num2str(f) '_cont']);

    Dcont = events(Dcont, 1, ev);
    Dcont.initials = initials;
    Dcont = dbs_eeg_headmodelling(Dcont);


    if epoch

        S = [];
        S.D = D;
        S.trl = trl;
        S.conditionlabels = conditionlabels(:);
        D = spm_eeg_epochs(S);

        if ~keep, delete(S.D);  end

        S = [];
        S.D = D;
        S.badchanthresh = details.badchanthresh;
        S.methods(1).fun = 'events';
        S.methods(1).channels = {'EEG'};
        S.methods(1).settings.whatevents.artefacts = 1;

        D = spm_eeg_artefact(S);

        if ~keep, delete(S.D);  end


        % Trial rejection =========================================
        S = [];
        S.D = D;
        S.badchanthresh = 1;
        S.methods(1).channels = {'LFP'};
        S.methods(1).fun = 'zscore';
        S.methods(1).settings.threshold = details.lfpthresh;

        D = spm_eeg_artefact(S);

        % ************ Breakpoint 2
        % ind = D.indchantype('LFP')
        % figure;plot(D.time, squeeze(D(ind(1), :, :)))

        %  details.badchanthresh = 0.02;
        %  S.badchanthresh = details.badchanthresh;
        %  D = spm_eeg_artefact(S);

        if ~keep, delete(S.D);  end


        if ~isempty(ecgind)
            S.D = Da;
            Da = spm_eeg_artefact(S);

            if ~keep, delete(S.D);  end
        end

        %%
        S = [];
        S.D = D;
        fD{f} = spm_eeg_remove_bad_trials(S);

        if ~keep && ~isequal(fname(fD{f}), fname(S.D))
            delete(S.D);
        end

    else
        fD{f} = D;
    end


    fD{f} = fD{f}.move([prefix initials '_rec_' num2str(rec_id) '_' condition '_' num2str(f)]);

    if ~isempty(ecgind)
        S = [];
        S.D = Da;
        aD{f} = spm_eeg_remove_bad_trials(S);

        if ~keep && ~isequal(fname(aD{f}), fname(S.D))
            delete(S.D);
        end
    end


end
%
if rec_id~=4
    fD(cellfun('isempty', fD)) = [];
    
    if ~isempty(ecgind)
        aD(cellfun('isempty', fD)) = [];
    end
    
    nf = numel(fD);
    
    if numel(fD)>1
        if ~isempty(ecgind)
            S.D = fname(aD{1});
            for f = 2:numel(aD)
                S.D = strvcat(S.D, fname(aD{f}));
            end
            Da = spm_eeg_merge(S);
        end
    
        if epoch
            S = [];
            S.D = fname(fD{1});
            for f = 2:numel(fD)
                S.D = strvcat(S.D, fname(fD{f}));
            end
            S.recode = 'same';
            D = spm_eeg_merge(S);
    
            fileind =[];
            for f = 1:numel(fD)
                fileind = [fileind f*ones(1, ntrials(fD{f}))];
                D = events(D, find(fileind == f), events(fD{f}, ':'));
                D = trialonset(D, find(fileind == f), trialonset(fD{f}, ':'));
    
                if ~keep
                    delete(fD{f});
                end
            end
            D.fileind = fileind;
    
            fD = {D};
        end
    elseif  numel(fD)==1
        fD{1}.fileind = ones(1, ntrials(fD{1}));
    
        if ~isempty(ecgind)
            Da = aD{1};
        end
    end
    %{
    S = [];
    S.D = Da;
    S.method = 'SVD';
    S.timewin = [0
        100];
    S.ncomp = 2;
    Da = spm_eeg_spatial_confounds(S);
    
    S = [];
    S.D = D;
    S.method = 'SPMEEG';
    S.conffile = fullfile(Da);
    D = spm_eeg_spatial_confounds(S);
    
    S = [];
    S.D = D;
    S.correction = 'SSP';
    D = spm_eeg_correct_sensor_data(S);
    
    if ~keep, delete(S.D);  end
    
    % Comment out to keep the heartbeat file for later examination
    if ~keep, delete(Da);  end
    %}
    
    for f = 1:numel(fD)
        fD{f}.initials = initials;
        fD{f} = dbs_eeg_headmodelling(fD{f});
    end
    
    if numel(fD)==1
        fD = fD{1};
    end
    
    %
end


return

