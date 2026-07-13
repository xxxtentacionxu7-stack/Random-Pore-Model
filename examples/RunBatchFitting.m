%% =========================================================
%  TGA_batch.m 鈥?鎵归噺澶勭悊澶氫釜TGA鏂囦欢锛屽姣斾笉鍚屾俯搴︾粨鏋?%  瀹為獙鏉′欢: CO2姘旀皼锛屽娓╁害绛夋俯姘斿寲
% =========================================================
clear; clc; close all;

%% 鐢ㄦ埛鍙傛暟璁剧疆
% --- 鏂囦欢鍒楄〃锛堟枃浠跺悕 + 瀵瑰簲娓╁害锛?--
files = {
    'CO2_850C.txt',  850;
    'CO2_900C.txt',  900;
    'CO2_950C.txt',  950;
};

% --- 閫氱敤鍙傛暟 ---
params.T_iso_start  = 840;    % 鎭掓俯娈佃捣濮嬫俯搴﹂槇鍊?(掳C)锛屽彲鎸夐渶璋冩暣
params.mass_ash     = [];     % 鐣欑┖ = 鑷姩鍙栨瘡涓枃浠舵渶鍚?0琛屽潎鍊?params.smooth_span  = 11;     % DTG骞虫粦绐楀彛
params.psi_init     = 3.0;    % RPM 蠄 鍒濆鐚滄祴
params.save_figures = true;   % 鏄惁淇濆瓨鍥剧墖
params.save_excel   = true;   % 鏄惁瀵煎嚭姹囨€籈xcel

%% 鎵归噺澶勭悊
n = size(files, 1);
results = struct();  % 瀛樺偍鎵€鏈夌粨鏋?
for i = 1:n
    fname = files{i, 1};
    T_exp = files{i, 2};

    fprintf('\n========================================\n');
    fprintf('澶勭悊鏂囦欢 [%d/%d]: %s  (瀹為獙娓╁害: %d掳C)\n', i, n, fname, T_exp);
    fprintf('========================================\n');

    % 璇诲彇鏁版嵁
    data = ReadTGA(fname);

    % 鑷姩鐏板垎锛堝彇鏈€鍚?0琛岃川閲忓潎鍊硷級
    if isempty(params.mass_ash)
        mass_ash_i = mean(data.m(end-9:end));
        fprintf('    鑷姩鐏板垎: %.4f %%\n', mass_ash_i);
    else
        mass_ash_i = params.mass_ash;
    end

    % 璋冩暣鎭掓俯娈甸槇鍊间负瀹為獙娓╁害-15掳C
    T_iso_i = T_exp - 15;

    % 鍚勬ā鍧楀鐞?    data = CalculateConversion(data, mass_ash_i, params.smooth_span);
    iso  = ExtractIsothermalSegment(data, T_iso_i);
    rpm  = FitRPM(iso, params.psi_init);

    % 瀛樺偍缁撴灉
    results(i).filename = fname;
    results(i).T_exp    = T_exp;
    results(i).k        = rpm.k;
    results(i).psi      = rpm.psi;
    results(i).R2       = rpm.R2;
    results(i).data     = data;
    results(i).iso      = iso;
    results(i).rpm      = rpm;
    results(i).mass_ash = mass_ash_i;

    fprintf('    缁撴灉: k=%.4f min^-1,  蠄=%.4f,  R虏=%.5f\n', rpm.k, rpm.psi, rpm.R2);
end

%% 姹囨€昏緭鍑?fprintf('\n\n============ 鎵归噺澶勭悊姹囨€?============\n');
fprintf('%-20s  %6s  %8s  %8s  %8s\n', '鏂囦欢', 'T(掳C)', 'k(min鈦宦?', '蠄', 'R虏');
fprintf('%s\n', repmat('-', 1, 60));
for i = 1:n
    fprintf('%-20s  %6d  %8.4f  %8.4f  %8.5f\n', ...
        results(i).filename, results(i).T_exp, ...
        results(i).k, results(i).psi, results(i).R2);
end

%% Arrhenius鍒嗘瀽锛堥渶瑕佽嚦灏?涓俯搴︼級
if n >= 2
    fprintf('\n>>> Arrhenius 鍒嗘瀽\n');
    ArrheniusAnalysis(results, params.save_figures);
end

%% 缁樺埗瀵规瘮鍥?PlotBatchComparison(results, params.save_figures);

%% 瀵煎嚭Excel姹囨€?if params.save_excel
    ExportExcel(results);
end

fprintf('\n=== 鎵归噺澶勭悊瀹屾垚 ===\n');

