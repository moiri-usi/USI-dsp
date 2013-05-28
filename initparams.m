clear;

fs = input('Enter the sampling rate in Hz: '); %
t_sim = input('Enter the simulation time in s: '); %
%f_sig = input('Enter the signal frequency in Hz: '); %
%t_q_speaker = input('Enter the queue duration of the speaker in s: '); %1.0
%t_q_micro = input('Enter the queue duration of the micro in s: '); %1.0
%ch_cnt = input('Enter the number of channels of the micro: '); %2
%fr_size = input('Enter the frame size of the micro: '); %1024

t_arr = 0:1/fs:t_sim;
% EXERCISE 1-1
% x = sin(2*pi*100*t_arr);

% EXERCISE 1-2
% x1 = sin(2*pi*50*t_arr);
% x2 = sin(2*pi*100*t_arr);
% x3 = sin(2*pi*200*t_arr);
% x4 = sin(2*pi*500*t_arr);
% x5 = sin(2*pi*1000*t_arr);
% x6 = sin(2*pi*2000*t_arr);
% x7 = sin(2*pi*4000*t_arr);
% x8 = sin(2*pi*6000*t_arr);
% x = x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8;

% EXERCISE 2-1
x = zeros(1,fs*t_sim);
x(fs*2) = 1;
x(fs*3) = 1;

data_in = [t_arr' x'];

sim('audio_io.mdl');

n = pow2(nextpow2(length(x)));
y = abs(fft(x,n)).^2/length(x)/fs;
f = (0:n-1)*(fs/n);

% Hpsd = dspdata.psd(y(1:length(y)/2),'fs',fs);
subplot(2,2,1)
% plot(Hpsd)
% axis([0,8,-50,2])
% title('Input')
% xlabel('Frequency (kHz)')
% ylabel('Power')
plot(x)
title('Input')
xlabel('time (s)')
ylabel('amplitude')

x_out = double(data_out);
% n_out = pow2(nextpow2(length(x_out)));
% y_out = abs(fft(x_out,n_out)).^2/length(x_out)/fs;
% f_out = (0:n_out-1)*(fs/n_out);
% Hpsd_out = dspdata.psd(y_out(1:length(y_out)/2),'fs',fs);
subplot(2,2,2)
% plot(Hpsd_out)
% axis([0,8,-50,2])
% title('Output')
% xlabel('Frequency (kHz)')
% ylabel('Power')
plot(x_out)
title('Output')
xlabel('time (s)')
ylabel('amplitude')

[S,F,T,P] = spectrogram(x,256,250,256,fs);
subplot(2,2,3)
surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
view(0,90);
xlabel('Time (Seconds)'); ylabel('Hz');
title('Input Spectrogram')

[S,F,T,P] = spectrogram(x_out,256,250,256,fs);
subplot(2,2,4)
surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
view(0,90);
xlabel('Time (Seconds)'); ylabel('Hz');
title('Output Spectrogram')