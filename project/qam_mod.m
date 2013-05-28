function [y lut x_idx] = qam_mod(x, N)

lut = qam_lut(N);

x_idx = bi2de(reshape(x,N,length(x)/N)','left-msb') + 1;
y = lut(x_idx);
