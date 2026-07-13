%% RunBatchFitting
% Batch processing workflow for multiple TGA files.
%
% Required private data:
%   CO2_850C.txt
%   CO2_900C.txt
%   CO2_950C.txt

clear; clc; close all;

%% Input files and experiment temperatures
files = {
    'CO2_850C.txt', 850;
    'CO2_900C.txt', 900;
    'CO2_950C.txt', 950;
};

%% Common parameters
params.T_iso_start  = 840;
params.mass_ash     = [];
params.smooth_span  = 11;
params.psi_init     = 3.0;
params.save_figures = true;
params.save_excel   = true;

%% Batch processing
n = size(files, 1);
results = struct();

for i = 1:n
    fname = files{i, 1};
    T_exp = files{i, 2};

    fprintf('\n========================================\n');
    fprintf('Processing file [%d/%d]: %s  (T = %d C)\n', i, n, fname, T_exp);
    fprintf('========================================\n');

    data = ReadTGA(fname);

    if isempty(params.mass_ash)
        mass_ash_i = mean(data.m(end-9:end));
        fprintf('    Estimated ash mass: %.4f %%\n', mass_ash_i);
    else
        mass_ash_i = params.mass_ash;
    end

    T_iso_i = T_exp - 15;

    data = CalculateConversion(data, mass_ash_i, params.smooth_span);
    iso  = ExtractIsothermalSegment(data, T_iso_i);
    rpm  = FitRPM(iso, params.psi_init);

    results(i).filename = fname;
    results(i).T_exp    = T_exp;
    results(i).k        = rpm.k;
    results(i).psi      = rpm.psi;
    results(i).R2       = rpm.R2;
    results(i).data     = data;
    results(i).iso      = iso;
    results(i).rpm      = rpm;
    results(i).mass_ash = mass_ash_i;

    fprintf('    Result: k = %.4f min^-1, psi = %.4f, R2 = %.5f\n', ...
        rpm.k, rpm.psi, rpm.R2);
end

%% Print summary
fprintf('\n\n============ Batch fitting summary ============\n');
fprintf('%-20s  %6s  %10s  %8s  %8s\n', 'File', 'T(C)', 'k(min^-1)', 'psi', 'R2');
fprintf('%s\n', repmat('-', 1, 64));
for i = 1:n
    fprintf('%-20s  %6d  %10.4f  %8.4f  %8.5f\n', ...
        results(i).filename, results(i).T_exp, ...
        results(i).k, results(i).psi, results(i).R2);
end

%% Arrhenius analysis
if n >= 2
    fprintf('\n>>> Arrhenius analysis\n');
    ArrheniusAnalysis(results, params.save_figures);
end

%% Plot comparison figures
PlotBatchComparison(results, params.save_figures);

%% Export summary table
if params.save_excel
    ExportExcel(results);
end

fprintf('\n=== Batch processing complete ===\n');

