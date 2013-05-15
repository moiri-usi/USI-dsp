function [y] = ofdm_demod(x, Nn, Nl, Ncp)

out = reshape(x, 2*(Nn+1)+Ncp, Nl);
out = out(Ncp+1:end,:);
y = round(fft(out));