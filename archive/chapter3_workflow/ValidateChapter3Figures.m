function ValidateChapter3Figures()
%% ValidateChapter3Figures
% Validate Chapter 3 TGA/RPM figure folders, exported files, data files,
% MATLAB plotting scripts, and generated figure contents.

clc; close all;

chapterDir = fileparts(mfilename('fullpath'));
if isempty(chapterDir)
    chapterDir = pwd;
end
projectDir = fileparts(chapterDir);
dataDir = fullfile(projectDir, 'claude');
reportPath = fullfile(chapterDir, 'Chapter3_validation_report.txt');

checks = {};
summary = struct('PASS', 0, 'WARN', 0, 'FAIL', 0);

figs = {
    'Fig3-1', 'Fig3-1_TG_Curves',          'PlotFig31TG.m';
    'Fig3-2', 'Fig3-2_DTG_Curves',         'PlotFig32DTG.m';
    'Fig3-3', 'Fig3-3_Conversion_Curves',  'PlotFig33Conversion.m';
    'Fig3-4', 'Fig3-4_RPM_Fitting_CO2',    'PlotFig34RPMFittingCO2.m';
    'Fig3-5', 'Fig3-5_RPM_Fitting_H2O',    'PlotFig35RPMFittingH2O.m';
    'Fig3-6', 'Fig3-6_RPM_Parameters',     'PlotFig36RPMParameters.m';
    'Fig3-7', 'Fig3-7_Synergy_Factor_R',   'PlotFig37SynergyFactor.m';
};

addpath(chapterDir);

