% set parameter 
%%%%%%%%%%%%%%%%
snr = input('Enter the signal to noise ratio: ');
fs = 16000; % sampling frequency
t_sim = 5;  % simulation time (measure frequency missmatch and noise)
Nt = 5;     % number of training frames per package
Nl = 20;    % number of data frames per package
M = 6;      % QAM constellation order

% measure sampling ferquency missmatch
% measure noise
% measure respons time (order)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prepare input signal
% t_arr = 0:1/fs:t_sim;
% x = zeros(1,fs*t_sim+1);
% x(fs*2) = 1;
% x(fs*3) = 1;
% data_in = [t_arr' x'];
% 
% % run test
% sim('audio_io.mdl');
%  
% %data_out = acoustic_channel_tv(data_in);
% % calculate frequency delta
% [delta_f noise_lvl resp_time] = get_ch_prop(data_out, fs);
% L = length(resp_time);      % estimation of the order of the channel
L = 100;
Nn = 2^ceil(log2(L)) - 1;   % calculation of number of elements per frame
Ncp = L + 10;               % calculation of cyclic prefix size

% get bitstream from input file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img_in = imread('img/image_in.jpg');
[img_row img_col img_color] = size(img_in);
img_bin_in = de2bi(img_in, 8);
x = img_bin_in(:);

% normalize bitstream (add zeroes)
Ns_pack = Nn*M*Nl;
x_norm = x;
zero_count = Ns_pack-rem(length(x), Ns_pack);
if (rem(length(x), Ns_pack) > 0),
    x_norm = [x' zeros(1, zero_count)];
end

% generate training stream
Ns_train = Nt*Nn*M;
x_train = round(rand(1, Ns_train));

% qam modulation of data stream
[y_qam_l lut] = qam_mod(x_norm, M);

% qam modulation of training stream
[y_qam_t lut] = qam_mod(x_train, M);

% generation of ofdm package
Np_tot = length(y_qam_l)/(Nn*Nl);       % number of total packages
Nf_tot = Np_tot*(Nt+Nl);                % number of total frames
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
[data_in y_ifft] = ofdm_mod(y_pack, Ncp);

% send through the channel
%sim('audio_io.mdl');
%data_out = acoustic_channel_tv(data_in);

% add noise
y_n = awgn(data_in, snr);

% add channel characteristics
coeff = randn(1,L);
data_out = filter(coeff, 1, y_n);

% ofdm demodulation
[y_demod_ofdm y_resh y_cut] = ofdm_demod(data_out, Nn, Nl, Ncp);

% equalize
y_comp = eq_zf(y_demod_ofdm, y_block_t, Nn, Nt, Nl);

% qam demodulation
[y y_qam_r] = qam_demod(y_comp, M);

% calculate bit error rate (BER)
[bit_cnt bit_err_cnt ratio] = ber(x_norm, y);
fprintf('the bit error ratio (BER) is: %d/%d=%f\n',...
    bit_err_cnt, bit_cnt, ratio);

y_final = y(1:end-zero_count);

% calculate symbol error rate (SER)
[symb_cnt symb_err_cnt ratio] = ser(y_qam_l.', y_qam_r(:));
fprintf('the symbol error ratio (SER) is: %d/%d=%f\n',...
    symb_err_cnt, symb_cnt, ratio);



% save bitstream to output file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img_bin_out = reshape(x, [], 8);
img_dec_out = bi2de(img_bin_out);
img_res_out = reshape(img_dec_out, img_row, img_col, img_color);
imwrite(img_res_out, 'img/image_out.jpg');
