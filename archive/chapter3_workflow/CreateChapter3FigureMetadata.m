function CreateChapter3FigureMetadata()
%% CreateChapter3FigureMetadata
% Create README, captions, and source_data.csv for Fig3-1 to Fig3-7.

clc;

chapterDir = fileparts(mfilename('fullpath'));
if isempty(chapterDir)
    chapterDir = pwd;
end
projectDir = fileparts(chapterDir);
dataDir = fullfile(projectDir, 'claude');
lastUpdated = datestr(now, 'yyyy-mm-dd HH:MM:SS');

items = buildItems(chapterDir, dataDir);

for i = 1:numel(items)
    item = items(i);
    figDir = fullfile(chapterDir, item.folder);
    if ~isfolder(figDir)
        mkdir(figDir);
    end

    writeTextFile(fullfile(figDir, 'README.md'), renderReadme(item, lastUpdated));
    writeTextFile(fullfile(figDir, 'Caption_CN.txt'), item.captionCN);
    writeTextFile(fullfile(figDir, 'Caption_EN.txt'), item.captionEN);

    figPath = fullfile(figDir, [item.baseName '.fig']);
    csvPath = fullfile(figDir, 'source_data.csv');
    exportFigSourceData(figPath, csvPath);

    fprintf('Metadata updated: %s\n', item.folder);
end

fprintf('\nChapter 3 figure metadata completed.\n');
end

