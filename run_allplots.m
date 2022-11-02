
initials='LN_PR_D006';

% condition={'PMT', 'ACT', 'POUR', 'REACH', 'WALK', 'HPT'};
% for cond=1:numel(condition)
% dbs_eeg_evoked_tf_plot('LN_PR_D006',condition{cond})
% end



% condition={'PMT', 'ACT', 'POUR', 'R', 'REACH', 'WALK', 'WRITE'};
% for cond=1:numel(condition)
%     dbs_percept_lfp_spectra(initials, 1, condition{cond});
% end
% 
% for cond=1:numel(condition)
%     dbs_percept_lfp_spectra(initials, 2, condition{cond})
% end
% 
% 
% 
% for cond=1:numel(condition)
% dbs_percept_lfp_spectra_plot('LN_PR_D006',condition{cond})
% end

% condition={'PMT', 'ACT', 'POUR', 'REACH', 'WALK'};
% for cond=1:numel(condition)
%     dbs_eeg_task_cohimages_plot(initials, condition{cond})
% end

% condition={'PMT', 'ACT', 'POUR', 'R', 'REACH', 'WALK', 'WRITE'};
% for cond=1:numel(condition)
%     dbs_eeg_percept_direction(initials, 1, condition{cond})
%     dbs_eeg_percept_direction(initials, 2, condition{cond})
% end
% 
% condition={'PMT', 'ACT', 'POUR', 'R', 'REACH', 'WALK', 'WRITE'};
% for cond=1:numel(condition)
%     dbs_eeg_percept_direction_plot(initials, condition{cond}, 'Granger')
%     dbs_eeg_percept_direction_plot(initials, condition{cond}, 'Coherence')
% end


condition={'PMT', 'ACT', 'POUR', 'R', 'REACH', 'WALK', 'WRITE'};
for cond=1:numel(condition)
    dbs_percept_dics_bootstrap(initials, 1, condition{cond}, [20 30])
    dbs_percept_dics_bootstrap(initials, 2, condition{cond}, [20 30])
end

condition={'PMT', 'ACT', 'POUR', 'R', 'REACH', 'WALK', 'WRITE'};
for cond=1:numel(condition)
    Max_peak_off_right(:,cond)=dbs_percept_find_max_cohpeaks(initials, 1, condition{cond}, [20 30], 'Right', 4, 1);
    Max_peak_off_left(:,cond)=dbs_percept_find_max_cohpeaks(initials, 1, condition{cond}, [20 30], 'Left', 4, 1);
    Max_peak_on_right(:,cond)=dbs_percept_find_max_cohpeaks(initials, 2, condition{cond}, [20 30], 'Right', 4, 1);
    Max_peak_on_left(:,cond)=dbs_percept_find_max_cohpeaks(initials, 2, condition{cond}, [20 30], 'Left', 4, 1);
end