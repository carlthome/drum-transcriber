function [y,varargout] = powspec(x, sr, wintime, steptime, dither)
%y = powspec(x, sr, wintime, steptime, sumlin, dither)
%or
%[y,f,t] = powspec(x, sr, wintime, steptime, sumlin, dither)
%
% compute the powerspectrum of the input signal.
% basically outputs a power spectrogram
%
% each column represents a power spectrum for a given frame
% each row represents a frequency
%
% default values:
% sr = 8000Hz
% wintime = 25ms (200 samps)
% steptime = 10ms (80 samps)
% which means use 256 point fft
% hamming window
%
% Modified by Gustav Henter 2008-07-03 to use Hanning windows
% Modified by Gustav Henter 2008-07-08 to give frequency and time outputs

% for sr = 8000
%NFFT = 256;
%NOVERLAP = 120;
%SAMPRATE = 8000;
%WINDOW = hamming(200);

if nargin < 2
  sr = 8000;
end
if nargin < 3
  wintime = 0.025;
end
if nargin < 4
  steptime = 0.010;
end
if nargin < 5
  dither = 1;
end

winpts = round(wintime*sr);
steppts = round(steptime*sr);

NFFT = 2^(ceil(log(winpts)/log(2)));
%WINDOW = hamming(winpts);
WINDOW = hanning(winpts,'periodic'); % Modified by Gustav Henter 2008-07-03
NOVERLAP = winpts - steppts;
SAMPRATE = sr;

% Values coming out of rasta treat samples as integers, 
% not range -1..1, hence scale up here to match (approx)
if nargout > 1
  [b,varargout{1},varargout{2}]...
      = specgram(x*32768,NFFT,SAMPRATE,WINDOW,NOVERLAP);
  y = abs(b).^2;
else
  y = abs(specgram(x*32768,NFFT,SAMPRATE,WINDOW,NOVERLAP)).^2;
end

% imagine we had random dither that had a variance of 1 sample 
% step and a white spectrum.  That's like (in expectation, anyway)
% adding a constant value to every bin (to avoid digital zero)
if (dither)
  y = y + winpts;
end
% ignoring the hamming window, total power would be = #pts
% I think this doesn't quite make sense, but it's what rasta/powspec.c does

% that's all she wrote
