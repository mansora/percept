initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005', 'LN_PR_D006','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
tasks={'R', 'ACT', 'PMT', 'SST', 'HPT', 'POUR', 'WALK', 'SPEAK', 'WRITE', 'SGT'};
failed_patient_prep={};
failed_patient_task={};
ind_patients = {};


for t=1:numel(tasks)
    failed_patient_Off={};
    failed_patient_On={};
    for i=1:numel(initials)
        close all
        try dbs_eeg_percept_prepare_spm12(initials{i}, 1, tasks{t})
        catch failed_patient_Off=[failed_patient_Off; initials{i}];    
        end

        close all
        try dbs_eeg_percept_prepare_spm12(initials{i}, 2, tasks{t})
        catch failed_patient_On=[failed_patient_On; initials{i}];
        end
    end
    failed_patient_prep{t,1}=failed_patient_Off;
    failed_patient_prep{t,2}=failed_patient_On;
end


for t=1:numel(tasks)
    failed_patient={};
    for i=1:numel(initials)
        close all
        try run_allplots(initials{i}, tasks{t},[])
        catch failed_patient=[failed_patient; initials{i}];    
        end    
    end
    failed_patient_task{t,1}=failed_patient;
    
end

for t=1:numel(tasks)
    plotLogSpectra_baselined(tasks{t})
    barplot_different_freqbands(tasks{t})
    barplot_different_freqbandsNoNormalization(tasks{t})
    barplotCoherence_different_freqbands(tasks{t}, 'Coherence')
    ind_patients{t,:} = plotConnectivityAverage(tasks{t}, 'Coherence')
    barplotCoherence_different_freqbands(tasks{t}, 'ShuffledCoherence')
    ind_patients{t,:} = plotConnectivityAverage(tasks{t}, 'ShuffledCoherence')
    barplotCoherence_different_freqbands(tasks{t}, 'GrangerfromEEG')
    ind_patients{t,:} = plotConnectivityAverage(tasks{t}, 'GrangerfromEEG')
    barplotCoherence_different_freqbands(tasks{t}, 'GrangertoEEG')
    ind_patients{t,:} = plotConnectivityAverage(tasks{t}, 'GrangertoEEG')
    barplotCoherence_different_freqbands(tasks{t}, 'ReversedGrangerfromEEG')
    ind_patients{t,:} = plotConnectivityAverage(tasks{t}, 'ReversedGrangerfromEEG')
    barplotCoherence_different_freqbands(tasks{t}, 'ReversedGrangertoEEG')
    ind_patients{t,:} = plotConnectivityAverage(tasks{t}, 'ReversedGrangertoEEG')

end

% for i=1:8
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 1, 'R')
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 2, 'R')
% end

% for i=1:8
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 1, 'ACT')
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 2, 'ACT')
% end

% for i=1:8
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 1, 'PMT')
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 2, 'PMT')
% end

% for i=1:8
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 1, 'SST')
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 2, 'SST')
% end

% for i=1:8
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 1, 'HPT')
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 2, 'HPT')
% end

% for i=1:8
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 1, 'POUR')
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 2, 'POUR')
% end
% 
% for i=3:8
%     close all
%     try dbs_eeg_percept_prepare_spm12(initials{i}, 1, 'WALK')
%     catch failed_patient_Off=[failed_patient_Off; initials{i}'];
%     end
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 2, 'WALK')
% end
% 

% for i=1:8
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 1, 'SPEAK')
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 2, 'SPEAK')
% end


% for i=1:8
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 1, 'WRITE')
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 2, 'WRITE')
% end

% for i=1:8
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 1, 'SGT')
%     close all
%     dbs_eeg_percept_prepare_spm12(initials{i}, 2, 'SGT')
% end


