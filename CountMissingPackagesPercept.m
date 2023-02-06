function CountMissingPackagesPercept()
    
    initials={'LN_PR_D001', 'LN_PR_D003','LN_PR_D004','LN_PR_D005', 'LN_PR_D006','LN_PR_D007','LN_PR_D008','LN_PR_D009'};
    
    for i=1:numel(initials)

        LFProot=['Z:\', initials{i}, '\raw_LFP\'];
        jsonfiles=dir([LFProot, '*.json']);
        
        for kk=1:numel(jsonfiles)
            js = jsondecode(fileread(fullfile(jsonfiles(kk).folder, jsonfiles(kk).name)));
        
            
            datafields = sort({'BrainSenseTimeDomain','IndefiniteStreaming'});
            
        
            if isfield(js, datafields{1})
                data = js.(datafields{1});
            
                FirstPacketDateTime = strrep(strrep({data(:).FirstPacketDateTime},'T',' '),'Z','');
                runs = unique(FirstPacketDateTime);
                fsample = data.SampleRateInHz;
                
                Pass = {data(:).Pass};
                tmp =  {data(:).GlobalSequences};
                for c = 1:length(tmp)
                    GlobalSequences{c,:} = str2num(tmp{c});
                    missingPackages{c,:} = (diff(str2num(tmp{c}))==2);
                    nummissinPackages(c) = numel(find(diff(str2num(tmp{c}))==2));
                end
                tmp =  {data(:).TicksInMses};
                for c = 1:length(tmp)
                    TicksInMses{c,:}= str2num(tmp{c});
                    TicksInS{c,:} = (TicksInMses{c,:} - TicksInMses{c,:}(1))/1000;
                end
            
                tmp =  {data(:).GlobalPacketSizes};
                for c = 1:length(tmp)
                    GlobalPacketSizes{c,:} = str2num(tmp{c});
                    isDataMissing(c)= logical(TicksInS{c,:}(end) >= sum(GlobalPacketSizes{c,:})/fsample);
                    time_real{c,:} = TicksInS{c,:}(1):1/fsample:TicksInS{c,:}(end)+(GlobalPacketSizes{c,:}(end)-1)/fsample;
                    time_real{c,:} = round(time_real{c,:},3);
                end
            
                if any(isDataMissing)
                    disp(['missing packages found in patient', initials{i}])
                end
            end
        end

    end

    
%     
%     gain=[data(:).Gain]';
%     [tmp1,tmp2] = strtok(strrep({data(:).Channel}','_AND',''),'_');
%     ch1 = strrep(strrep(strrep(strrep(tmp1,'ZERO','0'),'ONE','1'),'TWO','2'),'THREE','3');
%     
%     [tmp1,tmp2] = strtok(tmp2,'_');
%     ch2 = strrep(strrep(strrep(strrep(tmp1,'ZERO','0'),'ONE','1'),'TWO','2'),'THREE','3');
%     side = strrep(strrep(strtok(tmp2,'_'),'LEFT','L'),'RIGHT','R');
%     Channel = strcat(hdr.chan,'_',side,'_', ch1, ch2);
%     d=[];
%     for c = 1:length(runs)
%         i=perceive_ci(runs{c},FirstPacketDateTime);
%         try 
%             x=find(ismember(i, find(isDataMissing)));
%             if ~isempty(x)
%                 warning('missing packages detected, will interpolate to replace missing data')
%                 for k=1:numel(x)
%                     isReceived = zeros(size(time_real{i(k),:}, 2), 1);
%                     nPackets = numel(GlobalPacketSizes{i(k),:});
%                     for packetId = 1:nPackets
%                         timeTicksDistance = abs(time_real{i(k),:} - TicksInS{i(k),:}(packetId));
%                         [~, packetIdx] = min(timeTicksDistance);
%                         if isReceived(packetIdx) == 1
%                             packetIdx = packetIdx +1;
%                         end
%                         isReceived(packetIdx:packetIdx+GlobalPacketSizes{i(k),:}(packetId)-1) = isReceived(packetIdx:packetIdx+GlobalPacketSizes{i(k),:}(packetId)-1)+1;
%             %             figure; plot(isReceived, '.'); yticks([0 1]); yticklabels({'not received', 'received'}); ylim([-1 10])
%                     end 
%                     data_temp = NaN(size(time_real{i(k),:}, 2), 1);
%                     data_temp(logical(isReceived), :) = data(i(k)).TimeDomainData;
%                     ind_interp=find(diff(isReceived));
%                     if isReceived(ind_interp(1)+1)==1
%                         ind_interp=[1 ind_interp];
%                         data_temp(1)=0;
%                     end
%                     if isReceived(ind_interp(end)+1)==0
%                         ind_interp=[ind_interp size(data_temp,1)-1];
%                         data_temp(end)=0;
%                     end
%                     for mm=1:2:numel(ind_interp/2)
%                         data_temp(ind_interp(mm)+1:ind_interp(mm+1))=...
%                         linspace(data_temp(ind_interp(mm)), data_temp(ind_interp(mm+1)+1), ind_interp(mm+1)-ind_interp(mm));
%                     end
%                     raw_temp(x(k),:)=data_temp';
%                 end
%                 raw=raw_temp;
%             else
%                 raw=[data(i).TimeDomainData]';
%             end
%         catch unmatched_samples
%             for xi=1:length(i)
%                 sl(xi)=length(data(i(xi)).TimeDomainData);
%             end
%             smin=min(sl);
%             raw=[];
%             for xi = 1:length(xi)
%                 raw(xi,:) = data(i(xi)).TimeDomainData(1:smin);
%             end
%             warning('Sample size differed between channels. Check session affiliation.')
%         end
%         d.hdr = hdr;
%         d.datatype = datafields{b};
%         d.hdr.CT.Pass=strrep(strrep(unique(strtok(Pass(i),'_')),'FIRST','1'),'SECOND','2');
%         d.hdr.CT.GlobalSequences=GlobalSequences(i,:);
%         d.hdr.CT.GlobalPacketSizes=GlobalPacketSizes(i,:);
%         d.hdr.CT.FirstPacketDateTime = runs{c};
%         
%         d.label=Channel(i);
%         d.trial{1} = raw;
%         
%         d.time{1} = linspace(seconds(datetime(runs{c},'Inputformat','yyyy-MM-dd HH:mm:ss.sss')-hdr.d0),seconds(datetime(runs{c},'Inputformat','yyyy-MM-dd HH:mm:ss.sss')-hdr.d0)+size(d.trial{1},2)/fsample,size(d.trial{1},2));
%         
%         d.fsample = fsample;
%         
%         firstsample = 1+round(fsample*seconds(datetime(runs{c},'Inputformat','yyyy-MM-dd HH:mm:ss.sss')-hdr.d0));
%         lastsample = firstsample+size(d.trial{1},2);
%         d.sampleinfo(1,:) = [firstsample lastsample];
%         if firstsample<0
%             keyboard
%         end
%         d.trialinfo(1) = c;
%         d.fname = [hdr.fname '_run-BSTD' char(datetime(runs{c},'Inputformat','yyyy-MM-dd HH:mm:ss.sss','format','yyyyMMddhhmmss'))];
%         d.hdr.Fs = d.fsample;
%         d.hdr.label = d.label;
%       
%         d.ecg=[];
%         d.ecg_cleaned=[];
%         for e = 1:size(raw,1)
%             d.ecg{e} = perceive_ecg(raw(e,:));
%             title(strrep(d.label{e},'_',' '))
%             xlabel(strrep(d.fname,'_',' '))
%             savefig(fullfile(hdr.fpath,[d.fname '_ECG_' d.label{e} '.fig']))
%             perceive_print(fullfile(hdr.fpath,[d.fname '_ECG_' d.label{e}]))
%             d.ecg_cleaned(e,:) = d.ecg{e}.cleandata;                 
%         end
%         % TODO: set if needed:
%         %d.keepfig = false; % do not keep figure with this signal open
%         alldata{length(alldata)+1} = d;
%     end

end