function drums = drummap()
%DRUMMAP Get drum map
%   Returns a drum map with information about each drum.

% TODO Some of the note values might not follow general MIDI standard.

labels = {'bd' 'sd' 'chh' 'ohh' 'rs' 'cs' 'cb' 'c' 'lmt' 'mt' 'mtr' 'lt' 'ltr' 'rc' 'ch' 'cr' 'spl'};
notes = {36 38 42 46 49 59 56 57 69 72 73 65 66 62 85 84 55};
durations = {0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1};

% If the global variable is set override the predefined durations.
global DURATION;
if ~isempty('DURATION')
    [durations{:}] = deal(DURATION);
    clear DURATION; % Only allow global variable to be used once.
end

drums = struct('name', labels, 'note', notes, 'duration', durations);
