function [fixed_peaks] = percept_fix_ecg_peaks(ecg, fs, peaks, islfp)


ind1 = repmat(-round(fs/2):round(fs/2), length(peaks), 1);
ind2 = repmat(peaks(:), 1, size(ind1, 2));

ind = ind1+ind2;

ind(any((ind<1 | ind>length(ecg))'), :) = [];

template = mean(ecg(ind));

if islfp
    [~, templI] = max(abs(template));
    peak_corr   = templI-round(fs/2)-1;
    fixed_peaks = peaks+peak_corr;
else

    ecg_enhanced = zscore(conv(ecg, flipud(template(:)), 'same'));

    [~, s1] = findpeaks(ecg_enhanced,'MinPeakHeight', 2,...
        'MinPeakDistance',fs/2);
    %%
    conv_template = conv(template, flipud(template(:)), 'same');
    [~, convI] = max(conv_template);
    [~, templI] = max(abs(template));

    if template(templI)<0
        ecg = -ecg;
    end

    peak_corr = templI - convI;

    % Fix missed peaks
    s1(find(diff(s1)<fs/2)+1) = [];
    ds1 = diff(s1);
    fds1 = medfilt1(ds1, 10);

    missed = find(abs(ds1./fds1-1)>0.2);

    fixed_peaks = s1;
    fixed_peaks(missed) = [];

    missed_orig = missed;
    missed(find(diff(missed)<2)+1)= [];

    n = length(s1);
    added = [];
    for i = 1:numel(missed)
        if missed(i)>1
            prev = s1(missed(i)-1);
            next = s1(find((1:n)>missed(i) & ~ismember(1:n, missed_orig), 1, 'first'));
            while (next-prev)>1.8*fds1(missed(i))
                start = round(prev+fds1(missed(i))*0.5);
                stop  = round(prev+fds1(missed(i))*1.5);
                [~, ind] = max(ecg_enhanced(start:stop));
                ind = ind+start-1;
                added = [added ind];
                prev = ind;
            end
        end
    end

    fixed_peaks = sort([fixed_peaks added])+peak_corr;    
end

fixed_peaks(fixed_peaks<1 | fixed_peaks>length(ecg)) = [];


for i = 1:numel(fixed_peaks)
    start = max(1, round(fixed_peaks(i)-fs/10));
    stop  = min(length(ecg), round(fixed_peaks(i)+fs/10));

    [~, ind] = max(ecg(start:stop));
    [~, ref] = min(abs(ecg(start:stop)-ecg(fixed_peaks(i))));

    fixed_peaks(i) = fixed_peaks(i) + (ind-ref);
end

return

%{
trfds1 = nan(max(rfds1), size(rfds1, 2));
trfds1(1, :) = ds1;
for i = find(rfds1>1)
   trfds1(1:rfds1(i), i) = fds1(i); 
end
trfds1 = reshape(trfds1, 1, []);
trfds1(isnan(trfds1 )) = [];
peaks2 = round(cumsum([s1(1) trfds1])+peak_corr);

fwd = find(ecg(peaks2+1)>ecg(peaks2));
while ~isempty(fwd)
    peaks2(fwd)= peaks2(fwd)+1;
    fwd = find(ecg(peaks2+1)>ecg(peaks2));
end

bwd = find(ecg(peaks2-1)>ecg(peaks2));
while ~isempty(bwd)
    peaks2(bwd)= peaks2(bwd)-1;
    bwd = find(ecg(peaks2-1)>ecg(peaks2));
end

fixed_peaks = peaks2;


ind1 = repmat(-round(fs/10):round(fs/2), length(peaks2), 1);
ind2 = repmat(peaks2(:), 1, size(ind1, 2));

ind = ind1+ind2;

to_remove_start = find(any((ind<1)'));
to_remove_end = find(any((ind>length(ecg))'));

removed_ind = 1:length(peaks2);

removed_ind([to_remove_start to_remove_end]) = [];
ind = ind(removed_ind, :);
%%
[template, est_lags]=woody(ecg(ind)', [],[],'woody','biased');

fest_lags = medfilt1(est_lags, 10);
outl_ind = find(abs(est_lags-medfilt1(est_lags, 10))>30);
for i = outl_ind
    if abs(est_lags(i))>abs(fest_lags(i))
        est_lags(i) =fest_lags(i);
    end
end
%%
[~, imax] = max(abs(template));

fixed_peaks = peaks2;
fixed_peaks(to_remove_start) = fixed_peaks(to_remove_start)+fest_lags(1)+((round(fs/2)+1)-imax);
fixed_peaks(to_remove_end) = fixed_peaks(to_remove_end)+fest_lags(end)+((round(fs/2)+1)-imax);

fixed_peaks(removed_ind) = fixed_peaks(removed_ind)+est_lags-((round(fs/2)+1)-imax);

fixed_peaks(fixed_peaks<1 | fixed_peaks>length(ecg)) = [];
fixed_peaks = round(fixed_peaks);

%%
figure;plot(ecg);
hold on
plot(fixed_peaks, ecg(fixed_peaks), '*r');
%}