function [includedFeatures, excludedFeatures] = segmentfeatures(features, midiFilePath, midiNotes)
%SEGMENTFEATURES Segment feature vectors according to a MIDI file.
%   The input MIDI file is used to segment the set of features over time.
%   includedFeatures is a cell array of matrices containing observation
%   sequences when the MIDI note was on. excludedFeatures is the same but
%   when the MIDI note was off.

% TODO Only use channel 10?

% TODO Make track selectable?

% TODO Strip note-off?

[v{1:length(midiNotes)}] = deal({[]});
includedFeatures = containers.Map(midiNotes, v);
excludedFeatures = containers.Map(midiNotes, v);

% Read midi file to segment features with.
try 
    load([midiFilePath '.mat'], 'midi');
catch
    midi = midiInfo(readmidi(midiFilePath), 0);
    save([midiFilePath '.mat'], 'midi');
end

% Segment each input MIDI note.
for midiNote = midiNotes
     
    % Go through occurences of note and store corresponding timestamps.
    onsets = midi(midi(:, 3) == midiNote, :);
    idxs = zeros(size(features.time));
    for i = 1:size(onsets, 1)
        startTime = onsets(i, 5);
        endTime = onsets(i, 6);
        
        % Pick all feature vectors occuring with note duration.
        idxs = idxs | startTime < features.time & features.time < endTime;
        
        % Always pick closest feature vector to onset time.
        [~, idx] = min(abs(features.time - startTime));
        idxs(idx) = 1;
    end;
    
    % Select features occuring with and without note by splitting v into a
    % cell array of multiple vectors by the logical vector idxs.
    partition = @(v, idxs) mat2cell(v(:, idxs == 1), size(v, 1), find(diff([0 idxs 0])==-1) - find(diff([0 idxs 0])==1));
    includedFeatures(midiNote) = partition(features.data, idxs);
    excludedFeatures(midiNote) = partition(features.data, not(idxs));
end;
