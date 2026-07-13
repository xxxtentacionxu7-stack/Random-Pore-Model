%% plot_900_atmospheres_TG_DTG
% Generate TG/DTG curves for CO2 and H2O at 900 C.
% Expected data columns: temperature (C), time (min), mass (%).

clear; clc; close all;

script_dir = fileparts(mfilename('fullpath'));
if ~isempty(script_dir)
    cd(script_dir);
end

style = paperStyle();
smooth_span = 11;

datasets = findAtmosphereFiles();
if isempty(datasets)
    error('No 900 C atmosphere files were found.');
end

fprintf('\n900 C atmosphere files found:\n');
for i = 1:numel(datasets)
    fprintf('  - %-8s  %s\n', datasets(i).label, datasets(i).file);
end

for i = 1:numel(datasets)
    datasets(i).data = readAndProcess(datasets(i).file, smooth_span);
end

plotIndividualPanels(datasets, style);
plotComparisonTG(datasets, style);
plotComparisonDTG(datasets, style);
plotComparisonPanels(datasets, style);

fprintf('\nGenerated figures in %s\n', pwd);
fprintf('  Individual: Paper_Fig_<atmosphere>_TG_DTG.png/pdf/eps\n');
fprintf('  Compare:    Paper_Fig_900C_CO2_H2O_only_TG_compare.png/pdf/eps\n');
fprintf('              Paper_Fig_900C_CO2_H2O_only_DTG_compare.png/pdf/eps\n');
fprintf('              Paper_Fig_900C_CO2_H2O_only_TG_DTG_panels.png/pdf/eps\n');

function datasets = findAtmosphereFiles()
    candidates = {
        'co2', 'CO_2 (900 C)',                   'CO2_900C.txt';
        'h2o', 'H_2O (900 C)',                   'H2O_900C.txt';
    };

    datasets = struct('key', {}, 'label', {}, 'file', {}, 'data', {});
    used_keys = {};

    for i = 1:size(candidates, 1)
        key = candidates{i, 1};
        label = candidates{i, 2};
        file = candidates{i, 3};
        if exist(file, 'file') && ~any(strcmp(used_keys, key))
            datasets(end + 1).key = key; %#ok<SAGROW>
            datasets(end).label = label;
            datasets(end).file = file;
            datasets(end).data = [];
            used_keys{end + 1} = key; %#ok<AGROW>
        end
    end
end

function data = readAndProcess(filename, smooth_span)
    raw = readmatrix(filename, 'Delimiter', '\t', 'FileType', 'text');
    if size(raw, 2) >= 3
        valid = ~any(isnan(raw(:, 1:3)), 2);
        raw = raw(valid, 1:3);

        data.T = raw(:, 1);
        data.t = raw(:, 2);
        data.m = raw(:, 3);
    elseif size(raw, 2) == 2
        valid = ~any(isnan(raw(:, 1:2)), 2);
        raw = raw(valid, 1:2);

        data.t = raw(:, 1);
        data.X = max(0, min(1, raw(:, 2)));
        data.m = 100 .* (1 - data.X);
        data.beta = chooseHeatingRate(data.t, 38.3, 900);
        data.T = min(38.3 + data.beta .* data.t, 900);
        fprintf('  Two-column mixed-gas data detected: time + conversion X.\n');
        fprintf('  Heating-rate check: 10 K/min reaches %.1f C; 20 K/min reaches %.1f C before the 900 C hold.\n', ...
            min(38.3 + 10 .* max(data.t), 900), min(38.3 + 20 .* max(data.t), 900));
        fprintf('  Selected beta = %.0f K/min; mass reconstructed as 100*(1-X).\n', data.beta);
    else
        error('Unsupported data format in %s. Expected 2 or 3 numeric columns.', filename);
    end

    dt = gradient(data.t);
    dm = gradient(data.m);
    dmdt_raw = dm ./ dt;

    data.dmdt = smoothDerivative(dmdt_raw, smooth_span);
    fprintf('Loaded %-28s rows=%4d  T=%.1f-%.1f C  t=%.1f-%.1f min  m=%.3f-%.3f %%\n', ...
        filename, numel(data.T), min(data.T), max(data.T), min(data.t), max(data.t), ...
        min(data.m), max(data.m));
