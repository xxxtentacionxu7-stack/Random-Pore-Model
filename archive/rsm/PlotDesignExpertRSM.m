function PlotDesignExpertRSM(dataDir)
if nargin < 1
    dataDir = fullfile(pwd, 'outputs', 'rsm_figures');
end

factors = readtable(fullfile(dataDir, 'factors.csv'), 'TextType', 'string', 'Encoding', 'UTF-8');
responses = readtable(fullfile(dataDir, 'responses.csv'), 'TextType', 'string', 'Encoding', 'UTF-8');
runs = readtable(fullfile(dataDir, 'design_expert_runs.csv'), 'TextType', 'string', 'Encoding', 'UTF-8');
models = readtable(fullfile(dataDir, 'response_models.csv'), 'TextType', 'string', 'Encoding', 'UTF-8');

if ~any(models.response_id == "4")
    h2 = models(models.response_id == "1", :);
    co = models(models.response_id == "2", :);
    h2.response_id(:) = "4";
    co.response_id(:) = "4";
    h2.response_name(:) = "鍚堟垚姘斾綋绉?;
    co.response_name(:) = "鍚堟垚姘斾綋绉?;
    h2.response_unit(:) = "mL";
    co.response_unit(:) = "mL";
    models = [models; h2; co];
end

outDir = fullfile(dataDir, 'figures');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

try
    set(groot, 'defaultAxesFontName', 'Microsoft YaHei');
    set(groot, 'defaultTextFontName', 'Microsoft YaHei');
catch
end
set(groot, 'defaultAxesFontSize', 9);
set(groot, 'defaultLineLineWidth', 1.2);
set(groot, 'defaultFigureColor', 'w');

pairs = nchoosek(1:height(factors), 2);
gridN = 55;

