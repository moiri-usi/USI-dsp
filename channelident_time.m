clear;

fs = input('Enter the sampling rate in Hz: '); %
t_sim = input('Enter the simulation time in s: '); %

t_arr = 0:1/fs:t_sim;

x = zeros(1,fs*t_sim+1);
x(fs*2) = 1;

data_in = [t_arr' x'];

sim('audio_io.mdl');

tolerance = 0.9;

x_out = double(data_out);
max_out_idx = find(x_out == max(x_out));
noise_lvl = max(abs(x_out(1:max_out_idx-1000)));

resp_t_arr = find(x_out > noise_lvl);
resp_ts = resp_t_arr(end) - resp_t_arr(1);

resp_t = 1000*resp_ts/fs;

fprintf('The respons time is aproximately %d ms.\n', resp_t);