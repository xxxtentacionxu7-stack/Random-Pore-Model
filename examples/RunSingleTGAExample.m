%% =========================================================
%  TGA_main.m 鈥?鐑噸鏁版嵁妯″潡鍖栧鐞嗕富绋嬪簭
%  瀹為獙鏉′欢: CO2姘旀皼, 850掳C 绛夋俯姘斿寲
%  鏁版嵁鏍煎紡: [娓╁害(掳C), 鏃堕棿(min), 璐ㄩ噺(%)]
% =========================================================
clear; clc; close all;

%% 1. 鐢ㄦ埛鍙傛暟璁剧疆锛堟牴鎹疄楠屼慨鏀规澶勶級
params.filename      = 'H2O_850C.txt';  % 鏁版嵁鏂囦欢鍚?params.T_iso_start   = 840;     % 鎭掓俯娈靛紑濮嬫俯搴﹂槇鍊?(掳C)
params.mass_ash      = 0.685;   % 鐏板垎娈嬩綑璐ㄩ噺 (%)锛屼粠鏁版嵁鏈熬璇诲彇
params.smooth_span   = 11;      % DTG骞虫粦绐楀彛锛堝鏁帮紝瓒婂ぇ瓒婂钩婊戯級
params.psi_init      = 3.0;     % RPM缁撴瀯鍙傛暟 蠄 鍒濆鐚滄祴鍊?params.save_figures  = true;    % 鏄惁淇濆瓨鍥剧墖

%% 2. 妯″潡璋冪敤
% --- 妯″潡1锛氭暟鎹鍙栦笌娓呮礂 ---
fprintf('>>> [1/4] 璇诲彇鏁版嵁...\n');
data = ReadTGA(params.filename);

% --- 妯″潡2锛氳浆鍖栫巼璁＄畻 & DTG ---
fprintf('>>> [2/4] 璁＄畻杞寲鐜囦笌DTG...\n');
data = CalculateConversion(data, params.mass_ash, params.smooth_span);

% --- 妯″潡3锛氭彁鍙栨亽娓╂ ---
fprintf('>>> [3/4] 鎻愬彇鎭掓俯姘斿寲娈?..\n');
iso = ExtractIsothermalSegment(data, params.T_iso_start);

% --- 妯″潡4锛歊PM鎷熷悎 ---
fprintf('>>> [4/4] 闅忔満瀛旀ā鍨?RPM)鎷熷悎...\n');
rpm = FitRPM(iso, params.psi_init);

% --- 妯″潡5锛氱粯鍥?---
PlotCoreResults(data, iso, rpm, params);

fprintf('\n=== 澶勭悊瀹屾垚 ===\n');
fprintf('RPM鍙傛暟: k = %.4f min^-1,  蠄 = %.4f\n', rpm.k, rpm.psi);
fprintf('鎷熷悎浼樺害 R虏 = %.6f\n', rpm.R2);

