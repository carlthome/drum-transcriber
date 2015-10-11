%[spectgram,f,t]=GetSpectralFeatures(signal,fs,winlength)
%or
%[mfccs]=GetSpectralFeatures(signal,fs,winlength,ncep)
%or
%[mfccs,spectgram,f,t]=GetSpectralFeatures(signal,fs,winlength,ncep)
%
%Method to calculate the spectrogram and/or speech recognition features
%(mel frequency cepstrum coefficients), for a given sound signal
%
%Usage:
%First load a sound file using wavread or similar, then use this function
%to perform feature extraction. If image or imagesc is used to display
%spectrograms or similar, users may wish to run "axis xy" to get low
%order/frequency components at the bottom of the plots.
%
%Input:
%signal=    vector containing sampled signal values
%fs=        sampling frequency of signal in Hz
%winlength= length of the analysis window in seconds
%ncep=      number of cepstral coefficients to return (including order 0)
%
%Result:
%mfccs=     matrix containing mel frequency cepstral coefficients for use
%           as features in speech recognition. Each column corresponds to
%           the cepstral coefficients of a single frame, with the zeroth
%           order coefficent at the top.
%spectgram= matrix containing intensities (squared amplitudes) of different
%           frequencies at different times for use in spectrogram plotting.
%           Each column represents one frame beginning with low frequency
%           components at the top.
%f=         A column of frequencies at which the spectrogram has been computed
%t=         A column of times at which the spectrogram has been computed
%
%References:
%this method is mostly a convenient wrapper for some slightly hacked methods
%from Daniel P. W. Ellis' rastamat-package
%(http://labrosa.ee.columbia.edu/matlab/rastamat/)
%
%Gustav Henter 2007-09-07 tested
%Gustav Henter 2008-07-08 tested
%Gustav Henter 2009-07-17 tested

function [varargout]=GetSpectralFeatures(signal,fs,winlength,varargin)

% Check that the function call matches the premissible input/output combos
if (nargin == 3) && (nargout == 3),
    calcmfccs = false;
    ncep = 1; % Set ncep to the minimum value
elseif (nargin == 4) && ((nargout == 1) || (nargout == 4)),
    calcmfccs = true;
    ncep = varargin{1};
else
    error(['Incorrect number of inputs and outputs. Run '...
        '"help GetSpectralFeatures" for valid syntax examples.']);
end

signal = real(double(signal)); % Make sure the signal is a real double

if fs <= 0
    fs = 44100; % Replace illegal fs-values with a standard sampling freq.
end

ncep = round(real(ncep(1))); % Make ncep a scalar integer
if ncep < 1,
    ncep = 1; % Set ncep to at least one
end

winlength = real(winlength(1)); % Make winlength a real scalar
if winlength*fs < ncep,
    winlength = ncep/fs; % Make the window at least ncep samples long
end

% Additional MFCC parameters
winshift = 0.5;
minfreq = 20;
maxfreq = 4000;
nbands = 30;
lifterexp = 0;
preemph = 0; % Turn off pre-emphasis

if calcmfccs,
    [mfccs,aspectrum,pspectrum] = melfcc(signal,fs,'wintime',winlength,...
        'hoptime',winlength*winshift,'numcep',ncep,'nbands',nbands,...
        'minfreq',minfreq,'maxfreq',maxfreq,'lifterexp',lifterexp,...
        'preemph',preemph);
    varargout = {mfccs};
else
    varargout = {};
end

if (nargout > 1),
    %fs*winlength,
    %fs*winlength*winshift,
    %varargout{1} = abs(spectrogram(signal,round(fs*winlength),...
    %    round(fs*winlength*winshift),round(fs*winlength),fs));
    [varargout{end+1},varargout{end+2},varargout{end+3}]...
        = powspec(signal,fs,winlength,winlength*winshift,0);
end