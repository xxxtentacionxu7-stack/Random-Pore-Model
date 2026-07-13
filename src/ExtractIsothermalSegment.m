function iso = ExtractIsothermalSegment(data, T_iso_start, mass_drop_thresh)
%EXTRACTISOTHERMALSEGMENT Extract the true isothermal reaction segment.
%
% The function first finds the isothermal start from the temperature
% threshold, then removes the initial dead-time/noise segment before a
% clear mass drop appears. Time is reset to zero at the true reaction start.

    if nargin < 3
        mass_drop_thresh = 1.0;
    end

    idx_T = find(data.T >= T_iso_start, 1, 'first');
    if isempty(idx_T)
        error('No data point found with temperature >= %.0f C. Adjust T_iso_start.', ...
            T_iso_start);
    end

    m_ref = data.m(idx_T);
    idx_react = idx_T;
    for ii = idx_T:length(data.m)
        if (m_ref - data.m(ii)) > mass_drop_thresh
            idx_react = ii;
            break;
        end
    end

    dead_time = data.t(idx_react) - data.t(idx_T);

    idx_start = idx_react;
    idx = idx_start:length(data.T);

    iso.T = data.T(idx);
    iso.t = data.t(idx) - data.t(idx_start);
    iso.m = data.m(idx);
    iso.X = data.X(idx);
    iso.dXdt = data.dXdt(idx);
    iso.dmdt = data.dmdt(idx);
    iso.dead_time = dead_time;

    X0_iso = iso.X(1);
    iso.X_iso = (iso.X - X0_iso) ./ (1 - X0_iso);
    iso.X_iso = max(0, min(1, iso.X_iso));

    fprintf('    Temperature threshold start: idx = %d, t = %.1f min, T = %.1f C\n', ...
        idx_T, data.t(idx_T), data.T(idx_T));
    if dead_time > 1e-6
        fprintf('    Dead time detected: %.1f min. Segment removed.\n', dead_time);
    end
    fprintf('    True reaction start: idx = %d, t = %.1f min\n', ...
        idx_start, data.t(idx_start));
    fprintf('    Reaction segment points: %d, duration: %.1f min\n', ...
        length(iso.t), iso.t(end));
    fprintf('    Isothermal conversion range: %.4f to %.4f\n', ...
        min(iso.X_iso), max(iso.X_iso));
end

