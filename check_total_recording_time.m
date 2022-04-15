function total_recording_time=check_total_recording_time(initials)

    total_recording_time=0;
    dbsroot = '\\piazzolla\vlad_shared\';
    files=dir(fullfile(dbsroot, initials, 'raw_LFP', '*.mat'));
    for i=1:size(files,1)
        temp=load(fullfile(files(i).folder, files(i).name));
        data=temp.data;
        recording_time=size(data.time{1},2)/data.fsample;
        total_recording_time=total_recording_time+recording_time;
    end
    seconds=mod(total_recording_time,60);
    minutes=(total_recording_time-seconds)/60;
    disp(['total time recorded during this session is ', num2str(minutes), ' minutes and ', ...
        num2str(seconds), ' seconds.'])
end