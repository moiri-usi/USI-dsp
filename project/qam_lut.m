function [lut] = qam_lut(N)
lut = 0;
if rem(N,2) == 0,
    for k=0:N/2-1
        const = 2^k;
        lut = [((real(lut)-const) + (imag(lut)+const)*i)...
               ((real(lut)-const) - (imag(lut)+const)*i)...
               (-(real(lut)-const) + (imag(lut)+const)*i)...
               (-(real(lut)-const) - (imag(lut)+const)*i)];
    end
else
    fprintf('Not possible to compute lut, N must be even\n');
end
