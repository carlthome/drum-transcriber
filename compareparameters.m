% This scrip tests different training and post-processing parameters.

% Make sure nothing in the workspace interfers. Remove everything.
clear all;

% TODO Don't let this be global, pass to functions instead.
global DURATION;

% Require data.
disp('Enter path to ENST directory:');
enstDirectory = input('', 's');
disp('Enter path to source audio to transcribe:');
sourcePath = input('', 's');
disp('Enter path to source MIDI (expected transcription of audio):');
expectedPath = input('', 's');
disp('Enter path to destination transcription (actual transcription of audio):');
destinationPath = input('', 's');

% Test parameters and store results.
results = struct('smoothing', 0, 'quantization', 0, 'duration', 0, 'precision', 0, 'recall', 0); % TODO Avoid creating first entry.
for smoothing = 0.0:0.5:1.0
    for quantization = 0.0:0.5:1.0
        for DURATION = linspace(0.1, 0.11, 10)
            
            % Display test parameters.
            fprintf('\nTesting %.3f seconds duration with %.1f quantization and %.1f smoothing.\n', DURATION, quantization, smoothing);
            
            % Delete previous transcription.
            delete(destinationPath);
            
            % Delete previous pattern recognition models.
            delete('models.mat');
            
            % Create training data.
            ensttomidi(enstDirectory, 'training-data');
            
            % Create drum transcription.
            main(sourcePath, destinationPath, false, smoothing, quantization);
            
            % Evaluate transcription.
            [precision, recall] = transcriptionperformance(destinationPath, expectedPath);
            
            % Store result.
            results(end+1) = struct('smoothing', smoothing, 'quantization', quantization, 'duration', DURATION, 'precision', precision, 'recall', recall);
            
            % Display result of test.
            fprintf('Result was a precision of %.2f and a recall of %.2f.\n', precision, recall);
        end
    end
end