initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005', 'LN_PR_D006','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};

tasks={'ACT', 'PMT'};

%
% lines 154 to 236 are commented out
% these three  lines are changed in the code dbs_percept_mov_analyse:
% S.timewin = [-997 2000]; %line 62
% conditionlabels = [conditionlabels clbl];  % line 116
% De = move(S.D, [erase(S.D.fname, '_cont')]); % line 241
% 
% for the resttrials they become
% S.timewin = [-1000 0];
% conditionlabels = [conditionlabels repmat({'rest'}, size(clbl))];
% De = move(S.D, ['resttrials_' erase(S.D.fname, '_cont')]);
% 
% 
% for the maintrials they become
% S.timewin = [0 1000];
% conditionlabels = [conditionlabels clbl];
% De = move(S.D, ['maintrials_' erase(S.D.fname, '_cont')]);

% and then you have to merge them by running to following piece
% 
% S=[];
% S.D={D1, D2};
% D_tot=spm_eeg_merge(S);




% for t=1:numel(tasks)
%     for i=1:numel(initials)
%         if ~(strcmp(initials{i}, 'LN_PR_D005') && strcmp(tasks{t}, 'PMT'))
%             dbs_percept_mov_analyse(initials{i}, 1, tasks{t})
%         end
%             dbs_percept_mov_analyse(initials{i}, 2, tasks{t})
%     end
% end


% for t=1:numel(tasks)
%     for i=1:numel(initials)
%             for rec_id=1:2
%                 try
%                     [files_, seq, root, details] = dbs_subjects_percept(initials{i}, rec_id);
%                 catch
%                     return;
%                 end
%                 
%                 
%                if ~(rec_id==1 && strcmp(initials{i}, 'LN_PR_D005') && strcmp(tasks{t}, 'PMT'))
% 
%                     cd(fullfile(root,  tasks{t}));
%                     
%                     try
%                         files1 = spm_select('FPList','.', ['^' 'resttrials_' initials{i} '_rec_' num2str(rec_id) '_' tasks{t} '_[0-9]*.mat']);
%                     catch
%                         files1 = spm_select('FPList','.', ['^' 'resttrials_' 'regexp_.*c|.*' initials{i} '_rec_' num2str(rec_id) '_' tasks{t} '_[0-9]*.mat']);
%                     end
%                     
%                     if isempty(files1)
%                         files1 = spm_select('FPList','.', ['^' 'resttrials_' '.' initials{i} '_rec_' num2str(rec_id) '_' tasks{t} '_[0-9]*.mat']);
%                     end
%     
%                     D1=spm_eeg_load(files1);
%     
%     
%                     try
%                         files2 = spm_select('FPList','.', ['^' 'maintrials_' initials{i} '_rec_' num2str(rec_id) '_' tasks{t} '_[0-9]*.mat']);
%                     catch
%                         files2 = spm_select('FPList','.', ['^' 'maintrials_' 'regexp_.*c|.*' initials{i} '_rec_' num2str(rec_id) '_' tasks{t} '_[0-9]*.mat']);
%                     end
%                     
%                     if isempty(files2)
%                         files2 = spm_select('FPList','.', ['^' 'maintrials_' '.' initials{i} '_rec_' num2str(rec_id) '_' tasks{t} '_[0-9]*.mat']);
%                     end
%     
%                     D2=spm_eeg_load(files2);
%                    
%     
%                     
%                     S=[];
%                     S.D={D1, D2};
%                     D_tot=spm_eeg_merge(S);
%     
%                     S=[];
%                     S.D=D_tot;
%                     De = move(D_tot, ['new_' erase(S.D.fname, 'cresttrials_')]);
% 
%                end
% 
%                 
% 
%             end
% 
% 
% 
%     end
% end


for t=1:numel(tasks)
    for i=1:numel(initials)
        if ~(strcmp(initials{i}, 'LN_PR_D005') && strcmp(tasks{t}, 'PMT'))
            dbs_eeg_percept_direction(initials{i}, 1,   tasks{t})     
            dbs_percept_new_lfp_spectra(initials{i}, 1, tasks{t})
        end
            dbs_eeg_percept_direction(initials{i}, 2,   tasks{t})
            dbs_percept_new_lfp_spectra(initials{i}, 2, tasks{t})
%             dbs_eeg_percept_direction_plot(initials{i}, tasks{t}, 'Granger')
            dbs_eeg_percept_direction_new_plot(initials{i}, tasks{t}, 'Coherence')
            dbs_percept_new_lfp_spectra_plot(initials{i},tasks{t});
    end
end
