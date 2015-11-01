function drums = drummap()
%DRUMMAP Get drum map
%   Returns a drum map. Each row is a specific drum, with the first column
%   being a string label with the drum name, the second column being the
%   drums MIDI note number, and the third column being an empirically
%   estimated average sound duration for the particular drum.

% TODO Enter more drums.
labels = {'bd' 'sd' 'chh'};
notes = [36 38 42];
durations = [0.4 0.5 0.1];
drums = {labels' notes' durations'};
     