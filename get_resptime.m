function [resp_t_fct] = get_resptime(x, tolerance)

x_out = double(x);
max_out_idx = find(x_out == max(x_out));
noise_lvl = max(abs(x_out(1:max_out_idx-1000)));

resp_t_arr = find(x_out > noise_lvl);
resp_t_fct = x_out(resp_t_arr(1):resp_t_arr(end));
