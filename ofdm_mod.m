function [y y_ifft] = ofdm_mod(x, Ncp)

out = ifft(x);
y_ifft = [out(end-Ncp+1:end,:); out];
y = y_ifft(:).';