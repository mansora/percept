function D = dbs_percept_lfp_spectra(initials, rec_id, condition)



    keep = 0;
    
    try
        [files_, seq, root, details] = dbs_subjects(initials, rec_id);
    catch
        return;
    end
    
    if nargin<3
        condition = 'R';
    end
    
    
    cd(fullfile(root, condition));
    
    % files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    try
        files = spm_select('FPList','.', ['^.' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials '_rec_' num2str(rec_id) '_' condition '_[0-9]*.mat']);
    end

% for n=1:size(files,1)

%     D = spm_eeg_load(files{n,:});
    temp_var=struct2cell(dir);

%     if isempty(cell2mat(strfind(temp_var(1,:),'EEG_spect_'))) && ...
%             isempty(cell2mat(strfind(temp_var(1,:),'LFP_spect_')))

        if 1
     
    
        D = spm_eeg_load(files);
    
      
        S = [];
        S.D = D;
        S.channels = details.chan;
        S.frequencies = 2:98;
        S.timewin = [-Inf Inf];
        S.phase = 0;
        S.method = 'mtmfft';
        S.settings.taper = 'dpss';
        S.settings.freqres = 1.5;
        S.prefix = 'LFP_spect_';
        D_temp = spm_eeg_tf(S);
        
        S = [];
        S.D = D_temp;
        S.robust = false;
        S.circularise = false;
        S.prefix = 'm';
        D_temp = spm_eeg_average(S);
        
        if ~keep, delete(S.D); end
    
        % S = [];
        % S.D = D;
        % S.method = 'Log';
        % S.prefix = 'r';
        % S.timewin = [-Inf 0];
        % S.pooledbaseline = 0;
        % D = spm_eeg_tf_rescale(S);
        % 
        % if ~keep, delete(S.D); end
        
        %D(:,:,:,:) = D(:,:,:,:)./repmat(sum(D(:, D.indfrequency(4):D.indfrequency(48), :, :), 2), 1, D.nfrequencies, 1, 1);
        
    %     D = move(D, spm_file(char(files{n,:}), 'prefix', 'LFP_spect_'));
        D_temp = move(D_temp, spm_file(char(files), 'prefix', 'LFP_spect_'));
    
    
        S = [];
        S.D = D;
        S.channels = D.chanlabels(D.indchantype('EEG'));
        S.frequencies = 2:98;
        S.timewin = [-Inf Inf];
        S.phase = 0;
        S.method = 'mtmfft';
        S.settings.taper = 'dpss';
        S.settings.freqres = 1.5;
        S.prefix = 'EEG_spect_';
        D = spm_eeg_tf(S);
        
        S = [];
        S.D = D;
        S.robust = false;
        S.circularise = false;
        S.prefix = 'm';
        D = spm_eeg_average(S);
        
        if ~keep, delete(S.D); end
    
        D = move(D, spm_file(char(files), 'prefix', 'EEG_spect_'));
    end
end

% end
