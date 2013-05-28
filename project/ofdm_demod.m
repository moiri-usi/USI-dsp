function [y y_resh y_cut] = ofdm_demod(x, Nn, Nl, Ncp)

f_len = 2*(Nn+1)+Ncp;
y_resh = reshape(x, f_len, length(x)/f_len);
y_cut = y_resh(Ncp+1:end,:);
y = fft(y_cut);

% set known values to zero
y(1,:) = 0;
y(Nn+2,:) = 0;
