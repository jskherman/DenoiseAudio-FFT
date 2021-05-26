%--------------------------------------------------------------------
%       USAGE: DenoiseAudio
%
%     AUTHORS: Arlie Brual, Je Sian Keith Herman, Giane Manoguid
%        DATE: May 26, 2021
%    MODIFIED: Arlie Brual, Je Sian Keith Herman, Giane Manoguid
%        DATE: May 26, 2021
%   
% DESCRIPTION: This function takes in an audio file and removes the
%              noise by cutting out the unwanted frequencies using
%              the Fast Fourier transform.
%   
%      INPUTS: file = 'The audio file that is to be filtered.' 
%         directory = 'Directory of the audio file.'
%         threshold = 'The threshold value that frequencies must
%                       meet in the power-spectral density plot.'
%
%     OUTPUTS: file_filtered = 'The filtered audio file saved in the
%                               same directory as the original file.'
%--------------------------------------------------------------------

% Clear all variables
close all; clear all; clc;

disp("DENOISING AUDIO DATA THROUGH FAST FOURIER TRANSFORM");

disp("AUTHORS: Arlie Brual, Je Sian Keith Herman, Giane Manoguid");

disp("DESCRIPTION: This program filters and plots audio data");

disp("WELCOME :)");

% Set number format
format short g;

% Ask user for the file
% Launch a dialog box for choosing the file
[file, directory] = uigetfile({"*.wav", "WAV";"*.flac", "FLAC";"*.ogg", "Ogg Vorbis"}, "Multiselect", "off");
filename = [directory, file];    % Concatenate the strings to get the full path of the file

% Load test audio file

% Do it in a try-catch block in order to handle errors due to a wrong file format
try                  
  [f, fs] = audioread(filename);    % Load signal f from audio file with sampling rate fs
catch err
  printf(["Unable to load file: ", file, "\n"]);                   % Print error
  error("Please choose a valid WAV, FLAC or Ogg Vorbis file.");
  clear all;                                                       % Clear variables and end script
end

info = audioinfo(filename);       % load metadata of audio file

% Specify the duration of the audio file

n = length(f);    % Calculate how many data points there are

duration = info.Duration;    % Load duration from file metadata
dt = duration/n;

t = [0:dt:duration];    % Specify the row vector for time in terms of seconds
t(:,n) = [];            % Remove the last element to match the length of variable f
t = t';                 % Transpose to column vector to match f

% Applying fft
X = fft(f, n);    % Compute the fast Fourier transform

% Power Density Spectrum (Plot 01)
P = X.*conj(X)/n;        % PSD, Power spectrum (power per freq)
F = 1/(dt*n)*(0:n);      % Frequency in Hz for the x axis
F(:,n) = [];             % Fix to be the same size as X
F = F';                  % Transpose into column vector


% Plot 01: Power Density Spectrum, unfiltered
figure;
plot(F, P), hold on;                         % Plot freq vs power and hold plot
title("Power Spectral Density");
xlabel("Frequency (Hz)");
ylabel("Power");

disp("Choose threshhold based on the figure");
threshold = input("Enter preferred threshold value : "); % Set the noise threshold

% Filtering the Noise using the Power Density Spectrum (Plot 02)
indices = P>threshold;    % Find all freqs with a power larger than the threshold
Pclean = P.*indices;      % Zero out all the other freqs
X2 = X;
X = indices.*X;           % Zero out small Fourier coefficients

figure;
plot(F, Pclean);                             % Plot freq vs power
title("Filtered Frequencies")
xlabel("Frequency (Hz)"); 
ylabel("Power");

% Applying the Inverse FFT (Plot 03)
Y = ifft(X);               % Inverse FFT for getting back the filtered signal

figure;

subplot(2, 1, 1);
plot(t, f);                          % Plot the filtered signal as a function of time
title("Original Signal");
xlabel("Time (s)"); 
ylabel("Amplitude");

subplot(2,1,2);
plot(t, Y);                          % Plot the filtered signal as a function of time
title("Filtered Signal");
xlabel("Time (s)"); 
ylabel("Amplitude");

% Listing out the frequencies

k = find(Pclean);    % Find the indices of the nonzero elements
freqlist = [];       % Initialize list/vector of frequencies
disp("\nThe filtered frequencies in Hz are:");    % First part of the message
for i = 1:length(k)                           % Second part iterating through all the values
    j = k(i,1);                               % Load the value of k for the index i into a number j
    freq = F(j,:);
    freqlist = [freqlist; freq];% Add to list (recursively) the value of the frequency corresponding to the index k
    fprintf('%.2f\n',freq);
end;
disp("");

% Script to write/save the filtered signal to a WAV file

% Create filename for new file
newfilename = [info.Filename(1:end-4) "_filtered.wav"];

% Write filtered signal to a wav file in the same directory as the original file
audiowrite(newfilename, Y, fs);

% Print a success message for feedback
disp("Success! The filtered audio file has been saved here:");
disp([newfilename "\n"]);