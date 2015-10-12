DEBUG = true;
VISUALIZE = true;

% Include all child directories
addpath(genpath('.'));

% Try to load trained models from disk, or perform new training.
try 
    load;
catch
    models = train_models('patterns');
    save;
end;

% str = input('', 's'); TODO Read test audio file on stdin?

% Transcribe drums in audio file with trained models.
transcript = transcribe_drums('test.wav', models);

% If drums were detected, create a MIDI file, else print an error.
if isempty(transcript)
    fprintf('No drums detected. Aborting.');
else
    % Create MIDI file from the transcribed drums.
    midi = sequence_midi(transcript);

    % Store MIDI file on disk.
    writemidi(midi, 'transcription.mid');
    
    % fprintf(str); TODO Print midi file on stdout?
    
    % Visualize test data result.
    if VISUALIZE
        figure;
        [y, fs] = audioread('test.wav');
        mono = (y(:, 1) + y(:, 2)) / 2;
        Notes = midiInfo(midi, 0);
        [PR, t, nn] = piano_roll(Notes);
        subplot(2,1,1), imagesc(fs*t, nn, PR), title('MIDI'), xlabel('Sample'), ylabel('Note');
        subplot(2,1,2), plot(mono), title('Waveform'), xlabel('Sample'), ylabel('Amplitude');
    end;
end;

% Bye bye!
if not(DEBUG)
    exit;
end;