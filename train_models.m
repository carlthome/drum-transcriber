function [ models ] = train_models( patternDirectory )
%TRAIN_MODELS Go through the given directory with patterns and train
% models on the patterns.
%   The pattern directory is expected to contain training data for the drum
%   detector models. A pattern should be an audio file and a corresponding
%   MIDI file with information about exactly when which drum is being
%   played. MIDI files should follow the GM standard. Note: multiple drums
%   across a combined MIDI file will be combined. The drum detector models
%   are as follows: per drum to be recognized, one four-state left-to-right
%   Hidden Markov Model (HMM) recognizes if the drum has been triggered.
%   One 5-piece Gaussian Mixture Model (GMM) detects when the drum is
%   silent. Deciding if a particular drum has been triggered or not in
%   subsequent test data can be determined by comparing the forward
%   probability of the HMM with the GMM. If the HMM has the higher
%   probability the drum has likely been triggered in the observation
%   sequence.

% TODO Go through a directory with multiple patterns when training models.
% directoryInfo = dir(patternDirectory);
% directoryInfo.name

% Extract features from pattern.
[features, timestamps] = read_audio('training-data/sample.wav');

% Train pattern recognition models.
models = {};

% TODO Abstract drum map to separate script.
snare = 38;
kick = 36;
hihat = 52; % TODO Should be 42.

% Go through every drum we want to recognize.
for drum = [snare kick hihat]
    
    % Segment training data for the current drum into two parts, given
    % a MIDI file. One set of feature vectors when the drum is played
    % according to the MIDI file, and one set of the remaining feature
    % vectors.
    [includedFeatures, excludedFeatures] = segment_features(features, timestamps, 'training-data/sample.mid', drum);
    
    % No point training a model if the particular drum was never played.
    if isempty(includedFeatures)
        continue;
    end;
    
    % Convert segmentation output into readable input by the pattern
    % recognition library.
    soundTraining = cell2mat(includedFeatures);
    soundTrainingLengths = cellfun('size', includedFeatures, 2);
    silentTraining = cell2mat(excludedFeatures);
    silentTrainingLengths = cellfun('size', excludedFeatures, 2);
    
    % Create, train and store a pair of pattern recognition models for
    % the current drum. One model is used to detect if the drum is
    % actively sounding, and the other model detects if it is silent.
    % The most probable output of the pair of models determines if the
    % drum is triggered or not.
    sound = MakeLeftRightHMM(4, GaussMixD(3), soundTraining, soundTrainingLengths);
    silent = MakeGMM(5, silentTraining);
    models{end+1} = { drum, sound, silent };
end;

end

