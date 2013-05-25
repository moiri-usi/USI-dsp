clear;

rand_seq_len = input(...
    'Enter the length of the pseudo random binary sequence: ');
N = input('Enter the length of the window (2, 4 or 6): ');
snr = input('Enter the signal to noise ratio: ');
L = input('Enter the order of the channel: ');
Nn = input('Enter the number of QAM elements (3, 7, 15, ...): ');
Ncp = input('Enter the length of the cyclic prefix (Lcp >= L): ');
% use values from ex 2-2, 2-3
%load_stc = load('ch_resp_time.mat');
%coeff = get_resptime(load_stc.x_out, 0.9);
%Ncp = length(coeff) + 5;

% generate the bitstream
x = round(rand(1,rand_seq_len));

% add zeros to the end of the stream to fit a multiple of 2*(Nn+1)*N
N_t = Nn*N;
if (rem(length(x),N_t) > 0),
    x_norm = [x zeros(1,N_t-rem(length(x),N_t))];
end

% qam modulation
[y_qam lut] = qam_mod(x_norm, N);

% generate ofdm package
Nl = length(y_qam)/Nn;
y_pack = reshape(y_qam, Nn, Nl);
y_pack = [zeros(1,Nl); y_pack; zeros(1,Nl); flipud(conj(y_pack))];

% ofdm modulation
[y_serial y_ifft] = ofdm_mod(y_pack, Ncp);

% add noise
y_n = awgn(y_serial, snr);

% add channel characteristics
coeff = randn(1, L);
y_ch = filter(coeff, 1, y_n);

% ofdm demodulation
[y_demod_ofdm y_resh y_cut] = ofdm_demod(y_ch, Nn, Nl, Ncp);

% remove redundant parts of ofdm package
y_demod_ofdm_cut = y_demod_ofdm(2:Nn+1,:);

% qam demodulation
[y y_qam_r] = qam_demod(y_demod_ofdm_cut, N);

% calculate bit error rate (BER)
[bit_cnt bit_err_cnt ratio] = ber(x_norm, y);
fprintf('the bit error ratio (BER) is: %d/%d=%f\n',...
    bit_err_cnt, bit_cnt, ratio);
