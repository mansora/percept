function [files, sequence, root, details] =dbs_subjects_percept(initials, rec_id)

if nargin <2
    rec_id = 1;
end

dbsroot = '\\piazzolla\vlad_shared';
outroot = 'D:\home\Data\DBS-MEG';

details = struct(...
    'mridir', fullfile(dbsroot, initials, 'MRI'));

details.chan = {'LFP'};
details.badchanthresh = 0.1;
details.bandstop = [70 180];
details.removespikes=0;
details.suffix = {'rec_1', 'rec_2', 'rec_3', 'rec_4', 'rec_5'};
details.initials=initials;

% details.eeg_ref = 'StimArt';
details.removesync = false;

details.lfpthresh = 4;

details.synch_ecg=1;
details.synch_percept_stamp=1;
details.process_logfiles=1;
details.process_videos=1;


% details.chanset = getfield(load(details.chanset), 'label');
%
% name = fieldnames(montage);
% montage = getfield(montage, name{1});
%
% details.fiducials = fullfile(dbsroot, initials, 'MRI', [initials '_smri_fid.txt']);


switch initials
    case 'LN_PR_D001'
        if rec_id == 1
            files={...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0001.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0002.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0003.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0005.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0006.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0007.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0008.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0019.vhdr'
                };
            sequence = {'R', 'PMT', 'ACT', 'SST', 'HPT', 'POUR', 'POUR', 'WALK'};
            root='\LN_PR_D001\rec1\';
            %details.lfpthresh = 20;
            details.freqrange=[65 75];
        elseif rec_id == 2
            files={...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0012.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0013.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0014.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0015.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0016.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0017.vhdr',...
                '\LN_PR_D001\raw_EEG\LN_PR_D001_0=20220107_0018.vhdr'
                };
            sequence = {'R', 'PMT', 'ACT', 'SST', 'HPT', 'POUR', 'WALK'};
            root='\LN_PR_D001\rec2\';
            %details.lfpthresh = 50;
            details.badchanthresh = 0.2;
            details.freqrange=[170 190];
        end
        details.bandstop = [70];
        details.lfp_ref = 'LFP_Gpi_R_02';
        details.chan = {'LFP_Gpi_R_02'};
        details.eeg_ref=repmat({'StimArt'},1,numel(files));
    case 'LN_PR_D003'
        if rec_id == 1
            files={...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0001.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0002.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0003.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0004.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0005.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0006.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0007.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0008.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0021.vhdr',...
                };
            sequence = {'R', 'PMT', 'ACT', 'SST', 'HPT', 'SGT', 'SPEAK', 'POUR', 'WALK'};
            root='\LN_PR_D003\rec1\';

            %details.lfpthresh = 20;
            details.bandstop = [70];
            details.lfp_ref = 'LFP_Gpi_R_02';
            details.chan = {'LFP_Gpi_R_02'};

            details.eeg_ref=repmat({'P3'},1,numel(files));
            details.eeg_ref{1}='StimArt';
            details.eeg_ref{2}='StimArt';
            details.eeg_ref{3}='StimArt';
            % TODO last file in here doesn't work with either Pr or StimArt
            % see if there's another channel you can use

        elseif rec_id == 2
            files={...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0010.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0011.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0012.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0013.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0014.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0016.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0017.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0018.vhdr',...
                '\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0020.vhdr',...
                };
            sequence = {'R', 'PMT', 'ACT', 'SST', 'HPT', 'SGT', 'SPEAK', 'POUR', 'WALK'};
            root='\LN_PR_D003\rec2\';
            %details.lfpthresh = 20;
            details.bandstop = [70];
            details.lfp_ref = 'LFP_Gpi_R_02';
            details.chan = {'LFP_Gpi_R_02'};
        elseif rec_id == 5
            files= {'\LN_PR_D003\raw_EEG\LN_PR_D003_20220204_0019.vhdr'};
            sequence = {'R'};
            root='\LN_PR_D003\streaming\';
            details.lfp_ref = 'LFP_Gpi_L_12';
            %details.lfpthresh = 20;
            details.removesync = false;
            details.badchanthresh = 0.3;
            details.chan = {
                'LFP_Gpi_L_03'
                'LFP_Gpi_L_13'
                'LFP_Gpi_L_02'
                'LFP_Gpi_R_03'
                'LFP_Gpi_R_13'
                'LFP_Gpi_R_02'
                'LFP_Gpi_L_01'
                'LFP_Gpi_L_12'
                'LFP_Gpi_L_23'
                'LFP_Gpi_R_01'
                'LFP_Gpi_R_12'
                'LFP_Gpi_R_23'
                };
            details.eeg_ref=repmat({'P3'},1,numel(files));
            details.eeg_ref{end}='StimArt';
            details.removespikes=1;
        end

        details.lfp_ref = 'LFP_Gpi_R_02';
        details.chan = {'LFP_Gpi_R_02'};

        details.lfpthresh = 20;
        details.bandstop = [70];
        details.freqrange=[70 90];

    case 'LN_PR_D004'
        %details.lfpthresh = 20;
        details.bandstop = [70];
        details.freqrange=[90 110];        
        details.lfp_ref = 'LFP_Gpi_R_02';

        if rec_id == 2
            files={...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0001.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0002.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0003.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0004.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0005.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0007.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0008.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0019.vhdr',...
                };
            sequence =  {'R', 'PMT', 'ACT', 'SST', 'HPT', 'SPEAK', 'POUR', 'WALK'};
            root='\LN_PR_D004\rec2\';

            details.lfp_ref = 'LFP_Gpi_R_02';
            details.eeg_ref = 'EMG2';
            details.chan = {'LFP_Gpi_R_02'};
            %details.lfpthresh = 30;

        elseif rec_id == 1
            files={...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0009.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0010.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0011.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0012.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0013.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0014.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0015.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0016.vhdr',...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0018.vhdr',...
                };
            sequence = {'R', 'PMT', 'ACT', 'SST', 'HPT', 'SPEAK', 'POUR', 'R', 'WALK'};
            root='\LN_PR_D004\rec1\';

            details.lfp_ref = 'LFP_Gpi_R_02';
            details.eeg_ref = 'EMG2';
            details.chan = {'LFP_Gpi_R_02'};
            %details.lfpthresh = 20;

        elseif rec_id == 3
            files={...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0020.vhdr',...
                };
            sequence = {'R'};
            root='\LN_PR_D004\rec3\';

        elseif rec_id == 5
            files={...
                '\LN_PR_D004\raw_EEG\LN_PR_D004_20220304_0017.vhdr',...
                };
            sequence = {'R'};
            details.lfp_ref = 'LFP_Gpi_L_01';
            details.eeg_ref = 'EMG2';
            root='\LN_PR_D004\streaming\';
            details.chan = {
                'LFP_Gpi_L_03'
                'LFP_Gpi_L_13'
                'LFP_Gpi_L_02'%
                'LFP_Gpi_R_03'
                'LFP_Gpi_R_13'
                'LFP_Gpi_R_02'
                'LFP_Gpi_L_01'%
                'LFP_Gpi_L_12'%
                'LFP_Gpi_L_23'
                'LFP_Gpi_R_01'
                'LFP_Gpi_R_12'%
                'LFP_Gpi_R_23'
                };
        end

        details.eeg_ref=repmat({'EMG2'},1,numel(files));
    case 'LN_PR_D005'
        details.lfpthresh = 20;
        details.bandstop = [70];
        details.lfp_ref = 'LFP_Gpi_L_02';
        details.freqrange=[110 130];

        if rec_id == 2
            files={...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0001.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0002.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0003.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0004.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0005.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0006.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0007.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0008.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0018.vhdr'
                };
            sequence =  {'R', 'PMT', 'ACT', 'SST', 'HPT', 'SGT', 'SPEAK', 'POUR', 'WALK'};
            root='\LN_PR_D005\rec2\';

            %details.lfpthresh = 30;

        elseif rec_id == 1
            files={...
                %                 '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0009.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0010.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0011.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0012.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_00120.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0013.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0014.vhdr',...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0016.vhdr'
                };
            %             sequence = {'R', 'SGT', 'HPT', 'ACT', 'SST', 'R', 'SGT'};
            sequence = {'SGT', 'HPT', 'ACT', 'SST', 'R', 'SGT', 'WALK'};
            root='\LN_PR_D005\rec1\';
        elseif rec_id == 3
            files={...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0017.vhdr',...
                };
            sequence = {'R'};
            root='\LN_PR_D005\rec3\';

            details.lfp_ref = 'LFP_Gpi_L_02';
        elseif rec_id == 5
            files={...
                '\LN_PR_D005\raw_EEG\LN_PR_D005_20220401_0019.vhdr',...
                };
            sequence = {'R'};
            details.lfp_ref = 'LFP_Gpi_R_23';
            details.eeg_ref = 'StimArt';
            root='\LN_PR_D005\streaming\';
            details.chan = {
                'LFP_Gpi_L_03'
                'LFP_Gpi_L_13'
                'LFP_Gpi_L_02'%
                'LFP_Gpi_R_03'
                'LFP_Gpi_R_13'
                'LFP_Gpi_R_02'
                'LFP_Gpi_L_01'%
                'LFP_Gpi_L_12'%
                'LFP_Gpi_L_23'
                'LFP_Gpi_R_01'
                'LFP_Gpi_R_12'%
                'LFP_Gpi_R_23'
                };
            details.freqrange=[1 200];
        end

        case 'LN_PR_D006'
        details.process_logfiles = 1;
        details.process_videos = 1;
        details.bandstop = 124;
        details.lfpthresh = 3.5;        
        details.lfp_ref = 'LFP_Gpi_L_13';
        details.freqrange=[120 130];
        details.synch_ecg = 0;
        details.synch_percept_stamp = 1;
        if rec_id == 2
            files={...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0001.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0002.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0003.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0004.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0005.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0006.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0007.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0008.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0024.vhdr'
                };
            sequence =  {'R', 'PMT', 'ACT', 'HPT', 'HPT', 'WRITE', 'WRITE', 'POUR', 'WALK'};
            root='\LN_PR_D006\rec2\';

            %details.lfpthresh = 30;
            details.chan =  {'LFP_Gpi_L_13', 'LFP_Gpi_R_13'};
        elseif rec_id == 1
            files={...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0015.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0016.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0017.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0018.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0019.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0020.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0021.vhdr',...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0022.vhdr'                
                };
            
             sequence =  {'R', 'PMT', 'ACT', 'HPT', 'HPT', 'WRITE', 'POUR', 'WALK'};
            root='\LN_PR_D006\rec1\';
            details.badchanthresh = 0.35;
            details.chan =  {'LFP_Gpi_L_13', 'LFP_Gpi_R_13'};
        elseif rec_id == 5
            files={...
                '\LN_PR_D006\raw_EEG\LN_PR_D006_20220531_0023.vhdr',...
                };
            sequence = {'R'};
            details.lfp_ref = 'LFP_Gpi_L_13';
            details.eeg_ref = 'StimArt';
            details.lfpthresh = 5;
            root='\LN_PR_D006\streaming\';
            details.process_logfiles = 0;
            details.chan = {
                'LFP_Gpi_L_03'
                'LFP_Gpi_L_13'
                'LFP_Gpi_L_02'%
                'LFP_Gpi_R_03'
                'LFP_Gpi_R_13'
                'LFP_Gpi_R_02'
                'LFP_Gpi_L_01'%
                'LFP_Gpi_L_12'%
                'LFP_Gpi_L_23'
                'LFP_Gpi_R_01'
                'LFP_Gpi_R_12'%
                'LFP_Gpi_R_23'
                };
            details.synch_ecg = 1;
            details.synch_percept_stamp = 0;
        end
    
        details.eeg_ref=repmat({'StimArt'},1,numel(files));
