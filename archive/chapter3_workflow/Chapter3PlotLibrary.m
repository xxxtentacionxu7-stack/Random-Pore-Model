function Chapter3PlotLibrary(whichFig)
%CHAPTER3_PLOT_LIB Generate Chapter 3 TGA/RPM thesis figures.
% Usage:
%   Chapter3PlotLibrary('Fig3-1')
%   Chapter3PlotLibrary('all')

    if nargin < 1 || isempty(whichFig)
        whichFig = 'all';
    end

    cfg = chapter3Config();
    addpath(cfg.chapterDir);

    switch lower(strtrim(whichFig))
        case {'all', '*'}
            plotFig31(cfg);
            plotFig32(cfg);
            plotFig33(cfg);
            plotFig34(cfg);
            plotFig35(cfg);
            plotFig36(cfg);
            plotFig37(cfg);
        case {'fig3-1', '3-1'}
            plotFig31(cfg);
        case {'fig3-2', '3-2'}
            plotFig32(cfg);
        case {'fig3-3', '3-3'}
            plotFig33(cfg);
        case {'fig3-4', '3-4'}
            plotFig34(cfg);
        case {'fig3-5', '3-5'}
            plotFig35(cfg);
        case {'fig3-6', '3-6'}
            plotFig36(cfg);
        case {'fig3-7', '3-7'}
            plotFig37(cfg);
        otherwise
            error('Unknown figure key: %s', whichFig);
    end
end

function cfg = chapter3Config()
    cfg.chapterDir = fileparts(mfilename('fullpath'));
    cfg.projectDir = fileparts(cfg.chapterDir);
    cfg.dataDir = fullfile(cfg.projectDir, 'claude');
    cfg.temps = [850, 900, 950];
    cfg.atmospheres = {'CO2', 'H2O'};
    cfg.smoothSpan = 11;
    cfg.exportResolution = 600;

    cfg.fontName = 'Times New Roman';
    cfg.figureColor = 'white';
    cfg.axisLineWidth = 1.2;
    cfg.curveLineWidth = 2.0;
    cfg.fitLineWidth = 2.0;
    cfg.markerSize = 6;
    cfg.axesFontSize = 11;
    cfg.labelFontSize = 12;
    cfg.legendFontSize = 10;
    cfg.panelFontSize = 12;
    cfg.annotationFontSize = 10;
    cfg.tickDirection = 'in';

    cfg.tempColors = [
        0.000, 0.447, 0.741;  % 850 C
        0.850, 0.325, 0.098;  % 900 C
        0.466, 0.674, 0.188   % 950 C
    ];
    cfg.atmColors.CO2 = [0.000, 0.447, 0.741];
    cfg.atmColors.H2O = [0.850, 0.325, 0.098];
    cfg.gray = [0.45, 0.45, 0.45];
end

function plotFig31(cfg)
    data = loadChapterData(cfg);
    fig = figure('Color', cfg.figureColor, 'Position', [80, 80, 900, 390], ...
        'Name', 'Fig3-1 TG curves');
    tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    styleLabel(ylabel(tl, 'Mass (%)'), cfg);
    styleLabel(xlabel(tl, 'Time (min)'), cfg);

    plotTGPanel(nexttile(tl, 1), data.CO2, cfg, '(a) CO_2');
    plotTGPanel(nexttile(tl, 2), data.H2O, cfg, '(b) H_2O');

    exportFigure(fig, fullfile(cfg.chapterDir, 'Fig3-1'), 'Fig3-1_TG_Curves', cfg);
end

function plotFig32(cfg)
    data = loadChapterData(cfg);
    fig = figure('Color', cfg.figureColor, 'Position', [80, 80, 900, 390], ...
        'Name', 'Fig3-2 DTG curves');
    tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    styleLabel(ylabel(tl, 'DTG (% min^{-1})'), cfg);
    styleLabel(xlabel(tl, 'Time (min)'), cfg);

    plotDTGPanel(nexttile(tl, 1), data.CO2, cfg, '(a) CO_2');
    plotDTGPanel(nexttile(tl, 2), data.H2O, cfg, '(b) H_2O');

    exportFigure(fig, fullfile(cfg.chapterDir, 'Fig3-2'), 'Fig3-2_DTG_Curves', cfg);
end

