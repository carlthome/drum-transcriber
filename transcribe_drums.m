function transcript = transcribe_drums(audioPath, models)
%TRANSCRIBE_DRUMS Recognize drums in a song.
%   Given an audio file of a song featuring drums, and trained pattern
%   recognition models, the likeliest transcript of drums is returned by
%   extracting features from the audio file and comparing short observation
%   sequences of said features per drum. Each drum has a sound-model and a
%   silence-model and the likeliest model to have produced the sequence
%   determines if the drum was triggered or not.

% Read test data and extract features.
[features, timestamps] = read_audio(audioPath);

% Go through each drum and determine if it's likeliest that it was silent
% or not per frame.
transcript = zeros(0, 2);
for i = 1:length(models)
    model = models{i};
    drum = model{1};
    sound = model{2};
    silent = model{3};
    
    % TODO Test look-ahead segmentation. Is this too naive? What is a good
    % window size?
    lookAhead = 10;
    for j = 1:length(features)-lookAhead
        window = features(:, j:j+lookAhead);
        time = timestamps(j);
        p1 = sound.logprob(window);
        p2 = silent.logprob(window);
        if (p1 > p2)
            if DEBUG; disp(['Drum ' drum 'hit at ' time ' seconds.']); end;
            transcript(end+1, :) = [time drum];
        end;
    end;
end;