end


files = files(:);

[~, file_table] = xlsread(fullfile(dbsroot, initials, [initials '.xlsx']));
file_table_array=readmatrix(fullfile(dbsroot, initials, [initials '.xlsx']));
details.vidoffset=zeros(2,length(files));

for f=1:length(files)
    ind = strmatch(spm_file(files{f}, 'basename'), file_table(:, 1), 'exact');

    lfp_file = {};
    log_file = {};
    video_file={};
    LED_file={};
    for i = 1:numel(ind)
        lfp_file{i}   =  fullfile(dbsroot, initials, 'raw_LFP', file_table{ind, 2});
        log_file{i}   =  spm_file(fullfile(dbsroot, initials, 'raw_Logfiles', file_table{ind, 4}), 'ext', '.mat');
        video_file{i} =  fullfile(dbsroot, initials, 'processed_MotionCapture', 'jsons', file_table{ind, 3});
        LED_file{i}   =  fullfile(dbsroot, initials, 'processed_MotionCapture', 'LED_videos', ['LED_', file_table{ind, 3}]);
    end

    if numel(ind)==1
        files(f, 2) = lfp_file;
        files(f, 3) = log_file;
        files(f, 4) = video_file;
        files(f, 5) = LED_file;
    else
        files{f, 2} = lfp_file;
        files{f, 3} = log_file;
        files{f, 4} = video_file;
        files{f, 5} = LED_file;
    end


    files{f, 1} = fullfile(dbsroot, files{f});


    if file_table_array(ind-1, 5)==1
        details.vidoffset_tocompute{f}='yes';
    else
        details.vidoffset_tocompute{f}='no';
        details.vidoffset(:,f)=[file_table_array(ind-1, 6) file_table_array(ind-1, 7)];
        for i = 1:numel(ind)
            LED_signal{i}=fullfile(dbsroot, initials, 'processed_MotionCapture', 'LED_signals', ['LED_', file_table{ind, 3} '.mat']);
        end
        if numel(ind)==1
            files(f, 6) = LED_signal;
        else
            files{f, 6} = LED_signal;
        end
    end
end



root = fullfile(outroot, root);