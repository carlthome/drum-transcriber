# drum-transcriber
Convert drum recordings into MIDI.

# Usage
 1. First set your working directory to the root of this repo. Make sure all folders and subfolders are added to MATLAB's path.
 1. Then download the [ENST drums](http://perso.telecom-paristech.fr/~grichard/ENST-drums/) dataset* and use [ensttomidi.m](./ensttomidi.m) to prepare training data for the hidden Markov models. Make sure trainingDataDirectory is set to `training-data`.
 1. Then run [main.m](./main.m) on an audio file to transcribe. The first run will be slow, because the hidden Markov models need to be trained on ENST drums first. Subsequent runs will be faster as training results persist between sessions.
 
*You could also contact us for a pretrained model, in case you don't have the time or patience to download ENST drums. We cannot share the training data for licensing reasons, unfortunately.

# Beware
This was a student project to learn about hidden Markov models. The resulting transcription is not great, unless the drums are able to be quantized heavily (preferably 16th notes or longer). Typically, many false notes are detected during a drum trigger, meaning that some post-processing is needed to cleanup the results. Some false triggering of snares when hi-hats are played, and vice versa, can also be a problem, although it's not terrible. Expect F-measures of around 70% with a time window of 30 ms.