function plotFig33(cfg)
    data = loadChapterData(cfg);
    fig = figure('Color', cfg.figureColor, 'Position', [80, 80, 900, 390], ...
        'Name', 'Fig3-3 Conversion curves');
    tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    styleLabel(ylabel(tl, 'Conversion (-)'), cfg);
    styleLabel(xlabel(tl, 'Time (min)'), cfg);

    plotConversionPanel(nexttile(tl, 1), data.CO2, cfg, '(a) CO_2');
    plotConversionPanel(nexttile(tl, 2), data.H2O, cfg, '(b) H_2O');

    exportFigure(fig, fullfile(cfg.chapterDir, 'Fig3-3'), 'Fig3-3_Conversion_Curves', cfg);
end

function plotFig34(cfg)
    data = loadChapterData(cfg);
    fig = figure('Color', cfg.figureColor, 'Position', [80, 80, 980, 330], ...
        'Name', 'Fig3-4 RPM fitting CO2');
    tl = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    styleLabel(ylabel(tl, 'Conversion (-)'), cfg);
    styleLabel(xlabel(tl, 'Time (min)'), cfg);

    for i = 1:numel(cfg.temps)
        ax = nexttile(tl, i);
        plotRPMFitPanel(ax, data.CO2(i), cfg.tempColors(i, :), cfg, ...
            sprintf('(%c) %s', char('a' + i - 1), tempLabel(cfg.temps(i))));
    end

    exportFigure(fig, fullfile(cfg.chapterDir, 'Fig3-4'), 'Fig3-4_RPM_Fitting_CO2', cfg);
end

function plotFig35(cfg)
    data = loadChapterData(cfg);
    fig = figure('Color', cfg.figureColor, 'Position', [80, 80, 980, 330], ...
        'Name', 'Fig3-5 RPM fitting H2O');
    tl = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    styleLabel(ylabel(tl, 'Conversion (-)'), cfg);
    styleLabel(xlabel(tl, 'Time (min)'), cfg);

    for i = 1:numel(cfg.temps)
        ax = nexttile(tl, i);
        plotRPMFitPanel(ax, data.H2O(i), cfg.tempColors(i, :), cfg, ...
            sprintf('(%c) %s', char('a' + i - 1), tempLabel(cfg.temps(i))));
    end

    exportFigure(fig, fullfile(cfg.chapterDir, 'Fig3-5'), 'Fig3-5_RPM_Fitting_H2O', cfg);
end

function plotFig36(cfg)
    data = loadChapterData(cfg);
    fig = figure('Color', cfg.figureColor, 'Position', [80, 80, 900, 390], ...
        'Name', 'Fig3-6 RPM parameters');
    tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    ax1 = nexttile(tl, 1);
    hold(ax1, 'on');
    plot(ax1, cfg.temps, [data.CO2.rpm_k], '-o', 'Color', cfg.atmColors.CO2, ...
        'LineWidth', cfg.curveLineWidth, 'MarkerSize', cfg.markerSize, ...
        'MarkerFaceColor', 'w', 'DisplayName', 'CO_2');
    plot(ax1, cfg.temps, [data.H2O.rpm_k], '--s', 'Color', cfg.atmColors.H2O, ...
        'LineWidth', cfg.curveLineWidth, 'MarkerSize', cfg.markerSize, ...
        'MarkerFaceColor', 'w', 'DisplayName', 'H_2O');
    styleLabel(xlabel(ax1, 'Temperature (^{\circ}C)', 'Interpreter', 'tex'), cfg);
    styleLabel(ylabel(ax1, 'k (min^{-1})', 'Interpreter', 'tex'), cfg);
    addPanelLabel(ax1, '(a)', cfg);
    legend(ax1, 'Location', 'southeast', 'Box', 'off', 'Interpreter', 'tex');

    ax2 = nexttile(tl, 2);
    hold(ax2, 'on');
    plot(ax2, cfg.temps, [data.CO2.rpm_psi], '-o', 'Color', cfg.atmColors.CO2, ...
        'LineWidth', cfg.curveLineWidth, 'MarkerSize', cfg.markerSize, ...
        'MarkerFaceColor', 'w', 'DisplayName', 'CO_2');
    plot(ax2, cfg.temps, [data.H2O.rpm_psi], '--s', 'Color', cfg.atmColors.H2O, ...
        'LineWidth', cfg.curveLineWidth, 'MarkerSize', cfg.markerSize, ...
        'MarkerFaceColor', 'w', 'DisplayName', 'H_2O');
    styleLabel(xlabel(ax2, 'Temperature (^{\circ}C)', 'Interpreter', 'tex'), cfg);
    styleLabel(ylabel(ax2, '\psi (-)', 'Interpreter', 'tex'), cfg);
    addPanelLabel(ax2, '(b)', cfg);
    legend(ax2, 'Location', 'southeast', 'Box', 'off', 'Interpreter', 'tex');

    formatFigure(fig, cfg);
    exportFigure(fig, fullfile(cfg.chapterDir, 'Fig3-6'), 'Fig3-6_RPM_Parameters', cfg);
