clear;

rand_seq_len = input('Enter the length of the pseudo random binary sequence: ');
N = input('Enter the length of the window: ');
%snr = input('Enter the signal to noise ratio: ');
snr = inf;
L = input('Enter the order of the channel: ');
Nn = input('Enter the number of QAM elements (3, 5, 9, 17, ...): ');
Nl = input('Enter the number of QAM frames: ');
Ncp = input('Enter the length of the cyclic prefix (Lcp >= L): ');

x = round(rand(1,rand_seq_len));
[y_mod lut x] = qam_mod(x, N);

if (Nl*Nn*N <= rand_seq_len),
    y_frame = y_mod(1:Nl*Nn);
    y_pack = reshape(y_frame, Nn, Nl);
    y_pack = [zeros(1,Nl); y_pack; zeros(1,Nl); flipud(y_pack.'')];
else
   error('the input stream is too small for the requested QAM elements');
end

[y_serial y_ifft] = ofdm_mod(y_pack, Ncp);

y_n = awgn(y_serial, snr);

y_ch = filter(randn(1,L),1 ,y_n);

[y_demod_ofdm y_resh y_cut] = ofdm_demod(y_n, Nn, Nl, Ncp);

y_demod_ofdm_cut = y_demod_ofdm(2:Nn+1,:);

y = qam_demod(y_demod_ofdm_cut, N);

[bit_cnt bit_err_cnt ratio] = ber(x(1:N*Nl*Nn), y);
fprintf('the bit error ratio (BER) is: %d/%d=%d\n', bit_err_cnt, bit_cnt, ratio);