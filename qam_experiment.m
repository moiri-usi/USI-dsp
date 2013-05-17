clear;

rand_seq_len = input('Enter the length of the pseudo random binary sequence: ');
N = input('Enter the length of the window: ');
snr = input('Enter the signal to noise ratio: ');
x = round(rand(1,rand_seq_len));

% add zeros to the end of the stream
x_norm = x;
if (rem(length(x),N) > 0),
    x_norm = [x zeros(1,N-rem(length(x),N))];
end

[y_mod lut] = qam_mod(x_norm, N);

subplot(2,1,1);
scatter(real(y_mod), imag(y_mod));
ax = 2^(N/2);
axis([-ax ax -ax ax]);
grid on;
title('QAM');
for k=1:length(lut)
    text(real(lut(k)), imag(lut(k)), dec2bin(k-1,6), 'horizontal', 'left', 'vertical', 'bottom');
end

y_n_mod = awgn(y_mod, snr);

subplot(2,1,2);
scatter(real(y_n_mod),imag(y_n_mod));
axis([-ax ax -ax ax]);
grid on;
title('QAM with noise');
for k=1:length(lut)
    text(real(lut(k)), imag(lut(k)), dec2bin(k-1,6), 'horizontal', 'left', 'vertical', 'bottom');
end

[y y_n_mod_r] = qam_demod(y_n_mod, N);

[bit_cnt bit_err_cnt ratio] = ber(x_norm, y);
fprintf('the bit error ratio (BER) is: %d/%d=%d\n', bit_err_cnt, bit_cnt, ratio);