%% compare_850_900_RPM_params
% Recompute RPM parameters for CO2 and H2O at 850/900 C with one rule set.

clear; clc; close all;

script_dir = fileparts(mfilename('fullpath'));
if ~isempty(script_dir)
    cd(script_dir);
end

params.smooth_span = 11;
params.psi_init = 3.0;
cases = {
    'CO2_850C.txt', 850, 'CO2';
    'CO2_900C.txt', 900, 'CO2';
    'H2O_850C.txt', 850, 'H2O';
    'H2O_900C.txt', 900, 'H2O';
};

fprintf('\n%-14s %-5s %-9s %-9s %-9s %-9s %-9s %-9s\n', ...
    'file', 'T', 'T_iso', 'dead_t', 'duration', 'k', 'psi', 'R2');
fprintf('%s\n', repmat('-', 1, 82));

for i = 1:size(cases, 1)
    fname = cases{i, 1};
    T_exp = cases{i, 2};
    T_iso_start = T_exp - 15;

    data = ReadTGA(fname);
    mass_ash = mean(data.m(end-9:end));
    data = CalculateConversion(data, mass_ash, params.smooth_span);
    iso = ExtractIsothermalSegment(data, T_iso_start);
    rpm = FitRPM(iso, params.psi_init);

    fprintf('%-14s %-5d %-9.1f %-9.2f %-9.2f %-9.5f %-9.5f %-9.5f\n', ...
        fname, T_exp, T_iso_start, iso.dead_time, iso.t(end), ...
        rpm.k, rpm.psi, rpm.R2);
end