end

function plotFig37(cfg)
    data = loadChapterData(cfg);
    syn = computeSynergyAt850(data, cfg);

    fig = figure('Color', cfg.figureColor, 'Position', [80, 80, 680, 420], ...
        'Name', 'Fig3-7 Synergy factor R');
    ax = axes(fig);
    hold(ax, 'on');

    xMax = 1;
    yMax = max(1.25, max([syn.Rmean]) + 0.25);
    patch(ax, [0, xMax, xMax, 0], [0, 0, 1, 1], [0.92, 0.92, 0.92], ...
        'EdgeColor', 'none', 'FaceAlpha', 0.55, 'HandleVisibility', 'off');
    yline(ax, 1, '--', 'R = 1', 'Color', cfg.gray, 'LineWidth', 1.2, ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom', ...
        'FontName', cfg.fontName, 'FontSize', cfg.annotationFontSize, ...
        'Interpreter', 'tex', 'HandleVisibility', 'off');

    for i = 1:numel(syn)
        plot(ax, syn(i).X, syn(i).R, '-', 'Color', cfg.tempColors(i, :), ...
            'LineWidth', cfg.curveLineWidth, 'DisplayName', syn(i).label);
    end

    text(ax, 0.06, 0.45, 'Inhibition', 'Units', 'data', ...
        'FontName', cfg.fontName, 'FontSize', cfg.annotationFontSize, ...
        'Color', cfg.gray);
    styleLabel(xlabel(ax, 'Conversion (-)'), cfg);
    styleLabel(ylabel(ax, 'Synergy factor R (-)'), cfg);
    xlim(ax, [0, xMax]);
    ylim(ax, [0, yMax]);
    legend(ax, 'Location', 'northeast', 'Box', 'off', 'Interpreter', 'tex');
    formatFigure(fig, cfg);

    exportFigure(fig, fullfile(cfg.chapterDir, 'Fig3-7'), 'Fig3-7_Synergy_Factor_R', cfg);
end

function plotTGPanel(ax, series, cfg, panelLabel)
    hold(ax, 'on');
    for i = 1:numel(series)
        plot(ax, series(i).iso_t, series(i).iso_m, '-', ...
            'Color', cfg.tempColors(i, :), 'LineWidth', cfg.curveLineWidth, ...
            'DisplayName', tempLabel(series(i).temp));
    end
    addPanelLabel(ax, panelLabel, cfg);
    legend(ax, 'Location', 'northeast', 'Box', 'off', 'Interpreter', 'tex');
    formatAxes(ax, cfg);
end

function plotDTGPanel(ax, series, cfg, panelLabel)
    hold(ax, 'on');
    for i = 1:numel(series)
        plot(ax, series(i).iso_t, -series(i).iso_dmdt, '-', ...
            'Color', cfg.tempColors(i, :), 'LineWidth', cfg.curveLineWidth, ...
            'DisplayName', tempLabel(series(i).temp));
    end
    addPanelLabel(ax, panelLabel, cfg);
    legend(ax, 'Location', 'best', 'Box', 'off', 'Interpreter', 'tex');
    formatAxes(ax, cfg);
end

function plotConversionPanel(ax, series, cfg, panelLabel)
    hold(ax, 'on');
    for i = 1:numel(series)
        plot(ax, series(i).iso_t, series(i).iso_X, '-', ...
            'Color', cfg.tempColors(i, :), 'LineWidth', cfg.curveLineWidth, ...
            'DisplayName', tempLabel(series(i).temp));
    end
    ylim(ax, [0, 1.02]);
    addPanelLabel(ax, panelLabel, cfg);
    legend(ax, 'Location', 'southeast', 'Box', 'off', 'Interpreter', 'tex');
    formatAxes(ax, cfg);
