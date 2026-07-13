% startup.m
% Add public project folders to the MATLAB path.

projectRoot = fileparts(mfilename('fullpath'));

addpath(fullfile(projectRoot, 'src'));
addpath(fullfile(projectRoot, 'fitting'));
addpath(fullfile(projectRoot, 'simulation'));
addpath(fullfile(projectRoot, 'utilities'));
addpath(fullfile(projectRoot, 'figures'));
addpath(fullfile(projectRoot, 'examples'));

fprintf('Random-Pore-Model paths loaded.\n');