end

function beta = chooseHeatingRate(t, T0, T_target)
    beta_candidates = [10, 20];
    max_T = T0 + beta_candidates .* max(t);
    reaches_target = max_T >= T_target;
    if any(reaches_target)
        beta = beta_candidates(find(reaches_target, 1, 'first'));
    else
        [~, idx] = min(abs(max_T - T_target));
        beta = beta_candidates(idx);
    end
end

function y = smoothDerivative(x, smooth_span)
    x = x(:);
    if mod(smooth_span, 2) == 0
        smooth_span = smooth_span + 1;
    end
    smooth_span = min(smooth_span, numel(x) - mod(numel(x) + 1, 2));
    if smooth_span < 5
        y = x;
        return;
    end

    if exist('sgolayfilt', 'file') || exist('sgolayfilt', 'builtin')
        y = sgolayfilt(x, 3, smooth_span);
    else
        y = movmean(x, smooth_span, 'Endpoints', 'shrink');
    end
end

function plotIndividualPanels(datasets, style)
    for i = 1:numel(datasets)
        d = datasets(i).data;
        fig = figure('Name', ['TG/DTG ' datasets(i).label], ...
            'Color', style.figureColor, 'Position', style.figSizeTall);
        tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

        ax1 = nexttile;
        plot(ax1, d.T, d.m, lineStyleForKey(datasets(i).key), ...
            'Color', colorForKey(datasets(i).key, style), ...
            'LineWidth', style.lineWidth);
        xlabel(ax1, 'Temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
        ylabel(ax1, 'Mass (%)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
        text(ax1, 0.02, 0.92, 'A', 'Units', 'normalized', ...
            'FontName', style.fontName, 'FontSize', style.panelFontSize, ...
            'FontWeight', 'bold');

        ax2 = nexttile;
        plot(ax2, d.T, d.dmdt, lineStyleForKey(datasets(i).key), ...
            'Color', colorForKey(datasets(i).key, style), ...
            'LineWidth', style.lineWidth);
        xlabel(ax2, 'Temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
        ylabel(ax2, 'dm/dt (%/min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
        text(ax2, 0.02, 0.92, 'B', 'Units', 'normalized', ...
            'FontName', style.fontName, 'FontSize', style.panelFontSize, ...
            'FontWeight', 'bold');

        ApplyFigureFormat(fig);
        applyPaperAxes(fig, style);
        basename = ['Paper_Fig_' sanitizeKey(datasets(i).key) '_TG_DTG'];
        ExportFigure(fig, basename);
    end
end

function plotComparisonTG(datasets, style)
    fig = figure('Name', '900 C TG comparison', 'Color', style.figureColor, ...
        'Position', style.figSizeMid);
    ax = axes(fig);
    hold(ax, 'on');
    for i = 1:numel(datasets)
        d = datasets(i).data;
        plot(ax, d.T, d.m, lineStyleForKey(datasets(i).key), ...
            'Color', colorForKey(datasets(i).key, style), ...
            'LineWidth', style.lineWidth, 'DisplayName', datasets(i).label);
    end
    xlabel(ax, 'Temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel(ax, 'Mass (%)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend(ax, 'Location', 'northeast', 'Box', 'off', ...
        'FontName', style.fontName, 'FontSize', style.legendFontSize);
    ApplyFigureFormat(fig);
    applyPaperAxes(fig, style);
    ExportFigure(fig, 'Paper_Fig_900C_CO2_H2O_only_TG_compare');
end

function plotComparisonDTG(datasets, style)
    fig = figure('Name', '900 C DTG comparison', 'Color', style.figureColor, ...
        'Position', style.figSizeMid);
    ax = axes(fig);
    hold(ax, 'on');
    for i = 1:numel(datasets)
        d = datasets(i).data;
        plot(ax, d.T, d.dmdt, lineStyleForKey(datasets(i).key), ...
            'Color', colorForKey(datasets(i).key, style), ...
            'LineWidth', style.lineWidth, 'DisplayName', datasets(i).label);
    end
    xlabel(ax, 'Temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel(ax, 'dm/dt (%/min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend(ax, 'Location', 'best', 'Box', 'off', ...
        'FontName', style.fontName, 'FontSize', style.legendFontSize);
    ApplyFigureFormat(fig);
    applyPaperAxes(fig, style);
    ExportFigure(fig, 'Paper_Fig_900C_CO2_H2O_only_DTG_compare');
end

function plotComparisonPanels(datasets, style)
    fig = figure('Name', '900 C TG/DTG panels', 'Color', style.figureColor, ...
        'Position', style.figSizeTall);
    tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

    ax1 = nexttile;
    hold(ax1, 'on');
    for i = 1:numel(datasets)
        d = datasets(i).data;
        plot(ax1, d.T, d.m, lineStyleForKey(datasets(i).key), ...
            'Color', colorForKey(datasets(i).key, style), ...
            'LineWidth', style.lineWidth, 'DisplayName', datasets(i).label);
    end
    xlabel(ax1, 'Temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel(ax1, 'Mass (%)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend(ax1, 'Location', 'northeast', 'Box', 'off', ...
        'FontName', style.fontName, 'FontSize', style.legendFontSize);
    text(ax1, 0.02, 0.92, 'A', 'Units', 'normalized', ...
        'FontName', style.fontName, 'FontSize', style.panelFontSize, ...
        'FontWeight', 'bold');

    ax2 = nexttile;
    hold(ax2, 'on');
    for i = 1:numel(datasets)
        d = datasets(i).data;
        plot(ax2, d.T, d.dmdt, lineStyleForKey(datasets(i).key), ...
            'Color', colorForKey(datasets(i).key, style), ...
            'LineWidth', style.lineWidth, 'DisplayName', datasets(i).label);
    end
    xlabel(ax2, 'Temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel(ax2, 'dm/dt (%/min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend(ax2, 'Location', 'best', 'Box', 'off', ...
        'FontName', style.fontName, 'FontSize', style.legendFontSize);
    text(ax2, 0.02, 0.92, 'B', 'Units', 'normalized', ...
        'FontName', style.fontName, 'FontSize', style.panelFontSize, ...
        'FontWeight', 'bold');

    ApplyFigureFormat(fig);
    applyPaperAxes(fig, style);
    ExportFigure(fig, 'Paper_Fig_900C_CO2_H2O_only_TG_DTG_panels');
end

function style = paperStyle()
    style = PaperStyle();
    style.fontName = 'Arial';
    style.labelFontSize = 10;
    style.titleFontSize = 10;
    style.axesFontSize = 9;
    style.legendFontSize = 8;
    style.panelFontSize = 11;
    style.lineWidth = 1.7;
    style.thinLineWidth = 1.1;
    style.exportResolution = 600;
    style.figSizeMid = [80 80 640 390];
    style.figSizeTall = [80 80 640 560];
    style.colors.blue = [0 114 178] ./ 255;
    style.colors.red = [213 94 0] ./ 255;
    style.colors.green = [0 158 115] ./ 255;
    style.colors.black = [0 0 0];
end

function applyPaperAxes(fig, style)
    ax = findall(fig, 'Type', 'axes');
    for i = 1:numel(ax)
        set(ax(i), 'FontName', style.fontName, ...
            'FontSize', style.axesFontSize, ...
            'LineWidth', 1.0, ...
            'Box', 'off', ...
            'TickDir', 'out', ...
            'TickLength', [0.012 0.012]);
    end
    legends = findall(fig, 'Type', 'Legend');
    for i = 1:numel(legends)
        set(legends(i), 'FontName', style.fontName, ...
            'FontSize', style.legendFontSize, ...
            'Box', 'off', ...
            'Interpreter', 'tex');
    end
end

function c = colorForKey(key, style)
    switch key
        case 'co2'
            c = style.colors.blue;
        case 'h2o'
            c = style.colors.red;
        case 'mix'
            c = style.colors.green;
        otherwise
            c = style.colors.black;
    end
end

function s = lineStyleForKey(key)
    switch key
        case 'co2'
            s = '-';
        case 'h2o'
            s = '--';
        case 'mix'
            s = '-.';
        otherwise
            s = '-';
    end
end

function key = sanitizeKey(key)
    key = strrep(key, '/', '_');
    key = strrep(key, '-', '_');
end

