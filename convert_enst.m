files = dir('enst-annotations');

output_dir = 'training-data/';

% skip . and ..
files = files(3:end);

for file = files'
  disp(file.name);
  ENST2MIDI(['enst-annotations/' file.name],  [output_dir file.name '.mid']);
end

% wav counterpart directory
wavdir = '/home/john/Dropbox/ENST-drums-public/samples';
wavs = dir(wavdir);
wavs = wavs(3:end);
for wf = wavs'
  
  % only add the wav file if the midi file exists
  midifile = [output_dir wf.name(1: end-4) '.txt.mid'];
  if (exist(midifile, 'file'))
    copyfile([wavdir '/' wf.name], [output_dir wf.name]);
  end
end