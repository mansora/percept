cd D:\fieldtrip-20211102\fieldtrip-20211102
ft_defaults

head_surface = ft_read_headshape('D:\Skanect\model_18_01_2022_edit.ply')
disp(head_surface)

% don't need to do this as you already export your data in mm
% head_surface = ft_convert_units(head_surface, 'mm');

ft_plot_mesh(head_surface)

cfg = [];
cfg.method = 'headshape';
fiducials = ft_electrodeplacement(cfg, head_surface);

cfg = [];
cfg.method        = 'fiducial';
cfg.coordsys      = 'ctf';
cfg.fiducial.nas  = fiducials.elecpos(1,:); %position of NAS
cfg.fiducial.lpa  = fiducials.elecpos(2,:); %position of LPA
cfg.fiducial.rpa  = fiducials.elecpos(3,:); %position of RPA
head_surface = ft_meshrealign(cfg, head_surface);

ft_plot_axes(head_surface)
ft_plot_mesh(head_surface)

cfg = [];
cfg.method = 'headshape';
elec = ft_electrodeplacement(cfg, head_surface);
elec.label={'Fp1', 'Fz', 'F3', 'F7', 'FT9', 'FC5', 'FC1', 'C3', 'T7', 'TP9', 'CP5', 'CP1', 'Pz', 'P3', 'P7', ...
    'O1', 'Oz', 'O2', 'P4', 'P8', 'TP10', 'CP6', 'CP2', 'Cz', 'C4', 'T8', 'FT10', 'FC6', 'FC2', 'F4', 'F8', 'Fp2', 'GND', 'REF'};

ft_plot_mesh(head_surface)
ft_plot_sens(elec)

cfg = [];
cfg.method     = 'moveinward';
cfg.moveinward = 12;
cfg.elec       = elec;
elec = ft_electroderealign(cfg);

% save elec file