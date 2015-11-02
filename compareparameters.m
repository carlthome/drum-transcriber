% Test different training parameters.
drumDurations = 0.0:0.05:1.0;

% TODO Don't use global variables. Pass arguments to main instead.
global DEBUG drumDuration;

disp('Enter full path to ENST directory:');
enstDirectory = input('', 's');

results = struct('duration', 0, 'precision', 0, 'recall', 0); % TODO Avoid creating first entry.
for drumDuration = drumDurations
    disp(['Testing drum duration ' num2str(drumDuration) ' seconds.']);

    % Fail silently on incorrect input.
    try
        % Create training data.
        ensttomidi(enstDirectory, 'training-data');
        
        % Create drum transcription (in DEBUG mode).
        DEBUG = true;
        main;
        
        % Evaluate drum transcription.
        [precision, recall] = transcriptionperformance('transcription.mid', expectedFilepath);
        
        % Store result.
        results(end+1) = struct('duration', drumDuration, 'precision', precision, 'recall', recall);
        
        % Save after every succesful test in case of a crash.
        save;
    catch ex
        disp(ex);
    end
end
