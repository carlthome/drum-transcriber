function drums = drummap()
%DRUMMAP Get drum map
%   Returns a drum map. Each row is a specific drum, with the first column
%   being a string label with the drum name, the second column being the
%   drums MIDI note number, and the third column being an empirically
%   estimated average sound duration for the particular drum.

% TODO some of the note values might not follow general MIDI standard
labels = {'bd' 'sd' 'chh' 'ohh' 'rs' 'cs' 'cb' 'c' 'lmt' 'mt' 'mtr' ...
  'lt' 'ltr' 'rc' 'ch' 'cr' 'spl'};
notes = [36 38 42 46 49 59 56 57 69 72 73 65 66 62 85 84 55];
durations = [0.1 0.08 0.04];
durations = [durations 0.05 * ones(1, 14)]; % temporary, same duration for the rest of the drums

drums = {labels' notes' durations'};
     