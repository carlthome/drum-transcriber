DEBUG = true;
VISUALIZE = true;
if DEBUG; clear models; end;

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

% Create MIDI file from the transcribed drums.
midi = sequence_midi(transcript);

% Store MIDI file on disk.
writemidi(midi, 'transcription.mid');

% fprintf(str); TODO Print midi file on stdout?

% TODO Visualize test data result.
if VISUALIZE
    figure;
    Notes = midiInfo(midi,0);
    [PR, t, nn] = piano_roll(Notes);
    subplot(2,1,1), imagesc(fs*t, nn, PR), title('MIDI'), xlabel('Sample'), ylabel('Note');
    subplot(2,1,2), plot(mono), title('Waveform'), xlabel('Sample'), ylabel('Amplitude');
end;

% Bye bye!
if not(DEBUG)
    exit;
end;