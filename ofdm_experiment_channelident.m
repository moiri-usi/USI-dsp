clear;

% enter the inputs for the experiment
rand_seq_len = input(...
    'Enter the length of the pseudo random binary sequence: ');
N = input('Enter the length of the window (2, 4 or 6): ');
snr = input('Enter the signal to noise ratio: ');
L = input('Enter the order of the channel: ');
Nn = input('Enter the number of QAM elements (3, 7, 15, ...): ');
Ncp = input('Enter the length of the cyclic prefix (Lcp >= L): ');

% generate bitstream
x = round(rand(1,rand_seq_len));

% add zeros to the end of the stream to fit a multiple of 2*(Nn+1)*N
N_t = Nn*N;
x_norm = x;
if (rem(length(x), N_t) > 0),
    x_norm = [x zeros(1, N_t-rem(length(x), N_t))];
end

% qam modulation
[y_qam lut] = qam_mod(x_norm, N);

% generate ofdm package
Nl = length(y_qam)/Nn;
y_pack_cut = reshape(y_qam, Nn, Nl);
y_pack = [zeros(1,Nl); y_pack_cut; zeros(1,Nl); flipud(conj(y_pack_cut))];

% ofdm modulation
[y_serial y_ifft] = ofdm_mod(y_pack, Ncp);

% add noise
y_n = awgn(y_serial, snr);

% add channel characteristics
coeff = randn(1,L);
y_ch = filter(coeff, 1, y_n);

% ofdm demodulation
[y_demod_ofdm y_resh y_cut] = ofdm_demod(y_ch, Nn, Nl, Ncp);

% remove redundant parts of ofdm package
y_demod_ofdm_cut = y_demod_ofdm(2:Nn+1,:);

% calculate channel coeffs
ch_f_cut = y_demod_ofdm_cut./y_pack_cut;

% calculate the average on the channel coeffs
ch_f_cut_av = sum(ch_f_cut.').'/length(ch_f_cut(1,:));

% generate channel coeffs accoring to ofdm package structure
ch_f_av = [0; ch_f_cut_av; 0; flipud(conj(ch_f_cut_av))];

% calcualte time response
ch_t = real(ifft(ch_f_av));

% add zeroes to match the coefficient length 
coeff = [coeff zeros(1,length(ch_t(:,1))-length(coeff))];

% plot the real time response and the calculated time response
subplot(2, 1, 1);
plot(coeff);
title('real time response');
subplot(2, 1, 2);
plot(ch_t);
title('calculated time response');

% compensate the channel
y_demod_comp = y_demod_ofdm_cut./repmat(ch_f_cut_av, 1, Nl);

% qam demodulation
[y y_qam_r] = qam_demod(y_demod_comp, N);

% calculate bit error rate (BER)
[bit_cnt bit_err_cnt ratio] = ber(x_norm, y);
fprintf('the bit error ratio (BER) is: %d/%d=%f\n',...
    bit_err_cnt, bit_cnt, ratio);
