%% =========================================================
%  TGA_synergy_pulse_main.m
%  CO2-H2O 鍏辨皵鍖栧崗鍚屾晥搴斿垎鏋?+ 鑴夊啿姘斿寲棰勬祴
%
%  鍓嶆彁: 宸茶繍琛岃繃 TGA_batch.m锛屽緱鍒扮函CO2/绾疕2O鍚勬俯搴︾殑RPM鍙傛暟
%        (k_CO2, psi_CO2, k_H2O, psi_H2O)
%
%  鏁版嵁闇€姹?
%    - CO2_850C.txt, CO2_900C.txt, CO2_950C.txt   (宸叉湁)
%    - H2O_850C.txt, H2O_900C.txt, H2O_950C.txt   (浣犻渶瑕佺‘璁ゅ懡鍚?
%    - Mix_850C_5gH2O_100mLCO2.txt
%    - Mix_850C_5gH2O_40mLCO2.txt
%    - Mix_850C_0.83gH2O_100mLCO2.txt
% =========================================================
clear; clc; close all;

%% ============ 绗?閮ㄥ垎: 鍙傛暟璁剧疆 ============
params.T_iso_start  = 840;     % 鎭掓俯娈靛垽鏂槇鍊?掳C)锛屽搴?50掳C瀹為獙锛?00/950璇峰湪寰幆閲岃嚜鍔ㄨ皟鏁?params.smooth_span  = 11;
params.psi_init     = 3.0;
params.save_figures = true;

% 鑴夊啿棰勬祴鍙傛暟
pulse_params.t_total = 60;    % 鎬诲弽搴旀椂闀?min)
pulse_params.t_on    = 10;    % H2O寮€鍚椂闀?min)
pulse_params.t_off   = 10;    % H2O鍏抽棴鏃堕暱(min)
pulse_params.dt      = 0.05;  % 绉垎姝ラ暱(min)

% 閫夋嫨鐢ㄥ摢涓祦閲忛厤姣旂殑鍗忓悓鍥犲瓙鏉ュ仛鑴夊啿棰勬祴
pulse_params.use_label = '5gH2O-100mLCO2';

%% ============ 绗?閮ㄥ垎: 鎷熷悎绾疌O2鍜岀函H2O鐨凴PM (850掳C) ============
fprintf('========== 鎷熷悎绾疌O2 (850掳C) ==========\n');
data_co2 = ReadTGA('CO2_850C.txt');
mass_ash_co2 = mean(data_co2.m(end-9:end));
data_co2 = CalculateConversion(data_co2, mass_ash_co2, params.smooth_span);
iso_co2  = ExtractIsothermalSegment(data_co2, params.T_iso_start);
rpm_co2  = FitRPM(iso_co2, params.psi_init);

fprintf('\n========== 鎷熷悎绾疕2O (850掳C) ==========\n');
data_h2o = ReadTGA('H2O_850C.txt');   % 鑻ユ枃浠跺悕涓嶅悓锛岃鍦ㄦ淇敼
mass_ash_h2o = mean(data_h2o.m(end-9:end));
data_h2o = CalculateConversion(data_h2o, mass_ash_h2o, params.smooth_span);
iso_h2o  = ExtractIsothermalSegment(data_h2o, params.T_iso_start);
rpm_h2o  = FitRPM(iso_h2o, params.psi_init);

%% ============ 绗?閮ㄥ垎: 涓夌閰嶆瘮鐨勬贩鍚堟暟鎹?鈫?鍗忓悓鏁堝簲鍒嗘瀽 ============
mix_files = {
    'Mix_850C_5gH2O_100mLCO2.txt',    '5gH2O-100mLCO2';
    'Mix_850C_5gH2O_40mLCO2.txt',     '5gH2O-40mLCO2';
    'Mix_850C_0.83gH2O_100mLCO2.txt', '0.83gH2O-100mLCO2';
};

