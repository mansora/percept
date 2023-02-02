initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005', 'LN_PR_D006','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
tasks={'R', 'ACT', 'PMT', 'SST', 'HPT', 'POUR', 'WALK', 'SPEAK', 'WRITE', 'SGT'};
failed_patient_prep={};


for t=1:numel(tasks)
    failed_patient_={};
    for i=1:numel(initials)
        close all
        try [diff_off(i,t), diff_on(i,t)]=dbs_percept_ofset_analysis(initials{i}, tasks{t});
        catch failed_patient_=[failed_patient_; initials{i}];    
        end
    end
    failed_patient_prep{t,1}=failed_patient_;
end