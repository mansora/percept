function [sigout, proj_out, ecg_peak_indices] = continuous_ecgremoval_new(sigin,settings,ecg,ecg_peak_indices)
% ECG-artefact correction script for LFP time series
% Epochs the data around each heartbeat (R peak) using Medtronic code
% Performs a singular value decomposition across epochs [BW]
% Removes first ncomp from each epoch
% Corrects for sudden jumps at start and end of each epoch
% Output is the corrected time series + index numbers of selected peaks
% Parameters should be chosen in order to cover most of the P-QRS-T wave
% but without overlap between subsequent P-QRS-T waves.
% This can be checked in figure 6: the blue line (original data) should be
% interrupted by short black (intermediate corrected) segments.
%
% REQUIRES:
% settings.art_width_search      = .1;  % search window for R peak
% settings.art_time_b4_peak      = .2;  % time in s before R peak (try to cover P)
% settings.art_time_after_peak   = .56; % time in s after R peak (try to cover T)
% settings.thr                   = .1;  % threshold for R peak detection
% settings.ncomp                 = 4;   % number of SVD components used to reconstruct artifact.
%                                         Could be increased if there is a lot of residual ECG left.
%                                         Note: ncomp > 20 is interpreted as a target percentage
%                                         of explained variance, e.g. 95 = 95%
% settings.Fs                           % sampling rate in Hz
% settings.polarity                     % 1 if R peak points upwards, 0 if R peak points downwards
%
% OPTIONAL:
% settings.showfigs                     % plot figures to monitor correction
% settings.savefigs                     % save figures to disk
% settings.label                        % label displayed as figure title/name
% settings.interactive                  % enable manual adjustments of detected peaks
%
% ecg                                   % synced ECG timeseries for visualization
% ecg_peak_indices                      % index numbers of pre-selected peaks
% -------------------------------------------------------------------------
% NOTE: perform this algorithm on a slighly longer time series as intended
% for analysis so first few seconds can be cut off due to filter
% -------------------------------------------------------------------------
% BW - 2 Feb 2018 / Oct 2021

if nargin==2
    ecg=[]; ecg_peak_indices=[];
elseif nargin==3
    ecg_peak_indices=[];
end
if size(sigin,2)>size(sigin,1)
    sigin=sigin';
end

%mandatory fields
Fs=settings.Fs;
polarity=settings.polarity;
art_width_search=settings.art_width_search;
art_time_b4_peak=settings.art_time_b4_peak;
art_time_after_peak=settings.art_time_after_peak;
% thr=settings.thr;
ncomp=settings.ncomp;

%other fields
if isfield(settings,'showfigs')
    showfigs=settings.showfigs;
else
    showfigs=1;
end
if isfield(settings,'savefigs')
    savefigs=settings.savefigs;
else
    savefigs=0;
end
if isfield(settings,'interactive')
    interactive=settings.interactive;
else
    interactive=1;
end
if isfield(settings,'label')
    label=settings.label;
else
    label='test';
end

if isempty(ecg)
    ecg=[];
    plotecg=0;
    if size(ecg,2)>size(ecg,1)
        ecg=ecg';
    end
else
    plotecg=1;
    scaleecg=nanstd(ecg)/nanstd(sigin);
    ecg=(ecg-nanmean(ecg))./scaleecg;
end
if isempty(ecg_peak_indices)
    ecg_peak_indices=[];
end

% Conversion of the parameters in number of samples
art_width_search_pts = round(art_width_search * Fs);
art_pts_b4_peak = round(art_time_b4_peak * Fs);
art_pts_after_peak = round(art_time_after_peak * Fs);
art_pts_plus_t_after_peak = art_pts_after_peak;
art_width_pts = art_pts_b4_peak + art_pts_plus_t_after_peak + 1;

% initialization
artifact_count = 0;
prev_pt = sigin(1);
data_index = 2;
art_index_vec = zeros(length(sigin), 1);
startedgepeak =[];
endedgepeak=[];
time=(1:length(sigin))/Fs;

