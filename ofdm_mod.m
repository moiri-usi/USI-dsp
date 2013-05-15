function [y] = ofdm_mod(x, Ncp)

out = ifft(x);
out = [x(1:Ncp,:); out];
y = out(:)';
