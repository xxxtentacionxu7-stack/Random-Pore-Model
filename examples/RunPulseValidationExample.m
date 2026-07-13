%% RunPulseValidationExample
% Validate the RPM + synergy-factor pulse prediction model.

clear; clc; close all;

%% Parameters
params.T_iso_start  = 840;
params.smooth_span  = 11;
params.psi_init     = 3.0;
params.save_figures = true;

pulse_file = 'pulse_data_11.txt';
pulse_delim = '\t';
mass_drop_thresh = 1.0;

t_on  = 10;
t_off = 10;
use_label = '5gH2O-100mLCO2';

%% Fit pure CO2 and pure H2O RPM parameters at 850 C
fprintf('========== Fitting pure CO2 at 850 C ==========\n');
data_co2 = ReadTGA('CO2_850C.txt');
mass_ash_co2 = mean(data_co2.m(end-9:end));
data_co2 = CalculateConversion(data_co2, mass_ash_co2, params.smooth_span);
iso_co2  = ExtractIsothermalSegment(data_co2, params.T_iso_start);
rpm_co2  = FitRPM(iso_co2, params.psi_init);

fprintf('\n========== Fitting pure H2O at 850 C ==========\n');
data_h2o = ReadTGA('H2O_850C.txt');
mass_ash_h2o = mean(data_h2o.m(end-9:end));
data_h2o = CalculateConversion(data_h2o, mass_ash_h2o, params.smooth_span);
iso_h2o  = ExtractIsothermalSegment(data_h2o, params.T_iso_start);
rpm_h2o  = FitRPM(iso_h2o, params.psi_init);

%% Analyze mixed-atmosphere synergy
mix_files = {
    'Mix_850C_5gH2O_100mLCO2.txt',    '5gH2O-100mLCO2';
    'Mix_850C_5gH2O_40mLCO2.txt',     '5gH2O-40mLCO2';
    'Mix_850C_0.83gH2O_100mLCO2.txt', '0.83gH2O-100mLCO2';
};

syn_all = {};
fprintf('\n========== Synergy analysis ==========\n');
for i = 1:size(mix_files, 1)
    fname = mix_files{i, 1};
    label = mix_files{i, 2};

    if ~isfile(fname)
        warning('File not found, skipped: %s', fname);
        continue;
    end

    data_mix = ReadTGA(fname);
    mass_ash_mix = mean(data_mix.m(end-9:end));
    data_mix = CalculateConversion(data_mix, mass_ash_mix, params.smooth_span);
    iso_mix  = ExtractIsothermalSegment(data_mix, params.T_iso_start);
    syn = AnalyzeSynergy(iso_mix, rpm_co2, rpm_h2o, label);
    syn_all{end+1} = syn; %#ok<SAGROW>
end

SF_selected = [];
for i = 1:length(syn_all)
    if strcmp(syn_all{i}.label, use_label)
        SF_selected = syn_all{i}.SF_mean;
        break;
    end
end

if isempty(SF_selected)
    error('No synergy factor found for label: %s', use_label);
end

fprintf('\nSelected synergy factor: %s, SF = %.4f\n', use_label, SF_selected);

%% Read measured pulsed experiment data
fprintf('\n========== Reading measured pulse data ==========\n');
pulse_data_raw = ReadPulseData(pulse_file, pulse_delim);

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
    fprintf('Detected dead time/noise segment = %.2f min. Segment removed.\n', dead_time);
end

idx_keep = idx_react:length(pulse_data_raw.t);
pulse_data.t = pulse_data_raw.t(idx_keep) - pulse_data_raw.t(idx_react);
pulse_data.m = pulse_data_raw.m(idx_keep);

%% Validate prediction
fprintf('\n========== Pulse prediction validation ==========\n');
mass_ash_pulse = mean(pulse_data.m(end-9:end));
fprintf('Pulse ash mass estimate: %.4f %%\n', mass_ash_pulse);

comp = ValidatePulsePrediction(pulse_data, mass_ash_pulse, rpm_co2, rpm_h2o, ...
    SF_selected, t_on, t_off, params.smooth_span);

%% Plot validation result
PlotPulseValidation(comp, params.save_figures);

fprintf('\n=== Pulse validation complete ===\n');
fprintf('RMSE = %.4f, MAE = %.4f, R2 = %.4f\n', comp.RMSE, comp.MAE, comp.R2);

