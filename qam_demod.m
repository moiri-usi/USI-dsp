function [y] = qam_demod(x, N)
run('lut');
M=2^N;
% round to nearest odd integer.

x = 2*fix(real(x)/2)+sign(real(x)) + (2*fix(imag(x)/2)+sign(imag(x)))*i;
max_val = 2^(N/2)-1;
min_val = -2^(N/2)+1;
x = max(real(x), min_val) + i*max(imag(x),min_val);
x = min(real(x), max_val) + i*min(imag(x),max_val);
%x = round(x);
if (M==4),
    [val idx_lut] = ismember(x,lut4);
end
if (M==16),
    [val idx_lut] = ismember(x,lut16);
end
if (M==64),
    [val idx_lut] = ismember(x,lut64);
end
y = de2bi(idx_lut-1, N,'left-msb')';
y = y(:)';
