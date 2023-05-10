function [diff_coherence, channs, freq_range_output]=ClusterbasedPermutationtest(data1_temp, data2_temp, title_, task, freq_range, which_range)
% clear
close all

side='right';

% % for 32 channels
% chanlabels32= {'Fp1', 'Fz', 'F3','F7','FT9','FC5','FC1','C3','T7','TP9','CP5','CP1',...
%             'Pz','P3','P7','O1','Oz','O2','P4','P8','TP10','CP6','CP2','Cz',...
%             'C4','T8','FT10','FC6','FC2','F4','F8', 'Fp2'};
% 
% 
% 
% D=spm_eeg_load('D:\home\Data\DBS-MEG\LN_PR_D001\rec1\R\LN_PR_D001_rec_1_R_1');
% Dft=spm2fieldtrip(D);
% cfg=[];
% cfg.channel=chanlabels;
% Dft=ft_preprocessing(cfg,Dft);


chanlabels64= {'Fp1','Fz','F3','F7','FT9','FC5','FC1','C3','T7','TP9','CP5','CP1','Pz','P3','P7','O1',...
'Oz','O2','P4','P8','TP10','CP6','CP2','Cz','C4','T8','FT10','FC6','FC2','F4','F8','Fp2','AF7','AF3',...
'AFz','F1','F5','FT7','FC3','C1','C5','TP7','CP3','P1','P5','PO7','PO3','POz','PO4','PO8','P6','P2',...
'CPz','CP4','TP8','C6','C2','FC4','FT8','F6','AF8','AF4','F2','Iz'};



D=spm_eeg_load('D:\home\Data\DBS-MEG\LN_PR_D009\rec1\R\LN_PR_D009_rec_1_R_1');
Dft=spm2fieldtrip(D);
cfg=[];
cfg.channel=chanlabels64;
Dft=ft_preprocessing(cfg,Dft);


% outputR=GetConnectivityData('R', 'Coherence');
% outputR_shifted=GetConnectivityData('R', 'ShuffledCoherence');
% outputACT=GetConnectivityData('ACT', 'Coherence');
% outputACT_shifted=GetConnectivityData('ACT', 'ShuffledCoherence');
% outputPMT=GetConnectivityData('PMT', 'Coherence');

% load('D:\home\dummyCoherencedataset.mat')
load('D:\home\dummyCoherencedataset64.mat')
% load('D:\home\layout_32channel.mat')
load('D:\home\layout_64channel.mat')
dummyCoherence.label=chanlabels64';

% data1_temp=outputWALK.off;
% data2_temp=outputWALK.on;








% title_={'left hand', 'right hand', 'left foot', 'right foot'};
 clear data1 data2
for subcond=1:size(data1_temp,3) %%:4
    
%     data1(:,:,limb,:)=cat(4, data1_temp(:,:,2*(limb-1)+1,:), data1_temp(:,:,2*limb,:));
%     data2(:,:,limb,:)=cat(4, data2_temp(:,:,2*(limb-1)+1,:), data2_temp(:,:,2*limb,:));

    data1(:,:,subcond,:)=squeeze(mean(data1_temp(:,:,subcond,:),3));;
    data2(:,:,subcond,:)=squeeze(mean(data2_temp(:,:,subcond,:),3));;

    avg_data=squeeze(mean(data1(:,:,subcond,:),4))-squeeze(mean(data2(:,:,subcond,:),4));


    clear data_pop1 data_pop2
    n_pop1=size(data1,4);
    for sub=1:n_pop1
        data_pop1{sub}= dummyCoherence;
        data_pop1{sub}.cohspctrm=squeeze(data1(:,:,subcond,sub));
    end
    
    n_pop2=size(data2,4);
    for sub=1:n_pop2
        data_pop2{sub}= dummyCoherence;
        data_pop2{sub}.cohspctrm=squeeze(data2(:,:,subcond,sub));
    end


    
    
    
    %% define neighbours
    cfg_neighb.method    = 'distance';
    cfg_neighb.layout    = layout;
    cfg_neighb.neighbourdist    = 0.3;
    neighbours           = ft_prepare_neighbours(cfg_neighb, Dft);


