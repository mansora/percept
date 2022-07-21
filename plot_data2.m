evs=D.events;
x=[];
for i=1:numel(evs)
    if strcmp(evs(i).type, 'left hand')
        if strcmp(evs(i).value, 'up')
            x=[x, evs(i).time];
        end
    end

end


figure, 


subplot(5,1,1), plot(D.time, D(D.indchannel('thumb_L_y'),:,:))
hold on, plot(D.time, D(D.indchannel('thumb_L_x'),:,:))
hold on, xline(x);
title('left thumb')

subplot(5,1,2), plot(D.time, D(D.indchannel('index_L_y'),:,:))
hold on, plot(D.time, D(D.indchannel('index_L_x'),:,:))
hold on, xline(x);
title('left index')


subplot(5,1,3), plot(D.time, D(D.indchannel('middle_L_y'),:,:))
hold on, plot(D.time, D(D.indchannel('middle_L_x'),:,:))
hold on, xline(x);
title('left middle')

subplot(5,1,4), plot(D.time, D(D.indchannel('ring_L_y'),:,:))
hold on, plot(D.time, D(D.indchannel('middle_L_x'),:,:))
hold on, xline(x);
title('left ring')

subplot(5,1,5), plot(D.time, D(D.indchannel('pinkie_L_y'),:,:))
hold on, plot(D.time, D(D.indchannel('middle_L_x'),:,:))
hold on, xline(x);
title('left pinkie')


%%
evs=D.events;
x=[];
for i=1:numel(evs)
    if strcmp(evs(i).type, 'right hand')
        if strcmp(evs(i).value, 'up')
            x=[x, evs(i).time];
        end
    end

end


figure, 

subplot(5,1,1), plot(D.time, D(D.indchannel('thumb_R_y'),:,:))
hold on, plot(D.time, D(D.indchannel('thumb_R_x'),:,:))
hold on, xline(x);
title('right thumb')

subplot(5,1,2), plot(D.time, D(D.indchannel('index_R_y'),:,:))
hold on, plot(D.time, D(D.indchannel('index_R_x'),:,:))
hold on, xline(x);
title('right index')


subplot(5,1,3), plot(D.time, D(D.indchannel('middle_R_y'),:,:))
hold on, plot(D.time, D(D.indchannel('middle_R_x'),:,:))
hold on, xline(x);
title('right middle')

subplot(5,1,4), plot(D.time, D(D.indchannel('ring_R_y'),:,:))
hold on, plot(D.time, D(D.indchannel('middle_R_x'),:,:))
hold on, xline(x);
title('right ring')

subplot(5,1,5), plot(D.time, D(D.indchannel('pinkie_R_y'),:,:))
hold on, plot(D.time, D(D.indchannel('middle_R_x'),:,:))
hold on, xline(x);
title('right pinkie')



