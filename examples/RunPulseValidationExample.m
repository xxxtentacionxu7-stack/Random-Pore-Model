%% =========================================================
%  TGA_pulse_validation_main.m
%  鐢ㄧ湡瀹炶剦鍐插疄楠屾暟鎹獙璇?RPM+鍗忓悓鍥犲瓙 棰勬祴妯″瀷
%
%  鍓嶆彁: 宸茶繍琛岃繃 TGA_synergy_pulse_main.m锛屽緱鍒?
%        rpm_co2, rpm_h2o, syn_all (鍚悇閰嶆瘮鐨凷F)
%
%  鏁版嵁闇€姹? 浣犳墜鍔ㄦ彁鍙栫殑涓ゅ垪鑴夊啿鏁版嵁鏂囦欢 (鏃堕棿\t璐ㄩ噺%)
%            渚嬪浠嶰rigin/浠櫒杞欢瀵煎嚭鏁寸悊鍚庣殑 pulse_data.txt
% =========================================================
clear; clc; close all;

%% ============ 鍙傛暟璁剧疆 ============
params.T_iso_start  = 840;
params.smooth_span  = 11;
params.psi_init     = 3.0;
params.save_figures = true;

pulse_file    = 'pulse_data_11.txt';  % 浣犳墜鍔ㄦ彁鍙栫殑涓ゅ垪鏂囦欢鍚?(鏃堕棿\t璐ㄩ噺%)
pulse_delim   = '\t';               % 鍒嗛殧绗? '\t' 鎴?','
mass_drop_thresh = 1.0;  % 姝绘椂闂存娴嬮槇鍊?%)锛氳川閲忎笅闄嶈秴杩囨鍊兼墠绠楀弽搴旂湡姝ｅ紑濮?                          % 鐢ㄤ簬鑷姩鍓旈櫎寮€澶寸殑浠櫒灏栧嘲/鍒囨崲鍣０娈?
t_on  = 10;  % H2O寮€鍚椂闀?min)
t_off = 10;  % H2O鍏抽棴鏃堕暱(min)

use_label = '5gH2O-100mLCO2';  % 鐢ㄥ摢缁勫崗鍚屽洜瀛愬仛棰勬祴瀵规瘮

%% ============ 绗?姝? 鎷熷悎绾疌O2鍜岀函H2O (850掳C) ============
fprintf('========== 鎷熷悎绾疌O2 (850掳C) ==========\n');
data_co2 = ReadTGA('CO2_850C.txt');
mass_ash_co2 = mean(data_co2.m(end-9:end));
data_co2 = CalculateConversion(data_co2, mass_ash_co2, params.smooth_span);
iso_co2  = ExtractIsothermalSegment(data_co2, params.T_iso_start);
rpm_co2  = FitRPM(iso_co2, params.psi_init);

fprintf('\n========== 鎷熷悎绾疕2O (850掳C) ==========\n');
data_h2o = ReadTGA('H2O_850C.txt');
mass_ash_h2o = mean(data_h2o.m(end-9:end));
data_h2o = CalculateConversion(data_h2o, mass_ash_h2o, params.smooth_span);
iso_h2o  = ExtractIsothermalSegment(data_h2o, params.T_iso_start);
rpm_h2o  = FitRPM(iso_h2o, params.psi_init);

%% ============ 绗?姝? 涓夌粍娣峰悎鏁版嵁 鈫?鍗忓悓鍥犲瓙 ============
mix_files = {
    'Mix_850C_5gH2O_100mLCO2.txt',    '5gH2O-100mLCO2';
    'Mix_850C_5gH2O_40mLCO2.txt',     '5gH2O-40mLCO2';
    'Mix_850C_0.83gH2O_100mLCO2.txt', '0.83gH2O-100mLCO2';
};

syn_all = {};
fprintf('\n========== 鍗忓悓鏁堝簲鍒嗘瀽 ==========\n');
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

% 鎵惧埌瑕佺敤鐨凷F
SF_selected = [];
for i = 1:length(syn_all)
    if strcmp(syn_all{i}.label, use_label)
        SF_selected = syn_all{i}.SF_mean;
        break;
    end
end
if isempty(SF_selected)
    error('鏈壘鍒版爣绛?%s 瀵瑰簲鐨勫崗鍚屽洜瀛愶紝璇锋鏌?use_label 璁剧疆', use_label);
end
fprintf('\n浣跨敤鍗忓悓鍥犲瓙: %s  SF=%.4f\n', use_label, SF_selected);

%% ============ 绗?姝? 璇诲彇鑴夊啿瀹炴祴鏁版嵁 ============
fprintf('\n========== 璇诲彇鑴夊啿瀹炴祴鏁版嵁 ==========\n');
pulse_data_raw = ReadPulseData(pulse_file, pulse_delim);

% 鑷姩姝绘椂闂存娴嬶細鎵惧埌璐ㄩ噺鐪熸寮€濮嬫樉钁椾笅闄嶇殑鐐癸紝鍓旈櫎涔嬪墠鐨勫櫔澹?寤惰繜娈?% (澶嶇敤涓嶵GA_extractIsothermal鐩稿悓鐨勯€昏緫锛屽洜涓鸿剦鍐叉暟鎹湰韬凡鏄亽娓╂锛?%  涓嶉渶瑕佸啀鎸夋俯搴﹀垏锛屽彧闇€鎸夎川閲忓彉鍖栧垽鏂湡瀹炲弽搴旇捣鐐?
m_ref = pulse_data_raw.m(1);
idx_react = 1;
for ii = 1:length(pulse_data_raw.m)
    if (m_ref - pulse_data_raw.m(ii)) > mass_drop_thresh
        idx_react = ii;
        break;
    end
end
dead_time = pulse_data_raw.t(idx_react) - pulse_data_raw.t(1);
if dead_time > 1e-6
    fprintf('*** 妫€娴嬪埌姝绘椂闂?鍣０娈?= %.2f min锛堝凡鍓旈櫎锛塡n', dead_time);
end

idx_keep = idx_react:length(pulse_data_raw.t);
pulse_data.t = pulse_data_raw.t(idx_keep) - pulse_data_raw.t(idx_react);
pulse_data.m = pulse_data_raw.m(idx_keep);

%% ============ 绗?姝? 楠岃瘉瀵规瘮 ============
fprintf('\n========== 鑴夊啿棰勬祴楠岃瘉 ==========\n');
% 鐏板垎锛氱敤鑴夊啿鏁版嵁鏈熬鍧囧€硷紙鍋囪80min宸﹀彸鍙嶅簲宸叉帴杩戝畬鎴愶級
mass_ash_pulse = mean(pulse_data.m(end-9:end));
fprintf('鑴夊啿鏁版嵁鐏板垎(鏈熬鍧囧€?: %.4f%%\n', mass_ash_pulse);

comp = ValidatePulsePrediction(pulse_data, mass_ash_pulse, rpm_co2, rpm_h2o, ...
    SF_selected, t_on, t_off, params.smooth_span);

%% ============ 绗?姝? 缁樺浘 ============
PlotPulseValidation(comp, params.save_figures);

fprintf('\n=== 鑴夊啿楠岃瘉瀹屾垚 ===\n');
fprintf('RMSE=%.4f, MAE=%.4f, R虏=%.4f\n', comp.RMSE, comp.MAE, comp.R2);