function items = buildItems(chapterDir, dataDir)
    co2Files = {
        fullfile(dataDir, 'CO2_850C.txt')
        fullfile(dataDir, 'CO2_900C.txt')
        fullfile(dataDir, 'CO2_950C.txt')
    };
    h2oFiles = {
        fullfile(dataDir, 'H2O_850C.txt')
        fullfile(dataDir, 'H2O_900C.txt')
        fullfile(dataDir, 'H2O_950C.txt')
    };
    mixFiles = {
        fullfile(dataDir, 'Mix_850C_5gH2O_100mLCO2.txt')
        fullfile(dataDir, 'Mix_850C_5gH2O_40mLCO2.txt')
        fullfile(dataDir, 'Mix_850C_0.83gH2O_100mLCO2.txt')
    };

    commonOut = @(baseName) {
        [baseName '.png']
        [baseName '.pdf']
        [baseName '.fig']
        'source_data.csv'
        'README.md'
        'Caption_CN.txt'
        'Caption_EN.txt'
    };

    items = makeItem( ...
        'Fig3-1', 'Fig3-1_TG_Curves', ...
        'Fig. 3-1 TG鏇茬嚎', ...
        'Fig. 3-1 TG curves of biomass char under CO2 and H2O atmospheres.', ...
        '灞曠ず鐢熺墿璐ㄧ劍鍦–O2鍜孒2O姘旀皼涓嬶紝涓嶅悓娓╁害绛夋俯姘斿寲杩囩▼涓殑璐ㄩ噺闅忔椂闂村彉鍖栵紝鐢ㄤ簬姣旇緝娓╁害鍜屾皵姘涘澶遍噸琛屼负鐨勫奖鍝嶃€?, ...
        'claude鐩綍涓殑CO2_850C/900C/950C.txt涓嶩2O_850C/900C/950C.txt锛岀粡绛夋俯娈垫彁鍙栧悗缁樺浘銆?, ...
        [co2Files; h2oFiles], ...
        'PlotFig31TG.m', ...
        fullfile(chapterDir, 'Fig3-1', 'PlotFig31TG.m'), ...
        '璇诲彇娓╁害銆佹椂闂村拰璐ㄩ噺鐧惧垎鏁帮紱浠ユ俯搴﹁揪鍒扮洰鏍囨俯搴﹀墠绾?5 C涓虹瓑娓╂璇嗗埆闃堝€硷紝骞跺墧闄ゅ垵濮嬫鏃堕棿锛涚粯鍒剁瓑娓╁弽搴旀椂闂?璐ㄩ噺鐧惧垎鏁版洸绾裤€?, ...
        commonOut('Fig3-1_TG_Curves'), ...
        '闇€瑕佷汉宸ョ‘璁O2涓嶩2O涓や釜瀛愬浘鏄惁鍧囩鍚堣鏂囩増闈㈡瘮渚嬶紝浠ュ強澶遍噸骞冲彴娈垫槸鍚﹂渶瑕佽鍓€?, ...
        '鐢熺墿璐ㄧ劍鍦–O2鍜孒2O姘旀皼涓嬬殑TG鏇茬嚎銆?, ...
        'TG curves of biomass char under CO2 and H2O atmospheres.');

    items(end+1) = makeItem( ...
        'Fig3-2', 'Fig3-2_DTG_Curves', ...
        'Fig. 3-2 DTG鏇茬嚎', ...
        'Fig. 3-2 DTG curves of biomass char under CO2 and H2O atmospheres.', ...
        '灞曠ずCO2鍜孒2O姘旀皼涓嬭川閲忔崯澶遍€熺巼闅忕瓑娓╁弽搴旀椂闂寸殑鍙樺寲锛岀敤浜庢瘮杈冩皵鍖栭€熺巼宄板€煎拰鍙嶅簲闃舵宸紓銆?, ...
        '鐢盕ig3-1鐩稿悓鍘熷鐑噸鏂囦欢璁＄畻璐ㄩ噺瀵规椂闂寸殑涓€闃跺鏁帮紝骞惰繘琛孲avitzky-Golay骞虫粦銆?, ...
        [co2Files; h2oFiles], ...
        'PlotFig32DTG.m', ...
        fullfile(chapterDir, 'Fig3-2', 'PlotFig32DTG.m'), ...
        '瀵圭瓑娓╂璐ㄩ噺鏇茬嚎姹傛椂闂村鏁帮紝缁樺埗-DTG浠ヨ〃绀烘鐨勫け閲嶉€熺巼锛涘钩婊戠獥鍙ｄ负11鐐癸紝鏇茬嚎棰滆壊涓嶧ig3-1淇濇寔涓€鑷淬€?, ...
        commonOut('Fig3-2_DTG_Curves'), ...
        '闇€瑕佷汉宸ョ‘璁TG宄板舰鏄惁闇€瑕佽繘涓€姝ュ幓鍣紝浠ュ強绾靛潗鏍囨槸鍚﹂噰鐢―TG姝ｅ€艰〃杈俱€?, ...
        '鐢熺墿璐ㄧ劍鍦–O2鍜孒2O姘旀皼涓嬬殑DTG鏇茬嚎銆?, ...
        'DTG curves of biomass char under CO2 and H2O atmospheres.');

    items(end+1) = makeItem( ...
        'Fig3-3', 'Fig3-3_Conversion_Curves', ...
        'Fig. 3-3 纰宠浆鍖栫巼鏇茬嚎', ...
        'Fig. 3-3 Carbon conversion curves under different gasification atmospheres.', ...
        '姣旇緝涓嶅悓姘旀皼鍜屾俯搴︽潯浠朵笅纰宠浆鍖栫巼闅忔椂闂寸殑鍙戝睍锛屼负鍚庣画RPM鎷熷悎鎻愪緵瀹為獙杞寲鐜囧熀纭€銆?, ...
        '浣跨敤CO2涓嶩2O涓夌娓╁害鐑噸鏁版嵁锛屼互鏈10涓川閲忕偣鍧囧€间及绠楁畫浣欑伆鍒嗗苟璁＄畻杞寲鐜囥€?, ...
        [co2Files; h2oFiles], ...
        'PlotFig33Conversion.m', ...
        fullfile(chapterDir, 'Fig3-3', 'PlotFig33Conversion.m'), ...
        '杞寲鐜囨寜X=(m0-m)/(m0-mf)璁＄畻锛屽苟浠ョ瓑娓╃湡瀹炲弽搴旇捣鐐归噸鏂板綊涓€鍖栦负0-1銆?, ...
        commonOut('Fig3-3_Conversion_Curves'), ...
        '闇€瑕佷汉宸ョ‘璁ょ伆鍒嗚川閲弇f閲囩敤鏈10鐐瑰潎鍊兼槸鍚︿笌璁烘枃姝ｆ枃鏂规硶瀹屽叏涓€鑷淬€?, ...
        '涓嶅悓姘斿寲姘旀皼涓嬬敓鐗╄川鐒︾殑纰宠浆鍖栫巼鏇茬嚎銆?, ...
        'Carbon conversion curves under different gasification atmospheres.');

    items(end+1) = makeItem( ...
        'Fig3-4', 'Fig3-4_RPM_Fitting_CO2', ...
        'Fig. 3-4 CO2姘斿寲RPM鎷熷悎', ...
        'Fig. 3-4 RPM fitting results for CO2 gasification.', ...
        '灞曠ずCO2姘斿寲瀹為獙杞寲鐜囦笌RPM妯″瀷鎷熷悎缁撴灉鐨勪竴鑷存€э紝骞剁粰鍑哄悇娓╁害鎷熷悎浼樺害R2銆?, ...
        '浣跨敤CO2_850C.txt銆丆O2_900C.txt鍜孋O2_950C.txt鐨勭瓑娓╄浆鍖栫巼鏁版嵁銆?, ...
        co2Files, ...
        'PlotFig34RPMFittingCO2.m', ...
        fullfile(chapterDir, 'Fig3-4', 'PlotFig34RPMFittingCO2.m'), ...
        '閲囩敤闅忔満瀛旀ā鍨嬬Н鍒嗗舰寮忔嫙鍚圶-t鏇茬嚎锛屽厛鎵弿psi骞朵及绠梜锛屽啀鐢熸垚瀹為獙鐐逛笌RPM鎷熷悎绾裤€?, ...
        commonOut('Fig3-4_RPM_Fitting_CO2'), ...
        '闇€瑕佷汉宸ョ‘璁O2鍦?50 C涓嬬殑RPM缁撴瀯鍙傛暟鏄惁閲囩敤鏈浘鑴氭湰缁撴灉锛岃繕鏄噰鐢ㄥ€欓€夊弬鏁拌〃涓殑鍙︿竴濂楅澶勭悊缁撴灉銆?, ...
        'CO2姘旀皼涓婻PM妯″瀷鎷熷悎缁撴灉銆?, ...
        'RPM fitting results for CO2 gasification.');

    items(end+1) = makeItem( ...
        'Fig3-5', 'Fig3-5_RPM_Fitting_H2O', ...
        'Fig. 3-5 H2O姘斿寲RPM鎷熷悎', ...
        'Fig. 3-5 RPM fitting results for H2O gasification.', ...
        '灞曠ずH2O姘斿寲瀹為獙杞寲鐜囦笌RPM妯″瀷鎷熷悎缁撴灉锛岀敤浜庝笌CO2姘斿寲鍔ㄥ姏瀛︽嫙鍚堢粨鏋滀繚鎸佸悓鐗堝紡姣旇緝銆?, ...
        '浣跨敤H2O_850C.txt銆丠2O_900C.txt鍜孒2O_950C.txt鐨勭瓑娓╄浆鍖栫巼鏁版嵁銆?, ...
        h2oFiles, ...
        'PlotFig35RPMFittingH2O.m', ...
        fullfile(chapterDir, 'Fig3-5', 'PlotFig35RPMFittingH2O.m'), ...
        '涓嶧ig3-4涓€鑷达紝閲囩敤RPM绉垎褰㈠紡鎷熷悎X-t鏇茬嚎锛屽苟鍦ㄥ悇瀛愬浘涓樉绀哄疄楠岀偣銆佹嫙鍚堢嚎鍜孯2銆?, ...
        commonOut('Fig3-5_RPM_Fitting_H2O'), ...
        '闇€瑕佷汉宸ョ‘璁2O鏇茬嚎鍒濆蹇弽搴旀鏄惁闇€瑕佸湪姝ｆ枃涓В閲婃鏃堕棿鍓旈櫎鏂规硶銆?, ...
        'H2O姘旀皼涓婻PM妯″瀷鎷熷悎缁撴灉銆?, ...
        'RPM fitting results for H2O gasification.');

    items(end+1) = makeItem( ...
        'Fig3-6', 'Fig3-6_RPM_Parameters', ...
        'Fig. 3-6 RPM鍔ㄥ姏瀛﹀弬鏁?, ...
        'Fig. 3-6 Comparison of RPM kinetic parameters under different temperatures.', ...
        '姣旇緝CO2涓嶩2O姘旀皼涓婻PM閫熺巼甯告暟k鍜岀粨鏋勫弬鏁皃si闅忔俯搴︾殑鍙樺寲瓒嬪娍銆?, ...
        '鍙傛暟鏉ヨ嚜Fig3-4鍜孎ig3-5鎷熷悎缁撴灉锛屽悓鏃舵眹鎬讳簬Fig3_RPM_fit_summary.csv銆?, ...
        [{fullfile(chapterDir, 'Fig3_RPM_fit_summary.csv')}; co2Files; h2oFiles], ...
        'PlotFig36RPMParameters.m', ...
        fullfile(chapterDir, 'Fig3-6', 'PlotFig36RPMParameters.m'), ...
        '鎻愬彇鍚勬俯搴︿笅RPM鎷熷悎寰楀埌鐨刱鍜宲si锛屽垎鍒粯鍒秌-Temperature涓巔si-Temperature涓や釜瀛愬浘銆?, ...
        commonOut('Fig3-6_RPM_Parameters'), ...
        '闇€瑕佷汉宸ョ‘璁ゆ槸鍚﹀湪璁烘枃涓噰鐢ㄧ嚎鎬у潗鏍囷紝鎴栧k浣跨敤Arrhenius褰㈠紡鍙﹁浣滃浘銆?, ...
        '涓嶅悓娓╁害涓婻PM鍔ㄥ姏瀛﹀弬鏁版瘮杈冦€?, ...
        'Comparison of RPM kinetic parameters under different temperatures.');

    items(end+1) = makeItem( ...
        'Fig3-7', 'Fig3-7_Synergy_Factor_R', ...
        'Fig. 3-7 鍗忓悓鍥犲瓙R', ...
        'Fig. 3-7 Variation of synergy factor R under different temperatures.', ...
        '灞曠ず娣峰悎姘斿寲涓疄娴嬮€熺巼鐩稿浜嶤O2涓嶩2O鐙珛绾挎€у彔鍔犻€熺巼鐨勫亸绂伙紝鐢ㄤ簬鍒ゆ柇鍗忓悓鎴栨姂鍒舵晥搴斻€?, ...
        '浣跨敤850 C涓嬩笁缁凜O2-H2O娣峰悎姘斿寲鏁版嵁锛屽苟缁撳悎850 C绾疌O2涓庣函H2O RPM鍙傛暟璁＄畻R銆?, ...
        [mixFiles; co2Files(1); h2oFiles(1)], ...
        'PlotFig37SynergyFactor.m', ...
        fullfile(chapterDir, 'Fig3-7', 'PlotFig37SynergyFactor.m'), ...
        'R=(dX/dt)mix/[(dX/dt)CO2+(dX/dt)H2O]锛涘浘涓姞鍏=1鐏拌壊铏氱嚎锛孯<1鍖哄煙鏍囨敞涓篒nhibition銆?, ...
        commonOut('Fig3-7_Synergy_Factor_R'), ...
        '褰撳墠鍙湁850 C娣峰悎姘旀暟鎹紱鑻ヨ鏂囧浘鍚嶅己璋僤ifferent temperatures锛岄渶瑕佽ˉ鍏?00 C鍜?50 C娣峰悎姘斿疄楠屾暟鎹悗鏇存柊銆?, ...
        '涓嶅悓娣峰悎姘旀潯浠朵笅鍗忓悓鍥犲瓙R鐨勫彉鍖栥€?, ...
        'Variation of synergy factor R under mixed gasification conditions.');
