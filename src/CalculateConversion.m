function data = CalculateConversion(data, mass_ash, smooth_span)
%CALCULATECONVERSION Calculate conversion, dX/dt, and dm/dt.
%
% Input:
%   data        - structure returned by ReadTGA.
%   mass_ash    - final ash/residue mass percentage.
%   smooth_span - Savitzky-Golay smoothing window.
%
% Output:
%   data.X    - conversion in [0, 1].
%   data.dXdt - smoothed dX/dt.
%   data.dmdt - smoothed dm/dt.

    m0  = data.m(1);
    m_f = mass_ash;

    data.X = (m0 - data.m) ./ (m0 - m_f);
    data.X = max(0, min(1, data.X));

    dt = gradient(data.t);
    dm = gradient(data.m);
    dmdt_raw = dm ./ dt;

    dX = gradient(data.X);
    dXdt_raw = dX ./ dt;

    poly_order = 3;
    if smooth_span < poly_order + 2
        smooth_span = poly_order + 2;
        if mod(smooth_span, 2) == 0
            smooth_span = smooth_span + 1;
        end
    end
    if mod(smooth_span, 2) == 0
        smooth_span = smooth_span + 1;
    end

    data.dmdt = sgolayfilt(dmdt_raw, poly_order, smooth_span);
    data.dXdt = sgolayfilt(dXdt_raw, poly_order, smooth_span);

    fprintf('    Initial mass: %.4f %%, ash mass: %.4f %%\n', m0, m_f);
    fprintf('    Maximum conversion: X_max = %.4f\n', max(data.X));
end

