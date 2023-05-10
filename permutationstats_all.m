
% for t=8:numel(tasks)
%     output{t}=GetConnectivityData(tasks{t}, 'Coherence');
%     output_shifted{t}=GetConnectivityData(tasks{t}, 'ShuffledCoherence');
% 
% end
% 
% for t=1:numel(tasks)
%     size(output{t}.off)
% end
% 
for t=2:3
    clear xoff_temp xoff_shifted_temp xon_temp xon_shifted_temp
    xoff=output{t}.off;
%     xoff_shifted=output_shifted{t}.off;
    for i=1:2
    xoff_temp(:,:,i,:)=cat(4, xoff(:,:,2*(i-1)+1,:), xoff(:,:,2*i,:));
%     xoff_shifted_temp(:,:,i,:)=cat(4, xoff_shifted(:,:,2*(i-1)+1,:), xoff_shifted(:,:,2*i,:));
    end
    output{t}.off=xoff_temp;
%     output_shifted{t}.off=xoff_shifted_temp;

    xon=output{t}.on;
%     xon_shifted=output_shifted{t}.on;
    for i=1:2
    xon_temp(:,:,i,:)=cat(4, xon(:,:,2*(i-1)+1,:), xon(:,:,2*i,:));
%     xon_shifted_temp(:,:,i,:)=cat(4, xon_shifted(:,:,2*(i-1)+1,:), xon_shifted(:,:,2*i,:));
    end
    output{t}.on=xon_temp;
%     output_shifted{t}.on=xon_shifted_temp;
end
% 
% 
clear xoff_temp xoff_shifted_temp xon_temp xon_shifted_temp
xoff=output{t}.off;
xoff_temp(:,:,1,:)=cat(4, xoff(:,:,1,:), xoff(:,:,2,:),xoff(:,:,3,:),xoff(:,:,4,:));
output{t}.off=xoff_temp;

xon=output{t}.on;
xon_temp(:,:,1,:)=cat(4, xon(:,:,1,:), xon(:,:,2,:),xon(:,:,3,:),xon(:,:,4,:));
output{t}.on=xon_temp;




tasks={'R', 'ACT', 'PMT', 'SST', 'HPT', 'POUR', 'WALK', 'SPEAK', 'WRITE', 'SGT'};


%     {'left hand', 'right hand', 'left foot', 'right foot'},...
%    {'left hand', 'right hand', 'left foot', 'right foot'},...
title_={{'R'},...
    {'hand', 'foot'},...
    {'hand', 'foot'},...
    {'SST_right','rest_right','SST_left','rest_left'},...
    {'hold_right','rest'},...
    {'pour','rest'},...
    {'walk','stand'},...
    {'speak','rest'},...
    {'write','rest'},...
    {'gest','rest'},...
    };

for t=1:numel(tasks)
    [diff_coherence_low{t}, channs_low, freq_range]=ClusterbasedPermutationtest(output{t}.on, output{t}.off, title_{t}, tasks{t}, [7, 30], 'low');
    [diff_coherence_high{t}, channs_high, freq_range]=ClusterbasedPermutationtest(output{t}.on, output{t}.off, title_{t}, tasks{t}, [30, 70], 'high')
    
    for k=1:size(channs_low,2)

    end
    plotConnectivityAfterPermutation(tasks{t}, 'Coherence', intersect(channs_low{1,1}, channs_low{1,2}), [7 14])

    plotBoxplotsAfterPermutation(tasks{t}, 'Coherence', intersect(channs_low{1,1}, channs_low{1,2}), [9 30])

   
end

% t=3;
% diff_coherence=ClusterbasedPermutationtest(output{t}.on, output{t}.off, title_{t}, tasks{t}, [7, 35]);





