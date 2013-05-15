clear;

rand_seq_len = input('Enter the length of the pseudo random binary sequence: ');
N = input('Enter the length of the window: ');
snr = input('Enter the signal to noise ratio: ');
Nn = input('Enter the number of QAM elements : ');
Nl = input('Enter the number of QAM frames : ');
Ncp = input('Enter the length of the cyclic prefix : ');

x = round(rand(1,rand_seq_len));
[y lut x] = qam_mod(x, N);

if (Nl*Nn <= rand_seq_len),
    y_frame = y(1:Nl*Nn);
    y_pack = reshape(y_frame, Nn, Nl);
    y_pack = [zeros(1,Nl); y_pack; zeros(1,Nl); flipud(y_pack.'')];
else
   error('the input stream is too small for the requested QAM elements');
end

y_serial = ofdm_mod(y_pack, Ncp);

y_demod = ofdm_demod(y_serial, Nn, Nl, Ncp);

[bit_cnt bit_err_cnt ratio] = ber(y_pack, y_demod);
fprintf('the bit error ratio (BER) is: %d/%d=%d\n', bit_err_cnt, bit_cnt, ratio);