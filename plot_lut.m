function [] = plot_lut(lut)

M = length(lut);
scatter(real(lut), imag(lut), 'filled');
grid on;
ax = sqrt(M);
axis([-ax ax -ax ax]);
for k=1:M
    text(real(lut(k)), imag(lut(k)), dec2bin(k-1,log2(M)),...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'middle');
end
title('Scatter plot');
xlabel('In-Phase');
ylabel('Quadrature');
