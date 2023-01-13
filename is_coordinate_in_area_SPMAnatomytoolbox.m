function [is_in_Area, probability, isindexzero]=is_coordinate_in_area_SPMAnatomytoolbox(My_coordinate, min_probability, area)

    if nargin==1
         area='Brain-Stem';
         min_probability=10;
    end
    load('D:\SPM\toolbox\Anatomy_v3\JuBrain_Data_public_v30.mat')

%     xyzmm = spm_orthviews('pos');
    xyzmm = My_coordinate;
    xyzv = JuBrain.Vo.mat \ [xyzmm; 1]; 
    xyzv = round(xyzv(1:3));
    
    index = Macro.Index(min(max(xyzv(1),1),size(Macro.Index,1)),min(max(xyzv(2),1),size(Macro.Index,2)),min(max(xyzv(3),1),size(Macro.Index,3)));
    is_in_Area=0;
    isindexzero=0;
    probability=0;
    if index==0
%         disp(['index=0 '])
        isindexzero=1;
    else
        [a, ~, B] = find(Macro.PMap(:,index)); [B, I] = sort(B,'descend'); B = B(B>.01);
        
        if numel(B)>0
            for i=1:numel(B)
                if strcmp(Macro.Namen{a(I(i))}, area) && B(i)*100>min_probability
                    is_in_Area=1;
                    probability=B(i)*100;
                end
            end
        end
    end

end
