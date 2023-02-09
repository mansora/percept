function run_allplots(initials, condition, freqband)
% initials='LN_PR_D006';
condition=cellstr(condition);
all_blocks={'PMT', 'ACT', 'POUR', 'R','REACH', 'WALK', 'WRITE','HPT'};
evoked_blocks={'PMT', 'ACT', 'POUR', 'REACH', 'WALK', 'HPT'};


for condd=1:numel(condition)


    if find(strcmp(evoked_blocks,condition{condd}))
        
        if find(strcmp({'ACT','PMT'},condition{condd}))
            if ~(strcmp(initials, 'LN_PR_D005') && strcmp(condition{condd}, 'PMT'))
                dbs_percept_mov_analyse(initials, 1, condition{condd})
            end
            dbs_percept_mov_analyse(initials, 2, condition{condd})
            
        elseif find(strcmp({'POUR','HPT','REACH','WALK','STAND'},condition{condd}))

            dbs_percept_stand_analyse(initials, 1, condition{condd})
            dbs_percept_stand_analyse(initials, 2, condition{condd})
           
        else
            warning('this block is not evoked')
        end

        % condition={'PMT', 'ACT', 'POUR', 'REACH', 'WALK', 'HPT'};
        dbs_eeg_evoked_tf_plot(initials,condition{condd})

        % condition={'PMT', 'ACT', 'POUR', 'REACH', 'WALK'};
        dbs_eeg_task_cohimages_plot(initials, condition{condd})

        
    end


    dbs_percept_rawdata_plot(initials, condition{condd})


    dbs_percept_lfp_spectra(initials, 1, condition{condd});
    dbs_percept_lfp_spectra(initials, 2, condition{condd});
    
    
    dbs_percept_lfp_spectra_plot(initials,condition{condd});

    dbs_percept_EEG_spectra_plot(initials,condition{condd}, [4 7]);
    dbs_percept_EEG_spectra_plot(initials,condition{condd}, [8 12]);
    dbs_percept_EEG_spectra_plot(initials,condition{condd}, [13 30]);
    dbs_percept_EEG_spectra_plot(initials,condition{condd}, [31 48]);
    dbs_percept_EEG_spectra_plot(initials,condition{condd}, [52 90]);




    % % condition={'PMT', 'ACT', 'POUR', 'R', 'REACH', 'WALK', 'WRITE'};
    dbs_eeg_percept_direction(initials, 1, condition{condd})
    dbs_eeg_percept_direction(initials, 2, condition{condd})
    % 
    %  
    % % condition={'PMT', 'ACT', 'POUR', 'R', 'REACH', 'WALK', 'WRITE'};
    dbs_eeg_percept_direction_plot(initials, condition{condd}, 'Granger')
    dbs_eeg_percept_direction_plot(initials, condition{condd}, 'Coherence')
    
    
    
    if ~isempty(freqband)
        % % condition={'PMT', 'ACT', 'POUR', 'R', 'REACH', 'WALK', 'WRITE'};
        dbs_percept_dics_bootstrap(initials, 1, condition{condd}, freqband)
        dbs_percept_dics_bootstrap(initials, 2, condition{condd}, freqband)
    
        % % condition={'PMT', 'ACT', 'POUR', 'R', 'REACH', 'WALK', 'WRITE'};
        [~, Max_peak_off_right(:,:,condd),~]=dbs_percept_find_max_cohpeaks(initials, 1, condition{condd}, freqband, 'Right', 4, 5);
        [~, Max_peak_off_left(:,:,condd),~]=dbs_percept_find_max_cohpeaks(initials, 1, condition{condd}, freqband, 'Left', 4, 5);
        [~, Max_peak_on_right(:,:,condd),~]=dbs_percept_find_max_cohpeaks(initials, 2, condition{condd}, freqband, 'Right', 4, 5);
        [~, Max_peak_on_left(:,:,condd),~]=dbs_percept_find_max_cohpeaks(initials, 2, condition{condd}, freqband, 'Left', 4, 5);
    
        Max_peaks.Max_peak_off_right=Max_peak_off_right;
        Max_peaks.Max_peak_off_left=Max_peak_off_left;
        Max_peaks.Max_peak_on_right=Max_peak_on_right;
        Max_peaks.Max_peak_on_left=Max_peak_on_left;
    
        save(['D:\home\results Percept Project\', initials,'\' initials, '_',condition{condd},'_Max_peaks',  num2str(freqband),'.mat'], 'Max_peaks')
    end
    close all
end