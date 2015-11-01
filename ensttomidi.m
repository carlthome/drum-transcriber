function ensttomidi(enstDirectory, trainingDataDirectory)
%ENSTTOMIDI Convert the ENST drum library to project training data.
%   Convert ENST annotation data to MIDI files, for use as training data in
%   the drum transcriber. The ENST drum library of drum recordings can be
%   found online at:
%   http://perso.telecom-paristech.fr/~grichard/ENST-drums/

% Load drum map
drums = drummap();

% Assume ENST directory contains specific child folders for annotations and
% audio.
annotationsDirectory = [enstDirectory '/annotations'];
samplesDirectory = [enstDirectory '/samples'];

% Convert each annotation to MIDI into the training data directory.
for file = dir([annotationsDirectory '/*.txt'])'
    [~, name, ~] = fileparts(file.name);
    annotationPath = [annotationsDirectory '/' name '.txt'];
    midiPath = [trainingDataDirectory '/' name '.mid'];
    
    % Read ENST annotation. The first column is the onset time, the second
    % column is the type of drum.
    fid = fopen(annotationPath);
    annotation = textscan(fid, '%f %s');
    fclose(fid);
    
    % Sequence annotation to MIDI and store to disk.
    M = ones(size(annotation{1}, 1), 6); % Assume track one and channel one.
    M(:, 4) = 127; % Velocity
    M(:, 5) = annotation{1}; % Note on
    for i = 1:length(drums{1})
        label = drums{1}(i);
        note = drums{2}(i);
        duration = drums{3}(i);
        
        idxs = strcmp(annotation{2}, label);
        M(idxs, 3) = note; % Note number
        M(idxs, 6) = M(idxs, 5) + duration; % Note off
    end;
    
    % Store sequenced MIDI to disk.
    writemidi(matrix2midi(M), midiPath);
    
    % Copy audio sample to training data directory as well.
    copyfile([samplesDirectory '/' name '.wav'], [trainingDataDirectory '/' name '.wav']);
end