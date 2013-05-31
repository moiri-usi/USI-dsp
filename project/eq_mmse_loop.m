function y_comp = eq_mmse_loop(x, x_t, Nn, Nt, Nl)
% remove redundant parts of ofdm package
y_demod_ofdm_cut = x(2:Nn+1,:);

% reshape received packages
y_t = y_demod_ofdm_cut(:, 1:Nt);
y_l = y_demod_ofdm_cut(:, Nt+1:end);

% calculate channel coeffs
ch_f = x_t./y_t;

% calculate the average on the channel coeffs
ch_f_av = sum(ch_f.').'/Nt;

% compensate the channel
y_comp = y_l.*repmat(ch_f_av, 1, Nl);
