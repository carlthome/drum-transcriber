function models = main(sourcePath, destinationPath)

DEBUG = true;

% Post-processing. Smoothing combines close drum hits in time. Quantization
% moves remaining drum hits to a 4/4 16-note grid.
smoothing = 0.0; % [0.0, 1.0]
quantization = 0.0; % [0.0, 1.0]

% Include all child directories
addpath(genpath('.'));

% Try to load trained models from disk, or perform new training.
try
    if DEBUG; delete('models.mat'); end;
    load models.mat;
catch
    models = trainmodels('training-data');
    save models.mat;
end;

% Transcribe drums in audio file with trained models.
transcript = transcribedrums(sourcePath, models, smoothing);

% If drums were detected, create a MIDI file, else print an error.
if isempty(transcript)
    disp('No drums detected. Aborting.');
else
    % Create MIDI file from the transcribed drums.
    tempo = mirgetdata(mirtempo(sourcePath, 'Spectrum'));
    midi = sequencemidi(transcript, tempo, quantization);
    
    % Store MIDI file on disk.
    writemidi(midi, destinationPath);
    
    % Visualize result.
    if DEBUG
        [y, fs] = audioread(sourcePath);
        mono = (y(:, 1) + y(:, 2)) / 2;
        notes = midiInfo(midi, 0);

        figure;
        colormap gray;
        ax1 = subplot(2,1,1);
        plot(mono), title('Waveform'), xlabel('Time'), ylabel('Amplitude');
%         ax1.XTick = 0:0.1:length(mono)/fs;
        drums = drummap();
        for note = [drums.note]
            onsets = notes(notes(:, 3) == note, 5);
            hold on;
            arrayfun(@(x) line(fs*[x x], [-1 1], 'LineStyle', ':'), onsets);
            hold off;
        end
        [pr, t, nn] = piano_roll(notes);
        ax2 = subplot(2,1,2);
%         ax2.XTick = 0:0.1:length(mono)/fs;
        imagesc(ceil(fs*t), nn, pr), title('MIDI'), xlabel('Time'), ylabel('Note');
        linkaxes([ax1 ax2],'x');
    end
end

% Bye bye!
if not(DEBUG)
    exit;
end