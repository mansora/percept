function Da=PoolTrialsRest

close all
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
    tasks={'R', 'SST', 'HPT', 'POUR', 'SPEAK', 'WRITE', 'SGT'};
    name_trials={'R', 'rest_right', 'rest_left', 'rest', 'rest', 'rest', 'rest', 'rest'};

    Da={};
    Df={};
    for i=1:numel(initials)

        for t=1:numel(tasks)

            try
            [files_, seq, root, details] = dbs_subjects(initials{i}, 1);
            catch
                return;
            end
       
            cd(fullfile(root, tasks{t}));
            
            try
                files = spm_select('FPList','.', ['^.' initials{i} '_rec_' num2str(1) '_' tasks{t} '_[0-9]*.mat']);
            catch
                files = spm_select('FPList','.', ['regexp_.*c|.*' initials{i} '_rec_' num2str(1) '_' tasks{t} '_[0-9]*.mat']);
            end
            
            if isempty(files)
                files = spm_select('FPList','.', ['^' initials{i} '_rec_' num2str(1) '_' tasks{t} '_[0-9]*.mat']);
            end

            try
                D=spm_eeg_load(files);
                S=[];
                S.D=D;
                if t>1
                    D = badtrials(D, [find(~contains(D.conditions, 'rest'))], 1);

                end
                D=spm_eeg_remove_bad_trials(S);
                D=conditions(D, 1:D.ntrials, 'R');
                Df{t}=D;
            catch
            end

        end
        
        S=[];
        S.D=Df;
        Da{i}=spm_eeg_merge(S);    

        for k=1:numel(Df)
            S=[];
            S.D=Df{k};
            delete(S.D);
        end
         
            
    end





end