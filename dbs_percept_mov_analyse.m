D = spm_eeg_load;
%%
movchan = D.selectchannels({['regexp_.*hand|.*foot|.*head|.*thumb|.*index'...
    '|.*index|.*middle|.*ring|.*pinkie']});
%%
figure;
for i = 1:length(movchan)
    subplot(10, 4, i)
    plot(D.time, D(movchan(i), :, 1));
    title(char(D.chanlabels(movchan(i))));
end
%%
ev = events(D, 1, 'samples');
lbl = {
    'hand_L', 'left hand', 'middle_L_y';
    'hand_R', 'right hand', 'middle_R_y';
    'foot_L', 'left leg', 'foot_L_y';
    'foot_R', 'right leg', 'foot_R_y';
    };
dirs = {'up', 'down'};

trl = [];
conditionlabels = {};

S = [];
S.D = D;
S.timewin = [-1500 3000];
S.reviewtrials = 0;
S.save = 0;
for i = 1:size(lbl, 1)
    cmov = D(D.indchannel(lbl{i, 1}), :);

    figure;
    plot(cmov);
    hold on
    cev =  ev(strmatch(lbl{i, 2}, {ev(:).type}));
    plot([cev(strmatch('up', {cev(:).value})).sample], D(D.indchannel(lbl{i, 1}), [cev(strmatch('up', {cev(:).value})).sample]), 'r*');
    plot([cev(strmatch('down', {cev(:).value})).sample], D(D.indchannel(lbl{i, 1}), [cev(strmatch('down', {cev(:).value})).sample]), 'g*');

    for j = 1:numel(dirs)
        S.trialdef.conditionlabel = [lbl{i, 1} '_' dirs{j}];
        S.trialdef.eventtype      = lbl{i, 2};
        S.trialdef.eventvalue     = dirs{j};

        [ctrl, clbl] = spm_eeg_definetrial(S);
        template = cmov(ctrl(1, 1):ctrl(1,2));
        for m = 1:2
            if m==1
                ind = 0:mean(diff(ctrl(:, 1:2), [], 2));
                ind = repmat(ind, size(ctrl, 1), 1)+repmat(ctrl(:, 1), 1, length(ind));
                template = mean(cmov(ind));
            end
            maxshift = 150;
            for k = 1:size(ctrl, 1)
                cdat = cmov(ctrl(k, 1):ctrl(k,2));
                [c, lags] = xcorr(template, cdat, 'coeff', D.fsample);
                [mc mci] = max(c(find(abs(lags)<maxshift)));
                mci = mci - find(lags(find(abs(lags)<maxshift)) == 0);
                ctrl(k, 1:2) = ctrl(k, 1:2)-mci;
                cdat = cmov(ctrl(k, 1):ctrl(k,2));
                if m == 1
                    template = ((k-1)*template+cdat)./k;
                end
            end
        end
        trl = [trl;ctrl];
        conditionlabels = [conditionlabels clbl];
    end
end
%%
S = [];
S.D = D;
S.trl = trl;
S.conditionlabels = conditionlabels(:);
D = spm_eeg_epochs(S);
%%
for i = 1:size(lbl, 1)
    for j = 1:numel(dirs)
        figure;
        plot(D.time, squeeze(D(D.indchannel(lbl{i, 1}), :, D.indtrial([lbl{i, 1} '_' dirs{j}]))));
    end
end
%%
freq = 1:2.5:100;
res  = 2.5*ones(size(freq));
res(freq>25) = 0.1*freq(freq>25);
res(freq>50) = 5;

S = [];
S.D = D;
S.channels = {'EEG', 'LFP'};
S.frequencies = freq;
S.timewin = [-Inf Inf];
S.phase = 0;
S.method = 'mtmconvol';
S.settings.taper = 'dpss';
S.settings.timeres = 400;%;200;
S.settings.timestep = 50;%25;
S.settings.freqres = res;%5;%
D = spm_eeg_tf(S);

S = [];
S.D = D;
S.robust.ks = 20;
S.robust.bycondition = 0;
D = spm_eeg_average(S);


S = [];
S.D = D;
S.method = 'LogR';
S.timewin = [-Inf 0];
S.prefix = 'r';
D = spm_eeg_tf_rescale(S);