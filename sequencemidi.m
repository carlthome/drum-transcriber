function midi = sequencemidi(transcript, tempo, quantization)
%SEQUENCEMIDI Convert a drum transcript to a MIDI sequence.
%   The input transcript should be which drum note was triggered and at
%   which time in seconds. The output is a single-track, single-channel
%   MIDI sequence at fixed velocity with the transcribed drums as note-on
%   messages of an arbitrarily short duration.
%
%   Optional: Given an input tempo and a quantization value (between 0.0
%   and 1.0, inclusive) each note onset will be shifted to a time value in
%   a 4/4 16-note grid from 0 to 100 percent. How much is determined by the
%   quantization value, where 0.0 means no quantization will be performed
%   and 1.0 means each note will be fully quantized to the grid.

midiSequence = zeros(0, 6);
for t = transcript'
    time = t(1);
    drum = t(2);
    
    % Quantize time if tempo given.
    if nargin > 1
        quantizedTime = quantizetime(time, tempo, 4);
        time = quantization*quantizedTime + (1-quantization)*time;
    end;
    
    track = 1;
    channel = 1;
    note = drum;
    velocity = 127;
    startTime = time;
    stopTime = time + 0.1;
    midiSequence(end+1, :) = [track channel note velocity startTime stopTime];
end;

midi = matrix2midi(midiSequence);
