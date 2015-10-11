function [ features, timestamps ] = read_audio( filePath )
%READ_AUDIO Extract features from audio file.
%   The audio file is segmented into 30 ms frames and MFCC is applied per
%   frame. features is a matrix containing each MFCC frame columnwise, over
%   time. timestamps is the corresponding time in seconds for the frame's
%   location in the audio file. Thus features(1) is a column vector with
%   each row a MFCC coefficient, and timestamps(1) is time zero in the
%   audio file.

% Read audio file
[samples, sampleRate] = audioread(filePath);
songLength = length(samples) / sampleRate;

% Sum stereo to mono.
mono = (samples(:, 1) + samples(:, 2)) / 2;

% TODO Reduce harmonic content with tonal supression.

% Extract MFCC from audio.
windowDuration = 0.03;
mfccCoefficients = 13;
[mfccs, fft, fftFrequencies, timestamps] = GetSpectralFeatures(mono, sampleRate, windowDuration, mfccCoefficients);

% TODO Also extract dynamic MFCC and add to features. 

features = mfccs;

% Normalize mean and variance per feature dimension.
features = bsxfun(@rdivide, bsxfun(@minus, features, mean(features, 2)), std(features, 0, 2));

end

