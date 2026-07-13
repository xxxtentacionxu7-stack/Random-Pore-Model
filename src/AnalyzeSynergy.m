function syn = AnalyzeSynergy(mix_data, co2_rpm, h2o_rpm, label)
%ANALYZESYNERGY Calculate CO2/H2O gasification synergy factor.
%
% The linear-addition reference assumes:
%   rate_linear = rate_CO2 + rate_H2O
%
% The synergy factor is defined as:
%   SF = measured_mixed_rate / rate_linear
%
% SF > 1 means positive synergy, SF < 1 means inhibition.

    X = mix_data.X_iso;
    t = mix_data.t;

    rate_mix = mix_data.dXdt;

    valid = (X > 0) & (X < 0.999);

    rate_co2 = zeros(size(X));
    rate_h2o = zeros(size(X));

    arg_co2 = 1 - co2_rpm.psi .* log(1 - X(valid));
    arg_h2o = 1 - h2o_rpm.psi .* log(1 - X(valid));
    arg_co2(arg_co2 < 0) = 0;
    arg_h2o(arg_h2o < 0) = 0;

    rate_co2(valid) = co2_rpm.k .* (1 - X(valid)) .* sqrt(arg_co2);
    rate_h2o(valid) = h2o_rpm.k .* (1 - X(valid)) .* sqrt(arg_h2o);

    rate_linear = rate_co2 + rate_h2o;

    SF = nan(size(X));
    nz = rate_linear > 1e-8;
    SF(nz) = rate_mix(nz) ./ rate_linear(nz);

    mid = (X > 0.05) & (X < 0.95) & ~isnan(SF) & isfinite(SF);
    SF_mean = mean(SF(mid));
    SF_std  = std(SF(mid));

    syn.label       = label;
    syn.t           = t;
    syn.X           = X;
    syn.rate_mix    = rate_mix;
    syn.rate_co2    = rate_co2;
    syn.rate_h2o    = rate_h2o;
    syn.rate_linear = rate_linear;
    syn.SF          = SF;
    syn.SF_mean     = SF_mean;
    syn.SF_std      = SF_std;

    fprintf('    [%s] Mean synergy factor SF = %.3f +/- %.3f\n', ...
        label, SF_mean, SF_std);
    if SF_mean > 1.05
        fprintf('        Positive synergy: mixed gasification is promoted.\n');
    elseif SF_mean < 0.95
        fprintf('        Negative synergy or inhibition.\n');
    else
        fprintf('        Close to linear addition.\n');
    end
end