%     cfg = [];
%     cfg.badchannel     = artif.badchannel;
%     cfg.method         = 'weighted';
%     cfg.neighbours     = neighbours;
%     data_pop1 = ft_channelrepair(cfg,data_pop1);
%     data_pop2 = ft_channelrepair(cfg,data_pop2);
    
    %% cluster-based permutation test
    cfg = [];
    cfg.layout = layout;
    cfg.neighbours = neighbours;
    cfg.channel = chanlabels64';
    cfg.connectivity=channelconnectivity(cfg);
    cfg.channelcmb = dummyCoherence.labelcmb;
    cfg.latency          = 'all';
    cfg.avgovertime = 'no';
    cfg.avgoverchan = 'no';
    cfg.frequency = freq_range;
    cfg.parameter = 'cohspctrm';
    cfg.method = 'montecarlo';
    cfg.statistic = 'ft_statfun_depsamplesT';
    % cfg.statistic        = 'ft_statfun_indepsamplesT';
    cfg.correctm = 'cluster';
    cfg.clusteralpha     = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.minnbchan        = 2;  
    cfg.tail = 0;
    cfg.clustertail = 0;
    cfg.alpha = 0.05; 
    cfg.numrandomization = 1000;
    
    
    
    %% design matrices
    % cfg.design           = [ones(1,n_pop1), ones(1,n_pop2)*2];
    clear design
    design(1,:) = [1:n_pop1, 1:n_pop2];
    design(2,:) = [ones(1,n_pop1), ones(1,n_pop2)*2];
    cfg.design = design;
    
    cfg.ivar = 2;
    cfg.uvar = 1;
    
    [diff_coherence{subcond}] = ft_freqstatistics(cfg, data_pop1{:}, data_pop2{:});
    
