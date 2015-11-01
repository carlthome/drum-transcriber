function midi = sequencemidi(transcript)
%SEQUENCEMIDI Convert a drum transcript to a MIDI sequence.
%   The input transcript should be which drum note was triggered and at
%   which time in seconds. The output is a single-track, single-channel
%   MIDI sequence at fixed velocity with the transcribed drums as note-on
%   messages of an arbitrarily short duration.

midiSequence = zeros(0, 6);
for t = transcript'
    time = t(1);
    drum = t(2);
    
    track = 1;
    channel = 1;
    note = drum;
    velocity = 127;
    startTime = time;
    stopTime = time + 0.1;
    midiSequence(end+1, :) = [track channel note velocity startTime stopTime];
end;

midi = matrix2midi(midiSequence);
