function main(sourcePath, destinationPath, visualize, smoothing, quantization)
%MAIN Transcribe drums into a MIDI file given an audio file.
%   Create a MIDI file transcription of the drums contained in the input
%   audio file. sourcePath should be the path to an audio file,
%   destinationPath is the path to the created MIDI file. visuzalize is a
%   boolean determining whether to plot results or not. smoothing is a
%   float from 0.0 to 1.0 determining how close drum hits can be in time
%   before they are combined. quantization is a float from 0.0 to 1.0
%   determining how much to move the remaining drum hits into a 4/4 16-note
%   grid.

% Make sure file paths are good.
if ~exist(sourcePath); error('Audio file not found.'); end;
if exist(destinationPath); error('Destination file already exists.'); end;

% Include all child directories
addpath(genpath('.'));

% Try to load trained models from disk, or perform new training.
try 
    load('models.mat', 'models');
    disp('Models loaded.');
catch
    disp('Models not found. Training new models. Be patient.');
    models = trainmodels('training-data');
    save('models.mat', 'models');
end

% Transcribe drums in audio file with trained models.
transcript = transcribedrums(sourcePath, models, smoothing);

% If drums were detected, create a MIDI file, else print an error.
if isempty(transcript)
    disp('No drums detected. Aborting...');
else
    % Create MIDI file from the transcribed drums.
    tempo = mirgetdata(mirtempo(sourcePath, 'Spectrum'));
    midi = sequencemidi(transcript, tempo, quantization);
    
    % Store MIDI file on disk.
    writemidi(midi, destinationPath);
    
    % Visualize result.
    if visualize
        visualizetranscript(sourcePath, destinationPath);
    end;
end
