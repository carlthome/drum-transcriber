function [includedFeatures, excludedFeatures] = segment_features(features, timestamps, midiFilePath, midiNotes)
%SEGMENT_FEATURES Segment feature vectors according to a MIDI file.
%   The input MIDI file is used to segment the set of features over time.
%   includedFeatures is a cell array of matrices containing observation
%   sequences when the MIDI note was on. excludedFeatures is the same but
%   when the MIDI note was off.

includedFeatures = containers.Map(midiNotes, {{[]}, {[]}, {[]}});
excludedFeatures = containers.Map(midiNotes, {{[]}, {[]}, {[]}});

% Read midi file to segment features with.
midi = midiInfo(readmidi(midiFilePath), 0);
% TODO Only use channel 10?
% TODO Make track selectable?
% TODO Strip note-off?

for c = midiNotes
    midiNote = c{1};
    
    % Go through occurences of note and store corresponding timestamps.
    onsets = midi(midi(:, 3) == midiNote, :);
    idxs = zeros(size(timestamps));
    for i = 1:size(onsets, 1)
        startTime = onsets(i, 5);
        endTime = onsets(i, 6);
        % TODO Allow some timing errors to alleviate problems with fixed
        % window lengths in MFCCs frame decomposition? Or segment MFCC by
        % note onsets instead?
        idxs = idxs | startTime < timestamps & timestamps < startTime+0.1;
    end;
    
    % Select features occuring with and without note by splitting v into a
    % cell array of multiple vectors by the logical vector idxs.
    partition = @(v, idxs) mat2cell(v(:, idxs == 1), size(v, 1), find(diff([0 idxs' 0])==-1) - find(diff([0 idxs' 0])==1));
    includedFeatures(midiNote) = partition(features, idxs);
    excludedFeatures(midiNote) = partition(features, not(idxs));
end;
