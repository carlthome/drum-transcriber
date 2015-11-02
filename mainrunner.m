% run enst conversion script

% drum durations in drummap
% different window sizes

global DEBUG
global drumDuration;

DEBUG = true;

for dur = 0.05:0.05:0.55
  drumDuration = dur;
  
  % Remove training data and run ENST conversion again
  delete('training-data/*');
  ensttomidi('/path/to/enst/ENST-drums-public', 'training-data');
  
  % Run the training for with this drum duration and save the model
  try
    main
    save(['models/' 'dur_' int2str(dur) '.mat']);
  catch ex
    ex
  end
end