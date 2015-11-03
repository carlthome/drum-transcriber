function transcript = transcribedrums(audioPath, drumModels, smoothing)
%TRANSCRIBEDRUMS Recognize drums in a song.
%   Given an audio file of a song featuring drums, and trained pattern
%   recognition models, the likeliest transcript of drums is returned by
%   extracting features from the audio file and comparing short observation
%   sequences of said features per drum. Each drum has a sound-model and a
%   silence-model and the likeliest model to have produced the sequence
%   determines if the drum was triggered or not.
%   
%   Optional: smoothing (a float from 0.0 to 1.0) determines how much time
%   smoothing should be applied to each drum hit. A smoothed time is a
%   weighted average of close drum hits, where the weights come from the
%   certainty of a drum hit, calculated as the difference between the
%   forward probabilities of the sound and silence model.

if nargin < 3
    smoothing = 0.0; % Default smoothing is no smoothing at all.
end;

% Read test data and extract features.
[features, windowSize] = readaudio(audioPath);

% Transcribe each drum separately.
transcript = zeros(0, 2);
for drumModel = drumModels
    onsets = struct('time', 0, 'certainty', 0);
    
    % Skip empty models (i.e. training data never contained drum).
    if isempty(drumModel.sound)
        continue;
    end;
    
    % Step through input and try to find at each step if the drum is likely
    % to have been hit or not.
    observationSequenceLength = floor(drumModel.duration / windowSize) + 1;
    for j = 1:length(features.data)-observationSequenceLength
        window = features.data(:, j:j+observationSequenceLength);
        p1 = drumModel.sound.logprob(window);
        p2 = drumModel.silent.logprob(window);
        if p1 > p2
            % Drum was likely hit. Store the time and certainty of the
            % stroke.´
            onsets(end+1) = struct('time', features.time(j), 'certainty', p1 - p2);
            
            %TODO Since a hit was registered, skip ahead to avoid
            %retriggering?
            % j = j + observationSequenceLength;
        end;
    end;
    onsets(1) = []; % TODO Remove silly hack.
    
    % TODO Remove too quick successions of drum hits? 
    % dt = drumModel.duration; 
    % onsets(find(diff(onsets) < dt) + 1) = [];
    
    % Smooth transcript.
    smoothingTime = smoothing * drumModel.duration;
    dt = [0 diff([onsets.time])];
    closeOnsets = struct('time', 0, 'certainty', 0);
    for j = 1:length(onsets)
        closeOnsets(end+1) = onsets(j);
        if dt(j) > smoothingTime 
            closeOnsets(1) = []; % TODO Remove silly hack.
            
            % Weight time values by forward probabilities.
            w = [closeOnsets.certainty] / sum([closeOnsets.certainty]);
            x = [closeOnsets.time];
            weightedTime = w * x';
            
            % Store drum hit at averaged time.
            transcript(end+1, :) = [weightedTime drumModel.note];
            closeOnsets = struct('time', 0, 'certainty', 0);
        end;
    end;   
end;
