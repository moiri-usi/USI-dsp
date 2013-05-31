clear;
% set parameter 
%%%%%%%%%%%%%%%%
Nt = 7;          % number of training frames per package
Nl = 90;         % number of data frames per package
M = 4;           % QAM constellation order

% % parameters for channel 1
% fs = 16000;      % sampling frequency
% t_sim = 5;       % simulation time (measure frequency missmatch and noise)
% t_delay = 2*fs;  % aprroximate delay of channel (in elements)
% t_init = 4*fs;   % initial sequence to be able to ignore simuling effects

% % parameters for channel 2
Ncp = 60;                     % calculation of cyclic prefix size
Nn = 2^ceil(log2(Ncp)) - 1;   % calculation of number of elements per frame

% % parameters for channel 3
% snr = input('Enter the signal to noise ratio: ');

% % This part is used to measure channel parameters before the signal is transmitted
% % it works reasonably well in case of the channel 1
% % (measure sampling ferquency missmatch, noise and respons time (order))
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
% Ncp = length(resp_time)+5;  % estimation of the order of the channel

% preare streams
%%%%%%%%%%%%%%%%%

% get bitstream from input file
img_in = imread('img/image_in_blank.bmp');
[img_row, img_col, img_color] = size(img_in);
img_bin_in = de2bi(img_in, 8);
x = img_bin_in(:);

% normalize bitstream (add zeroes)
% % this was a try to add a symbol at the end of the image (for more comments see report)
% rem_M = rem(length(x),M);
% zero_M = zeros(1, M*ceil(rem_M/M)-rem_M);
% x_norm_M = [x' zero_M [1 1] zeros(1, M-2)];
x_norm_M = x';
Ns_pack = Nn*M*Nl;
rem_Ns_pack = rem(length(x_norm_M), Ns_pack);
zero_Ns_pack = zeros(1, Ns_pack*ceil(rem_Ns_pack/Ns_pack)-rem_Ns_pack);
x_norm = [x_norm_M zero_Ns_pack];

% generate training stream
Ns_train = Nt*Nn*M;
x_train = round(rand(1, Ns_train));

% qam modulation
%%%%%%%%%%%%%%%%%

% qam modulation of data stream
[y_qam_l, lut_t] = qam_mod(x_norm, M);

% qam modulation of training stream
[y_qam_t, lut] = qam_mod(x_train, M);

% ofdm modulation
%%%%%%%%%%%%%%%%%%

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

for k=0:Np_tot-1,
    % ofdm modulation
    y_single_pack = y_pack(:,k*(Nt+Nl)+1:(k+1)*(Nt+Nl));
    [y_ofdm, y_ifft] = ofdm_mod(y_single_pack, Ncp);

    % transmission of the data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % chose one of the three different channel types:

    % 1. real acoustic channel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % prepare signal to transmit
    % y_ofdm_z = [zeros(1, t_init) y_ofdm zeros(1, t_delay)];
    % t_sim = (length(y_ofdm_z)-1)/fs;
    % t_arr = 0:1/fs:t_sim;
    % data_in = [t_arr' y_ofdm_z'];

    % % send through the channel
    % sim('audio_io.mdl');

    % get the actual signal
    % n_lvl_max = max(data_out(t_init:t_init+t_delay/2));
    % data_idx_max = find(data_out(t_init:end) > 3*n_lvl_max);
    % n_lvl_min = min(data_out(t_init:t_init+t_delay/2));
    % data_idx_min = find(data_out(t_init:end) < 3*n_lvl_min);
    % data_out_cut = data_out(t_init+min(data_idx_max(1),data_idx_min(1)):...
    %     t_init+max(data_idx_max(end),data_idx_min(end)));
    % 
    % % adapt due to frequency difference
    % data_out_cut = data_out_cut(1:length(y_ofdm));

    % 2. time variant simulated acoustic channel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % send through the channel
    data_out_cut = acoustic_channel_tv(y_ofdm');

    % 3. simple simulated random channel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % add noise
    % y_n = awgn(y_ofdm, inf);
    % 
    % % add channel characteristics
    % coeff = randn(1,L);
    % data_out_cut = filter(coeff, 1, y_n);

    % ofdm demodulation
    %%%%%%%%%%%%%%%%%%%%
    [y_demod_ofdm, y_resh, y_cut] = ofdm_demod(data_out_cut, Nn, Nl, Ncp);

    % equalize
    y_comp(:,k*Nl+1:(k+1)*Nl) = eq_mmse_loop(y_demod_ofdm, y_fram_t, Nn, Nt, Nl);
end

% qam demodulation
%%%%%%%%%%%%%%%%%%%
[y, y_qam_r] = qam_demod(y_comp, M);

% quality of the transmission
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate bit error rate (BER)
[bit_cnt, bit_err_cnt, ratio] = ber(x_norm, y);
fprintf('the bit error ratio (BER) is: %d/%d=%f\n',...
    bit_err_cnt, bit_cnt, ratio);

% calculate symbol error rate (SER)
[symb_cnt, symb_err_cnt, ratio] = ser(y_qam_l.', y_qam_r(:));
fprintf('the symbol error ratio (SER) is: %d/%d=%f\n',...
    symb_err_cnt, symb_cnt, ratio);

% save bitstream to output file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove the zeroes at the end (used to normalize the input)
% here the transmitted image size must be known
y_final=y(1:img_row*img_col*img_color*8);

% % this is a try to handle it without knowing the image size by adding a known symbol
% % at the end, followed by the normalization zeros. It does not work because the symbol
% % must be aligned with the qam constallation number M -> some random number of zeros is
% % added between the image and the spezial symbol. To reconstruct the image (see below) in
% % any case, the image size must be known here at the receiver
% y_end_idx = find(bi2de(reshape(y, M, [])', 'left-msb')>(2^(M-1)+2^(M-2)-1));
% y_final = y(1:(y_end_idx(end)-1)*M);
img_bin_out = reshape(y_final, [], 8);
img_dec_out = bi2de(img_bin_out);
img_res_out = reshape(img_dec_out, img_row, img_col, img_color);
imwrite(uint8(img_res_out), 'img/image_out.bmp');

