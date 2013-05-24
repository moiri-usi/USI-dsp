function [y lut] = qam_mod(x, N)

lut = qam_lut(N)

idx = bi2de(reshape(x,length(x)/N,N),'left-msb') + 1;
y = lut(idx);