syn_all = {};
fprintf('\n========== 鍗忓悓鏁堝簲鍒嗘瀽锛堜笁绉嶆祦閲忛厤姣旓級 ==========\n');
for i = 1:size(mix_files, 1)
    fname = mix_files{i, 1};
    label = mix_files{i, 2};

    if ~isfile(fname)
        warning('鏂囦欢涓嶅瓨鍦紝璺宠繃: %s', fname);
        continue;
    end

    data_mix = ReadTGA(fname);
    mass_ash_mix = mean(data_mix.m(end-9:end));
    data_mix = CalculateConversion(data_mix, mass_ash_mix, params.smooth_span);
    iso_mix  = ExtractIsothermalSegment(data_mix, params.T_iso_start);

    syn = AnalyzeSynergy(iso_mix, rpm_co2, rpm_h2o, label);
    syn_all{end+1} = syn; %#ok<SAGROW>
end

%% ============ 绗?閮ㄥ垎: 鑴夊啿姘斿寲棰勬祴 ============
fprintf('\n========== 鑴夊啿姘斿寲棰勬祴 ==========\n');

% 鎵惧埌鎸囧畾娴侀噺閰嶆瘮鐨勫崗鍚屽洜瀛?syn_selected = [];
for i = 1:length(syn_all)
    if strcmp(syn_all{i}.label, pulse_params.use_label)
        syn_selected = syn_all{i};
        break;
    end
end

if isempty(syn_selected)
    warning('鏈壘鍒版爣绛句负 %s 鐨勫崗鍚岀粨鏋滐紝浣跨敤绗竴涓彲鐢ㄩ厤姣?, pulse_params.use_label);
    syn_selected = syn_all{1};
end

pulse = SimulatePulse(rpm_co2, rpm_h2o, syn_selected, ...
    pulse_params.t_total, pulse_params.t_on, pulse_params.t_off, pulse_params.dt);

% --- 瀵规瘮鍩哄噯1: H2O杩炵画閫氬叆(鍋囪鍏ㄧ▼寮€) ---
pulse_continuous = SimulatePulse(rpm_co2, rpm_h2o, syn_selected, ...
    pulse_params.t_total, pulse_params.t_total, 0, pulse_params.dt);

% --- 瀵规瘮鍩哄噯2: 浠匔O2(H2O鍏ㄧ▼鍏抽棴) ---
pulse_co2_only = SimulatePulse(rpm_co2, rpm_h2o, syn_selected, ...
    pulse_params.t_total, 0, pulse_params.t_total, pulse_params.dt);

fprintf('  瀵规瘮-H2O杩炵画閫氬叆: X(%.0fmin) = %.4f\n', pulse_params.t_total, pulse_continuous.X(end));
fprintf('  瀵规瘮-浠匔O2:       X(%.0fmin) = %.4f\n', pulse_params.t_total, pulse_co2_only.X(end));

%% ============ 绗?閮ㄥ垎: 缁樺浘 ============
PlotSynergyAndPulse(syn_all, pulse, params.save_figures);

%% ============ 姹囨€绘墦鍗?============
fprintf('\n\n============ 缁撴灉姹囨€?============\n');
fprintf('绾疌O2 (850掳C):  k=%.4f, psi=%.4f, R虏=%.5f\n', rpm_co2.k, rpm_co2.psi, rpm_co2.R2);
fprintf('绾疕2O (850掳C):  k=%.4f, psi=%.4f, R虏=%.5f\n', rpm_h2o.k, rpm_h2o.psi, rpm_h2o.R2);
fprintf('\n鍚勬祦閲忛厤姣斿崗鍚屽洜瀛?\n');
for i = 1:length(syn_all)
    fprintf('  %-8s  SF = %.3f 卤 %.3f\n', syn_all{i}.label, syn_all{i}.SF_mean, syn_all{i}.SF_std);
end
fprintf('\n鑴夊啿棰勬祴 (浣跨敤 %s 鐨凷F=%.3f):\n', pulse_params.use_label, syn_selected.SF_mean);
fprintf('  鑴夊啿(10寮€/10鍏?:   X(%.0fmin) = %.4f\n', pulse_params.t_total, pulse.X(end));
fprintf('  H2O杩炵画閫氬叆:       X(%.0fmin) = %.4f\n', pulse_params.t_total, pulse_continuous.X(end));
fprintf('  浠匔O2:             X(%.0fmin) = %.4f\n', pulse_params.t_total, pulse_co2_only.X(end));

fprintf('\n=== 鍏ㄩ儴瀹屾垚 ===\n');

