function [precision, recall] = transcriptionperformance(resultFilepath, expectedFilepath)
%TRANSCRIPTIONPERFORMANCE computes precision and recall of a result
%transcription. Precision is the ratio of resulting drum events that have a
%match in the expected transcription. Recall is the ratio of the expected
%drum events that have a match in the resulting transcription.

deltaTime = 0.03;

result = readmidi(resultFilepath);
resultNotes = midiInfo(result, 0);
expected = readmidi(expectedFilepath);
expectedNotes = midiInfo(expected, 0);

precision = matchnotes(resultNotes, expectedNotes, deltaTime);
recall = matchnotes(expectedNotes, resultNotes, deltaTime);

end

function ratio = matchnotes(matchFrom, matchIn, deltaTime)
  matchedNotes = 0;
  for de = 1:size(matchFrom, 1)
    note = matchFrom(de, 3);
    onset = matchFrom(de, 5);
    
    % TODO should a match only be used once?
    
    % Intersection of drum events of same type and drum events within
    % deltatime
    possibleMatches = matchIn(:, 3) == note & abs(matchIn(:, 5) - onset) <= deltaTime;
    if (sum(possibleMatches) > 0); matchedNotes = matchedNotes + 1; end
  end
  
  ratio = matchedNotes / size(matchFrom, 1);
end