function output=GetConnectivityData(condition, Coh_state) 

% close all
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005','LN_PR_D007','LN_PR_D008','LN_PR_D009'};

    kk=7;
    if strcmp(condition, 'SGT')
        kk=2;
    end
    
     [files_, seq, root, details] = dbs_subjects(initials{kk}, 1);
     cd(fullfile(root, condition));

     


%     try
%         files = spm_select('FPList','.', ['^' 'new_' '^.' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
%     catch
%         files = spm_select('FPList','.', ['^' 'new_' 'regexp_.*c|.*' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
%     end
%     
%     if isempty(files)
%         files = spm_select('FPList','.', ['^' 'new_' '.' initials{1} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
%     end

     try
        files = spm_select('FPList','.', ['^.' initials{kk} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    catch
        files = spm_select('FPList','.', ['regexp_.*c|.*' initials{kk} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    
    if isempty(files)
        files = spm_select('FPList','.', ['^' initials{kk} '_rec_' num2str(1) '_' condition '_[0-9]*.mat']);
    end
    
    D = spm_eeg_load(files);
   

    switch Coh_state
        case 'Coherence'
            Coh_state_num=1;
            start_ind=1;
        case 'ImagCoherence'
            Coh_state_num=2;
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



    D_off_left=[];
    D_off_right=[];
    D_on_left=[];
    D_on_right=[];

    for sub_condition=1:numel(D.condlist)
        subcondition =D.condlist{sub_condition};% 'foot_L_up';

     for i=1:numel(initials)
        
        
       
        
    
        [files_, seq, root, details] = dbs_subjects(initials{i}, 2);
        cd(fullfile(root, condition));


%         try
%             files = spm_select('FPList','.', ['^' 'new_' '^.' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
%         catch
%             files = spm_select('FPList','.', ['^' 'new_' 'regexp_.*c|.*' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
%         end
%         
%         if isempty(files)
%             files = spm_select('FPList','.', ['^' 'new_' '.' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
%         end


        try
            files = spm_select('FPList','.', ['^.' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        catch
            files = spm_select('FPList','.', ['regexp_.*c|.*' initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        end
        
        if isempty(files)
            files = spm_select('FPList','.', ['^'  initials{i} '_rec_' num2str(2) '_' condition '_[0-9]*.mat']);
        end
        
        try
        Dchan = spm_eeg_load(files);
        lfpchan=Dchan.indchantype('LFP');
        
        %EEGchannels=D_on_R.indchantype('EEG');
%         chanlabels= {'Fp1', 'Fz', 'F3','F7','FT9','FC5','FC1','C3','T7','TP9','CP5','CP1',...
%             'Pz','P3','P7','O1','Oz','O2','P4','P8','TP10','CP6','CP2','Cz',...
%             'C4','T8','FT10','FC6','FC2','F4','F8', 'Fp2'};

        chanlabels= {'Fp1','Fz','F3','F7','FT9','FC5','FC1','C3','T7','TP9','CP5','CP1','Pz','P3','P7','O1',...
            'Oz','O2','P4','P8','TP10','CP6','CP2','Cz','C4','T8','FT10','FC6','FC2','F4','F8','Fp2','AF7','AF3',...
            'AFz','F1','F5','FT7','FC3','C1','C5','TP7','CP3','P1','P5','PO7','PO3','POz','PO4','PO8','P6','P2',...
            'CPz','CP4','TP8','C6','C2','FC4','FT8','F6','AF8','AF4','F2','Iz'};





        EEGchannels=cellfun(@(s) find(strcmp(Dchan.chanlabels, s)), chanlabels);

        catch
         warning(['patient ', initials{i}, ' Off stim does not have', condition])   
        end

        [files_, seq, root, details] = dbs_subjects(initials{i}, 1);
        cd(fullfile(root, condition));
    
%         files = spm_select('FPList','.', ['C_', condition, '_', subcondition, 'new_','.', initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
%         if isempty(files)
%             files = spm_select('FPList','.', ['C_', condition, '_', subcondition, 'new_', initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
%         end

         files = spm_select('FPList','.', ['C_', condition, '_', subcondition, '.', initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
        if isempty(files)
            files = spm_select('FPList','.', ['C_', condition, '_', subcondition, initials{i} '_rec_' num2str(1) '_' condition '\w*.mat']);
        end
        
        try
        Dc_off=spm_eeg_load(files);

%         if i<4
%             disp('needs interpolation')
%         end
        

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

%         files = spm_select('FPList','.', ['C_', condition, '_', subcondition, 'new_','.', initials{i} '_rec_' num2str(2) '_' condition '\w*.mat']);
%         if isempty(files)
%             files = spm_select('FPList','.', ['C_', condition, '_', subcondition, 'new_',initials{i} '_rec_' num2str(2) '_' condition '\w*.mat']);
%         end
        
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



    output.D_on_left=D_on_left;
    output.D_off_left=D_off_left;
    output.D_on_right=D_on_right;
    output.D_off_right=D_off_right;


%     chanlabelsflipped= {'Fp2', 'Fz', 'F4','F8','FT10','FC6','FC2','C4','T8','TP10','CP6','CP2',...
%             'Pz','P4','P8','O2','Oz','O1','P3','P7','TP9','CP5','CP1','Cz',...
%             'C3','T7','FT9','FC5','FC1','F3','F7', 'Fp1'};

    chanlabelsflipped= {'Fp2','Fz','F4','F8','FT10','FC6','FC2','C4','T8','TP10','CP6','CP2','Pz','P4','P8','O2',...
            'Oz','O1','P3','P7','TP9','CP5','CP1','Cz','C3','T7','FT9','FC5','FC1','F3','F7','Fp1','AF8','AF4',...
            'AFz','F2','F6','FT8','FC4','C2','C6','TP8','CP4','P2','P6','PO8','PO4','POz','PO3','PO7','P7','P1',...
            'CPz','CP3','TP7','C5','C1','FC3','FT7','F5','AF7','AF3','F1','Iz'};



    indices_flipped=cell2mat(arrayfun(@(s) find(strcmp(chanlabels, s)), chanlabelsflipped, 'UniformOutput', false));

    D_on_left_switched   = D_on_left(indices_flipped,:,:,:);
    D_off_left_switched  = D_off_left(indices_flipped,:,:,:);

%     if find(strcmp({'ACT','PMT'}, condition))
%         D_on_left_switched=D_on_left_switched(:,:,[2,3,1,2,7,8,5,6],:);
%         D_off_left_switched=D_off_left_switched(:,:,[2,3,1,2,7,8,5,6],:);
% 
% %         D_on_left_switched=D_on_left_switched(:,:,[1,3,4,2,3,8,9,6,7],:);
% %         D_off_left_switched=D_off_left_switched(:,:,[1,3,4,2,3,8,9,6,7],:);
%     end

    D_off = cat(4, D_off_left_switched,D_off_right);
    D_on  = cat(4, D_on_left_switched,D_on_right);

  

    output.off=D_off;
    output.on=D_on;



end
   