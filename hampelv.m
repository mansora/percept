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