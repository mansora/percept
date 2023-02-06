                                                                                                                                                                                                                                                                                                                function varargout = process_s3p( varargin )
% process_hmp: Hampel Filter. 
%
% =============================================================================@
%
% Authors: Levent Kandemir, 2018
% 

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % === Description the process
    sProcess.Comment     = 'DBS Artifact Removal - Hampel Filter';
    sProcess.FileTag     = 'Hampel';
    sProcess.Category    = 'Filter';
    sProcess.SubGroup    = 'DBS_Noise';
    sProcess.Index       = 66;
    
    % === Definition of the input accepted by this process
    sProcess.InputTypes  = {'data', 'results', 'raw', 'matrix'};
    sProcess.OutputTypes = {'data', 'results', 'raw', 'matrix'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    
    % === Epoch length will be used to divide the data. 
    sProcess.options.label2.Comment = '<B>Filter Options</B>:';
    sProcess.options.label2.Type    = 'label';
	
	sProcess.options.winlen.Comment = 'Window Length (Hz.): ';
    sProcess.options.winlen.Type    = 'combobox';
    sProcess.options.winlen.Value   = {1, {'0.25', '0.50', '0.75', '1', '2', '3', '4', '5'}};
    
    sProcess.options.ct.Comment = 'Constant: ';
    sProcess.options.ct.Type    = 'combobox';
    sProcess.options.ct.Value   = {3, {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'}};
    
	sProcess.options.ftr.Comment = 'Frequencies to Reject:';
    sProcess.options.ftr.Type    = 'text';
    sProcess.options.ftr.Value   = '';
    
    sProcess.options.fmax.Comment = 'Lowpass Frequency:';
    sProcess.options.fmax.Type    = 'value';
    sProcess.options.fmax.Value   = {300,'Hz. ',2};
end


%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) % Giving information to the user. 
    wlist=sProcess.options.winlen.Value{2};
    clist=sProcess.options.ct.Value{2};
    if isempty(sProcess.options.ftr.Value)
        freqs='All';
    else
        freqs=sProcess.options.ftr.Value;
    end
    Comment=char(strcat("WindowLength=", wlist(sProcess.options.winlen.Value{1}), "Hz C=", clist(sProcess.options.ct.Value{1}), " Freqs=", freqs));
end


%% ===== RUN =====
function sInput = Run(sProcess,sInput) % Main function.
    %% Get the path for process report.
    target=strcat(getfield(bst_get('ProtocolInfo'), 'STUDIES'),'\',sInput.SubjectName,...
        '\',getfield(bst_get('Study'), 'Name'),'\','process_settings');
    
    %% Load Channel File and Data File
    channelfile=load(file_fullpath(sInput.ChannelFile));
    temp=load(file_fullpath(sInput.FileName));
    
    %% Reject bad channels and bad segments
    % Get blue print for bad channels
    bp=demount({channelfile.Channel(:).Type}', sInput.ChannelFlag, temp.Device);
    % Get map for bad segments
    map=badseg(temp.F.events, sInput.TimeVector); 
    % Simplification for FFT
    if mod(sum(map),2)
        map(find(map,1,'last'))=0;
    end

    % Reduce data to good channels and segments
    datagood=sInput.A(bp, logical(map)); 
    szdata=size(datagood); 
    
    %% Getting algorithm specific options ready. 
    % Get window length and constant
    wlen=str2double(sProcess.options.winlen.Value{2}{sProcess.options.winlen.Value{1}});
    ct=str2double(sProcess.options.ct.Value{2}{sProcess.options.ct.Value{1}});

    % Get user defined frequencies
    freqspan=linspace(0, temp.F.prop.sfreq/2, szdata(2)/2+1);
    
    % Select frequencies to operate on
    ind=getfreqs(freqspan, sProcess.options.fmax.Value{1}, sProcess.options.ftr.Value);

    %% Calculation
    % All channels FFT
    multi_chan=fft(datagood, [], 2);
    
    % Process real and imaginary parts separately and reconstruct
    abs=hampelv(real(multi_chan),wlen,ct,ind,freqspan);
    im=hampelv(imag(multi_chan),wlen,ct,ind,freqspan);
    cleaned=complex(abs,im);
    
    % Correct complex conjugate so that ifft works
    szc=size(cleaned,2)/2;
    rev_cleaned=fliplr(cleaned(:,2:szc));
    cleaned(:,(szc+2):end)=conj(rev_cleaned);
    
    % Save cleaned data
    sInput.A(bp,logical(map))=ifft(cleaned, [], 2); 
    
    %% Save process settings
    fid = fopen(strcat(target,'.txt'), 'wt' );
    fprintf(fid, 'Window_Length: %d', wlen);
    fprintf(fid, '\nConstant: %d', ct);
    fprintf(fid, '\nFrequencies_to_reject: %s', sProcess.options.ftr.Value);
    fprintf(fid, '\nLpassFreq: %d', sProcess.options.fmax.Value{1});
    fclose(fid);           

end

%% Helper Functions
function x=hampelv(x,wlen,ct,ind,freqspan)

    % Prepare window
    tt=freqspan(1):find(freqspan<1, 1, 'last' );
    wlen=floor(wlen*(length(tt)-2));
    
    % Reduce input to requested frequencies
    processed=x(:,ind);
    
    % Get moving median and mad scale
    med=movmedian(processed, 2*wlen+1, 2);
    deviant=movmad(processed, 2*wlen+1, 2);

    % Detect outliers
    S=1.4286*deviant;               % Allen (2009) Eq. 2
    comp=abs(processed-med)>ct*S;   % Allen (2009) Eq. 1
    
    % Replace outliers with median and return
    processed(comp)=med(comp);
    x(:,ind)=processed; 

end

function ind=getfreqs(freqspan, fmax, user_freqs)
% in-line functions
sr=@(a, ind) str2double(a{ind});
mind=@(a,b) min(abs(a-b));
% allocation
ind=[];
if ~isempty(user_freqs)
    if ~contains(user_freqs,'-')
        % consider individual frequencies
        freqs=str2double(user_freqs);
        for i=1:numel(freqs)
            [~, ind1]=mind(freqspan, freqs(i));
            ind=[ind ind1]; %#ok<*AGROW>
        end
    else
        % if multiple interval
        mult_int=strsplit(user_freqs,{',', ' '});
        for i=1:numel(mult_int)
            switch numel(strsplit(mult_int{i}, '-'))
                case 1
                    [~, ind1]=mind(freqspan,sr(strsplit(mult_int{i}, '-'), 1));
                    ind=[ind ind1];
                case 2
                    [~, ind1]=mind(freqspan,sr(strsplit(mult_int{i}, '-'), 1));
                    [~, ind2]=mind(freqspan,sr(strsplit(mult_int{i}, '-'), 2));
                    ind=[ind ind1:ind2];
                otherwise
                    error('\nWrong frequency definition!');
            end
        end
    end
else
    fprintf('\nFull Spectrum Smoothing!');
    [~, ind1]=mind(freqspan, fmax);
    ind=[ind 1:ind1];
end
ind=unique(ind);

end