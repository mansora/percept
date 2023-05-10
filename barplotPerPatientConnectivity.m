function barplotPerPatientConnectivity(freq_range, Coh_state)
close all
initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
figure('units','normalized','outerposition',[0 0 1 1]),
ind_=1;
tasks={'R', 'ACT', 'PMT', 'SST', 'HPT', 'POUR', 'WALK', 'SPEAK', 'WRITE', 'SGT'};

subcondition={{'R'},...
    {'hand_L_up','hand_L_down','hand_R_up','hand_R_down','foot_L_up','foot_L_down','foot_R_up','foot_R_down'},...
    {'hand_L_up','hand_L_down','hand_R_up','hand_R_down','foot_L_up','foot_L_down','foot_R_up','foot_R_down'},...
    {'SST_right','rest_right','SST_left','rest_left'},...
    {'hold_right','rest'},...
    {'pour','rest'},...
    {'walk','stand'},...
    {'speak','rest'},...
    {'write','rest'},...
    {'gest','rest'},...
    };


D=spm_eeg_load('D:\home\Data\DBS-MEG\LN_PR_D001\rec2\R\C_R_RLN_PR_D001_rec_2_R_1.mat');

indmin = find(min(abs(D.frequencies-freq_range(1)))==abs(D.frequencies-freq_range(1)));
indmax = find(min(abs(D.frequencies-freq_range(2)))==abs(D.frequencies-freq_range(2)));

switch Coh_state
        case 'Coherence'
            Coh_state_num=1;
            start_ind=1;
        case 'ShuffledCoherence'
            Coh_state_num=11;
            start_ind=1;
        case 'GrangerfromEEG'
            Coh_state_num=4;
            start_ind=1;
        case 'GrangertoEEG'
            Coh_state_num=4;
            start_ind=2;
        case 'ReversedGrangerfromEEG'
            Coh_state_num=9;
            start_ind=1;
        case 'ReversedGrangertoEEG'
            Coh_state_num=9;
            start_ind=2;
        case 'ShuffledGrangerfromEEG'
            Coh_state_num=14;
            start_ind=1;
         case 'ShuffledGrangertoEEG'
            Coh_state_num=14;
            start_ind=2;
end


for sub=1:7


tasks_all_off={};
tasks_all_on={};
ind_=1;

