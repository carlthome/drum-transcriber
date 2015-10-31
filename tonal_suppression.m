function samples = tonal_suppression(samples, sampleRate, partials, windowDuration)
%TONAL_SUPPRESSION Reduce harmonic content in an audio signal.
%   Remove tones from an audio signal by adding a phase inverted
%   synthesized signal to the original signal. The synthesized signal is
%   constructed by FFT analysis and the n loudest frequencies are selected.
%   samples = original audio signal
%   partials = n loudest frequencies
%   windowDuration = FFT window time

% TODO Implement function and use it in feature extraction step.

LISTEN = true; % TODO Remove.

config = model_conf()
[samples, model] = model_ansyn(samples, config);

if LISTEN
    playblocking(audioplayer(samples, sampleRate));
end;

% % Decompose signal into frames and calculate FFT per frame.
% [~, ffts, frequencies, ~] = GetSpectralFeatures(samples, sampleRate, windowDuration, 1);
% 
% % Keep only the loudest frequencies per frame.
% [sorted, idxs] = sort(ffts, 1);
% ffts = sorted(1:partials, :);
% frequencies = frequencies(idxs(1:partials, :));
% volumes = bsxfun(@rdivide, ffts, sum(ffts, 1));
% 
% % TODO http://recherche.ircam.fr/anasyn/roebel/amt_audiosignale/VL6.pdf
% 
% % Synthesize frames with additive synthesis.
% suppressionSignal = [];
% for frame = 1:size(ffts, 2)
%     fs = frequencies(:, frame);
%     vs = volumes(:, frame);
%     d = windowDuration / 2; % Account for segmentation overlap. TODO Return frame overlap from GetSpectralFeatures, or make into input parameter.
%     buffer = zeros(1, floor(d*sampleRate));
%     for i = 1:length(fs)
%         f = fs(i);
%         v = vs(i);
%         buffer = buffer + v*sin(linspace(0, d*f*2*pi, length(buffer)));
%     end;
%     suppressionSignal = [suppressionSignal buffer];
% end;
% 
% % Append silence if needed. TODO Fix segmentation in GetSpectralFeatures instead.
% suppressionSignal(end:length(samples)) = 0;
% 
% % Add phase inverted signal to original signal.
% samples = samples - suppressionSignal';
