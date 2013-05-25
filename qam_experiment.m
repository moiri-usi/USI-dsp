clear;

% enter experimant data
rand_seq_len = input(...
    'Enter the length of the pseudo random binary sequence: ');
N = input('Enter the length of the window: ');
snr = input('Enter the signal to noise ratio: ');
x = round(rand(1,rand_seq_len));

% add zeros to the end of the stream
x_norm = x;
if (rem(length(x),N) > 0),
    x_norm = [x zeros(1,N-rem(length(x),N))];
end

% modulate
[y_mod lut x_idx] = qam_mod(x_norm, N);

% plot the qam
subplot(1,3,1);
plot_lut(lut, 'QAM', N, 1);

% plot the modulated data
subplot(1,3,2);
plot_lut(y_mod, 'Data Set', N);

% add noise
y_n_mod = awgn(y_mod, snr);

% plot the modulated data with noise
subplot(1,3,3);
plot_lut(y_n_mod, 'Data Set with noise', N);

% demodulate
[y y_n_mod_r y_idx] = qam_demod(y_n_mod, N);

% calculate bit error rate (BER)
[bit_cnt bit_err_cnt ratio] = ber(x_norm, y);
fprintf('the bit error ratio (BER) is: %d/%d=%f\n',...
    bit_err_cnt, bit_cnt, ratio);
