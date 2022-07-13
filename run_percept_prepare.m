initials='LN_PR_D006';

rec_id=2;
sequence =  {'R', 'PMT', 'ACT', 'HPT', 'HPT', 'WRITE', 'WRITE', 'POUR', 'WALK'};
for i=1:size(sequence,2)
    dbs_eeg_percept_prepare_spm12(initials, rec_id, sequence{i});
end

rec_id=1;
sequence =  {'R', 'PMT', 'ACT', 'HPT', 'HPT', 'WRITE', 'POUR', 'WALK'};
for i=1:size(sequence,2)
    dbs_eeg_percept_prepare_spm12(initials, rec_id, sequence{i});
end
