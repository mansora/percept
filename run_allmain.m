initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005', 'LN_PR_D006','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
tasks={'R', 'ACT', 'PMT', 'SST', 'HPT', 'POUR', 'WALK', 'SPEAK', 'WRITE', 'SGT'};
failed_patient_prep={};
failed_patient_task={};
ind_patients = {};


% for t=1:numel(tasks)
%     failed_patient_Off={};
%     failed_patient_On={};
%     for i=1:numel(initials)
%         close all
%         try dbs_eeg_percept_prepare_spm12(initials{i}, 1, tasks{t})
%         catch failed_patient_Off=[failed_patient_Off; initials{i}];    
%         end
% 
%         close all
%         try dbs_eeg_percept_prepare_spm12(initials{i}, 2, tasks{t})
%         catch failed_patient_On=[failed_patient_On; initials{i}];
%         end
%     end
%     failed_patient_prep{t,1}=failed_patient_Off;
%     failed_patient_prep{t,2}=failed_patient_On;
% end


% for t=1:numel(tasks)
%     failed_patient={};
%     for i=1:numel(initials)
%         close all
%         try run_allplots(initials{i}, tasks{t},[])
%         catch failed_patient=[failed_patient; initials{i}];    
%         end    
%     end
%     failed_patient_task{t,1}=failed_patient;
%     
% end

% %% for summary results
% for t=1:numel(tasks)
%     plotLogSpectra_baselined(tasks{t})
%     barplot_different_freqbands(tasks{t})
%     barplot_different_freqbandsNoNormalization(tasks{t})
%     barplotCoherence_different_freqbands(tasks{t}, 'Coherence')
%     ind_patients{t} = plotConnectivityAverage(tasks{t}, 'Coherence')
%     barplotCoherence_different_freqbands(tasks{t}, 'ShuffledCoherence')
%     ind_patients{t} = plotConnectivityAverage(tasks{t}, 'ShuffledCoherence')
%     barplotCoherence_different_freqbands(tasks{t}, 'GrangerfromEEG')
%     ind_patients{t} = plotConnectivityAverage(tasks{t}, 'GrangerfromEEG')
%     barplotCoherence_different_freqbands(tasks{t}, 'GrangertoEEG')
%     ind_patients{t} = plotConnectivityAverage(tasks{t}, 'GrangertoEEG')
%     barplotCoherence_different_freqbands(tasks{t}, 'ReversedGrangerfromEEG')
%     ind_patients{t} = plotConnectivityAverage(tasks{t}, 'ReversedGrangerfromEEG')
%     barplotCoherence_different_freqbands(tasks{t}, 'ReversedGrangertoEEG')
%     ind_patients{t} = plotConnectivityAverage(tasks{t}, 'ReversedGrangertoEEG')
%      dbs_percept_EEG_Coherence_plot('ACT', 'Coherence',[13 30])
% end

%% for BRST results (only useful for ACT/PMT)
for t=2:3

   % Slide 1
   plotLogSpectra_baselinedAverage(tasks{t})

   dbs_eeg_evoked_tf_plotAverage(tasks{t})

   % Slide 2
%    dbs_percept_EEG_spectra_plotAverage(tasks{t}, [4 7])
%    dbs_percept_EEG_spectra_plotAverage(tasks{t}, [8 12])
%    dbs_percept_EEG_spectra_plotAverage(tasks{t}, [13 30])
%    dbs_percept_EEG_spectra_plotAverage(tasks{t}, [31 48])
%    dbs_percept_EEG_spectra_plotAverage(tasks{t}, [52 80])

     % Slide 3
     dbs_eeg_task_cohimages_plotAverage(tasks{t})
%    % Slide 4
%    dbs_percept_Coherence_topoplotAveraged(tasks{t}, 'Coherence', [4 7])
%    dbs_percept_Coherence_topoplotAveraged(tasks{t}, 'Coherence', [8 12])
%    dbs_percept_Coherence_topoplotAveraged(tasks{t}, 'Coherence', [13 30])
%    dbs_percept_Coherence_topoplotAveraged(tasks{t}, 'Coherence', [31 48])
%    dbs_percept_Coherence_topoplotAveraged(tasks{t}, 'Coherence', [52 80])
   plotConnectivityAverageCollapse(tasks{t}, 'Coherence')
   plotConnectivityAverageCollapse(tasks{t}, 'GrangerfromEEG')
   plotConnectivityAverageCollapse(tasks{t}, 'GrangertoEEG')
end

plotConnectivityAverageCollapse('R', 'Coherence')
plotConnectivityAverageCollapse('R', 'GrangerfromEEG')
plotConnectivityAverageCollapse('R', 'GrangertoEEG')
