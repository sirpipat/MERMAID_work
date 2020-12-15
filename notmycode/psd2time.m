function PY = psd2time(f,Sf,d,fs,M)
% PY = PSD2TIME(f,Sf,d,fs,M)
%
% Converts power spectral density to time-series data
%
% INPUT
% f             discrete frequencies
% Sf            line spectrum at f
% d             duration
% fs            sampling rate
% M             number of experiments
%
%
% Last modified by Sirawich Pipatprathanporn, 11/16/2020

% Number of experiment
defval('M',20);
% duration
defval('d',10);
% Number of times samples
defval('fs',100);
N = d*fs+1;
t=linspace(0,d,N);
% Discrete frequencies
defval('f',[1 2 3 4 5 6 7 8]);
% Spectral density at these frequencies
defval('Sf',[1 2 3 4 4 3 2 1]);

% Random amplitudes
af=randn(M,length(f)).*repmat(sqrt(Sf),M,1);
% These would be deterministic, always takinh the same 
% af=repmat(sqrt(Sf),M,1);
% Phase-randomized Fourier series with these amplitudes
y=[af*sin(2*pi*f'*t+2*pi*repmat(rand(length(f),1),1,length(t)))]';

% MATLAB Fourier transform
Y=fft(y);

% Properly index and make sure that power is not lost from taking half of
% the frequencies
Y=Y(1:floor(size(Y,1)/2),:) * sqrt(2);

% Direct sepctral estimater of Walden and Perceval (206c) without any
% window. Equal to the periodogram.
PY=abs(Y).^2 / fs / N;

% Frequencies for psd
F = ((1:size(PY,1))'-1)/d;

% With fudged normalizations
Sfest=   mean(PY,   2);
Sfmin=prctile(PY, 5,2);
Sfmax=prctile(PY,95,2);

subplot(211)
plot(t,y(:,1:min(5,M)))
xlabel('time [s]')
ylabel('signal')
% Verify Parseval
% this never gives an error
diferm(var(y,1),sum(PY,1)/d,-log10(0.05*rms(var(y,1))));
title(sprintf('signal rms %8.3f vs scaled power %8.3f',...
	      rms(rms(y')),sqrt(sum(Sf))*sqrt(2)/2))

subplot(212)
semilogy(F,Sfest,'b')
hold on
% semilogy(F,Sfmin,'r')
% semilogy(F,Sfmax,'g')
% plot the input spectral density
semilogy(f,Sf,'ko')
hold off
xlim([0 1])
%ylim(10.^[-5 5])
xlabel('frequency (Hz)')
ylabel('power spectral density')


