clear;

rand_seq_len = input('Enter the length of the pseudo random binary sequence: ');
N = input('Enter the length of the window: ');
snr = input('Enter the signal to noise ratio: ');
%snr = inf;
L = input('Enter the order of the channel: ');
Nn = input('Enter the number of QAM elements (3, 7, 15, ...): ');
Ncp = input('Enter the length of the cyclic prefix (Lcp >= L): ');
Nl = input('Enter the size of the data packages Nl > 10: ');

% generate data stream
x = round(rand(1,rand_seq_len));

% add zeros to the end of the stream
x_norm = x;
if (rem(length(x),N) > 0),
    x_norm = [x zeros(1,N-rem(length(x),N))];
end
% add zeros to the end of the stream to fit a multiple of 2*(Nn+1)*N
N_t = Nn*N;
if (rem(length(x),N_t) > 0),
    x_norm = [x_norm zeros(1,N_t-rem(length(x_norm),N_t))];
end

% generate training package
Nt = round(Nl/10);
x_train = round(rand(1, Nt*Nn*N));
y_qam_train = qam_mod(x_train, N);

y_pack_train_cut = reshape(y_qam_train, Nn, Nt);
y_pack_train = [zeros(1,Nt); y_pack_train_cut; zeros(1,Nt); flipud(y_pack_train_cut.'')];

% generate data packages
[y_qam lut] = qam_mod(x_norm, N);
Nl = length(y_qam)/Nn;
y_pack_cut = reshape(y_qam, Nn, Nl);
y_pack = [zeros(1,Nl); y_pack_cut; zeros(1,Nl); flipud(y_pack_cut.'')];

[y_serial y_ifft] = ofdm_mod(y_pack, Ncp);

y_n = awgn(y_serial, snr);

% coeff = use values from exercise 2-2 2-3
coeff = randn(1,L);
y_ch = filter(coeff, 1, y_n);

[y_demod_ofdm y_resh y_cut] = ofdm_demod(y_ch, Nn, Nl, Ncp);

y_demod_ofdm_cut = y_demod_ofdm(2:Nn+1,:);

ch_f_cut = y_demod_ofdm_cut./y_pack_cut;

ch_f = [zeros(1,Nl); ch_f_cut; zeros(1,Nl); flipud(ch_f_cut.'')];

ch_f_av = sum(ch_f.').'/length(ch_f(1,:));

ch_t = ifft(ch_f_av);

coeff = [coeff zeros(1,length(ch_t(:,1))-length(coeff))];
subplot(2, 1, 1);
plot(coeff);
subplot(2, 1, 2);
plot(ch_t);