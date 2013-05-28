function y = eq_zf(x, x_t, Nn, Nt, Nl)
% remove redundant parts of ofdm package
y_demod_ofdm_cut = x(2:Nn+1,:);                     % Nn by Np_tot*(Nt+Nl)

% reshape received packages
y_dor = reshape(permute(...
    reshape(y_demod_ofdm_cut, Nn, Nt+Nl, []), [1 3 2]), [], Nt+Nl);
y_dor_t = y_dor(:, 1:Nt);                           % Nt by Np_tot*Nn
y_dor_l = y_dor(:, Nt+1:end);                       % Nl by Np_tot*Nn

% calculate channel coeffs
ch_f_dor = y_dor_t./x_t;                            % Nt by Np_tot*Nn

% calculate the average on the channel coeffs
ch_f_dor_av = sum(ch_f_dor.').'/Nt;                 % 1 by Np_tot*Nn

% compensate the channel
y_dor_comp = y_dor_l./repmat(ch_f_dor_av, 1, Nl);   % Nl by Np_tot*Nn

% reshape package
y = reshape(permute(...                             % Nn by Np_tot*Nl
    reshape(y_dor_comp, Nn, [], Nl), [1 3 2]), Nn, []);
