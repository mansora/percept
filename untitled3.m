% figure,plot(n1(offset_stamp_start:end))
% hold on, plot(n2*0.1)
% 
% 
% figure, plot(n1(size_window_end(1)+temp_TF:size_window_end(2)+temp_TF-1))
% figure, plot(n2(size_window_end(1)+temp_TF:size_window_end(2)+temp_TF-1))
% 
% figure, plot(n2)
% 
% 
% 


for npatient=setdiff(1:9,2)
    dbs_eeg_percept_prepare_spm12(['LN_PR_D00', num2str(npatient)],1,'R')
    dbs_eeg_percept_prepare_spm12(['LN_PR_D00', num2str(npatient)],2,'R')
end


close all
for npatient=setdiff(1:9,2)
dbs_percept_lfp_spectra(['LN_PR_D00', num2str(npatient)],1,'R')
dbs_percept_lfp_spectra(['LN_PR_D00', num2str(npatient)],2,'R')
dbs_percept_lfp_spectra_plot(['LN_PR_D00', num2str(npatient)],'R')
end


               