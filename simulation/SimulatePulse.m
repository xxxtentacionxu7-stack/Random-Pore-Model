function pulse = SimulatePulse(co2_rpm, h2o_rpm, syn, t_total, t_on, t_off, dt)
%SIMULATEPULSE Predict pulsed H2O/CO2 gasification conversion.
%
% CO2 is assumed to be continuously supplied. H2O is switched on and off
% periodically. When H2O is on, the mixed rate is corrected by the synergy
% factor. When H2O is off, only the CO2 RPM rate is used.

    n_steps = round(t_total / dt);
    t_vec = (0:n_steps) * dt;
    X_vec = zeros(size(t_vec));
    rate_vec = zeros(size(t_vec));
    valve_vec = zeros(size(t_vec));

    cycle_len = t_on + t_off;
    SF = syn.SF_mean;

    X_vec(1) = 0;

    for i = 1:n_steps
        t_now = t_vec(i);
        X_now = X_vec(i);

        phase = mod(t_now, cycle_len);
        is_on = phase < t_on;
        valve_vec(i) = is_on;

        X_safe = min(max(X_now, 0), 0.9999);

        arg_co2 = 1 - co2_rpm.psi * log(1 - X_safe);
        arg_co2 = max(arg_co2, 0);
        rate_co2 = co2_rpm.k * (1 - X_safe) * sqrt(arg_co2);

        if is_on
            arg_h2o = 1 - h2o_rpm.psi * log(1 - X_safe);
            arg_h2o = max(arg_h2o, 0);
            rate_h2o = h2o_rpm.k * (1 - X_safe) * sqrt(arg_h2o);
            rate_now = SF * (rate_co2 + rate_h2o);
        else
            rate_now = rate_co2;
        end

        rate_vec(i) = rate_now;
        X_vec(i+1) = min(X_now + rate_now * dt, 1);
    end

    phase_end = mod(t_vec(end), cycle_len);
    valve_vec(end+1) = phase_end < t_on; %#ok<NASGU>
    valve_vec = valve_vec(1:length(t_vec));

    pulse.t = t_vec;
    pulse.X = X_vec;
    pulse.rate = rate_vec;
    pulse.valve = valve_vec;
    pulse.SF_used = SF;
    pulse.t_on = t_on;
    pulse.t_off = t_off;

    fprintf('    Pulse prediction complete: total = %.0f min, on/off = %.0f/%.0f min, SF = %.3f\n', ...
        t_total, t_on, t_off, SF);
    fprintf('    Predicted final conversion X(%.0f min) = %.4f\n', ...
        t_total, X_vec(end));
end