end

function item = makeItem(folder, baseName, titleCN, titleEN, purpose, dataSource, ...
    rawPaths, scriptName, scriptPath, method, outputs, manualConfirm, captionCN, captionEN)
    item.folder = folder;
    item.baseName = baseName;
    item.titleCN = titleCN;
    item.titleEN = titleEN;
    item.purpose = purpose;
    item.dataSource = dataSource;
    item.rawPaths = rawPaths(:);
    item.scriptName = scriptName;
    item.scriptPath = scriptPath;
    item.method = method;
    item.outputs = outputs(:);
    item.manualConfirm = manualConfirm;
    item.captionCN = captionCN;
    item.captionEN = captionEN;
end

function txt = renderReadme(item, lastUpdated)
    lines = {};
    lines{end+1} = ['# ' item.folder]; %#ok<AGROW>
    lines{end+1} = '';
    lines{end+1} = ['- 鍥惧彿: ' item.folder];
    lines{end+1} = ['- 涓枃鍥惧悕: ' item.titleCN];
    lines{end+1} = ['- 鑻辨枃鍥惧悕: ' item.titleEN];
    lines{end+1} = ['- 鏈浘鐩殑: ' item.purpose];
    lines{end+1} = ['- 鏁版嵁鏉ユ簮: ' item.dataSource];
    lines{end+1} = '- 鍘熷鏁版嵁鏂囦欢璺緞:';
    for i = 1:numel(item.rawPaths)
        lines{end+1} = ['  - ' item.rawPaths{i}]; %#ok<AGROW>
    end
    lines{end+1} = ['- 缁樺浘鑴氭湰: ' item.scriptName];
    lines{end+1} = ['- 缁樺浘鑴氭湰璺緞: ' item.scriptPath];
    lines{end+1} = ['- 璁＄畻鏂规硶: ' item.method];
    lines{end+1} = '- 杈撳嚭鏂囦欢:';
    for i = 1:numel(item.outputs)
        lines{end+1} = ['  - ' item.outputs{i}]; %#ok<AGROW>
    end
    lines{end+1} = ['- 闇€瑕佷汉宸ョ‘璁ょ殑闂: ' item.manualConfirm];
    lines{end+1} = ['- 鏈€鍚庢洿鏂版椂闂? ' lastUpdated];
    lines{end+1} = '';
    txt = strjoin(lines, newline);
