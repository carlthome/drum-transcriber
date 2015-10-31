function [features, timestamps] = read_audio(filePath)
%READ_AUDIO Extract features from audio file.
%   The audio file is segmented into 30 ms frames and MFCC is applied per
%   frame. features is a matrix containing each MFCC frame columnwise, over
%   time. timestamps is the corresponding time in seconds for the frame's
%   location in the audio file. Thus features(1) is a column vector with
%   each row a MFCC coefficient, and timestamps(1) is time zero in the
%   audio file.

% Read audio file.
[samples, sampleRate] = audioread(filePath);

% TODO Don't add noise signal even though it seems to be required else 0:th
% MFCC is inf and rest are NaN.
whiteNoise = (2*rand(1,1)-1);
samples(samples == 0) = 0.0001 * whiteNoise; 

% Sum stereo to mono if needed.
if (size(samples, 2) > 1)
    samples = (samples(:, 1) + samples(:, 2)) / 2;
end;

% Reduce harmonic content in signal (works because the drums we want to
% recognize are primarily atonal).
% TODO mono = tonal_suppression(mono, sampleRate, 30, 0.0929);

% Extract MFCC from audio.
[mfccs, ~, ~, timestamps] = GetSpectralFeatures(samples, sampleRate, 0.03, 13);

% TODO Also extract dynamic MFCC and add to features. 
% [mfccs, ~, ~, timestamps] = GetSpectralFeatures(samples, sampleRate, 0.03, 13);

features = mfccs;

% Normalize mean and variance per feature dimension.
features = bsxfun(@rdivide, bsxfun(@minus, features, mean(features, 2)), std(features, 0, 2));
