function [delta_f noise_lvl resp_t_fct] = get_ch_prop(x, fs)

tolerance = 1;
d_tolerance = 0.01;
x_out = double(x);

% get max values
max_out_idx = 0;
while length(max_out_idx) < 2,
    tolerance = tolerance - d_tolerance;
    max_out_idx = find(x_out > tolerance*max(x_out));
end;

% calculate frequency delta
delta_out = max(diff(max_out_idx));
delta_f = abs(delta_out - fs);

% select the first impulse and measure the noise before
noise_lvl = max(abs(x_out(1:max_out_idx(1)-1000)));

% measure the response time
start_idx = max_out_idx(end)-1000;
resp_t_arr = find(x_out(start_idx:end) > 2*noise_lvl);
resp_t_arr = resp_t_arr + start_idx;
resp_t_fct = x_out(resp_t_arr(1):resp_t_arr(end));
