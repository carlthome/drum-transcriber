function quantizedTime = quantizetime(time, bpm, note)
%QUANTIZETIME Round time to closest quantized time.
%   Round time to closest note according to tempo and note sub division.
%   For example a time of 0.2 seconds with a tempo of 120 BPM and quarter
%   notes would output the time X seconds, as that is the closest matching
%   quarter note in time. bpm is an integer describing the tempo. note is
%   an integer describing the note division, for example 1 for quarter
%   notes, 2 for eight notes and so on.

% TODO Function assumes time signature is 4/4. Allow other time signatures.

bpm = note * bpm;
bps = bpm / 60;
accuracy = 1 / bps;
quantizedTime = round(time / accuracy) * accuracy;

