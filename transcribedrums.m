function transcript = transcribedrums(audioPath, drumModels)
%TRANSCRIBEDRUMS Recognize drums in a song.
%   Given an audio file of a song featuring drums, and trained pattern
%   recognition models, the likeliest transcript of drums is returned by
%   extracting features from the audio file and comparing short observation
%   sequences of said features per drum. Each drum has a sound-model and a
%   silence-model and the likeliest model to have produced the sequence
%   determines if the drum was triggered or not.

% Read test data and extract features.
windowSize = 0.03;
[features, timestamps] = readaudio(audioPath, windowSize);

% Go through each drum and determine if it's likeliest that it was silent
% or not per frame.
transcript = zeros(0, 2);
for drumModel = drumModels
    onsets = [];
    
    % Skip empty models (i.e. training data never contained drum).
    if isempty(drumModel.sound)
        continue;
    end;
    
    % Go through entire input sequence in tiny steps and try to find if
    % drum is likely to have been triggered or not.
    observationSequenceLength = floor(drumModel.duration / windowSize) + 1;
    for j = 1:length(features)-observationSequenceLength
        window = features(:, j:j+observationSequenceLength);
        time = timestamps(j);
        if drumModel.sound.logprob(window) > drumModel.silent.logprob(window)
            onsets(end+1) = time;
            j = j + observationSequenceLength; % TODO Test skipping on hit.
        end;
    end;
    
    % TODO Make into function parameter.
    smoothing = 0.0;
    
    % Smooth transcript by keeeping first occurence of close drum triggers.
    dt = smoothing*drumModel.duration;
    onsets(diff(onsets) < dt) = [];
    
    % Smooth transcript by averaging close drum triggers in time.
    smoothingTime = smoothing*drumModel.duration;
    dt = [0 diff(onsets)];
    s = 0;
    n = 0;
    for j = 1:length(onsets)
        s = s + onsets(j);
        n = n + 1;
        if dt(j) > smoothingTime 
            transcript(end+1, :) = [s/n drumModel.note];
            s = 0;
            n = 0;
        end;
    end;    
end;
