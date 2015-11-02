DEBUG = false;

global drumDuration; % TODO Don't use global variables. Pass arguments to main instead.

% Test different training parameters.
tests = 10;
drumDurations = linspace(0.05, 0.15, tests);

% Setup cache folder for models.
if DEBUG; rmdir('models'); end;
mkdir('models');

% Require training data.
disp('Enter path to ENST directory:');
enstDirectory = input('', 's');

disp('Enter path to audio file to transcribe:');
sourcePath = input('', 's');

disp('Enter path to transcription output destination:');
destinationPath = input('', 's');

disp('Enter path to MIDI file with expected transcription of audio:');
expectedPath = input('', 's');

results = struct('duration', 0, 'precision', 0, 'recall', 0); % TODO Avoid creating first entry.
for drumDuration = drumDurations
    
    % Try to load trained models if exist in cache.
    cachePath = ['models/duration_' num2str(drumDuration) '.mat'];
    copyfile(cachePath, 'models.mat');
    
    % Fail silently on incorrect input.
    try
        disp(['Testing drum duration ' num2str(drumDuration) ' seconds.']);
        
        % Create training data.
        ensttomidi(enstDirectory, 'training-data');
        
        % Create drum transcription.
        models = main(sourcePath, destinationPath);
        
        % Evaluate drum transcription.
        [precision, recall] = transcriptionperformance(destinationPath, expectedPath);
        
        % Store and show result.
        results(end+1) = struct('duration', drumDuration, 'precision', precision, 'recall', recall);
        save cachePath;
        disp(['Precision was ' precision ' while recall was ' recall '.']);
    catch ex
        disp(ex);
    end
end
