global DEBUG, DEBUG = true;

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

% Get path to source audio file to transcribe to destination MIDI file.
if not(DEBUG)
    sourcePath = input('', 's');
    destinationPath = input('', 's');
else
    sourcePath = 'test.wav';
    destinationPath = 'transcription.mid';
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
        subplot(2,1,1);
        plot(mono), title('Waveform'), xlabel('Time'), ylabel('Amplitude');
        gca.XTick = 0:0.1:length(y)/fs;
        % TODO Plot all drums.
        for note = [36 38 42]
            onsets = notes(notes(:, 3) == note, 5);
            hold on;
            arrayfun(@(x) line(fs*[x x], [-1 1], 'LineStyle', ':'), onsets);
            hold off;
        end
        [pr, t, nn] = piano_roll(notes);
        subplot(2,1,2), imagesc(fs*t, nn, pr), title('MIDI Sequence'), xlabel('Time'), ylabel('Note');
    end;
end;

% Bye bye!
if not(DEBUG)
    exit;
end;