end

function plotRPMFitPanel(ax, d, color, cfg, panelLabel)
    hold(ax, 'on');
    idx = downsampleIndex(numel(d.rpm_t), 45);
    plot(ax, d.rpm_t(idx), d.rpm_X_data(idx), 'o', ...
        'Color', color, 'MarkerFaceColor', 'w', ...
        'MarkerSize', cfg.markerSize, 'LineWidth', cfg.axisLineWidth, ...
        'DisplayName', 'Experiment');
    plot(ax, d.rpm_t, d.rpm_X_fit, '-', ...
        'Color', color, 'LineWidth', cfg.fitLineWidth, ...
        'DisplayName', 'RPM fit');
    ylim(ax, [0, 1.03]);
    xlim(ax, [0, max(d.rpm_t)]);
    addPanelLabel(ax, panelLabel, cfg);
    text(ax, 0.52, 0.18, sprintf('R^2 = %.4f', d.rpm_R2), ...
        'Units', 'normalized', 'Interpreter', 'tex', ...
        'FontName', cfg.fontName, 'FontSize', cfg.annotationFontSize);
    legend(ax, 'Location', 'southeast', 'Box', 'off', 'Interpreter', 'tex');
    formatAxes(ax, cfg);
end

function label = tempLabel(temp)
    label = sprintf('%d ^{\\circ}C', temp);
end

function addPanelLabel(ax, label, cfg)
    text(ax, 0.04, 0.92, label, 'Units', 'normalized', ...
        'FontName', cfg.fontName, ...
        'FontSize', cfg.panelFontSize, ...
        'FontWeight', 'bold', ...
        'Interpreter', 'tex');
end

function styleLabel(h, cfg)
    set(h, 'FontName', cfg.fontName, ...
        'FontSize', cfg.labelFontSize, ...
        'Interpreter', 'tex');
end

function data = loadChapterData(cfg)
    persistent cache;
    if ~isempty(cache)
        data = cache;
        return;
    end

    for a = 1:numel(cfg.atmospheres)
        atm = cfg.atmospheres{a};
        for i = 1:numel(cfg.temps)
            temp = cfg.temps(i);
            filename = fullfile(cfg.dataDir, sprintf('%s_%dC.txt', atm, temp));
            data.(atm)(i) = loadOneDataset(filename, atm, temp, cfg);
        end
    end

    cache = data;
end

function d = loadOneDataset(filename, atm, temp, cfg)
    if ~isfile(filename)
        error('Missing data file: %s', filename);
    end
    raw = readmatrix(filename, 'Delimiter', '\t', 'FileType', 'text');
    raw = raw(:, 1:min(3, size(raw, 2)));
    raw = raw(~any(isnan(raw), 2), :);
    if size(raw, 2) < 3
        error('Expected at least 3 numeric columns in %s', filename);
    end

    d.atm = atm;
    d.temp = temp;
    d.filename = filename;
    d.T = raw(:, 1);
    d.t = raw(:, 2);
    d.m = raw(:, 3);
    d.massAsh = mean(d.m(max(1, end - 9):end));
    d.X = clamp((d.m(1) - d.m) ./ (d.m(1) - d.massAsh), 0, 1);
    d.dmdt = smoothVector(gradient(d.m) ./ gradient(d.t), cfg.smoothSpan);
    d.dXdt = smoothVector(gradient(d.X) ./ gradient(d.t), cfg.smoothSpan);

    iso = extractIso(d, temp - 15, 1.0, cfg.smoothSpan);
    d.iso_t = iso.t;
    d.iso_m = iso.m;
    d.iso_X = iso.X;
    d.iso_dmdt = iso.dmdt;
    d.iso_dXdt = iso.dXdt;

    rpm = fitRPM(iso.t, iso.X);
    d.rpm_t = rpm.t;
    d.rpm_X_data = rpm.X_data;
    d.rpm_X_fit = rpm.X_fit;
    d.rpm_k = rpm.k;
    d.rpm_psi = rpm.psi;
    d.rpm_R2 = rpm.R2;
end

