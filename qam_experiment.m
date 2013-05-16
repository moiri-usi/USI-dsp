clear;

rand_seq_len = input('Enter the length of the pseudo random binary sequence: ');
N = input('Enter the length of the window: ');
snr = input('Enter the signal to noise ratio: ');
x = round(rand(1,rand_seq_len));
[y lut x] = qam_mod(x, N);

subplot(2,1,1);
scatter(real(y),imag(y));
ax = 2^(N/2);
axis([-ax ax -ax ax]);
grid on;
title('QAM');
for k=1:length(lut)
    text(real(lut(k)), imag(lut(k)), dec2bin(k-1,6), 'horizontal', 'left', 'vertical', 'bottom');
end

y_n = awgn(y, snr);

subplot(2,1,2);
scatter(real(y_n),imag(y_n));
axis([-ax ax -ax ax]);
grid on;
title('QAM with noise');
for k=1:length(lut)
    text(real(lut(k)), imag(lut(k)), dec2bin(k-1,6), 'horizontal', 'left', 'vertical', 'bottom');
end

y_demod = qam_demod(y_n, N);

[bit_cnt bit_err_cnt ratio] = ber(x, y_demod);
fprintf('the bit error ratio (BER) is: %d/%d=%d\n', bit_err_cnt, bit_cnt, ratio);