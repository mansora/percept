function ev=dbs_eeg_percept_convert_logfile_to_event(S_trl, D, input_logfile)
    nev = size(S_trl.trl, 1);
    ev = [];

    if ~isempty(strfind(input_logfile, 'REST'))
        for i = 1:nev
            ev(i).type  = S_trl.conditionlabels{i};
            ev(i).value = 'REST';
            ev(i).time  = D.timeonset+S_trl.trl(i, 1)/D.fsample;
        end
        [~, ind] = sort([ev.time]);
        ev=ev(ind);

      
    elseif ~isempty(strfind(input_logfile, 'PMT')) || ~isempty(strfind(input_logfile, 'ACT'))
        for i = 1:nev
            ev(i).type  = S_trl.conditionlabels{i};
            ev(i).value = 'up';
            ev(i).time  = D.timeonset+S_trl.trl(i, 1)/D.fsample;
            ev(nev+i).type  = S_trl.conditionlabels{i};
            ev(nev+i).value = 'down';
            ev(nev+i).time  = D.timeonset+S_trl.trl(i, 2)/D.fsample;
        end
        [~, ind] = sort([ev.time]);
        ev=ev(ind);
    elseif ~isempty(strfind(input_logfile, 'DPT'))
        %% TODO add markers for this

    elseif ~isempty(strfind(input_logfile, 'SST'))
 
    elseif ~isempty(strfind(input_logfile, 'SGT'))

        

    elseif ~isempty(strfind(input_logfile, 'HPT')) || ~isempty(strfind(input_logfile, 'REACH'))
        nev = size(S_trl.trl, 1);
        ev = [];            
        for i = 1:nev
            ev(i).type  = 'arms';
            ev(i).value = 'up';
            ev(i).time  = D.timeonset+S_trl.trl(i, 1)/D.fsample;
            ev(nev+i).type  = 'arms';
            ev(nev+i).value = 'down';
            ev(nev+i).time  = D.timeonset+S_trl.trl(i, 2)/D.fsample;
        end
        [~, ind] = sort([ev.time]);
        ev=ev(ind);
        

    elseif ~isempty(strfind(input_logfile, 'WRITE'))
        nev = size(S_trl.trl, 1);
        ev = [];            
        for i = 1:nev
            ev(i).type  = 'write';
            ev(i).value = 'right';
            ev(i).time  = D.timeonset+S_trl.trl(i, 1)/D.fsample;
            ev(nev+i).type  = 'write';
            ev(nev+i).value = 'left';
            ev(nev+i).time  = D.timeonset+S_trl.trl(i, 1)/D.fsample;
        end
        [~, ind] = sort([ev.time]);
        ev=ev(ind);
        
        
        

    elseif ~isempty(strfind(input_logfile, 'POUR'))
        for i = 1:nev
            ev(i).type  = S_trl.conditionlabels{i};
            ev(i).value = S_trl.conditionlabels{i};
            ev(i).time  = D.timeonset+S_trl.trl(i, 1)/D.fsample;  
        end
        [~, ind] = sort([ev.time]);
        ev=ev(ind);
        

    elseif ~isempty(strfind(input_logfile, 'SPEAK'))
        
        

    elseif ~isempty(strfind(input_logfile, 'WALK'))
        if ~isempty(strfind(input_logfile, 'LN_PR_D006'))
            for i = 1:nev
                ev(i).type  = 'walk';
                ev(i).value = S_trl.conditionlabels{i};
                ev(i).time  = D.timeonset+S_trl.trl(i, 1)/D.fsample;  
            end
            [~, ind] = sort([ev.time]);
            ev=ev(ind);
   
        else
            
    
           
        end
        
    else disp('no match found')
    end


    

end