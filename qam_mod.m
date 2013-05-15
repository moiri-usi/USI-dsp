function [y lut x] = qam_mod(x, N)
run('lut');
M = 2^N;
% add zeros to the end of the stream
if (rem(length(x),N) > 0),
    x = [x zeros(1,N-rem(length(x),N))];
end

y = zeros(1, length(x)/N-1);
l = 1;
for k=1:N:length(x)
    if M == 4,
        c = lut4(bi2de(x(k:k+N-1),'left-msb')+1);
        lut = lut4;
    end
    if M == 16,
        c = lut16(bi2de(x(k:k+N-1),'left-msb')+1);
        lut = lut16;
    end
    if M == 64,
        c = lut64(bi2de(x(k:k+N-1),'left-msb')+1);
        lut = lut64;
    end
    y(l) = c;
    l = l+1;
end