end

function writeTextFile(filePath, content)
    fid = fopen(filePath, 'w', 'n', 'UTF-8');
    if fid < 0
        error('Cannot write file: %s', filePath);
    end
    cleaner = onCleanup(@() fclose(fid));
    fprintf(fid, '%s\n', content);
    clear cleaner;
end

function exportFigSourceData(figPath, csvPath)
    if ~isfile(figPath)
        error('Missing FIG file: %s', figPath);
    end

    fig = openfig(figPath, 'invisible');
    cleaner = onCleanup(@() close(fig));
    data = collectFigureData(fig);

    fid = fopen(csvPath, 'w', 'n', 'UTF-8');
    if fid < 0
        error('Cannot write source data CSV: %s', csvPath);
    end
    fileCleaner = onCleanup(@() fclose(fid));
    fprintf(fid, 'series_id,object_type,display_name,panel,x,y\n');
    for i = 1:numel(data)
        x = data(i).x(:);
        y = data(i).y(:);
        n = max(numel(x), numel(y));
        if numel(x) == 1 && n > 1
            x = repmat(x, n, 1);
        end
        if numel(y) == 1 && n > 1
            y = repmat(y, n, 1);
        end
        if numel(x) ~= numel(y)
            n = min(numel(x), numel(y));
            x = x(1:n);
            y = y(1:n);
        end
        for j = 1:n
            fprintf(fid, '%d,%s,%s,%s,%.12g,%.12g\n', ...
                i, csvEscape(data(i).objectType), csvEscape(data(i).displayName), ...
                csvEscape(data(i).panel), x(j), y(j));
        end
    end
    clear fileCleaner cleaner;
