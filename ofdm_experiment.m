clear;

rand_seq_len = input('Enter the length of the pseudo random binary sequence: ');
N = input('Enter the length of the window (2, 4 or 6): ');
Nn = input('Enter the number of QAM elements (3, 7, 15, ...): ');
Ncp = input('Enter the length of the cyclic prefix (Lcp >= L): ');

x = round(rand(1,rand_seq_len));

% add zeros to the end of the stream to fit a multiple of N
x_norm = x;
if (rem(length(x),N) > 0),
    x_norm = [x zeros(1,N-rem(length(x),N))];
end
% add zeros to the end of the stream to fit a multiple of 2*(Nn+1)*N
N_t = Nn*N;
if (rem(length(x),N_t) > 0),
    x_norm = [x_norm zeros(1,N_t-rem(length(x_norm),N_t))];
end

[y_qam lut] = qam_mod(x_norm, N);

Nl = length(y_qam)/Nn;

y_pack = reshape(y_qam, Nn, Nl);
y_pack = [zeros(1,Nl); y_pack; zeros(1,Nl); flipud(conj(y_pack))];

[y_serial y_ifft] = ofdm_mod(y_pack, Ncp);

y_demod_ofdm = ofdm_demod(y_serial, Nn, Nl, Ncp);
y_demod_ofdm_cut = y_demod_ofdm(2:Nn+1,:);
[y y_qam_r y_idx_lut] = qam_demod(y_demod_ofdm_cut, N);

[bit_cnt bit_err_cnt ratio] = ber(x_norm, y);
fprintf('the bit error ratio (BER) is: %d/%d=%d\n', bit_err_cnt, bit_cnt, ratio);
