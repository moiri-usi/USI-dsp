function [y y_ifft] = ofdm_mod(x, Ncp)

out = real(ifft(x)); % use only real part because of octave
y_ifft = [out(end-Ncp+1:end,:); out];
y = y_ifft(:).';
