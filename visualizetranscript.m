function visualizetranscript(audioPath, midiPath)
%VISUALIZETRANSCRIPT Display a plot with the waveform and the piano roll.

% Read audio and MIDI file.
[y, fs] = audioread(audioPath);
mono = (y(:, 1) + y(:, 2)) / 2;
midi = midiInfo(readmidi(midiPath), 0);
[pr, t, nn] = piano_roll(midi);

% Create new plot.
figure;

% Plot waveform
ax1 = subplot(2,1,1);
plot(mono), title('Waveform'), xlabel('Time (s)'), ylabel('Amplitude');
ax1.YTick = -1:1;
ax1.XTickLabel = linspace(0, length(mono)/fs, length(ax1.XTick));
drums = drummap();
colors = prism(length(drums));

% Overlay waveform with vertical lines for each drum onset.
hold on;
for i = 1:length(drums)
    note = drums(i).note;
    color = colors(i, :);
    onsets = midi(midi(:, 3) == note, 5);
    arrayfun(@(x) line(fs*[x x], [-1 1], 'Color', color, 'LineStyle', ':'), onsets);
end
hold off;

% Plot MIDI sequence.
ax2 = subplot(2,1,2);
colormap gray;
% TODO Color each drum in piano roll just like the asymptotes in the
% waveform plot
imagesc(fs*t, nn, 1-pr), title('MIDI'), xlabel('Time (s)'), ylabel('Note');
range = min([drums.note]):max([drums.note]);
ax2.YTick = range; 
ax2.YTickLabel = range;
ax2.XTickLabel = ax1.XTickLabel;
linkaxes([ax1 ax2],'x');