if isempty(ecg_peak_indices)

    noECGTemp = sigin;
    LFPecg = sigin;

    LFPnorm = normalize(LFPecg);

    [Rpeak,locs_Rwave] = findpeaks(LFPnorm,'MinPeakHeight',(2.5*std(LFPnorm)),...
        'MinPeakDistance',Fs/2);

    % Also search the flipped signal for R-peaks:
    [Speak,locs_Swave] = findpeaks(-LFPnorm,'MinPeakHeight',(2.5*std(-LFPnorm)),...
        'MinPeakDistance',Fs/2);

    % Determine which way the peaks are highest, corresponding to R-peaks:
    if isempty(Rpeak)
        Rpeak = 0;
    end
    if isempty(Speak)
        Speak = 0;
    end

    if mean(Speak) > mean(Rpeak) && length(Speak) >= length(Rpeak)
        locs_Rwave = locs_Swave;
        polarity = 1;
        LFPnorm = -LFPnorm;
    end

    disp(['Number of peaks detected: ' num2str(length(locs_Rwave))]);

    % If there are no R-peaks detected at all:
    if isempty(locs_Rwave)
        disp('Inconsistent ECG artefact: LFP signal has no obvious R-peaks')
        % If heartbeats are missed: no ECG artefact is detected:
    elseif any(diff(locs_Rwave)/Fs > 3)
        disp('Inconsistent ECG artefact: LFP signal has no R-peak every three seconds')
        % If heart rate is too low:
    elseif length(locs_Rwave) < (40/60)*(length(LFPecg)/Fs)
        disp('Inconsistent ECG artefact: LFP signal has unreliable heart rate (< 40 bpm)')

        % Else: continue with removal
    else
        disp('Consistent ECG artefact')
    end
else
    disp('warning: using pre-defined ECG peaks');
    LFPnorm = sigin;
    locs_Rwave = ecg_peak_indices';
end

if interactive
    figure(123456);clf(123456);
    if plotecg
        plot(ecg,'g'); hold on
    end
    plot(LFPnorm, 'b'), hold on,plot(locs_Rwave, LFPnorm(locs_Rwave),'r*')
    legend('LFPs', ['Detected R-peaks: ' num2str(length(locs_Rwave))])
    title('Do you want to add or remove peaks y/n?');
    key=input('Press "y" to make manual adjustments, press "n" to continue filtering:','s');
    close(figure(123456))

    if key == 'y'
        figure(78146);clf(78146);
        l_epoch=1500;%5000;%10000
        nint=length(LFPnorm)/(l_epoch);
        j = 1;
        while j < nint+1
            figure(78146)
            plot(LFPnorm,'b'),hold on,plot(locs_Rwave, LFPnorm(locs_Rwave),'r*')
            xlim([(j-1)*l_epoch j*l_epoch])
            checkpeaks=1;
            while checkpeaks
                figure(78146)
                if plotecg
                    plot(ecg,'g'); hold on
                end
                plot(LFPnorm,'b'),hold on,plot(locs_Rwave, LFPnorm(locs_Rwave),'r*')
                title('Press "r" to remove a peak, "a" to add a peak, and any other key to continue');
                xlim([(j-1)*l_epoch j*l_epoch])
                key=input('Press "r" to remove a peak, "a" to add a peak, and any other key to continue:','s');
                if key=='r' % remove peak on click
                    [X,Y] = ginput(1);
                    [~,ix]=min(abs(locs_Rwave-X));
                    locs_Rwave(ix)=[];
                    clf
                elseif key=='a' % add peak on click
                    [X,Y] = ginput(1);
                    mn = round(X)-20;
                    mx = round(X)+20;
                    if mx > length(LFPnorm)
                        mx = length(LFPnorm);
                    elseif mn <= 0
                        mn = 1;
                    end
                    if polarity==1
                        x1 = find(LFPnorm == max(LFPnorm(mn:mx)));
                        if length(x1) > 1
                            x2 = find(x1>mn & x1<mx);
                            x1 = x1(max(x2));
                        end
                    elseif polarity==0
                        x1 = find(LFPnorm == min(LFPnorm(mn:mx)));
                        if length(x1) > 1
                            x2 = find(x1>mn & x1<mx);
                            x1 = x1(min(x2));
                        end
                    end
                    locs_Rwave = [locs_Rwave; x1];
                    locs_Rwave = sort(locs_Rwave);
                elseif key=='b' %go back one epoch
                    j = j - 1;
                elseif key=='f' %finish interactive
                    j = nint+1;
                else
                    checkpeaks=0; %done with this epoch, go to the next
                    j = j + 1;
                end
            end
        end
    end
    j = 1;
    disp(['Number of peaks detected after manual adjustments: ' num2str(length(locs_Rwave))]);

end

art_indicies = locs_Rwave';
artifact_count = length(locs_Rwave);

