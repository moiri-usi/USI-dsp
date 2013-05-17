function [y lut] = qam_mod(x, N)
run('lut');
M = 2^N;

if M == 4,
    lut = lut4;
end
if M == 16,
    lut = lut16;
end
if M == 64,
    lut = lut64;
end

idx = bi2de(reshape(x,length(x)/N,N),'left-msb') + 1;
y = lut(idx);