function [ includedFeatures, excludedFeatures ] = segment_features( features, timestamps, midiFilePath, midiNote )
%SEGMENT_FEATURES Segment feature vectors according to a MIDI file.
%   The input MIDI file is used to segment the set of features over time.
%   includedFeatures is a cell array of matrices containing observation
%   sequences when the MIDI note was on. excludedFeatures is the same but
%   when the MIDI note was off.

% Read midi file to segment features with.
midi = midiInfo(readmidi(midiFilePath));
% TODO Only use channel 10?
% TODO Make track selectable?
% TODO Strip note-off?

% Go through all occurences of the note and store corresponding features.
onsets = midi(midi(:, 3) == midiNote, :);
includedFeatures = {};
idxs = zeros(size(timestamps));
for i = 1:length(onsets)
    startTime = onsets(i, 5);
    endTime = onsets(i, 6);
    % TODO Allow some timing errors to alleviate problems with fixed window
    % lengths in MFCCs frame decomposition? Or segment MFCC by note onsets
    % instead?
    window = timestamps > startTime & timestamps < endTime;
    idxs = idxs | window;
    includedFeatures{end+1} = features(:, window);
end;

%TODO Select all remaining features not occuring with note.
idxs = not(idxs);
excludedFeatures = includedFeatures;

end

