function comp = ValidatePulsePrediction(pulse_data, mass_ash, rpm_co2, rpm_h2o, SF, t_on, t_off, smooth_span)
%VALIDATEPULSEPREDICTION Compare measured pulse data with model prediction.
%
% Input:
%   pulse_data - measured pulse data with fields t and m.
%   mass_ash   - final ash/residue mass percentage.
%   rpm_co2    - pure CO2 RPM parameters.
%   rpm_h2o    - pure H2O RPM parameters.
%   SF         - scalar synergy factor.
%   t_on       - H2O-on duration.
%   t_off      - H2O-off duration.

    %#ok<INUSD>

    m0 = pulse_data.m(1);
    X_meas = (m0 - pulse_data.m) / (m0 - mass_ash);
    X_meas = max(0, min(1, X_meas));
    t_meas = pulse_data.t;

    t_total = t_meas(end);
    dt = 0.05;
    pred = SimulatePulse(rpm_co2, rpm_h2o, struct('SF_mean', SF), ...
        t_total, t_on, t_off, dt);

    X_pred_interp = interp1(pred.t, pred.X, t_meas, 'linear', 'extrap');

    resid = X_meas - X_pred_interp;
    RMSE = sqrt(mean(resid.^2));
    MAE = mean(abs(resid));

    SS_res = sum(resid.^2);
    SS_tot = sum((X_meas - mean(X_meas)).^2);
    R2 = 1 - SS_res / SS_tot;

    comp.t_meas = t_meas;
    comp.X_meas = X_meas;
    comp.t_pred = pred.t;
    comp.X_pred = pred.X;
    comp.valve = pred.valve;
    comp.RMSE = RMSE;
    comp.MAE = MAE;
    comp.R2 = R2;
    comp.SF_used = SF;
    comp.t_on = t_on;
    comp.t_off = t_off;

    fprintf('    Measured vs predicted comparison:\n');
    fprintf('      RMSE = %.4f\n', RMSE);
    fprintf('      MAE  = %.4f\n', MAE);
    fprintf('      R2   = %.4f\n', R2);
    fprintf('      Final measured X = %.4f, final predicted X = %.4f\n', ...
        X_meas(end), X_pred_interp(end));
end

