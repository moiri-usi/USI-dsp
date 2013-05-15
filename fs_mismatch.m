run('initparams');

tolerance = 0.9;

max_out = find(x_out > tolerance*max(x_out));
delta_out = max(diff(max_out));

delta_f = abs(delta_out - fs);
fprintf('The delta of the samplig frequency is %d samples per second.\n', delta_f);