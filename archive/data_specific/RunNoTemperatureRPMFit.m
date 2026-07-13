%% RunNoTemperatureRPMFit
% Fit RPM parameters from time-conversion data without temperature column.
%
% Expected worksheet layout exported from Origin:
%   column 1  : time (min)
%   column 2  : continuous CO2/H2O conversion X
%   column 3  : continuous CO2 conversion X
%   column 18 : continuous H2O conversion X

clear; clc; close all;

data_file = fullfile('private-data', 'continuous_conversion.xlsx');
save_figures = true;

raw = readmatrix(data_file);

datasets = {
    'CO2_H2O', raw(:,1), raw(:,2);
    'CO2',     raw(:,1), raw(:,3);
    'H2O',     raw(:,1), raw(:,18);
};

results = struct([]);
for i = 1:size(datasets, 1)
    label = datasets{i, 1};
    t = datasets{i, 2};
    X = datasets{i, 3};

    valid = isfinite(t) & isfinite(X) & X >= 0 & X < 0.999;
    t = t(valid);
    X = X(valid);

    if isempty(t) || isempty(X)
        warning('No valid data found for %s.', label);
        continue;
    end

    t = t - t(1);
    iso.t = t(:);
    iso.X_iso = X(:);

    rpm = FitRPM(iso, 3.0);

    results(i).label = label;
    results(i).t = iso.t;
    results(i).X = iso.X_iso;
    results(i).rpm = rpm;

    fprintf('%s: k = %.6f min^-1, psi = %.6f, R2 = %.6f, X_end = %.4f\n', ...
        label, rpm.k, rpm.psi, rpm.R2, iso.X_iso(end));
end

%% Plot all continuous curves and RPM fits
style = PaperStyle();
colors = lines(numel(results));

figure('Name', 'No-temperature RPM fit', 'Color', style.figureColor, 'Position', style.figSizeMid);
hold on;

for i = 1:numel(results)
    plot(results(i).t, results(i).X, 'o', ...
        'Color', colors(i,:), ...
        'MarkerSize', 3, ...
        'HandleVisibility', 'off');
    plot(results(i).rpm.t, results(i).rpm.X_fit, '-', ...
        'Color', colors(i,:), ...
        'LineWidth', style.lineWidth, ...
        'DisplayName', sprintf('%s: k=%.4f, psi=%.3f, R2=%.4f', ...
            results(i).label, results(i).rpm.k, results(i).rpm.psi, results(i).rpm.R2));
end

xlabel('Time (min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
ylabel('Conversion X', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
legend('Location', 'northwest', 'FontName', style.fontName, 'FontSize', style.legendFontSize, 'Box', 'off');
ApplyFigureFormat(gcf);

if save_figures
    ExportFigure(gcf, 'Fig_NoTemp_RPM_continuous');
end

save('TGA_NoTemp_RPM_results.mat', 'results');


