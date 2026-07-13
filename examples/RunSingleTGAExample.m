%% RunSingleTGAExample
% Single-file TGA processing and RPM fitting workflow.
%
% Required private data:
%   H2O_850C.txt or another three-column TGA text file.
%
% Data format:
%   column 1: temperature (C)
%   column 2: time (min)
%   column 3: mass (%)

clear; clc; close all;

%% User parameters
params.filename     = 'CO2_850C.txt';
params.T_iso_start  = 840;
params.mass_ash     = 0.685;
params.smooth_span  = 11;
params.psi_init     = 3.0;
params.save_figures = true;

%% 1. Read TGA data
fprintf('>>> [1/4] Reading TGA data...\n');
data = ReadTGA(params.filename);

%% 2. Calculate conversion and derivative signals
fprintf('>>> [2/4] Calculating conversion and DTG...\n');
data = CalculateConversion(data, params.mass_ash, params.smooth_span);

%% 3. Extract isothermal reaction segment
fprintf('>>> [3/4] Extracting isothermal segment...\n');
iso = ExtractIsothermalSegment(data, params.T_iso_start);

%% 4. Fit Random Pore Model
fprintf('>>> [4/4] Fitting RPM parameters...\n');
rpm = FitRPM(iso, params.psi_init);

%% 5. Plot results
PlotCoreResults(data, iso, rpm, params);

fprintf('\n=== Processing complete ===\n');
fprintf('RPM parameters: k = %.4f min^-1, psi = %.4f\n', rpm.k, rpm.psi);
fprintf('Goodness of fit: R2 = %.6f\n', rpm.R2);

