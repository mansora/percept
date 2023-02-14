function dbs_percept_Coherence_topoplotAveraged(condition, Coh_state, freqband)
    
    close all
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};

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



    D_off_left=[];
    D_off_right=[];
    D_on_left=[];
    D_on_right=[];

    for sub_condition=1:numel(D.condlist)
        subcondition =D.condlist{sub_condition};% 'foot_L_up';

     for i=1:numel(initials)
        
        
       
        
    
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
        chanlabels= {'Fp1', 'Fz', 'F3','F7','FT9','FC5','FC1','C3','T7','TP9','CP5','CP1',...
            'Pz','P3','P7','O1','Oz','O2','P4','P8','TP10','CP6','CP2','Cz',...
            'C4','T8','FT10','FC6','FC2','F4','F8', 'Fp2'};


        EEGchannels=cellfun(@(s) find(strcmp(Dchan.chanlabels, s)), chanlabels);

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
                D_off_left(:,:,sub_condition,i)=(temp(EEGchannels, :));
               
                temp=squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_right(:,:,sub_condition,i)=(temp(EEGchannels, :));
               
            else
                temp = squeeze((Dc_off(start_ind:4:end,:,1,Coh_state_num)));
                D_off_right(:,:,sub_condition,i) = (temp(EEGchannels, :));
               
                temp = squeeze((Dc_off(start_ind+2:4:end,:,1,Coh_state_num)));
                D_off_left(:,:,sub_condition,i) = (temp(EEGchannels, :));
               
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp = squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_left(:,:,sub_condition,i)= (temp(EEGchannels, :));
               
            else
                temp= squeeze((Dc_off(start_ind:2:end,:,1,Coh_state_num)));
                D_off_right(:,:,sub_condition,i)=  (temp(EEGchannels, :));
               
            end

        end
        
        catch
            warning(['patient ', initials{i}, ' Off stim does not have', condition])
            D.condlist{sub_condition}

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
                D_on_left(:,:,sub_condition,i) = (temp(EEGchannels, :));
               
                temp= squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_right(:,:,sub_condition,i)= (temp(EEGchannels, :));
                
            else
                temp =squeeze((Dc_on(start_ind:4:end,:,1,Coh_state_num)));
                D_on_right(:,:,sub_condition,i) = (temp(EEGchannels, :));
               
                temp=squeeze((Dc_on(start_ind+2:4:end,:,1,Coh_state_num)));
                D_on_left(:,:,sub_condition,i)=(temp(EEGchannels, :));
                
            end

        else
            if strcmp(Dchan.chanlabels{lfpchan(1)}(end-3),'L')
                temp =squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_left(:,:,sub_condition,i)=(temp(EEGchannels, :));
               
            else
                temp=squeeze((Dc_on(start_ind:2:end,:,1,Coh_state_num)));
                D_on_right(:,:,sub_condition,i)=(temp(EEGchannels, :));
               
            end

        end

        catch
            warning(['patient ', initials{i}, ' On stim does not have', condition])
        end
     end
    end

 
    for kk=size(D_on_left,4):-1:1
        if numel(find(D_on_left(:,:,:,kk)==0))==numel(D_on_left(:,:,:,1)) || numel(find(D_off_left(:,:,:,kk)==0))==numel(D_off_left(:,:,:,1))
            D_on_left(:,:,:,kk)=[];
            D_off_left(:,:,:,kk)=[];
        end

        if numel(find(D_on_right(:,:,:,kk)==0))==numel(D_on_right(:,:,:,1)) || numel(find(D_off_right(:,:,:,kk)==0))==numel(D_off_right(:,:,:,1))
            D_on_right(:,:,:,kk)=[];
            D_off_right(:,:,:,kk)=[];
        end
    end
   

    D_on_left_temp=D_on_left;
    D_off_left_temp=D_off_left;
    D_on_right_temp=D_on_right;
    D_off_right_temp=D_off_right;

    limb_list={'hand', 'foot'};
    for limb=1:2

        D_on_left   =squeeze(mean(D_on_left_temp(:,:,1+4*(limb-1):4+4*(limb-1),:),3));
        D_off_left  =squeeze(mean(D_off_left_temp(:,:,1+4*(limb-1):4+4*(limb-1),:),3));
        D_on_right  =squeeze(mean(D_on_right_temp(:,:,1+4*(limb-1):4+4*(limb-1),:),3));
        D_off_right =squeeze(mean(D_off_right_temp(:,:,1+4*(limb-1):4+4*(limb-1),:),3));

        ind1 = find(min(abs(Dc_on.frequencies-freqband(1)))==abs(Dc_on.frequencies-freqband(1)));
        ind2 = find(min(abs(Dc_on.frequencies-freqband(2)))==abs(Dc_on.frequencies-freqband(2)));

        D_on_left   = squeeze(mean(D_on_left(:,ind1:ind2,:),2));
        D_off_left  = squeeze(mean(D_off_left(:,ind1:ind2,:),2));
        D_on_right  = squeeze(mean(D_on_right(:,ind1:ind2,:),2));
        D_off_right = squeeze(mean(D_off_right(:,ind1:ind2,:),2));
    

       
        spm_eeg_plotScalpData((squeeze(mean(D_on_left,2))-squeeze(mean(D_off_left,2))), D.coor2D(D.indchantype('EEG')), D.chanlabels(D.indchantype('EEG')));
%         title(['Coherence topoplot On-Off Left ' num2str(freqband)])
    
        spm_mkdir(['D:\home\results Percept Project\ForBRST']);
        saveas(gcf, ['D:\home\results Percept Project\ForBRST\Coherence topoplot On-Off Left Averaged', condition,...
           '_', limb_list{limb} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])
        

        
        spm_eeg_plotScalpData((squeeze(mean(D_on_right,2))-squeeze(mean(D_off_right,2))), D.coor2D(D.indchantype('EEG')), D.chanlabels(D.indchantype('EEG')));
%         title(['Coherence topoplot On-Off Right ' num2str(freqband)])
    
        spm_mkdir(['D:\home\results Percept Project\ForBRST']);
        saveas(gcf, ['D:\home\results Percept Project\ForBRST\Coherence topoplot On-Off Right Averaged', condition,...
           '_', limb_list{limb} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])


        chanlabelsflipped= {'Fp2', 'Fz', 'F4','F8','FT10','FC6','FC2','C4','T7','TP10','CP6','CP2',...
            'Pz','P4','P7','O2','Oz','O1','P3','P8','TP9','CP5','CP1','Cz',...
            'C3','T8','FT9','FC5','FC1','F3','F7', 'Fp1'};

        indices_flipped=cell2mat(arrayfun(@(s) find(strcmp(chanlabels, s)), chanlabelsflipped, 'UniformOutput', false));

        D_on_left_switched   = D_on_left(indices_flipped,:);
        D_off_left_switched  = D_off_left(indices_flipped,:);

        D_off = [D_on_left_switched,D_off_right];
        D_on  = [D_off_left_switched,D_on_right];

        spm_eeg_plotScalpData((squeeze(mean(D_on,2))-squeeze(mean(D_off,2))), D.coor2D(D.indchantype('EEG')), D.chanlabels(D.indchantype('EEG')));
%         title(['Coherence topoplot On-Off Right ' num2str(freqband)])
    
        spm_mkdir(['D:\home\results Percept Project\ForBRST']);
        saveas(gcf, ['D:\home\results Percept Project\ForBRST\Coherence topoplot On-Off BothSides Averaged', condition,...
           '_', limb_list{limb} ,'_freqband_',num2str(freqband(1)),'_',num2str(freqband(2)),'.png'])









    end






end
