function [precision, recall] = transcriptionperformance(actualPath, expectedPath)
%TRANSCRIPTIONPERFORMANCE Compute precision and recall of transcription.
%   Precision is the ratio of resulting drum events that have a match in
%   the expected transcription. Recall is the ratio of the expected drum
%   events that have a match in the resulting transcription. actualPath
%   should be the path to a MIDI file containing the output drum
%   transcription. expectedPath should be the path to the actual drum
%   transcription (manually annotated by humans, for example).

% TODO Return one precision and recall number per MIDI note, and not only
% a total average.

% TODO Make deltaTime an optional input parameter.

deltaTime = 0.03;

result = readmidi(actualPath);
resultNotes = midiInfo(result, 0);
expected = readmidi(expectedPath);
expectedNotes = midiInfo(expected, 0);

precision = matchnotes(resultNotes, expectedNotes, deltaTime);
recall = matchnotes(expectedNotes, resultNotes, deltaTime);

end

function ratio = matchnotes(matchFrom, matchIn, deltaTime)
  matchedNotes = 0;
  for de = 1:size(matchFrom, 1)
    note = matchFrom(de, 3);
    onset = matchFrom(de, 5);
    
    possibleMatchIndexes = find(matchIn(:, 3) == note & abs(matchIn(:, 5) - onset) <= deltaTime);
    
    if ~isempty(possibleMatchIndexes)
      possibleMatches = matchIn(possibleMatchIndexes, :);
      [~, ind] = min(abs(possibleMatches(:, 5) - onset));
      matchIn(possibleMatchIndexes(ind), 3) = -1;
      
      matchedNotes = matchedNotes + 1;
    end
  end
  
  ratio = matchedNotes / size(matchFrom, 1);
  
end