function iso = extractIso(d, Tstart, massDropThreshold, smoothSpan)
    idxT = find(d.T >= Tstart, 1, 'first');
    if isempty(idxT)
        error('No isothermal start found for %s at %.0f C.', d.filename, Tstart);
    end

    mRef = d.m(idxT);
    idxReact = idxT;
    for ii = idxT:numel(d.m)
        if (mRef - d.m(ii)) > massDropThreshold
            idxReact = ii;
            break;
        end
    end

    idx = idxReact:numel(d.m);
    X0 = d.X(idxReact);
    iso.t = d.t(idx) - d.t(idxReact);
    iso.m = d.m(idx);
    iso.X = clamp((d.X(idx) - X0) ./ max(1 - X0, eps), 0, 1);
    iso.dmdt = smoothVector(gradient(iso.m) ./ gradient(iso.t), smoothSpan);
    iso.dXdt = smoothVector(gradient(iso.X) ./ gradient(iso.t), smoothSpan);
end

function rpm = fitRPM(t, X)
    t = t(:);
    X = X(:);
    valid = isfinite(t) & isfinite(X) & t >= 0 & X >= 0 & X < 0.995;
    tFit = t(valid);
    XFit = X(valid);

    psiRange = linspace(0.01, 20, 600);
    sse = nan(size(psiRange));
    kVals = nan(size(psiRange));

    for i = 1:numel(psiRange)
        psi = psiRange(i);
        F = rpmF(XFit, psi);
        ok = isfinite(F) & tFit > 0;
        if nnz(ok) < 5
            continue;
        end
        k = (tFit(ok)' * F(ok)) / (tFit(ok)' * tFit(ok));
        pred = rpmInvert(k .* tFit(ok), psi);
        sse(i) = sum((XFit(ok) - pred).^2);
        kVals(i) = k;
    end

    [~, best] = min(sse);
    psi = psiRange(best);
    k = kVals(best);
    XpredAll = rpmInvert(k .* t, psi);
    predFit = rpmInvert(k .* tFit, psi);
    ssRes = sum((XFit - predFit).^2);
    ssTot = sum((XFit - mean(XFit)).^2);

    rpm.t = t;
    rpm.X_data = X;
    rpm.X_fit = clamp(XpredAll, 0, 1);
    rpm.k = k;
    rpm.psi = psi;
    rpm.R2 = 1 - ssRes / ssTot;
end

function F = rpmF(X, psi)
    X = clamp(X, 0, 0.999999);
    F = (2 ./ psi) .* (sqrt(1 - psi .* log(1 - X)) - 1);
end

function X = rpmInvert(F, psi)
    inner = (psi .* F ./ 2 + 1).^2;
    X = 1 - exp((1 - inner) ./ psi);
    X = clamp(X, 0, 1);
end

function syn = computeSynergyAt850(data, cfg)
    mixFiles = {
        'Mix_850C_5gH2O_100mLCO2.txt', '5 g H_2O-100 mL CO_2';
        'Mix_850C_5gH2O_40mLCO2.txt', '5 g H_2O-40 mL CO_2';
        'Mix_850C_0.83gH2O_100mLCO2.txt', '0.83 g H_2O-100 mL CO_2'
    };

    co2 = data.CO2(1);
    h2o = data.H2O(1);
    for i = 1:size(mixFiles, 1)
        filename = fullfile(cfg.dataDir, mixFiles{i, 1});
        label = mixFiles{i, 2};
        mix = loadMixDataset(filename, cfg);
        X = mix.iso_X(:);
        rateMix = mix.iso_dXdt(:);
        valid = X > 0.03 & X < 0.95;

        rateCO2 = zeros(size(X));
        rateH2O = zeros(size(X));
        argCO2 = 1 - co2.rpm_psi .* log(1 - X(valid));
        argH2O = 1 - h2o.rpm_psi .* log(1 - X(valid));
        rateCO2(valid) = co2.rpm_k .* (1 - X(valid)) .* sqrt(max(argCO2, 0));
        rateH2O(valid) = h2o.rpm_k .* (1 - X(valid)) .* sqrt(max(argH2O, 0));
        rateLinear = rateCO2 + rateH2O;

        R = nan(size(X));
        ok = valid & rateLinear > 1e-8 & isfinite(rateMix);
        R(ok) = rateMix(ok) ./ rateLinear(ok);
        keep = ok & isfinite(R) & R > 0 & R < 3;

        syn(i).label = label; %#ok<AGROW>
        syn(i).X = X(keep);
        syn(i).R = smoothVector(R(keep), cfg.smoothSpan);
        syn(i).Rmean = mean(syn(i).R, 'omitnan');
    end
