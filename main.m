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
        hold on;
        plot(mono);
        for i= 1:size(notes, 1)
            note = notes(i, 3);
            onset = notes(i, 5) * fs;
            if note == 36; line([onset onset], [-1 1], 'Color', 'r');
            elseif note == 38; line([onset onset], [-1 1], 'Color', 'g');
            elseif note == 42; line([onset onset], [-1 1], 'Color', 'b');
            end
        end
        hold off;

%         TODO Remove old plot?
%         [PR, t, nn] = piano_roll(notes);
%         subplot(2,1,1), imagesc(fs*t, nn, PR), title('MIDI'), xlabel('Sample'), ylabel('Note');
%         subplot(2,1,2), plot(mono), title('Waveform'), xlabel('Sample'), ylabel('Amplitude');
    end;    
end;

% Bye bye!
if not(DEBUG)
    exit;
end;