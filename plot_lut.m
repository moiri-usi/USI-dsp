function plot_lut(lut, plot_title, N, plot_text)

len = length(lut);
M = 2^N;
dot_style = 'white';
if plot_text == 0,
    dot_style = 'filled';
end
scatter(real(lut), imag(lut), dot_style);
grid on;
ax = sqrt(M);
axis([-ax ax -ax ax]);
if plot_text==1,
    for k=1:len
        text(real(lut(k)), imag(lut(k)), dec2bin(k-1, N),...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle');
    end
end
title(plot_title);
xlabel('In-Phase');
ylabel('Quadrature');