end

function mix = loadMixDataset(filename, cfg)
    if ~isfile(filename)
        error('Missing mix data file: %s', filename);
    end
    raw = readmatrix(filename, 'Delimiter', '\t', 'FileType', 'text');
    raw = raw(:, 1:min(3, size(raw, 2)));
    raw = raw(~any(isnan(raw), 2), :);
    mix.T = raw(:, 1);
    mix.t = raw(:, 2);
    mix.m = raw(:, 3);
    mix.massAsh = mean(mix.m(max(1, end - 9):end));
    mix.X = clamp((mix.m(1) - mix.m) ./ (mix.m(1) - mix.massAsh), 0, 1);
    mix.dmdt = smoothVector(gradient(mix.m) ./ gradient(mix.t), cfg.smoothSpan);
    mix.dXdt = smoothVector(gradient(mix.X) ./ gradient(mix.t), cfg.smoothSpan);
    iso = extractIso(mix, 840, 1.0, cfg.smoothSpan);
    mix.iso_t = iso.t;
    mix.iso_m = iso.m;
    mix.iso_X = iso.X;
    mix.iso_dXdt = iso.dXdt;
end

function y = smoothVector(x, span)
    x = x(:);
    if numel(x) < 5
        y = x;
        return;
    end
    if mod(span, 2) == 0
        span = span + 1;
    end
    span = min(span, numel(x) - 1 + mod(numel(x), 2));
    span = max(span, 5);
    if mod(span, 2) == 0
        span = span - 1;
    end

    if exist('sgolayfilt', 'file') || exist('sgolayfilt', 'builtin')
        y = sgolayfilt(x, 3, span);
    else
        y = movmean(x, span, 'Endpoints', 'shrink');
    end
end

function idx = downsampleIndex(n, targetN)
    if n <= targetN
        idx = 1:n;
    else
        idx = unique(round(linspace(1, n, targetN)));
    end
end

function formatFigure(fig, cfg)
    set(fig, 'Color', cfg.figureColor);
    ax = findall(fig, 'Type', 'axes');
    for i = 1:numel(ax)
        formatAxes(ax(i), cfg);
    end
    leg = findall(fig, 'Type', 'Legend');
    for i = 1:numel(leg)
        set(leg(i), 'FontName', cfg.fontName, ...
            'FontSize', cfg.legendFontSize, ...
            'Box', 'off', ...
            'Interpreter', 'tex');
    end
end

function formatAxes(ax, cfg)
    set(ax, 'FontName', cfg.fontName, 'FontSize', cfg.axesFontSize, ...
        'LineWidth', cfg.axisLineWidth, 'TickDir', cfg.tickDirection, ...
        'Box', 'on', 'Layer', 'top', 'Color', cfg.figureColor);
    styleLabel(ax.XLabel, cfg);
    styleLabel(ax.YLabel, cfg);
    title(ax, '');
    grid(ax, 'off');
end

function exportFigure(fig, outDir, baseName, cfg)
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end
    formatFigure(fig, cfg);
    set(fig, 'Renderer', 'painters');
    drawnow;

    if isappdata(0, 'Chapter3ValidationSkipExport') && getappdata(0, 'Chapter3ValidationSkipExport')
        return;
    end

    savefig(fig, fullfile(outDir, [baseName '.fig']));
    if exist('exportgraphics', 'file') || exist('exportgraphics', 'builtin')
        exportgraphics(fig, fullfile(outDir, [baseName '.png']), ...
            'Resolution', cfg.exportResolution, 'BackgroundColor', 'white');
        exportgraphics(fig, fullfile(outDir, [baseName '.pdf']), ...
            'ContentType', 'vector', 'BackgroundColor', 'white');
    else
        print(fig, fullfile(outDir, [baseName '.png']), '-dpng', ...
            sprintf('-r%d', cfg.exportResolution));
        print(fig, fullfile(outDir, [baseName '.pdf']), '-dpdf', '-painters');
    end
end

function y = clamp(x, lo, hi)
    y = min(max(x, lo), hi);
end

