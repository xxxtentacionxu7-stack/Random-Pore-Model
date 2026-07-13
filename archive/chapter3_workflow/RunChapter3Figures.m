clear; clc; close all;

chapterDir = fileparts(mfilename('fullpath'));
addpath(chapterDir);
Chapter3PlotLibrary('all');

fprintf('\nChapter 3 figures exported to:\n%s\n', chapterDir);

