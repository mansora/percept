function mXYZ=dbs_percept_find_max_cohpeaks(initials, rec_id, condition, band, hemisphere, smooth, n_peaks)

%     smooth = 4;
    
    try
        [files, seq, root, details] = dbs_subjects_percept(initials, rec_id);
    catch
        out = [];
        return;
    end
    
    banddir = sprintf('band_%d_%dHz', band);

    if strcmp(details.chan{1}(end-3),'L')
        chan_L=details.chan{1};
        chan_R=details.chan{2};
    else
        chan_R=details.chan{1};
        chan_L=details.chan{2};
    end
    
    switch hemisphere
        case 'Left'
            chan=chan_L;
        case 'Right'
            chan=chan_R;      
    end

    
    cd(fullfile(root, condition, banddir, chan));
    
    spm_smooth('full_orig.nii','sfull_orig.nii',smooth)
    
    vol = spm_vol('sfull_orig.nii');
    [Y,XYZ] = spm_read_vols(vol);
    
    thresh = nanmean(Y(:))+2*nanstd(Y(:));
    
    %%
    [p, f, x] = fileparts(vol.fname);
    
    Y(Y<thresh) = NaN;
    vol.fname = fullfile(p, ['thresh' f '.nii']);
    spm_write_vol(vol, Y);
    
    XYZ = vol.mat\[XYZ;ones(1,size(XYZ,2))];
    XYZ = XYZ(1:3,:);
    
    Y=Y(:);
    XYZ(:,isnan(Y))=[];
    Y(isnan(Y))=[];
    [N,Z,M,A] = spm_max(Y,XYZ);
    
    mXYZ = vol.mat*[M;ones(1,size(M,2))];
    mXYZ = mXYZ(1:3,:)';
    mXYZ=mXYZ(1:n_peaks,:);



end
