function rpm = FitRPM(iso, psi_init)
%FITRPM Fit Random Pore Model parameters.
%
% Random Pore Model:
%   dX/dt = k * (1 - X) * sqrt(1 - psi * ln(1 - X))
%
% Integrated form used for fitting:
%   2/psi * (sqrt(1 - psi * ln(1 - X)) - 1) = k * t
%
% Input:
%   iso      - isothermal segment structure with fields t and X_iso.
%   psi_init - initial guess for psi. Kept for interface compatibility.
%
% Output:
%   rpm - structure containing k, psi, X_fit, R2, and scan data.

    %#ok<NASGU>
    t_data = iso.t;
    X_data = iso.X_iso;

    valid = X_data < 0.999;
    t_fit = t_data(valid);
    X_fit = X_data(valid);

    %% Step 1: linearized scan over psi
    psi_range = linspace(0.1, 20, 500);
    R2_scan = zeros(size(psi_range));

    for i = 1:length(psi_range)
        psi_i = psi_range(i);
        arg = 1 - psi_i .* log(1 - X_fit);
        if any(arg <= 0)
            R2_scan(i) = 0;
            continue;
        end

        F_i = (2 / psi_i) .* (sqrt(arg) - 1);
        k_i = (t_fit' * F_i) / (t_fit' * t_fit);
        X_pred_i = RPM_invertF(k_i .* t_fit, psi_i);

        SS_res = sum((X_fit - X_pred_i).^2);
        SS_tot = sum((X_fit - mean(X_fit)).^2);
        R2_scan(i) = 1 - SS_res / SS_tot;
    end

    [~, best_idx] = max(R2_scan);
    psi_lin = psi_range(best_idx);

    arg_best = 1 - psi_lin .* log(1 - X_fit);
    F_best = (2 / psi_lin) .* (sqrt(arg_best) - 1);
    k_lin = (t_fit' * F_best) / (t_fit' * t_fit);

    %% Step 2: nonlinear least-squares refinement
    rpm_model = @(params, t) RPM_invertF(params(1) .* t, params(2));

    options = optimoptions('lsqcurvefit', ...
        'Display', 'off', ...
        'MaxIterations', 2000, ...
        'FunctionTolerance', 1e-10);

    try
        params0 = [k_lin, psi_lin];
        lb = [0, 0.01];
        ub = [10, 50];
        params_fit = lsqcurvefit(rpm_model, params0, t_fit, X_fit, lb, ub, options);
        k_nls = params_fit(1);
        psi_nls = params_fit(2);
    catch
        warning('Nonlinear fitting did not converge. Using linearized scan result.');
        k_nls = k_lin;
        psi_nls = psi_lin;
    end

    %% Final prediction and goodness of fit
    X_pred = RPM_invertF(k_nls .* t_data, psi_nls);
    X_pred = max(0, min(1, X_pred));

    SS_res = sum((X_fit - RPM_invertF(k_nls .* t_fit, psi_nls)).^2);
    SS_tot = sum((X_fit - mean(X_fit)).^2);
    R2 = 1 - SS_res / SS_tot;

    rpm.k = k_nls;
    rpm.psi = psi_nls;
    rpm.R2 = R2;
    rpm.t = t_data;
    rpm.X_data = X_data;
    rpm.X_fit = X_pred;
    rpm.R2_scan = R2_scan;
    rpm.psi_range = psi_range;

    fprintf('    Linearized estimate: k = %.4f, psi = %.4f\n', k_lin, psi_lin);
    fprintf('    Nonlinear result:    k = %.4f, psi = %.4f, R2 = %.6f\n', ...
        k_nls, psi_nls, R2);
end

function X = RPM_invertF(F_val, psi)
%RPM_INVERTF Invert the integrated RPM expression.

    inner = (psi .* F_val / 2 + 1).^2;
    X = 1 - exp((1 - inner) / psi);
    X = max(0, min(1, X));
end

