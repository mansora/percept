function CountMissingPackagesPercept(initials)
    
    LFProot=['Z:\', initials, '\raw_LFP\'];
    jsonfiles=dir([LFProot, '*.json']);

    js = jsondecode(fileread(fullfile(jsonfiles.folder, jsonfiles.name)));

%     datafields = sort({'EventSummary','BrainSenseLfp','BrainSenseTimeDomain','LfpMontageTimeDomain','IndefiniteStreaming','BrainSenseSurvey'});
    datafields = sort({'BrainSenseTimeDomain','IndefiniteStreaming'});

    data = js.(datafields{1});
%     tmp =  {data(:).GlobalSequences};
%     for c = 1:length(tmp)
%         GlobalSequences(c,:) = str2double(tmp{c});
%     end


    FirstPacketDateTime = strrep(strrep({data(:).FirstPacketDateTime},'T',' '),'Z','');
    runs = unique(FirstPacketDateTime);
    
    Pass = {data(:).Pass};
    tmp =  {data(:).GlobalSequences};
    for c = 1:length(tmp)
        GlobalSequences{c,:} = str2num(tmp{c});
    end
    tmp =  {data(:).GlobalPacketSizes};
    for c = 1:length(tmp)
        GlobalPacketSizes{c,:} = str2num(tmp{c});
    end
    
    fsample = data.SampleRateInHz;
    gain=[data(:).Gain]';
    [tmp1,tmp2] = strtok(strrep({data(:).Channel}','_AND',''),'_');
    ch1 = strrep(strrep(strrep(strrep(tmp1,'ZERO','0'),'ONE','1'),'TWO','2'),'THREE','3');
    
    [tmp1,tmp2] = strtok(tmp2,'_');
    ch2 = strrep(strrep(strrep(strrep(tmp1,'ZERO','0'),'ONE','1'),'TWO','2'),'THREE','3');
    side = strrep(strrep(strtok(tmp2,'_'),'LEFT','L'),'RIGHT','R');
%     Channel = strcat(hdr.chan,'_',side,'_', ch1, ch2);
    d=[];
    for c = 1:length(runs)
        i=perceive_ci(runs{c},FirstPacketDateTime);
        try
            raw=[data(i).TimeDomainData]';
        catch unmatched_samples
            for xi=1:length(i)
                sl(xi)=length(data(i(xi)).TimeDomainData);
            end
            smin=min(sl);
            raw=[];
            for xi = 1:length(xi)
                raw(xi,:) = data(i(xi)).TimeDomainData(1:smin);
            end
            warning('Sample size differed between channels. Check session affiliation.')
        end
        d.hdr = hdr;
        d.datatype = datafields{b};
        d.hdr.CT.Pass=strrep(strrep(unique(strtok(Pass(i),'_')),'FIRST','1'),'SECOND','2');
        d.hdr.CT.GlobalSequences=GlobalSequences(i,:);
        d.hdr.CT.GlobalPacketSizes=GlobalPacketSizes(i,:);
        d.hdr.CT.FirstPacketDateTime = runs{c};
        
        d.label=Channel(i);
        d.trial{1} = raw;
        
        d.time{1} = linspace(seconds(datetime(runs{c},'Inputformat','yyyy-MM-dd HH:mm:ss.sss')-hdr.d0),seconds(datetime(runs{c},'Inputformat','yyyy-MM-dd HH:mm:ss.sss')-hdr.d0)+size(d.trial{1},2)/fsample,size(d.trial{1},2));
        
        d.fsample = fsample;
        
        firstsample = 1+round(fsample*seconds(datetime(runs{c},'Inputformat','yyyy-MM-dd HH:mm:ss.sss')-hdr.d0));
        lastsample = firstsample+size(d.trial{1},2);
        d.sampleinfo(1,:) = [firstsample lastsample];
        if firstsample<0
            keyboard
        end
        d.trialinfo(1) = c;
        d.fname = [hdr.fname '_run-BSTD' char(datetime(runs{c},'Inputformat','yyyy-MM-dd HH:mm:ss.sss','format','yyyyMMddhhmmss'))];
        d.hdr.Fs = d.fsample;
        d.hdr.label = d.label;
      
        d.ecg=[];
        d.ecg_cleaned=[];
        for e = 1:size(raw,1)
            d.ecg{e} = perceive_ecg(raw(e,:));
            title(strrep(d.label{e},'_',' '))
            xlabel(strrep(d.fname,'_',' '))
            savefig(fullfile(hdr.fpath,[d.fname '_ECG_' d.label{e} '.fig']))
            perceive_print(fullfile(hdr.fpath,[d.fname '_ECG_' d.label{e}]))
            d.ecg_cleaned(e,:) = d.ecg{e}.cleandata;                 
        end
        % TODO: set if needed:
        %d.keepfig = false; % do not keep figure with this signal open
        alldata{length(alldata)+1} = d;
    end

end