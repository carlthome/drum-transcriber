function [features, timestamps] = readaudio(filePath, windowSize)
%READAUDIO Extract features from audio file.
%   The audio file is segmented into frames and MFCC is applied per frame.
%   features is a matrix containing each MFCC frame columnwise, over time.
%   timestamps is the corresponding time in seconds for the frame's
%   location in the audio file.

% Feature extraction parameters:
% mirparallel(1);           % TODO Use MIRtoolbox in parallel.
mirverbose(0);              % Hide console output
mirwaitbar(0);              % Hide progress bars
windowOverlap = 0.5;        % Frame overlap
melBands = 40;              % Number of mel-bands in MFCC
mfccCoefficients = 0:12;    % The MFCC coefficients to calculate
deltas = 0:1;               % MFCC orders
radius = 2;                 % MFCC derivative window width

% Read audio file into memory.
a = miraudio(filePath, 'Normal');
% TODO Use MIRtoolbox flowchart design instead of reading entire audio file
% into memory.
% a = miraudio('Design', 'Normal');

% Sum stereo to mono.
a = mirsum(a);

% mireval(a, filePath);

% TODO Reduce harmonic content in signal (works because the drums we want
% to recognize are primarily atonal).
% mono = tonalSuppression(mono, sampleRate, 30, 0.0929);

% Decompose audio into frames.
a = mirframe(a, 'Length', windowSize, 'Hop', windowOverlap);

% Get onset times for each frame in the audio file.
timestamps = get(a, 'FramePos');
timestamps = timestamps{1}{1}(1, :);

% Calculate MFCC.
features = [];
for delta = deltas
    mfccs = mirgetdata(mirmfcc(a, 'Bands', melBands, 'Rank', mfccCoefficients, 'Delta', delta, 'Radius', radius));
    mfccs = [mfccs(:, 1:delta*radius) mfccs mfccs(:, end-delta*radius+1:end)];
    features = [features; mfccs];
end;

% TODO Add timbral features.

% Normalize mean and variance per feature dimension.
features = bsxfun(@rdivide, bsxfun(@minus, features, mean(features, 2)), std(features, 0, 2));

% TODO Perform PCA and remove dead features.
