function [features, timestamps, windowSize] = readaudio(filePath)
%READAUDIO Extract features from audio file.
%   The audio file is segmented into frames and MFCC is applied per frame.
%   features is a matrix containing each MFCC frame columnwise, over time.
%   timestamps is the corresponding time in seconds for the frame's
%   location in the audio file.

% Feature extraction parameters:
% mirparallel(1);           % TODO Use MIRtoolbox in parallel. Doesn't seem to work.
mirverbose(0);              % Hide console output
mirwaitbar(0);              % Hide progress bars
windowSize = 0.0464;        % Frame duration
windowOverlap = 0.75;       % Frame overlap
melBands = 40;              % Number of mel-bands in MFCC
mfccCoefficients = 0:12;    % The MFCC coefficients to calculate
deltas = 0:1;               % MFCC orders
radius = 2;                 % MFCC derivative window width

% Read audio file into memory (sum stereo to mono).
a = mirsum(filePath);

% TODO Reduce harmonic content in signal (should work because the drums we
% want to recognize are primarily atonal).
% mono = tonalSuppression(mono, sampleRate, 30, 0.0929);

% Decompose audio into frames.
a = mirframe(a, 'Length', windowSize, 'Hop', (1-windowOverlap));

% Get start times for each frame in the audio file.
timestamps = get(a, 'FramePos');
timestamps = timestamps{1}{1}(1, :);

% Calculate MFCC.
features = zeros(length(deltas)*length(mfccCoefficients), size(timestamps, 2));
for delta = deltas
    mfccs = mirgetdata(mirmfcc(a, 'Bands', melBands, 'Rank', mfccCoefficients, 'Delta', delta, 'Radius', radius));
    idxs = (delta*length(mfccCoefficients)+mfccCoefficients) + 1;
    features(idxs, :) = [mfccs(:, 1:delta*radius) mfccs mfccs(:, end-delta*radius+1:end)];
end;

% TODO Add timbral features.

% Normalize mean and variance per feature dimension.
features = bsxfun(@rdivide, bsxfun(@minus, features, mean(features, 2)), std(features, 0, 2));

% TODO Perform PCA and remove dead features.
