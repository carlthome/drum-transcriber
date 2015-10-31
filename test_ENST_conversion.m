midi = readmidi('training-data/116_minus-one_rock-60s_sticks.txt.mid');
[y, fs] = audioread('training-data/116_minus-one_rock-60s_sticks.wav');
mono = (y(:, 1) + y(:, 2)) / 2;

for i = 1:length(mono)
  if (rms(mono(i:i+30)) > 0.01)
    start = i;
    break;
  end
  
  i = i + 30;
end

hold on;
plot(mono);

notes = midiInfo(midi, 0);
notes = notes(:, [3, 5]);

for i= 1:size(notes, 1)
  note = notes(i, 1);
  onset = start + notes(i, 2) * fs;
  
  if note == 36
    line([onset, onset], [-1, 1], 'Color', 'r');
  elseif note == 38
    line([onset, onset], [-1, 1], 'Color', 'g');
  elseif note == 42
    line([onset, onset], [-1, 1], 'Color', 'b');
  end
end
