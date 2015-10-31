function models = train_models(patternDirectory)
%TRAIN_MODELS Go through the given directory with patterns and train
% models on the patterns.
%   The pattern directory is expected to contain training data for the drum
%   detector models. A pattern should be an audio file and a corresponding
%   MIDI file with information about exactly when which drum is being
%   played. MIDI files should follow the GM standard. Note: multiple drums
%   across a combined MIDI file will be combined. The drum detector models
%   are as follows: per drum to be recognized, one four-state left-to-right
%   Hidden Markov Model (HMM) recognizes if the drum has been triggered.
%   One 5-component Gaussian Mixture Model (GMM) detects when the drum is
%   silent. Deciding if a particular drum has been triggered or not in
%   subsequent test data can be determined by comparing the forward
%   probability of the HMM with the GMM. If the HMM has the higher
%   probability the drum has likely been triggered in the observation
%   sequence.

% TODO Abstract drum map to separate script.
kick = 36;
snare = 38;
hihat = 42;
drums = {kick, snare, hihat};

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
    [features, timestamps] = read_audio(pathToAudio);
    
    % Segment training data for the current drum into two parts, given a
    % MIDI file. One set of feature vectors when the drum is played
    % according to the MIDI file, and one set of the remaining feature
    % vectors.
    [m1, m2] = segment_features(features, timestamps, pathToMidi, drums);
    included{i} = m1;
    excluded{i} = m2;
end;

% Concatenate feature vector sequences, assuming there is silence in the
% beginning and end of each song.
includedFeatures = containers.Map(drums, {{}, {}, {}});
excludedFeatures = containers.Map(drums, {{}, {}, {}});
for i = 1:length(paths)
    m1 = included{i};
    m2 = excluded{i};
    includedFeatures = [includedFeatures; m1];
    excludedFeatures = [excludedFeatures; m2];
end;

% Per drum we want to recognize: train pattern recognition models.
models = cell(size(drums));
for i = 1:length(drums)
    drum = drums{i};
    m1 = includedFeatures(drum);
    m2 = excludedFeatures(drum);
    
    % No point training a model if the particular drum was never played.
    if isempty(m1)
        continue;
    end;
    
    % Convert segmentation output into readable input by the pattern
    % recognition library.
    soundTraining = cell2mat(m1);
    soundTrainingLengths = cellfun('size', m1, 2);
    silentTraining = cell2mat(m2);
    silentTrainingLengths = cellfun('size', m2, 2);
    
    % Create, train and store a pair of pattern recognition models for the
    % current drum. One model is used to detect if the drum is actively
    % sounding, and the other model detects if it is silent.
    sound = MakeLeftRightHMM(4, GaussD, soundTraining, soundTrainingLengths);
    silent = MakeGMM(5, silentTraining);
    models{i} = { drum, sound, silent };
end;
