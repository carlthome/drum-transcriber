function models = trainmodels(patternDirectory)
%TRAINMODELS Go through the given directory with patterns and train
% models on the patterns.
%   The pattern directory is expected to contain training data for the drum
%   detector models. A pattern should be an audio file and a corresponding
%   MIDI file with information about exactly when which drum is being
%   played. MIDI files should follow the GM standard.
%  
%   Note: multiple drums across a combined MIDI file will be combined.

% Get MIDI notes for the drums to transcribe.
drums = drummap();
notes = [drums.note];

% Go through a directory with multiple songs (audio + MIDI pairs) and
% extract and segment features (using the parallel processing toolbox).
files = dir([patternDirectory '/*.wav']);
paths = {files.name};
included = cell(size(paths));
excluded = cell(size(paths));
parfor i = 1:length(paths)
    path = paths{i};
    [~, name, ~] = fileparts(path);
    pathToAudio = [patternDirectory '/' name '.wav'];
    pathToMidi = [patternDirectory '/' name '.mid'];
    
    % Extract features from pattern.
    windowSize = 0.03;
    [features, timestamps] = readaudio(pathToAudio, windowSize);
    
    % Segment training data for the current drum into two parts, given a
    % MIDI file. One set of feature vectors when the drum is played
    % according to the MIDI file, and one set of the remaining feature
    % vectors.
    [m1, m2] = segmentfeatures(features, timestamps, pathToMidi, notes);
    included{i} = m1;
    excluded{i} = m2;
end;

% Concatenate maps.
[vals{1:length(notes)}] = deal({[]});
includedFeatures = containers.Map(notes, vals);
excludedFeatures = containers.Map(notes, vals);
for i = 1:length(paths)
    m1 = included{i};
    m2 = excluded{i};
    includedFeatures = [includedFeatures; m1];
    excludedFeatures = [excludedFeatures; m2];
end;

% Per drum we want to recognize: train pattern recognition models.
models = drums;
for i = 1:length(drums)
    % Get relevant feature segmentation for current drum.
    included = includedFeatures(models(i).note);
    excluded = excludedFeatures(models(i).note);
    
    % No point training a model if the particular drum was never played.
    if isempty(included)
        continue;
    else
        % Convert segmentation output into readable input by the pattern
        % recognition library.
        soundTraining = cell2mat(included);
        soundTrainingLengths = cellfun('size', included, 2);
        silentTraining = cell2mat(excluded);
        silentTrainingLengths = cellfun('size', excluded, 2);
        
        % Create, train and store a pair of pattern recognition models for
        % the current drum. One model is used to detect if the drum is
        % actively sounding, and the other model detects if it is silent.
        models(i).sound = MakeLeftRightHMM(4, GaussD, soundTraining, soundTrainingLengths);
        models(i).silent = MakeLeftRightHMM(1, GaussMixD(5), silentTraining, silentTrainingLengths);
    end;
end;
