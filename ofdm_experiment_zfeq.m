clear;

% enter the inputs for the experiment
Ns = input('Enter the length of the pseudo random binary sequence: ');
N = input('Enter the length of the window (2, 4 or 6): ');
snr = input('Enter the signal to noise ratio: ');
L = input('Enter the order of the channel: ');
Nn = 2^ceil(log2(L)) - 1;
Ncp = L + 1;
Nl = input('Enter the number of frames per data package: ');
Nt = input('Enter the number of training frames per data packages: ');

% generate data stream
x = round(rand(1, Ns));

% generate training stream
Ns_train = Nt*Nn*N;
x_train = round(rand(1, Ns_train));

% add zeros to the end of the stream to fit a multiple of data packages
Ns_pack = Nn*N*Nl;
x_norm = x;
if (rem(length(x), Ns_pack) > 0),
    x_norm = [x zeros(1, Ns_pack-rem(length(x), Ns_pack))];
end

% qam modulation of training stream
[y_qam_t lut] = qam_mod(x_train, N);

% qam modulation of data stream
[y_qam_l lut] = qam_mod(x_norm, N);

% generate data package
Np_tot = length(y_qam_l)/(Nn*Nl);   % number of total packages
Nf_tot = Np_tot*(Nt+Nl);            % number of total frames
y_fram_t = reshape(y_qam_t, Nn, []);    % consecutive training frames
y_fram_l = reshape(y_qam_l, Nn, []);    % consecutive data frames
y_block_l = reshape(permute(...
    reshape(y_fram_l, Nn, Nl, []), [1 3 2]), [], Nl);
y_block_t = repmat(y_fram_t, Np_tot, 1);
y_block_tl = [y_block_t y_block_l];
y_pack_cut = reshape(permute(...        % consecutive packages
    reshape(y_block_tl, Nn, [], Nt+Nl), [1 3 2]), Nn, []);
y_pack = [zeros(1,Nf_tot); y_pack_cut; zeros(1,Nf_tot);...
    flipud(conj(y_pack_cut))];          % consecutive packages ofdm

% ofdm modulation
[y_serial y_ifft] = ofdm_mod(y_pack, Ncp);

% add noise
y_n = awgn(y_serial, snr);

% add channel characteristics
coeff = randn(1,L);
y_ch = filter(coeff, 1, y_n);

% ofdm demodulation
[y_demod_ofdm y_resh y_cut] = ofdm_demod(y_ch, Nn, Nl, Ncp);

% equalize the received signal with the zero forced equalizer
y_comp = eq_zf(y_demod_ofdm, y_block_t, Nn, Nt, Nl);

% qam demodulation
[y y_qam_r] = qam_demod(y_comp, N);

% calculate bit error rate (BER)
[bit_cnt bit_err_cnt ratio] = ber(x_norm, y);
fprintf('the bit error ratio (BER) is: %d/%d=%f\n',...
    bit_err_cnt, bit_cnt, ratio);

% calculate symbol error rate (SER)
[symb_cnt symb_err_cnt ratio] = ser(y_qam_l.', y_qam_r(:));
fprintf('the symbol error ratio (SER) is: %d/%d=%f\n',...
    symb_err_cnt, symb_cnt, ratio);

% plot the qam
subplot(2,2,1);
plot_lut(lut, 'QAM', N, 1);

% plot the modulated data
subplot(2,2,2);
plot_lut(y_qam_l, 'Data Set', N);

% plot the modulated data with noise
subplot(2,2,3);
plot_lut(y_comp, 'Data Set with noise', N);

% plot the modulated data with noise assigned
subplot(2,2,4);
plot_lut(y_qam_r, 'Data Set assigned', N);
