initials={'LN_PR_D006'};
condition='POUR';
hemispheres={'Right', 'Left'};
bands={[20 30], [23.5 3.5 44.8], 'beta'};


rec_id = 1;
%%
pos = [];
label = {};
for s = 1:numel(initials)
    [~, ~, ~, details] = dbs_subjects_percept(initials{s}, rec_id);
    ROI = {};
    for b = 1:size(bands, 1)
        for c = 1:numel(hemispheres)
            cpos =  dbs_percept_coordinate_sources(initials{s}, rec_id, condition, bands{b,1}, hemispheres{c}, bands{b,2});
            if norm(cpos- bands{b, 2})<15
                pos = [pos; cpos];
            else
                pos = [pos;  bands{b, 2}];
            end
            
%             label = [label, repmat(bands(b, 3), size(cpos, 1))];
            ROI = [ROI; {['CTX_' bands{b, 3} '_' hemispheres{c}], cpos, bands{b, 1}}];
        end
    end
    %dbs_meg_coh_peak_extraction(initials{s}, rec_id, condition, hemisphere, ROI)
end
% %%
% figure;
% ft_plot_mesh(export(gifti(fullfile(spm('dir'), 'canonical', 'iskull_2562.surf.gii')), 'ft'), 'facealpha', 0);
% hold on;
% cm = colormap('jet');
% plot3(pos(:, 1),pos(:, 2), pos(:, 3), '.', 'MarkerSize', 35, 'Color', [0 0 0]);
% %%