clear D1_LFP_all D2_LFP_all
for t=1:numel(tasks)

    clear D_off_right D_on_right
    clear D_off_left D_off_left
    for sub_condition=1:size(subcondition{t},2)
        

        
        
       
        
    
        [files_, seq, root, details] = dbs_subjects(initials{sub}, 1);
        cd(fullfile(root, tasks{t}));



        try
            files = spm_select('FPList','.', ['^.' initials{sub} '_rec_' num2str(1) '_' tasks{t} '_[0-9]*.mat']);
        catch
            files = spm_select('FPList','.', ['regexp_.*c|.*' initials{sub} '_rec_' num2str(1) '_' tasks{t} '_[0-9]*.mat']);
        end
        
        if isempty(files)
            files = spm_select('FPList','.', ['^'  initials{sub} '_rec_' num2str(1) '_' tasks{t} '_[0-9]*.mat']);
        end
        
        try

        Dchan = spm_eeg_load(files);
        lfpchan=Dchan.indchantype('LFP');
        
       
        chanlabels= {'Fp1','Fz','F3','F7','FT9','FC5','FC1','C3','T7','TP9','CP5','CP1','Pz','P3','P7','O1',...
            'Oz','O2','P4','P8','TP10','CP6','CP2','Cz','C4','T8','FT10','FC6','FC2','F4','F8','Fp2','AF7','AF3',...
            'AFz','F1','F5','FT7','FC3','C1','C5','TP7','CP3','P1','P5','PO7','PO3','POz','PO4','PO8','P6','P2',...
            'CPz','CP4','TP8','C6','C2','FC4','FT8','F6','AF8','AF4','F2','Iz'};





        EEGchannels=cellfun(@(s) find(strcmp(Dchan.chanlabels, s)), chanlabels);

        

        [files_, seq, root, details] = dbs_subjects(initials{sub}, 1);
        cd(fullfile(root, tasks{t}));
    


         files = spm_select('FPList','.', ['C_', tasks{t}, '_', subcondition{t}{sub_condition}, '.', initials{sub} '_rec_' num2str(1) '_' tasks{t} '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', tasks{t}, '_', subcondition{t}{sub_condition}, initials{sub} '_rec_' num2str(1) '_' tasks{t} '\w*.mat']);
        end
        
        try
        Dc_off=spm_eeg_load(files);


        

        if numel(lfpchan)>1
            if strcmp(Dchan.chanlabels{lfpchan(2)}(end-3),'L')
                temp=squeeze((Dc_off(start_ind:4:end,:,1,Coh_state_num)));
                D_off_left(:,:,sub_condition)=(temp(EEGchannels, :));
               
                temp=squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_right(:,:,sub_condition)=(temp(EEGchannels, :));
               
            else
                temp = squeeze((Dc_off(start_ind:4:end,:,1,Coh_state_num)));
                D_off_right(:,:,sub_condition) = (temp(EEGchannels, :));
               
                temp = squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_left(:,:,sub_condition) = (temp(EEGchannels, :));
               
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp = squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_left(:,:,sub_condition)= (temp(EEGchannels, :));
               
            else
                temp= squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_right(:,:,sub_condition)=  (temp(EEGchannels, :));
               
            end

        end
        
        catch
            warning(['patient ', initials{sub}, ' Off stim does not have', tasks{t}])
            D.condlist{sub_condition}

        end
    
        [files_, seq, root, details] = dbs_subjects(initials{sub}, 2);
        cd(fullfile(root, tasks{t}));


        
        files = spm_select('FPList','.', ['C_', tasks{t}, '_', subcondition{t}{sub_condition}, '.', initials{sub} '_rec_' num2str(2) '_' tasks{t} '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', tasks{t}, '_', subcondition{t}{sub_condition}, initials{sub} '_rec_' num2str(2) '_' tasks{t} '\w*.mat']);
        end
        try
        Dc_on=spm_eeg_load(files);
       

        if numel(lfpchan)>1
            if strcmp(Dchan.chanlabels{lfpchan(2)}(end-3),'L')
                temp=squeeze((Dc_on(start_ind:4:end,:,1,Coh_state_num)));
                D_on_left(:,:,sub_condition) = (temp(EEGchannels, :));
               
                temp= squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_right(:,:,sub_condition)= (temp(EEGchannels, :));
                
            else
                temp =squeeze((Dc_on(start_ind:4:end,:,1,Coh_state_num)));
                D_on_right(:,:,sub_condition) = (temp(EEGchannels, :));
               
                temp=squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_left(:,:,sub_condition)=(temp(EEGchannels, :));
                
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp =squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_left(:,:,sub_condition)=(temp(EEGchannels, :));
               
            else
                temp=squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_right(:,:,sub_condition)=(temp(EEGchannels, :));
               
            end

        end

        catch
            warning(['patient ', initials{sub}, ' On stim does not have', tasks{t}])
        end


        

        tasks_all_on{ind_}=tasks{t};
            
            t_count=1;
    catch

         warning(['patient ', initials{sub}, ' Off stim does not have', tasks{t}]) 
        t_count=0;
        end
    end

    if t_count==1
    if sub<3
    switch t
                
        case {2 , 3}
            D2_LFP_all(1,:,:,ind_)=mean(D_on_right,3);
            D1_LFP_all(1,:,:,ind_)=mean(D_off_right,3);
        case 4 
            D2_LFP_all(1,:,:,ind_)=mean(D_on_right(:,:,[1,4]),3);
            D1_LFP_all(1,:,:,ind_)=mean(D_off_right(:,:,[1,4]),3);
        case {1, 5 , 6 , 7 , 8 , 9 , 10}
            D2_LFP_all(1,:,:,ind_)=D_on_right(:,:,1);
            D1_LFP_all(1,:,:,ind_)=D_off_right(:,:,1);
    end
    else
        switch t
            case {2 , 3}
                D2_LFP_all(1,:,:,ind_)=squeeze(mean(D_on_left,3)); 
                D2_LFP_all(2,:,:,ind_)=squeeze(mean(D_on_right,3));
                D1_LFP_all(1,:,:,ind_)=squeeze(mean(D_off_left,3)); 
                D1_LFP_all(2,:,:,ind_)=squeeze(mean(D_off_right,3));
            case 4 
                D2_LFP_all(1,:,:,ind_)=squeeze(mean(D_on_left(:,:,[1,4]),3));
                D2_LFP_all(2,:,:,ind_)=squeeze(mean(D_on_right(:,:,[1,4]),3));
                D1_LFP_all(1,:,:,ind_)=squeeze(mean(D_off_left(:,:,[1,4]),3));
                D1_LFP_all(2,:,:,ind_)=squeeze(mean(D_off_right(:,:,[1,4]),3));
            case {1, 5 , 6 , 7 , 8 , 9 , 10}
                D2_LFP_all(1,:,:,ind_)=squeeze(D_on_left(:,:,1));
                D2_LFP_all(2,:,:,ind_)=squeeze(D_on_right(:,:,1));
                D1_LFP_all(1,:,:,ind_)=squeeze(D_off_left(:,:,1));
                D1_LFP_all(2,:,:,ind_)=squeeze(D_off_right(:,:,1));
        end


    end
    ind_=ind_+1;
    end



