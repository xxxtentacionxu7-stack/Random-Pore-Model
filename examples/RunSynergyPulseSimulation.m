%% RunSynergyPulseSimulation
% CO2/H2O synergy analysis and pulsed gasification prediction.

clear; clc; close all;

%% Parameters
params.T_iso_start  = 840;
params.smooth_span  = 11;
params.psi_init     = 3.0;
params.save_figures = true;

pulse_params.t_total = 60;
pulse_params.t_on    = 10;
pulse_params.t_off   = 10;
pulse_params.dt      = 0.05;
pulse_params.use_label = '5gH2O-100mLCO2';

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

%% Predict pulsed gasification
fprintf('\n========== Pulsed gasification prediction ==========\n');

syn_selected = [];
for i = 1:length(syn_all)
    if strcmp(syn_all{i}.label, pulse_params.use_label)
        syn_selected = syn_all{i};
        break;
    end
end

if isempty(syn_selected)
    warning('Label %s not found. Using the first available synergy result.', ...
        pulse_params.use_label);
    syn_selected = syn_all{1};
end

pulse = SimulatePulse(rpm_co2, rpm_h2o, syn_selected, ...
    pulse_params.t_total, pulse_params.t_on, pulse_params.t_off, pulse_params.dt);

pulse_continuous = SimulatePulse(rpm_co2, rpm_h2o, syn_selected, ...
    pulse_params.t_total, pulse_params.t_total, 0, pulse_params.dt);

pulse_co2_only = SimulatePulse(rpm_co2, rpm_h2o, syn_selected, ...
    pulse_params.t_total, 0, pulse_params.t_total, pulse_params.dt);

fprintf('  Continuous H2O reference: X(%.0f min) = %.4f\n', ...
    pulse_params.t_total, pulse_continuous.X(end));
fprintf('  CO2-only reference:       X(%.0f min) = %.4f\n', ...
    pulse_params.t_total, pulse_co2_only.X(end));

%% Plot results
PlotSynergyAndPulse(syn_all, pulse, params.save_figures);

fprintf('\n\n============ Summary ============\n');
fprintf('Pure CO2 at 850 C: k = %.4f, psi = %.4f, R2 = %.5f\n', ...
    rpm_co2.k, rpm_co2.psi, rpm_co2.R2);
fprintf('Pure H2O at 850 C: k = %.4f, psi = %.4f, R2 = %.5f\n', ...
    rpm_h2o.k, rpm_h2o.psi, rpm_h2o.R2);

fprintf('\nSynergy factors:\n');
for i = 1:length(syn_all)
    fprintf('  %-20s  SF = %.3f +/- %.3f\n', ...
        syn_all{i}.label, syn_all{i}.SF_mean, syn_all{i}.SF_std);
end

fprintf('\nPulse prediction using %s, SF = %.3f:\n', ...
    pulse_params.use_label, syn_selected.SF_mean);
fprintf('  Pulse mode:      X(%.0f min) = %.4f\n', pulse_params.t_total, pulse.X(end));
fprintf('  Continuous H2O:  X(%.0f min) = %.4f\n', pulse_params.t_total, pulse_continuous.X(end));
fprintf('  CO2 only:        X(%.0f min) = %.4f\n', pulse_params.t_total, pulse_co2_only.X(end));

fprintf('\n=== All done ===\n');

