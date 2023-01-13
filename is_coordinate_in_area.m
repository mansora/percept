function [out_put, val_min]=is_coordinate_in_area(My_coordinate, area, min_dist)

    switch area
        case 'SMA'
            Y_equal=[15, 16];
        case 'STG'
            Y_equal=[85, 86];
        case 'MOG'
            Y_equal=[55, 56];
        case 'Brainstem'
            Y_equal=[159:170];

    end
    
    vol = spm_vol('D:\SPM\toolbox\AAL3\ROI_MNI_V7.nii');
%     vol = spm_vol('D:\SPM\toolbox\Anatomy_v3\JuBrain_Map_public_v30.nii');
    
    [Y,XYZ] = spm_read_vols(vol);


    XYZ_temp=[];
    for i=1:numel(Y_equal)
        XYZ_temp=[XYZ_temp, XYZ(:,find(Y==Y_equal(i)))];
    end

    [val_min, ind_min]=min(pdist2(My_coordinate, XYZ_temp'));

    if val_min<min_dist
        out_put=1;
    else
        out_put=0;
    end


end