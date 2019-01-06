clear all;

t_wc_path = 'T_W_C.txt';
t_wc_file = fopen(t_wc_path);
t_wc_data = textscan(t_wc_file, ... 
      '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','Delimiter',''); 
fclose(t_wc_file);
t_wc_data = cell2mat(t_wc_data); 
kf_positions = t_wc_data(:, [4, 8, 12]); 
 
chars = char('2014-12-09-13-21-02/rect_scaled_rgb_images/left/1418132416737115.jpg');
name = chars()

paths = localPaths(); 
datasetRoot= paths.dsetRootRobotCar; 
subsetRoot = paths.subsetsRootRobotCar;

tvt = 'training';
seq_id = '2014-07-14-14-49-50';
path = [subsetRoot seq_id '/' 'image_index_' tvt '_subset.txt'];
mask_file = fopen(path);
mask = cell2mat(textscan(mask_file, '%u'));
fclose(mask_file);