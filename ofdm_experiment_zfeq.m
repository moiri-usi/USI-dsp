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

% add the training package to the stream
num_row = Ns_pack;
num_col = length(x_norm)/num_row;
x_r_norm = reshape(x_norm, num_row, num_col);
x_t_norm = repmat(x_train', 1, num_col);
x_rt_norm = [x_t_norm; x_r_norm];
x_rt_norm = x_rt_norm(:)';

% qam modulation
[y_qam lut] = qam_mod(x_rt_norm, N);

% generate data packages
Nf_tot = length(y_qam)/Nn;  % number of total frames
Np_tot = Nf_tot/(Nt+Nl);
y_pack_cut = reshape(y_qam, Nn, Nf_tot);
y_pack = [zeros(1,Nf_tot); y_pack_cut; zeros(1,Nf_tot);...
    flipud(conj(y_pack_cut))];
y_pack_train = y_pack_cut(:, 1:Nt);

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
y_demod_ofdm_cut = y_demod_ofdm(2:Nn+1,:);          % Nn by Np_tot*(Nt+Nl)

% reshape received packages
y_dor = reshape(permute(...
    reshape(y_demod_ofdm_cut, Nn, Nt+Nl, []), [1 3 2]), [], Nt+Nl);
y_dor_t = y_dor(:, 1:Nt);                           % Nt by Np_tot*Nn
y_dor_l = y_dor(:, Nt+1:end);                       % Nl by Np_tot*Nn

% calculate channel coeffs
ch_f_dor = y_dor_t./repmat(y_pack_train, Np_tot, 1);% Nt by Np_tot*Nn

% calculate the average on the channel coeffs
ch_f_dor_av = sum(ch_f_dor.').'/Nt;                 % 1 by Np_tot*Nn

% compensate the channel
y_dor_comp = y_dor_l./repmat(ch_f_dor_av, 1, Nl);   % Nl by Np_tot*Nn

% reshape package
y_comp = reshape(permute(...                        % Nn by Np_tot*Nl
    reshape(y_dor_comp, Nn, [], Nl), [1 3 2]), Nn, []);

% qam demodulation
[y y_qam_r] = qam_demod(y_comp, N);

% calculate bit error rate (BER)
[bit_cnt bit_err_cnt ratio] = ber(x_norm, y);
fprintf('the bit error ratio (BER) is: %d/%d=%f\n',...
    bit_err_cnt, bit_cnt, ratio);
