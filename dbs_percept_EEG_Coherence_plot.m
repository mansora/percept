function dbs_percept_EEG_Coherence_plot(condition, Coh_state, freqband)
   
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
    ind_patient={};

     [files_, seq, root, details] = dbs_subjects(initials{1}, 1);
     cd(fullfile(root, condition));

    try
        files = spm_select('FPList','.', ['^.' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    
    D = spm_eeg_load(files);
   

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
    end



    for sub_condition=1:numel(D.condlist)
        subcondition =D.condlist{sub_condition};% 'foot_L_up';

     for i=1:numel(initials)
        
        z=1;
        D_off_left=[];
        D_off_right=[];
        D_on_left=[];
        D_on_right=[];
       
        
    
        [files_, seq, root, details] = dbs_subjects(initials{i}, 2);
        cd(fullfile(root, condition));


         try
            files = spm_select('FPList','.', ['^.' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        catch
            files = spm_select('FPList','.', ['regexp_.*c|.*' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        end
        
        if isempty(files)
            files = spm_select('FPList','.', ['^' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        end
        
        Dchan = spm_eeg_load(files);
        lfpchan=Dchan.indchantype('LFP');
        %EEGchannels=D_on_R.indchantype('EEG');
        EEGchannels=[Dchan.indchantype('EEG')];

        [files_, seq, root, details] = dbs_subjects(initials{i}, 1);
        cd(fullfile(root, condition));
    
        files = spm_select('FPList','.', ['C_', condition, '_', subcondition, '.', initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', condition, '_', subcondition, initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
        end
        try
        Dc_off=spm_eeg_load(files);
        

        if numel(lfpchan)>1
            if strcmp(Dchan.chanlabels{lfpchan(2)}(end-3),'L')
                temp=squeeze((Dc_off(start_ind:4:end,:,1,Coh_state_num)));
                D_off_left(:,:)=(temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp=squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_right(:,:)=(temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp = squeeze((Dc_off(start_ind:4:end,:,1,Coh_state_num)));
                D_off_right(:,:) = (temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp = squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_left(:,:) = (temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp = squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_left(:,:)= (temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp= squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_right(:,:)=  (temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        end
        
        plottOff=1;
        catch
            warning(['patient ', initials{i}, ' Off stim does not have', condition])
            plottOff=0;
        end
    
        [files_, seq, root, details] = dbs_subjects(initials{i}, 2);
        cd(fullfile(root, condition));

        files = spm_select('FPList','.', ['C_', condition, '_', subcondition, '.', initials{i} '_rec_' num2str(2) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', condition, '_', subcondition, initials{i} '_rec_' num2str(2) '_' condition '\w*.mat']);
        end
        try
        Dc_on=spm_eeg_load(files);
       

        if numel(lfpchan)>1
            if strcmp(Dchan.chanlabels{lfpchan(2)}(end-3),'L')
                temp=squeeze((Dc_on(start_ind:4:end,:,1,Coh_state_num)));
                D_on_left(:,:) = (temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp= squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_right(:,:)= (temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp =squeeze((Dc_on(start_ind:4:end,:,1,Coh_state_num)));
                D_on_right(:,:) = (temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
                temp=squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_left(:,:)=(temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp =squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_left(:,:)=(temp(EEGchannels, :));
                [~, ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            else
                temp=squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_right(:,:)=(temp(EEGchannels, :));
                [~,ind(z)]= max(mean(temp(EEGchannels, :),2));
                z=z+1;
            end

        end

        plottOn=1;
        catch
            warning(['patient ', initials{i}, ' On stim does not have', condition])
            plottOn=0;
        end

       ind_patient{i}=ind;
      both=[];
 
   





    if plottOn==1 && plottOff==1

        ind1 = find(min(abs(Dc_on.frequencies-freqband(1)))==abs(Dc_on.frequencies-freqband(1)));
        ind2 = find(min(abs(Dc_on.frequencies-freqband(2)))==abs(Dc_on.frequencies-freqband(2)));
    

        try
        spm_eeg_plotScalpData(squeeze(mean(D_on_left(:,ind1:ind2),2))-squeeze(mean(D_off_left(:,ind1:ind2),2)), Dchan.coor2D(Dchan.indchantype('EEG')), Dchan.chanlabels(Dchan.indchantype('EEG')));
        title(['Coherence topoplot On-Off Left ' num2str(freqband)])
    
        spm_mkdir(['D:\home\results Percept Project\Summary']);
        saveas(gcf, ['D:\home\results Percept Project\Summary\',initials{i},' Coherence topoplot On-Off Left', condition,...
           '_', D.condlist{sub_condition} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])
        catch
        end

        try
        spm_eeg_plotScalpData(squeeze(mean(D_on_right(:,ind1:ind2),2))-squeeze(mean(D_off_right(:,ind1:ind2),2)), Dchan.coor2D(Dchan.indchantype('EEG')), Dchan.chanlabels(Dchan.indchantype('EEG')));
        title(['Coherence topoplot On-Off Right ' num2str(freqband)])
    
        spm_mkdir(['D:\home\results Percept Project\Summary']);
        saveas(gcf, ['D:\home\results Percept Project\Summary\',initials{i},' Coherence topoplot On-Off Right', condition,...
           '_', D.condlist{sub_condition} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])
        catch
        end

    end

    end




end
