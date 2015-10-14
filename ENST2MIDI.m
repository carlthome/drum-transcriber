function [noteOnsets] = ENST2MIDI(infile, outfile)
f = fopen(infile);
res = textscan(f, '%f %s');

% times and notes
noteOnsets = [res{1} cellfun(@convertNote, res{2})];

% remove rows with unknown note
noteOnsets = noteOnsets(noteOnsets(:, 2) ~= -1, :);
if (size(noteOnsets, 1) ~= 0)
  N = size(noteOnsets, 1);
  M = zeros(N, 6);
  M(:, 1:2) = ones(N, 2);
  M(:, 4) = 127;
  M(:, 5) = noteOnsets(:, 1);
  noteOffOffset = 0.1;
  for i = 1:size(noteOnsets, 1)
    note = noteOnsets(i, 2);
    M(i, 3) = note;
    M(i, 6) = M(i, 5) + noteOffOffset;
  end
  
  midi_new = matrix2midi(M);
  writemidi(midi_new, outfile);
  
end
end

function note = convertNote(s)
if (strcmp(s, 'bd'))
  note = 36;
elseif (strcmp(s, 'sd'))
  note = 38;
elseif (strcmp(s, 'chh'))
  note = 42;
else
  % unknown
  note = -1;
end
end
