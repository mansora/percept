function fix_LED_signal(initials)
        % this code needs to be applied to LED_signal from LN_PR_D007
        % onwards, because we added LED sequences on the onset of the other
        % markers within the experiment too, which is problematic for the
        % synchronization script

        dbsroot = '\\piazzolla\vlad_shared\';
        unfixedLED_signal_dir=[dbsroot, initials, '\processed_MotionCapture\LED_signals\unfixed'];
        files_LED=dir(fullfile(unfixedLED_signal_dir, '*.mat')); %created from the function dbs_eeg_percept_determine_video_offset_LED_save
        
        for i=1:numel(files_LED)
            load(fullfile(files_LED(i).folder, files_LED(i).name));
            figure, plot(LED_signal)
            title('specify the points between which you want to fix')
            [x,y]=ginput(2);
            close all
            LED_signal(x(1):x(2))=linspace(y(1),y(2),x(2)-x(1)+1);
            figure, plot(LED_signal);
            hold on, xline(x(1), 'k'), xline(x(2),'k')
            inp_=input("happy? y/n:","s");
            if inp_=='y'
                save(fullfile([dbsroot, initials, '\processed_MotionCapture\LED_signals\', files_LED(i).name]), 'LED_signal')
            else
                disp(files_LED(i).name)
                break;
            end




        end
       
end