%     %% plot results
%     cfg = [];
%     cfg.channel = 'all';
%     cfg.layout = layout;
%     cfg.zlim = [-1 1];
%     cfg.alpha = 0.01;
%     cfg.refchannel = 'all';
%     cfg.highlightsizeseries     = [20 0 0 0 0];
%     cfg.highlightcolorpos       = [0 0 0];
%     cfg.highlightcolorneg       = [1 0 0];
%     cfg.subplotsize             = [4 5];
%     cfg.position                = get(0,'screensize');
%     cfg.saveaspng = ['D:\dystonia project\IamBrain\permutationstats\' task, num2str(freq_range), title_{subcond}];
% %     figure,
% %     title(title_{subcond})
%     try
%         ft_clusterplot(cfg, diff_coherence{subcond});
%     catch
%         warning([title_{subcond}, ' has no clusters present, nothing to plot'])
%     end



if strcmp(which_range, 'low')
    for num_cluster=1:size(diff_coherence{subcond}.negclusters,2)
    if diff_coherence{subcond}.negclusters(num_cluster).prob<0.05
%         disp(diff_coherence{subcond}.negclusters(num_cluster).prob)
        channstemp=diff_coherence{subcond}.negclusterslabelmat==num_cluster;
        range= find(mean(channstemp,1));
        channs{subcond,num_cluster}=find(mean(channstemp,2));
%         channs_sig=chanlabels64(channs);
    
        
    
   
    temp=diff_coherence{subcond};
    [~, indmin]=min(abs(dummyCoherence.freq-temp.freq(min(range))));
    [~, indmax]=min(abs(dummyCoherence.freq-temp.freq(max(range))));
    disp(temp.freq(min(range)))
    disp(temp.freq(max(range)))
    freq_range_output{subcond,num_cluster}=[temp.freq(min(range))  temp.freq(max(range))];
    temp.stat= repmat(mean(avg_data(:,indmin:indmax),2),1,size(temp.stat,2));
    cfgtopo=[];
    cfgtopo.parameter    = 'stat';
    cfgtopo.colorbar     = 'yes';
    cfgtopo.zlim         = [-0.03 0.03];
    cfgtopo.marker       = 'on';
    cfgtopo.style        = 'straight';
    cfgtopo.markersize   = 5;
    cfgtopo.highlight    = 'on';
    cfgtopo.highlightchannel =channs{subcond};
    cfgtopo.layout       = layout;
    cfgtopo.highlightcolor   = [1 0 0];
    cfgtopo.highlightsize    =  20;
    cfgtopo.highlightsymbol  = 'o';
    cfgtopo.highlightfontsize = 20;
    
 
    ft_topoplotTFR(cfgtopo, temp);
    hold on, text(-0.5, -0.5 , num2str([temp.freq(min(range))  temp.freq(max(range))]))
    text(-0.5, -0.4 , ['p value ' num2str(diff_coherence{subcond}.negclusters(num_cluster).prob)])
    
    set(gcf,'Position',get(0,'screensize'))
   
    hline = findobj(gcf, 'type', 'line');
    set(hline,'LineWidth',10)
    
    colormap('jet');
    c = colorbar;
    c.LineWidth = 5;
    c.FontSize=40;
    c.FontWeight='bold';

    try
    saveas(gcf, ['D:\dystonia project\IamBrain\permutationstats\negclusters' task, '_freqrange_', num2str(freq_range(1)), '_', num2str(freq_range(2)),'_', title_{subcond}, '_clusternum_', num2str(num_cluster), '.png'])
    catch
        disp(task)
    end
    

    end
    
    
    end




else

    for num_cluster=1:size(diff_coherence{subcond}.posclusters,2)
    if diff_coherence{subcond}.posclusters(num_cluster).prob<0.05
%         disp(diff_coherence{subcond}.negclusters(num_cluster).prob)
        channstemp=diff_coherence{subcond}.posclusterslabelmat==num_cluster;
        range= find(mean(channstemp,1));
        channs{subcond, num_cluster}=find(mean(channstemp,2));
%         channs_sig=chanlabels64(channs);
    
        
    
   
    temp=diff_coherence{subcond};
    [~, indmin]=min(abs(dummyCoherence.freq-temp.freq(min(range))));
    [~, indmax]=min(abs(dummyCoherence.freq-temp.freq(max(range))));
    disp(temp.freq(min(range)))
    disp(temp.freq(max(range)))
    freq_range_output{subcond, num_cluster}=[temp.freq(min(range))  temp.freq(max(range))];
    temp.stat= repmat(mean(avg_data(:,indmin:indmax),2),1,size(temp.stat,2));
    cfgtopo=[];
    cfgtopo.parameter    = 'stat';
    cfgtopo.colorbar     = 'yes';
    cfgtopo.zlim         = [-0.03 0.03];
    cfgtopo.marker       = 'on';
    cfgtopo.style        = 'straight';
    cfgtopo.markersize   = 5;
    cfgtopo.highlight    = 'on';
    cfgtopo.highlightchannel =channs{subcond};
    cfgtopo.layout       = layout;
    cfgtopo.highlightcolor   = [0 0 0];
    cfgtopo.highlightsize    =  20;
    cfgtopo.highlightsymbol  = 'o';
    cfgtopo.highlightfontsize = 20;
    
 
    ft_topoplotTFR(cfgtopo, temp);
    hold on, text(-0.5, -0.5 , num2str([temp.freq(min(range))  temp.freq(max(range))]))
    text(-0.5, -0.4 , ['p value ' num2str(diff_coherence{subcond}.posclusters(num_cluster).prob)])
    
    set(gcf,'Position',get(0,'screensize'))
   
    hline = findobj(gcf, 'type', 'line');
    set(hline,'LineWidth',10)
    
    colormap('jet');
    c = colorbar;
    c.LineWidth = 5;
    c.FontSize=40;
    c.FontWeight='bold';

    saveas(gcf, ['D:\dystonia project\IamBrain\permutationstats\posclusters' task, '_freqrange_', num2str(freq_range(1)), '_', num2str(freq_range(2)),'_', title_{subcond}, '_clusternum_', num2str(num_cluster), '.png'])
    
    

    end

    end
end


end

end
    
    

