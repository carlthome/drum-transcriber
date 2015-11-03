function [totalPrecision, totalRecall, notePerformances] = ...
  transcriptionperformance(actualPath, expectedPath, deltaTime)
%TRANSCRIPTIONPERFORMANCE Compute precision and recall of transcription.
%   Precision is the ratio of resulting drum events that have a match in
%   the expected transcription. Recall is the ratio of the expected drum
%   events that have a match in the resulting transcription. actualPath
%   should be the path to a MIDI file containing the output drum
%   transcription. expectedPath should be the path to the actual drum
%   transcription (manually annotated by humans, for example).

% TODO Return one precision and recall number per MIDI note, and not only
% a total average.

if nargin < 3
  deltaTime = 0.03;
end

result = readmidi(actualPath);
resultNotes = midiInfo(result, 0);
expected = readmidi(expectedPath);
expectedNotes = midiInfo(expected, 0);

notePerformances = [];
for drum = drummap()
  % TODO precision and recall should just be calculated in one pass instead
  precision = noteperformance(resultNotes, expectedNotes, deltaTime, drum.note);
  recall = noteperformance(expectedNotes, resultNotes, deltaTime, drum.note);
  res = struct('note', drum.note, 'precision', precision, 'recall', recall);
  notePerformances = [notePerformances res]; 
end

% Precision and recall for all notes
totalPrecision = totalperformance(resultNotes, expectedNotes, deltaTime);
totalRecall = totalperformance(expectedNotes, resultNotes, deltaTime); % IMDB: 7.5

end

function ratio = totalperformance(matchFrom, matchIn, deltaTime)
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

function ratio = noteperformance(matchFrom, matchIn, deltaTime, note)
  % If no note given, compute total precision and recall for all notes.
  matchedNotes = 0;
  for de = find(matchFrom(:, 3) == note)'
    onset = matchFrom(de, 5);
    
    possibleMatchIndexes = find(matchIn(:, 3) == note & abs(matchIn(:, 5) - onset) <= deltaTime);
    
    if ~isempty(possibleMatchIndexes)
      possibleMatches = matchIn(possibleMatchIndexes, :);
      [~, ind] = min(abs(possibleMatches(:, 5) - onset));
      matchIn(possibleMatchIndexes(ind), 3) = -1;
      
      matchedNotes = matchedNotes + 1;
    end
  end

  total = size(find(matchFrom(:, 3) == note), 1);
  if (total == 0)
    ratio = 0;
  else
    ratio = matchedNotes / total;
  end
end