logLine('PASS', '寮€濮嬬涓夌珷 TGA/RPM 鍥剧墖妫€鏌?);
logLine('PASS', ['绔犺妭鐩綍: ' chapterDir]);

%% 1-5. Folder and export checks.
for i = 1:size(figs, 1)
    figId = figs{i, 1};
    baseName = figs{i, 2};
    scriptName = figs{i, 3};
    figDir = fullfile(chapterDir, figId);

    if isfolder(figDir)
        logLine('PASS', [figId ' 鏂囦欢澶瑰瓨鍦?]);
    else
        logLine('FAIL', [figId ' 鏂囦欢澶圭己澶?]);
        continue;
    end

    pngPath = fullfile(figDir, [baseName '.png']);
    pdfPath = fullfile(figDir, [baseName '.pdf']);
    figPath = fullfile(figDir, [baseName '.fig']);
    scriptPath = fullfile(figDir, scriptName);
    readmePath = fullfile(figDir, 'README.md');
    captionCNPath = fullfile(figDir, 'Caption_CN.txt');
    captionENPath = fullfile(figDir, 'Caption_EN.txt');
    sourceDataPath = fullfile(figDir, 'source_data.csv');

    checkFileExists([figId ' PNG瀛樺湪'], pngPath, false);
    checkFileExists([figId ' PDF瀛樺湪'], pdfPath, false);
    checkFileExists([figId ' FIG瀛樺湪'], figPath, true);
    checkFileExists([figId ' 缁樺浘鑴氭湰.m瀛樺湪'], scriptPath, false);
    checkFileExists([figId ' README.md瀛樺湪'], readmePath, false);
    checkFileExists([figId ' Caption_CN.txt瀛樺湪'], captionCNPath, false);
    checkFileExists([figId ' Caption_EN.txt瀛樺湪'], captionENPath, false);
    checkFileExists([figId ' source_data.csv瀛樺湪'], sourceDataPath, false);

    validatePng(figId, pngPath);
    validatePdf(figId, pdfPath);
    validateReadme(figId, readmePath);
    validateSourceData(figId, sourceDataPath);
end

%% 7. Main generation script exists and can run.
mainScript = fullfile(chapterDir, 'RunChapter3Figures.m');
checkFileExists('RunChapter3Figures.m瀛樺湪', mainScript, false);

%% 8-10. Raw data and RPM summary checks.
validateRawData(dataDir);
validateRpmSummary(fullfile(chapterDir, 'Fig3_RPM_fit_summary.csv'));

%% 6, 9. Run plotting scripts independently and inspect generated figure data.
for i = 1:size(figs, 1)
    figId = figs{i, 1};
    scriptPath = fullfile(chapterDir, figId, figs{i, 3});
    validatePlotScript(figId, scriptPath);
end

%% 7. Run the all-in-one script from scratch.
validateMakeAll(mainScript);

%% Write report.
fid = fopen(reportPath, 'w');
if fid < 0
    error('Cannot write validation report: %s', reportPath);
end
fprintf(fid, 'Chapter 3 TGA/RPM Validation Report\n');
fprintf(fid, 'Generated: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf(fid, 'Chapter directory: %s\n\n', chapterDir);
for i = 1:numel(checks)
    fprintf(fid, '%s\n', checks{i});
end
fprintf(fid, '\nSummary: PASS=%d, WARN=%d, FAIL=%d\n', ...
    summary.PASS, summary.WARN, summary.FAIL);
fclose(fid);

fprintf('\nValidation report written to:\n%s\n', reportPath);
fprintf('Summary: PASS=%d, WARN=%d, FAIL=%d\n', ...
    summary.PASS, summary.WARN, summary.FAIL);

%% Local helper functions.
function logLine(level, message)
    line = sprintf('[%s] %s', upper(level), message);
    checks{end + 1} = line; %#ok<SAGROW>
    switch upper(level)
        case 'PASS'
            summary.PASS = summary.PASS + 1;
        case 'WARN'
            summary.WARN = summary.WARN + 1;
        case 'FAIL'
            summary.FAIL = summary.FAIL + 1;
        otherwise
            summary.WARN = summary.WARN + 1;
    end
    fprintf('%s\n', line);
end

function checkFileExists(label, filePath, warnOnly)
    if isfile(filePath)
        info = dir(filePath);
        if info.bytes > 0
            logLine('PASS', label);
        else
            logLine('FAIL', [label '锛屼絾鏂囦欢涓虹┖']);
        end
    elseif warnOnly
        logLine('WARN', strrep(label, '瀛樺湪', '缂哄け'));
    else
        logLine('FAIL', strrep(label, '瀛樺湪', '缂哄け'));
    end
end

function validatePng(figId, pngPath)
    if ~isfile(pngPath)
        return;
    end
    try
        info = imfinfo(pngPath);
        if info.Width > 0 && info.Height > 0
            logLine('PASS', [figId ' 鍥剧墖鎴愬姛瀵煎嚭']);
            logLine('PASS', sprintf('%s PNG鍒嗚鲸鐜囨湁鏁? %d x %d px', ...
                figId, info.Width, info.Height));
        else
            logLine('FAIL', [figId ' PNG瀹藉害鎴栭珮搴︿负0']);
        end

        [dpiX, dpiY, dpiKnown] = getPngDpi(info);
        if dpiKnown && abs(dpiX - 600) <= 5 && abs(dpiY - 600) <= 5
            logLine('PASS', sprintf('%s PNG涓?00 dpi: %.1f x %.1f dpi', ...
                figId, dpiX, dpiY));
        elseif dpiKnown
            logLine('WARN', sprintf('%s PNG涓嶆槸600 dpi: %.1f x %.1f dpi', ...
                figId, dpiX, dpiY));
        else
            logLine('WARN', [figId ' PNG鏈娴嬪埌DPI鍏冩暟鎹?]);
        end
    catch ME
        logLine('FAIL', [figId ' PNG璇诲彇澶辫触: ' ME.message]);
    end
end

function [dpiX, dpiY, known] = getPngDpi(info)
    dpiX = NaN;
    dpiY = NaN;
    known = false;
    if ~isfield(info, 'XResolution') || ~isfield(info, 'YResolution')
        return;
    end
    x = double(info.XResolution);
    y = double(info.YResolution);
    unit = '';
    if isfield(info, 'ResolutionUnit')
        unit = lower(string(info.ResolutionUnit));
    end

    if contains(unit, 'inch')
        dpiX = x;
        dpiY = y;
        known = true;
    elseif contains(unit, 'centimeter') || contains(unit, 'cm')
        dpiX = x * 2.54;
        dpiY = y * 2.54;
        known = true;
    elseif contains(unit, 'meter')
        dpiX = x / 39.3700787402;
        dpiY = y / 39.3700787402;
        known = true;
    elseif x > 1000 || y > 1000
        dpiX = x / 39.3700787402;
        dpiY = y / 39.3700787402;
        known = true;
    elseif x > 0 && y > 0
        dpiX = x;
        dpiY = y;
        known = true;
    end
end

function validatePdf(figId, pdfPath)
    if ~isfile(pdfPath)
        return;
    end
    try
        info = dir(pdfPath);
        if info.bytes <= 0
            logLine('FAIL', [figId ' PDF鏂囦欢涓虹┖']);
            return;
        end
        txt = fileread(pdfPath);
        hasPdfHeader = contains(txt(1:min(end, 20)), '%PDF');
        hasRasterImage = ~isempty(regexp(txt, '/Subtype\s*/Image', 'once'));
        hasVectorHints = contains(txt, '/Font') || contains(txt, ' re') || ...
            contains(txt, ' m') || contains(txt, ' l') || contains(txt, '/Type /Page');

        if ~hasPdfHeader
            logLine('FAIL', [figId ' PDF澶翠俊鎭紓甯?]);
        elseif hasRasterImage && ~hasVectorHints
            logLine('FAIL', [figId ' PDF鐤戜技绾綅鍥撅紝闈炵煝閲忔牸寮?]);
        elseif hasRasterImage
            logLine('WARN', [figId ' PDF鍚綅鍥惧璞★紝璇蜂汉宸ョ‘璁ゆ槸鍚︿粛婊¤冻鐭㈤噺瑕佹眰']);
        elseif hasVectorHints
            logLine('PASS', [figId ' PDF涓虹煝閲忔牸寮?]);
        else
            logLine('WARN', [figId ' PDF鐭㈤噺鏍煎紡鏃犳硶鑷姩纭']);
        end
    catch ME
        logLine('FAIL', [figId ' PDF璇诲彇澶辫触: ' ME.message]);
    end
end

function validateReadme(figId, readmePath)
    if ~isfile(readmePath)
        return;
    end
    try
        txt = fileread(readmePath);
        required = {'鍥惧彿', '涓枃鍥惧悕', '鑻辨枃鍥惧悕', '鏈浘鐩殑', '鏁版嵁鏉ユ簮', ...
            '鍘熷鏁版嵁鏂囦欢璺緞', '缁樺浘鑴氭湰', '璁＄畻鏂规硶', '杈撳嚭鏂囦欢', ...
            '闇€瑕佷汉宸ョ‘璁ょ殑闂', '鏈€鍚庢洿鏂版椂闂?};
        missing = {};
        for k = 1:numel(required)
            if ~contains(txt, required{k})
                missing{end + 1} = required{k}; %#ok<AGROW>
            end
        end
        if isempty(missing)
            logLine('PASS', [figId ' README瀛楁瀹屾暣']);
        else
            logLine('FAIL', [figId ' README瀛楁缂哄け: ' strjoin(missing, ', ')]);
        end
    catch ME
        logLine('FAIL', [figId ' README璇诲彇澶辫触: ' ME.message]);
    end
end

function validateSourceData(figId, sourceDataPath)
    if ~isfile(sourceDataPath)
        return;
    end
    try
        T = readtable(sourceDataPath, 'TextType', 'string');
        if isempty(T) || height(T) == 0
            logLine('FAIL', [figId ' source_data.csv涓虹┖']);
            return;
        end
        required = {'series_id', 'object_type', 'display_name', 'panel', 'x', 'y'};
        names = T.Properties.VariableNames;
        missing = {};
        for k = 1:numel(required)
            if ~ismember(required{k}, names)
                missing{end + 1} = required{k}; %#ok<AGROW>
            end
        end
        if ~isempty(missing)
            logLine('FAIL', [figId ' source_data.csv瀛楁缂哄け: ' strjoin(missing, ', ')]);
        elseif any(isnan(T.x)) || any(isnan(T.y)) || any(isinf(T.x)) || any(isinf(T.y))
            logLine('FAIL', [figId ' source_data.csv鍚玁aN鎴朓nf']);
        else
            logLine('PASS', [figId ' source_data.csv鏈夋晥']);
        end
    catch ME
        logLine('FAIL', [figId ' source_data.csv璇诲彇澶辫触: ' ME.message]);
    end
end

function validateRawData(rawDataDir)
    if isfolder(rawDataDir)
        logLine('PASS', '鍘熷鏁版嵁鐩綍瀛樺湪');
    else
        logLine('FAIL', '鍘熷鏁版嵁鐩綍涓嶅瓨鍦?);
        return;
    end

    dataFiles = {
        'CO2_850C.txt', 'CO2_900C.txt', 'CO2_950C.txt', ...
        'H2O_850C.txt', 'H2O_900C.txt', 'H2O_950C.txt', ...
        'Mix_850C_5gH2O_100mLCO2.txt', ...
        'Mix_850C_5gH2O_40mLCO2.txt', ...
        'Mix_850C_0.83gH2O_100mLCO2.txt'
    };

    for k = 1:numel(dataFiles)
        path = fullfile(rawDataDir, dataFiles{k});
        if isfile(path)
            logLine('PASS', ['鍘熷鏁版嵁璺緞瀛樺湪: ' dataFiles{k}]);
            validateNumericMatrix(['鍘熷鏁版嵁 ' dataFiles{k}], path);
        else
            logLine('FAIL', ['鍘熷鏁版嵁璺緞涓嶅瓨鍦? ' dataFiles{k}]);
        end
    end
end

function validateNumericMatrix(label, filePath)
    try
        raw = readmatrix(filePath, 'Delimiter', '\t', 'FileType', 'text');
        if isempty(raw)
            logLine('FAIL', [label ' 涓虹┖鏁扮粍']);
            return;
        end
        if size(raw, 2) < 3
            logLine('FAIL', [label ' 鍒楁暟涓嶈冻3鍒?]);
            return;
        end
        raw3 = raw(:, 1:3);
        validRows = ~all(isnan(raw3), 2);
        raw3 = raw3(validRows, :);
        if isempty(raw3)
            logLine('FAIL', [label ' 鏈夋晥鏁版嵁涓虹┖']);
            return;
        end
        if any(isnan(raw3(:)))
            logLine('FAIL', [label ' 鍚湁NaN']);
        elseif any(isinf(raw3(:)))
            logLine('FAIL', [label ' 鍚湁Inf']);
        elseif numel(unique([numel(raw3(:,1)), numel(raw3(:,2)), numel(raw3(:,3))])) ~= 1
            logLine('FAIL', [label ' 鏁版嵁闀垮害涓嶄竴鑷?]);
        else
            logLine('PASS', [label ' 鏃燦aN/Inf/绌烘暟缁?闀垮害涓嶄竴鑷?]);
        end
    catch ME
        logLine('FAIL', [label ' 璇诲彇澶辫触: ' ME.message]);
    end
end

function validateRpmSummary(summaryPath)
    if ~isfile(summaryPath)
        logLine('WARN', 'RPM鎷熷悎鍙傛暟鎽樿缂哄け');
        return;
    end
    try
        T = readtable(summaryPath, 'TextType', 'string');
        required = {'atmosphere', 'temperature_C', 'k_min_1', 'psi', 'R2'};
        names = matlab.lang.makeValidName(T.Properties.VariableNames);
        T.Properties.VariableNames = names;
        missing = {};
        for k = 1:numel(required)
            if ~ismember(required{k}, names)
                missing{end + 1} = required{k}; %#ok<AGROW>
            end
        end
        if ~isempty(missing)
            logLine('FAIL', ['RPM鎷熷悎鍙傛暟瀛楁缂哄け: ' strjoin(missing, ', ')]);
            return;
        end
        expectedRows = 6;
        values = [T.k_min_1, T.psi, T.R2];
        if height(T) < expectedRows
            logLine('FAIL', 'RPM鎷熷悎鍙傛暟琛屾暟涓嶅畬鏁?);
        elseif any(isnan(values(:))) || any(isinf(values(:)))
            logLine('FAIL', 'RPM鎷熷悎鍙傛暟鍚湁NaN鎴朓nf');
        else
            logLine('PASS', 'RPM鎷熷悎鍙傛暟瀹屾暣');
        end
    catch ME
        logLine('FAIL', ['RPM鎷熷悎鍙傛暟鎽樿璇诲彇澶辫触: ' ME.message]);
    end
end

function validatePlotScript(figId, scriptPath)
    if ~isfile(scriptPath)
        logLine('FAIL', [figId ' 缁樺浘鑴氭湰鏃犳硶杩愯锛氳剼鏈己澶?]);
        return;
    end
    oldDir = pwd;
    close all force;
    try
        setappdata(0, 'Chapter3ValidationSkipExport', true);
        runScriptIsolated(scriptPath);
        logLine('PASS', [figId ' 缁樺浘鑴氭湰鍙嫭绔嬭繍琛?]);
        validateOpenFigureData(figId);
        validateOpenFigureStyle(figId);
    catch ME
        logLine('FAIL', [figId ' 缁樺浘鑴氭湰鐙珛杩愯澶辫触: ' compactError(ME)]);
    end
    if isappdata(0, 'Chapter3ValidationSkipExport')
        rmappdata(0, 'Chapter3ValidationSkipExport');
    end
    cd(oldDir);
    close all force;
end

function validateMakeAll(mainScriptPath)
    if ~isfile(mainScriptPath)
        logLine('FAIL', 'RunChapter3Figures.m 鏃犳硶杩愯锛氳剼鏈己澶?);
        return;
    end
    oldDir = pwd;
    close all force;
    try
        setappdata(0, 'Chapter3ValidationSkipExport', true);
        runScriptIsolated(mainScriptPath);
        logLine('PASS', 'RunChapter3Figures.m 鍙粠澶磋繍琛屽畬鎴?);
        validateOpenFigureData('RunChapter3Figures');
        validateOpenFigureStyle('RunChapter3Figures');
    catch ME
        logLine('FAIL', ['RunChapter3Figures.m 浠庡ご杩愯澶辫触: ' compactError(ME)]);
    end
    if isappdata(0, 'Chapter3ValidationSkipExport')
        rmappdata(0, 'Chapter3ValidationSkipExport');
    end
    cd(oldDir);
    close all force;
end

function runScriptIsolated(scriptPath)
    % Plot scripts begin with CLEAR. Execute them in the base workspace so
    % CLEAR cannot remove validation-state variables from this function.
    safePath = strrep(scriptPath, '''', '''''');
    evalin('base', ['run(''' safePath ''');']);
end

function validateOpenFigureData(label)
    figsOpen = findall(0, 'Type', 'figure');
    if isempty(figsOpen)
        logLine('FAIL', [label ' 杩愯鍚庢湭鐢熸垚浠讳綍鍥剧獥']);
        return;
    end
    bad = {};
    for f = reshape(figsOpen, 1, [])
        objects = findall(f, '-property', 'YData');
        for obj = reshape(objects, 1, [])
            x = [];
            try
                y = get(obj, 'YData');
                if isprop(obj, 'XData')
                    x = get(obj, 'XData');
                end
            catch
                continue;
            end
            bad = appendDataIssues(bad, obj, x, y);
        end
        imageObjects = findall(f, '-property', 'CData');
        for obj = reshape(imageObjects, 1, [])
            try
                c = get(obj, 'CData');
                if isempty(c)
                    bad{end + 1} = 'CData涓虹┖鏁扮粍'; %#ok<AGROW>
                elseif isnumeric(c) && (any(isnan(c(:))) || any(isinf(c(:))))
                    bad{end + 1} = 'CData鍚玁aN鎴朓nf'; %#ok<AGROW>
                end
            catch
            end
        end
    end
    if isempty(bad)
        logLine('PASS', [label ' 鍥句腑鏃燦aN/Inf/绌烘暟缁?闀垮害涓嶄竴鑷?]);
    else
        logLine('FAIL', [label ' 鍥句腑鏁版嵁寮傚父: ' strjoin(unique(bad), '; ')]);
    end
end

function validateOpenFigureStyle(label)
    expectedFont = 'Times New Roman';
    expectedAxesFontSize = 11;
    expectedLabelFontSize = 12;
    expectedLegendFontSize = 10;
    expectedAxisLineWidth = 1.2;
    expectedCurveLineWidth = 2.0;
    expectedMarkerSize = 6;
    tol = 1e-6;

    figsOpen = findall(0, 'Type', 'figure');
    if isempty(figsOpen)
        logLine('FAIL', [label ' style check found no open figures']);
        return;
    end

    issues = {};
    for f = reshape(figsOpen, 1, [])
        issues = checkColor(issues, f, 'Color', [1 1 1], 'figure background is not white');

        axesObjects = findall(f, 'Type', 'axes');
        for ax = reshape(axesObjects, 1, [])
            issues = checkString(issues, ax, 'FontName', expectedFont, 'axes font is not Times New Roman');
            issues = checkNumber(issues, ax, 'FontSize', expectedAxesFontSize, tol, 'axes font size is not 11 pt');
            issues = checkNumber(issues, ax, 'LineWidth', expectedAxisLineWidth, tol, 'axes line width is not 1.2');
            issues = checkString(issues, ax, 'TickDir', 'in', 'tick direction is not in');
            issues = checkColor(issues, ax, 'Color', [1 1 1], 'axes background is not white');
            if isprop(ax, 'Title') && isprop(ax.Title, 'String') && ~isempty(ax.Title.String)
                issues{end + 1} = 'title is not empty'; %#ok<AGROW>
            end
            issues = checkLabelObject(issues, ax.XLabel, expectedFont, expectedLabelFontSize, 'x label');
            issues = checkLabelObject(issues, ax.YLabel, expectedFont, expectedLabelFontSize, 'y label');

            lineObjects = findall(ax, 'Type', 'line');
            for ln = reshape(lineObjects, 1, [])
                if isprop(ln, 'LineStyle') && ~strcmp(get(ln, 'LineStyle'), 'none')
                    issues = checkNumber(issues, ln, 'LineWidth', expectedCurveLineWidth, tol, 'curve line width is not 2.0');
                end
                if isprop(ln, 'Marker') && ~strcmp(get(ln, 'Marker'), 'none')
                    issues = checkNumber(issues, ln, 'MarkerSize', expectedMarkerSize, tol, 'marker size is not 6');
                end
            end
        end

        legendObjects = findall(f, 'Type', 'Legend');
        for lgd = reshape(legendObjects, 1, [])
            issues = checkString(issues, lgd, 'FontName', expectedFont, 'legend font is not Times New Roman');
            issues = checkNumber(issues, lgd, 'FontSize', expectedLegendFontSize, tol, 'legend font size is not 10 pt');
            issues = checkString(issues, lgd, 'Box', 'off', 'legend box is not off');
        end
    end

    if isempty(issues)
        logLine('PASS', [label ' format unified: font/size/linewidth/marker/tick/title/legend/background']);
    else
        logLine('FAIL', [label ' format issues: ' strjoin(unique(issues), '; ')]);
    end
end

function issues = checkLabelObject(issues, h, expectedFont, expectedSize, prefix)
    if isempty(h) || ~isvalid(h)
        return;
    end
    issues = checkString(issues, h, 'FontName', expectedFont, [prefix ' font is not Times New Roman']);
    issues = checkNumber(issues, h, 'FontSize', expectedSize, 1e-6, [prefix ' font size is not 12 pt']);
end

function issues = checkString(issues, obj, propName, expected, message)
    if ~isprop(obj, propName)
        return;
    end
    try
        value = get(obj, propName);
        if ~strcmp(char(value), expected)
            issues{end + 1} = message; %#ok<AGROW>
        end
    catch
    end
end

function issues = checkNumber(issues, obj, propName, expected, tol, message)
    if ~isprop(obj, propName)
        return;
    end
    try
        value = double(get(obj, propName));
        if isempty(value) || any(abs(value - expected) > tol)
            issues{end + 1} = message; %#ok<AGROW>
        end
    catch
    end
end

function issues = checkColor(issues, obj, propName, expected, message)
    if ~isprop(obj, propName)
        return;
    end
    try
        value = get(obj, propName);
        if ischar(value) || isstring(value)
            isWhite = strcmpi(char(value), 'white') || strcmpi(char(value), 'w');
        else
            value = double(value);
            isWhite = numel(value) == 3 && all(abs(value(:)' - expected) < 1e-6);
        end
        if ~isWhite
            issues{end + 1} = message; %#ok<AGROW>
        end
    catch
    end
end

function bad = appendDataIssues(bad, obj, x, y)
    if isempty(y)
        bad{end + 1} = [class(obj) ' YData涓虹┖鏁扮粍']; %#ok<AGROW>
        return;
    end
    if isnumeric(y) && (any(isnan(y(:))) || any(isinf(y(:))))
        bad{end + 1} = [class(obj) ' YData鍚玁aN鎴朓nf']; %#ok<AGROW>
    end
    if ~isempty(x)
        if isnumeric(x) && (any(isnan(x(:))) || any(isinf(x(:))))
            bad{end + 1} = [class(obj) ' XData鍚玁aN鎴朓nf']; %#ok<AGROW>
        end
        if isnumeric(x) && isnumeric(y) && numel(x) ~= numel(y)
            bad{end + 1} = [class(obj) ' XData/YData闀垮害涓嶄竴鑷?]; %#ok<AGROW>
        end
    end
end

function msg = compactError(ME)
    msg = ME.message;
    msg = regexprep(msg, '\s+', ' ');
    if numel(msg) > 220
        msg = [msg(1:220) '...'];
    end
end

end