end


    


    








 
    
    

    D_diff=squeeze(mean(D2_LFP_all(:,:,indmin:indmax,:),3))./squeeze(mean(D1_LFP_all(:,:,indmin:indmax,:),3));
    if sub>2
        D_diff=squeeze(mean(D_diff,2));
    else
        D_diff=mean(D_diff,1);
    end
     % average over all channels, need to fix and pick a subset of channels of interest
    subplot(2,4,sub)
    boxchart(D_diff', 'LineWidth', 5)
%     ylim([-0.5 5])
%     bh=boxplot(D_diff')
%     set(bh,'LineWidth', 5);
    
    if sub==1
        ylabel([Coh_state ' On/Off ', num2str(freq_range(1)), '-',num2str(freq_range(2)), 'Hz '], 'FontSize', 30, 'FontWeight','bold')
    end

    

    xlabel(initials{sub}(7:10), 'FontSize', 30, 'FontWeight','bold')
    
    a = get(gca,'XTickLabel');  
    set(gca,'linewidth',5)
    set(gca,'XTickLabel',a,'fontsize',20,'FontWeight','bold')     
    
    if size(D2_LFP_all,1)==1
%         legend({'right'})
        xticklabels({'right'})
        hold on, plot(1, D_diff', 'o', 'MarkerSize', 10, 'LineWidth', 5,'HandleVisibility','off')
        text(ones(ceil(size(D_diff,2)/2),1)+0.3,D_diff(1:2:end), tasks_all_on(1:2:end), 'FontWeight', 'bold', 'FontSize', 10)
        text(ones(floor(size(D_diff,2)/2),1)+0.6,D_diff(2:2:end), tasks_all_on(2:2:end), 'FontWeight', 'bold', 'FontSize', 10)

    else
%         legend({'left', 'right'})
        xticklabels({'left', 'right'})
        hold on, plot(1, D_diff(1,:)', 'o', 'MarkerSize', 10, 'LineWidth', 5,'HandleVisibility','off')
        text(ones(ceil(size(D_diff,2)/2),1)-0.5,D_diff(1,1:2:end), tasks_all_on(1:2:end), 'FontWeight', 'bold', 'FontSize', 10)
        text(ones(floor(size(D_diff,2)/2),1)-0.9,D_diff(1,2:2:end), tasks_all_on(2:2:end), 'FontWeight', 'bold', 'FontSize', 10)

        hold on, plot(2, D_diff(2,:)', 'o', 'MarkerSize', 10, 'LineWidth', 5,'HandleVisibility','off')
        text(2*ones(ceil(size(D_diff,2)/2),1)+0.3,D_diff(2,1:2:end), tasks_all_on(1:2:end), 'FontWeight', 'bold', 'FontSize', 10)
        text(2*ones(floor(size(D_diff,2)/2),1)+0.6,D_diff(2,2:2:end), tasks_all_on(2:2:end), 'FontWeight', 'bold', 'FontSize', 10)
    end



    spm_mkdir(['D:\dystonia project\IamBrain\permutationstats']);
    saveas(gcf, ['D:\dystonia project\IamBrain\permutationstats\',  'barplotPersubjectConnectivity','_', Coh_state, 'On-Off ', num2str(freq_range(1)), '-',num2str(freq_range(2)), 'Hz ', '.png'])
    
end

end