for r = 1:height(responses)
    responseId = string(responses.id(r));
    responseModels = models(models.response_id == responseId, :);
    if isempty(responseModels)
        continue
    end

    responseName = string(responses.name(r));
    responseUnit = string(responses.unit(r));
    safeName = matlab.lang.makeValidName(char(responseName));

    fig3d = figure('Units', 'centimeters', 'Position', [1, 1, 28, 18], 'Renderer', 'painters');
    t3 = tiledlayout(fig3d, 2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t3, responseTitle(responseName, responseUnit, "3D response surfaces"), 'FontWeight', 'bold', 'FontSize', 12);

    fig2d = figure('Units', 'centimeters', 'Position', [1, 1, 28, 18], 'Renderer', 'painters');
    t2 = tiledlayout(fig2d, 2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t2, responseTitle(responseName, responseUnit, "Contour maps"), 'FontWeight', 'bold', 'FontSize', 12);

    for p = 1:size(pairs, 1)
        i = pairs(p, 1);
        j = pairs(p, 2);
        xi = linspace(factors.low(i), factors.high(i), gridN);
        xj = linspace(factors.low(j), factors.high(j), gridN);
        [XI, XJ] = meshgrid(xi, xj);
        actual = factors.center';
        Z = zeros(size(XI));
        for k = 1:numel(XI)
            actual(i) = XI(k);
            actual(j) = XJ(k);
            Z(k) = predictResponse(actual, factors, responseModels);
        end

        ax = nexttile(t3);
        surf(ax, XI, XJ, Z, 'EdgeColor', [0.2 0.2 0.2], 'EdgeAlpha', 0.14, 'FaceAlpha', 0.97);
        hold(ax, 'on');
        scatter3(ax, double(runs.(factors.id(i))), double(runs.(factors.id(j))), double(runs.("Y" + responseId)), ...
            28, 'filled', 'MarkerFaceColor', [0.9 0.2 0.1], 'MarkerEdgeColor', 'k', 'LineWidth', 0.35);
        hold(ax, 'off');
        colormap(ax, parula);
        xlabel(ax, factorLabel(factors, i));
        ylabel(ax, factorLabel(factors, j));
        zlabel(ax, responseAxisLabel(responseName, responseUnit));
        title(ax, panelTitle(factors, i, j), 'FontSize', 8.5);
        grid(ax, 'on');
        box(ax, 'on');
        view(ax, [-42, 28]);
        axis(ax, 'tight');

        ax = nexttile(t2);
        contourf(ax, XI, XJ, Z, 14, 'LineColor', 'none');
        hold(ax, 'on');
        contour(ax, XI, XJ, Z, 8, 'LineColor', [0.15 0.15 0.15], 'LineWidth', 0.45);
        scatter(ax, double(runs.(factors.id(i))), double(runs.(factors.id(j))), 20, ...
            'o', 'filled', 'MarkerFaceColor', [0.95 0.95 0.95], 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
        hold(ax, 'off');
        colormap(ax, parula);
        cb = colorbar(ax);
        cb.Label.String = responseAxisLabel(responseName, responseUnit);
        xlabel(ax, factorLabel(factors, i));
        ylabel(ax, factorLabel(factors, j));
        title(ax, panelTitle(factors, i, j), 'FontSize', 8.5);
        axis(ax, 'tight');
        box(ax, 'on');
    end

    exportAll(fig3d, outDir, sprintf('%s_3D_response_surfaces', safeName));
    exportAll(fig2d, outDir, sprintf('%s_contour_maps', safeName));
    close(fig3d);
    close(fig2d);
end

makeSummaryFigure(dataDir, outDir, factors, responses, runs);
end

function y = predictResponse(actual, factors, model)
coded = containers.Map;
for ii = 1:height(factors)
    coded(char(factors.id(ii))) = (actual(ii) - factors.center(ii)) / factors.half_range(ii);
end
y = 0;
for ii = 1:height(model)
    term = char(model.term(ii));
    coef = str2double(model.coef(ii));
    if strcmp(term, 'Intercept')
        value = 1;
    elseif contains(term, '^2')
        key = erase(term, '^2');
        value = coded(char(key)) ^ 2;
    elseif strlength(string(term)) == 2
        value = coded(term(1)) * coded(term(2));
    else
        value = coded(term);
    end
    y = y + coef * value;
end
end

function s = factorLabel(factors, idx)
unit = string(factors.unit(idx));
if unit == ""
    s = char(factors.name(idx));
else
    s = char(factors.name(idx) + " (" + unit + ")");
end
end

function s = responseAxisLabel(name, unit)
if unit == ""
    s = char(name);
else
    s = char(name + " (" + unit + ")");
end
end

function s = panelTitle(factors, i, j)
fixed = strings(0);
for k = 1:height(factors)
    if k ~= i && k ~= j
        fixed(end + 1) = factors.name(k) + "=" + strip(string(num2str(factors.center(k), '%.3g'))) + factors.unit(k); %#ok<AGROW>
    end
end
s = char(factors.id(i) + "-" + factors.id(j) + " | fixed: " + strjoin(fixed, ", "));
end

function s = responseTitle(name, unit, suffix)
s = char(name + " (" + unit + ") - " + suffix);
end

function exportAll(fig, outDir, baseName)
pngPath = fullfile(outDir, baseName + ".png");
pdfPath = fullfile(outDir, baseName + ".pdf");
svgPath = fullfile(outDir, baseName + ".svg");
exportgraphics(fig, pngPath, 'Resolution', 600);
exportgraphics(fig, pdfPath, 'ContentType', 'vector');
exportgraphics(fig, svgPath, 'ContentType', 'vector');
end

function makeSummaryFigure(dataDir, outDir, factors, responses, runs)
fig = figure('Units', 'centimeters', 'Position', [1, 1, 22, 15], 'Renderer', 'painters');
t = tiledlayout(fig, 2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
title(t, 'Design-Expert experimental responses (30 runs)', 'FontWeight', 'bold', 'FontSize', 12);
for r = 1:height(responses)
    ax = nexttile(t);
    yName = "Y" + string(responses.id(r));
    scatter(ax, double(runs.runNo), double(runs.(yName)), 34, double(runs.A), 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 0.35);
    xlabel(ax, 'Run number');
    ylabel(ax, responseAxisLabel(responses.name(r), responses.unit(r)));
    title(ax, char(responses.name(r)), 'FontSize', 9);
    grid(ax, 'on');
    box(ax, 'on');
end
colormap(fig, parula);
exportAll(fig, outDir, "experimental_response_summary");
close(fig);

copyfile(fullfile(dataDir, 'design_expert_runs.csv'), fullfile(outDir, 'design_expert_runs.csv'));
copyfile(fullfile(dataDir, 'response_models.csv'), fullfile(outDir, 'response_models.csv'));
end


