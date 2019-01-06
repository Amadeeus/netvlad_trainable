function [kf_positions] = getUTMPosition(t_wc_path) 
  t_wc_file = fopen(t_wc_path);
  t_wc_data = textscan(t_wc_file, ... 
        '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','Delimiter',''); 
  fclose(t_wc_file);
  t_wc_data = cell2mat(t_wc_data); 
  % kf_positions = t_wc_data(:, [4, 8, 12]);
  kf_positions = t_wc_data(:, [4, 8]);
end