%Average of artifacts
cnt=1;
art_avg_count = 0;
art_sum = zeros(art_width_pts, 1);
toremove=[];
for i = 1:artifact_count
    start_index = art_indicies(i) - art_pts_b4_peak; end_index = art_indicies(i) + art_pts_plus_t_after_peak;
    if start_index > 0 && end_index <= length(sigin)
        allqrst(cnt,:)=sigin(start_index:end_index);
        if plotecg
            allqrst_ecg(cnt,:)=ecg(start_index:end_index);
        end
        cnt=cnt+1;
    elseif start_index <= 0
        disp('warning: first peak near start of the time window cannot be used in SVD')
        toremove=[toremove i];
        startedgepeak=art_indicies(i);
    elseif end_index > length(sigin)
        disp('warning: last peak near end of the time window cannot be used in SVD')
        toremove=[toremove i];
        endedgepeak=art_indicies(i);
    end
end % for i

art_indicies(toremove)=[];

disp(['number of peaks = ',num2str(size(allqrst,1))])

if showfigs
    figure,set(gcf,'color','w');
    if plotecg
        plot(time,ecg,'g'); hold on
    end
    plot(time,sigin,'b'),hold on,plot(time(art_indicies),sigin(art_indicies),'r*')
    if ~isempty(startedgepeak)
        plot(time(startedgepeak),sigin(startedgepeak),'m*');
    end
    if ~isempty(endedgepeak)
        plot(time(endedgepeak),sigin(endedgepeak),'m*');
    end
    %     x=get(gca,'xlim');plot(xlim,[thr thr],'k:')
    xlabel('Time [s]');
    title([strrep(label,'_',' '),': detected R peaks in original data'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

qrst = mean(allqrst,1);

% check if Average looks ok
if showfigs
    time_qrst=(1:length(qrst))/Fs;
    figure,set(gcf,'color','w');
    plot(time_qrst,qrst,'linewidth',2)
    xlabel('Time [s]');
    title([strrep(label,'_',' '),': Average P-QRS-T']);
    set(gca,'fontsize',14)
    if plotecg
        hold on,plot(time_qrst,mean(allqrst_ecg,1),'g');
        legend('template data','template ECG')
    else
        legend('template data')
    end
    if savefigs
        print(gcf,[label,'_template_',num2str(settings.ncomp),'comp.jpg'],'-djpeg');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%

sigout = sigin;

% perform SVD
[U,S,V] = svd(allqrst');
var_ex=diag(S).^2/sum(diag(S).^2);
if ncomp>20 % take %explained variance
    ind=find(cumsum(var_ex)>=ncomp/100);
    ncomp=ind(1);
end
proj=U(:,1:ncomp)*S(1:ncomp,:)*V';

if showfigs
    figure,set(gcf,'color','w','position', [ 43         305        1003         384]);
    subplot(1,3,[1 2]),plot(time_qrst,U(:,1:ncomp),'linewidth',2); title([strrep(label,'_',' '),': SVD components - cumulative energy = ',num2str(100*sum(var_ex(1:ncomp))),' %'])
    xlabel('Time [s]');
    labels=[];
    try
        for k=1:ncomp;labels=[labels;num2str(k)]; end
        legend(labels)
    end
    set(gca,'fontsize',14)
    subplot(133),bar(var_ex(1:10),'k');title('SVD components - % energy');
    set(gca,'fontsize',14)
    if savefigs
        print(gcf,[label,'_components_',num2str(settings.ncomp),'comp.jpg'],'-djpeg');
    end
end

% remove artifacts from data
for i=1:length(art_indicies)

    columnMeans = proj(:,i);
    columnMeans1 = columnMeans;

    if length(columnMeans1) >= round(0.05*Fs)
        Qwave = round(0.04*Fs);
        Swave = length(columnMeans1)-round(0.04*Fs);
    else
        Qwave = round((length(columnMeans1)/2)-2);
        Swave = length(columnMeans1)-round((length(columnMeans1)/2)-2);
    end
    firsthalf = columnMeans1(1:Qwave);
    secondhalf = columnMeans1(Swave:end);
    [firstzero, secondzero] = findSmallestDifference(firsthalf, secondhalf);
    if isnan(firstzero) % In this case, artifact corrupted the signal
        continue
    end
    secondzero = (Swave-1) + secondzero;
    columnMeans(1:firstzero-1) = columnMeans1(firstzero);       % Let tails run smoothly to smallest value
    columnMeans(secondzero+1:end) = columnMeans1(secondzero);

    % Important that both tails have same value:
    if columnMeans(end) < columnMeans(1)
        if firstzero > 1
            columnMeans(1:firstzero-1) = columnMeans(end);
        elseif firstzero == 1
            columnMeans(firstzero) = columnMeans(end);
        end
    elseif columnMeans(end) > columnMeans(1)
        if secondzero < length(columnMeans)
            columnMeans(secondzero+1:end) = columnMeans(1);
        elseif secondzero == length(columnMeans)
            columnMeans(secondzero) = columnMeans(1);
        end
    end

    %     Optimisation with x+b lsqnonlin:

    start_index(i) = art_indicies(i) - art_pts_b4_peak;
    end_index(i) = art_indicies(i) + art_pts_plus_t_after_peak;
    y = sigout(start_index(i):end_index(i));
    t = 1:length(y);

    % Gradient Search Options (Use 'doc optimset' for more options)
    options = optimset('lsqnonlin');
    options = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective');
    options = optimset('display','off');
    %                 options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt');
    %                 options = optimset(options, 'Display','iter');

    % Initial Guess & Upper & Lower Bounds
    p0 = [2];
    lb = [-10 -10];
    ub = [10 10];

    % errorfunc
    func = @(p)fune(p,columnMeans,y); % gives vector, required for lsqnonlin

    % LSQnonlin
    [parest,J,~,~,output]=lsqnonlin(func,p0,lb,ub,options);

    % Estimate & Plot yest
    [sigout(start_index(i):end_index(i)),ymod2(i,:)] = fune(parest,columnMeans,y);

    if showfigs
        if i == 7
            figure(); clf
            plot(t,y,'k',t, columnMeans1, 'b', t,columnMeans, 'g',t,ymod2(i,:),'m.','linewidth',4); hold on;
            legend('Measurements','Template','Zero Template', strcat('Gradient Search, err:',num2str(J)), 'FontSize', 12)
            xlim([0 164])
            xlabel('Samples [250 Hz]')
            title('SVD - LFP Timestamps')

            figure()
            plot(t,y, 'color', [0.6350 0.0780 0.1840], 'LineWidth',1); hold on;
            plot(t,columnMeans,'g','linewidth',3); hold on;
            plot(t,ymod2(i,:), '.', 'color', [0.3010 0.7450 0.9330],'linewidth',3, 'MarkerSize', 12);
            %                 legend('LFP(QRS)','QRS_{Template}', 'LFP_{ECG}(QRS)', 'FontSize', 12)
            set(gca,'visible','off')
        end
    end

    proj_out(:,i) = columnMeans;
    clear y columnMeans columnMeans1 tri

end

% Remove zero-projections - artifact
proj_out( :, ~any(proj_out,1) ) = [];

% check if continuous data are properly corrected
if showfigs
    figure,set(gcf,'color','w');
    plot(time,sigin,'b'),hold on, plot(time,sigout,'k')
    legend('raw','cleaned')
    title([strrep(label,'_',' '),': continuous time series'])
    set(gca,'fontsize',14)
end

% compare spectral profiles
[P_in,F]=pwelch(sigin,[],[],[],Fs);
[P_out,F]=pwelch(sigout,[],[],[],Fs);
if showfigs
    figure,set(gcf,'color','w');
    plot(F,P_in,'b'),hold on, plot(F,P_out,'r');
    legend('original','corrected final')
    xlim([0 40]),xlabel('Frequency [Hz]'),ylabel('Power')
    title(strrep(label,'_',' '))
    set(gca,'fontsize',14)
    if savefigs
        print(gcf,[label,'_psd_',num2str(settings.ncomp),'comp.jpg'],'-djpeg');
    end
end

ecg_peak_indices=[startedgepeak art_indicies endedgepeak];

function [idxA, idxB, result] = findSmallestDifference(A, B)

% Sort both arrays
% using sort function
A1 = sort(A);
B1 = sort(B);

m = length(A);
n = length(B);

% Initialize result as max value
result = 70;

% Scan Both Arrays up to
% size of of the Arrays
for a = 1:m
    for b = 1:n
        if (abs(A1(a) - B1(b)) < result)
            result = abs(A1(a) - B1(b));
            a1 = a;
            b1 = b;
        end
    end
end
if exist('a1','var')
    idxA = find(A == A1(a1));
    idxB = find(B == B1(b1));
else
    idxA = NaN;
    idxB = NaN;
end
result;

%* Error Function
function [e, yhat] = fune(p,u,y)

b = p(1);

% Define estimated y: yhat
yhat = u + b;

% Define error: e
e = y - yhat;
% J = e' * e;
