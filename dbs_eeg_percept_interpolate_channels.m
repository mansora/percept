function D=dbs_eeg_percept_interpolate_channels(D, badchannels)

   


   chanlabels32= {'Fp1', 'Fz', 'F3','F7','FT9','FC5','FC1','C3','T7','TP9','CP5','CP1',...
            'Pz','P3','P7','O1','Oz','O2','P4','P8','TP10','CP6','CP2','Cz',...
            'C4','T8','FT10','FC6','FC2','F4','F8', 'Fp2'};

    

    chanlabels64= {'Fp1','Fz','F3','F7','FT9','FC5','FC1','C3','T7','TP9','CP5','CP1','Pz','P3','P7','O1',...
        'Oz','O2','P4','P8','TP10','CP6','CP2','Cz','C4','T8','FT10','FC6','FC2','F4','F8','Fp2','AF7','AF3',...
        'AFz','F1','F5','FT7','FC3','C1','C5','TP7','CP3','P1','P5','PO7','PO3','POz','PO4','PO8','P6','P2',...
        'CPz','CP4','TP8','C6','C2','FC4','FT8','F6','AF8','AF4','F2','Iz'};

    if nargin<2
        badchannel={'AF7','AF3',...
            'AFz','F1','F5','FT7','FC3','C1','C5','TP7','CP3','P1','P5','PO7','PO3','POz','PO4','PO8','P6','P2',...
            'CPz','CP4','TP8','C6','C2','FC4','FT8','F6','AF8','AF4','F2','Iz'};

        Dft=spm2fieldtrip(D);
        Dft.label= {Dft.label{1:32}, badchannel{:}, Dft.label{33:end}}';
        Dft.hdr.label=Dft.label;
        Dft.hdr.nChans=Dft.hdr.nChans+32;
        Dft.hdr.chanunit=[Dft.hdr.chanunit(1:32), repmat({'unkown'},1,32), Dft.hdr.chanunit(33:end)];
        missingchans=Dft.hdr.nChans-numel(Dft.hdr.chantype)-32;
        if missingchans>1
            Dft.hdr.chantype=[Dft.hdr.chantype(1:32), repmat({'eeg'},1,32), Dft.hdr.chantype(33:end-12), repmat({'unknown'},1,missingchans), Dft.hdr.chantype(end-11:end)];
        else
            Dft.hdr.chantype=[Dft.hdr.chantype(1:32), repmat({'eeg'},1,32), Dft.hdr.chantype(33:end)];
        end
        
        for i=1:numel(Dft.trial)
            Dft.trial{i}=[Dft.trial{i}(1:32,:); zeros(32,size(Dft.trial{1},2)); Dft.trial{i}(33:end,:)];
        end
    else
        badchannel=chanlabels64(badchannels);
        goodchannels=setdiff(1:64, badchannels);

        Dft=spm2fieldtrip(D);
        Dft.label= [chanlabels64'; D.chanlabels(setdiff(1:D.nchannels, D.indchantype('EEG')))'];
        Dft.hdr.label=Dft.label;
        Dft.hdr.nChans=Dft.hdr.nChans+numel(badchannel);
        n_noEEG=numel(setdiff(1:D.nchannels, D.indchantype('EEG')));
        n_EEG=numel(D.indchantype('EEG'));
        Dft.hdr.chanunit=[repmat({'uV'},1,64), repmat({'unknown'},1,n_noEEG)];
        Dft.hdr.chantype=[repmat({'eeg'},1,64), repmat({'unknown'},1,n_noEEG)];
        for i=1:numel(Dft.trial)
            temp=[zeros(64,size(Dft.trial{1},2)); Dft.trial{i}(n_EEG+1:end,:)];
            temp(goodchannels,:)=Dft.trial{i}(1:n_EEG,:);
            Dft.trial{i}=temp;
        end
    end


    

% To create layout from 64 channel file just do:
%     cfg=[];
%     layout=ft_prepare_layout(cfg,Dft);
    load('D:\home\layout_64channel.mat')
    D_temp=spm_eeg_load('D:\home\Data\DBS-MEG\LN_PR_D009\rec2\R\LN_PR_D009_rec_2_R_8');
     

    Dft_temp=spm2fieldtrip(D_temp);
   

    cfg_neighb.method    = 'distance';
    cfg_neighb.layout    = layout;
    cfg_neighb.neighbourdist    = 0.2;
    neighbours           = ft_prepare_neighbours(cfg_neighb, Dft);


    cfg = [];
    cfg.badchannel     = badchannel;
    cfg.senstype       = 'eeg';
    cfg.elec           = Dft_temp.elec;
    cfg.method         = 'weighted';
    cfg.neighbours     = neighbours;
    Dft = ft_channelrepair(cfg,Dft);


    D=spm_eeg_ft2spm(Dft, D.fname);