end

function data = collectFigureData(fig)
    data = struct('objectType', {}, 'displayName', {}, 'panel', {}, 'x', {}, 'y', {});
    axesList = findall(fig, 'Type', 'axes');
    axesList = flipud(axesList(:));
    seriesId = 0;
    for a = 1:numel(axesList)
        ax = axesList(a);
        panel = getPanelLabel(ax, a);
        children = flipud(findall(ax, '-property', 'YData'));
        for c = 1:numel(children)
            obj = children(c);
            if strcmp(get(obj, 'Type'), 'text')
                continue;
            end
            try
                y = get(obj, 'YData');
            catch
                continue;
            end
            if isempty(y) || ~isnumeric(y)
                continue;
            end
            try
                x = get(obj, 'XData');
            catch
                x = (1:numel(y));
            end
            if isempty(x) || ~isnumeric(x)
                x = (1:numel(y));
            end
            seriesId = seriesId + 1;
            data(seriesId).objectType = get(obj, 'Type'); %#ok<AGROW>
            data(seriesId).displayName = getDisplayName(obj, seriesId);
            data(seriesId).panel = panel;
            data(seriesId).x = x;
            data(seriesId).y = y;
        end
    end
end

function panel = getPanelLabel(ax, index)
    panel = sprintf('Panel_%d', index);
    texts = findall(ax, 'Type', 'text');
    for i = 1:numel(texts)
        s = string(get(texts(i), 'String'));
        if startsWith(s, "(")
            panel = char(s);
            return;
        end
    end
end

function name = getDisplayName(obj, seriesId)
    name = '';
    try
        name = get(obj, 'DisplayName');
    catch
    end
    if isempty(name)
        name = sprintf('series_%d', seriesId);
    end
    name = char(string(name));
end

function out = csvEscape(value)
    value = char(string(value));
    value = strrep(value, '"', '""');
    out = ['"' value '"'];
end

