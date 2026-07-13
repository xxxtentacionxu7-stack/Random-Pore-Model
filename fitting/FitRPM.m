function rpm = FitRPM(iso, psi_init)
%% FitRPM 鈥?妯″潡4锛氶殢鏈哄瓟妯″瀷(RPM)鎷熷悎
%
%  闅忔満瀛旀ā鍨?(Random Pore Model, Bhatia & Perlmutter 1980):
%
%    dX/dt = k * (1-X) * sqrt(1 - 蠄*ln(1-X))
%
%  绉垎褰㈠紡锛堢敤浜庢嫙鍚?X vs t锛?
%
%    2/蠄 * [sqrt(1 - 蠄*ln(1-X)) - 1] = k * t
%
%  鍙傛暟:
%    k   鈥?琛ㄨ鍙嶅簲閫熺巼甯告暟 (min^-1)
%    蠄   鈥?缁撴瀯鍙傛暟锛堝弽鏄犲瓟缁撴瀯婕斿彉锛屜?0 琛ㄧず鍏堝姞閫熷悗鍑忛€燂級
%
%  杈撳叆:
%    iso      鈥?鎭掓俯娈垫暟鎹粨鏋勪綋 (鍚?t, X_iso)
%    psi_init 鈥?蠄 鍒濆鐚滄祴鍊?%
%  杈撳嚭: rpm 鈥?缁撴瀯浣擄紝鍚?k, psi, X_fit, R2

    t_data = iso.t;
    X_data = iso.X_iso;

    % 鍘绘帀 X=1 鐨勭偣锛坙n(0) 鏃犲畾涔夛級
    valid  = X_data < 0.999;
    t_fit  = t_data(valid);
    X_fit  = X_data(valid);

    %% 鏂规硶1: 绾挎€у寲鎷熷悎锛堝揩閫熶及绠楋級
    % 浠?F(X) = 2/蠄 * [sqrt(1 - 蠄*ln(1-X)) - 1]
    % 鍒?F(X) = k*t锛屽涓嶅悓 蠄 鎵弿锛屾壘鏈€浼樼嚎鎬у叧绯?
    psi_range = linspace(0.1, 20, 500);
    R2_scan   = zeros(size(psi_range));

    for i = 1:length(psi_range)
        psi_i = psi_range(i);
        arg   = 1 - psi_i .* log(1 - X_fit);
        if any(arg <= 0); R2_scan(i) = 0; continue; end
        F_i   = (2/psi_i) .* (sqrt(arg) - 1);
        % 绾挎€у洖褰?F = k*t锛堣繃鍘熺偣锛?        k_i   = (t_fit' * F_i) / (t_fit' * t_fit);
        X_pred_i = RPM_invertF(k_i .* t_fit, psi_i);
        SS_res = sum((X_fit - X_pred_i).^2);
        SS_tot = sum((X_fit - mean(X_fit)).^2);
        R2_scan(i) = 1 - SS_res/SS_tot;
    end

    [~, best_idx] = max(R2_scan);
    psi_lin = psi_range(best_idx);

    % 鐢ㄦ渶浼?蠄 璁＄畻瀵瑰簲 k
    arg_best = 1 - psi_lin .* log(1 - X_fit);
    F_best   = (2/psi_lin) .* (sqrt(arg_best) - 1);
    k_lin    = (t_fit' * F_best) / (t_fit' * t_fit);

    %% 鏂规硶2: 闈炵嚎鎬ф渶灏忎簩涔樼簿鍖栵紙浠ョ嚎鎬цВ涓哄垵鍊硷級
    rpm_model = @(params, t) RPM_invertF(params(1) .* t, params(2));

    options = optimoptions('lsqcurvefit', ...
        'Display', 'off', ...
        'MaxIterations', 2000, ...
        'FunctionTolerance', 1e-10);

    try
        params0  = [k_lin, psi_lin];
        lb       = [0, 0.01];
        ub       = [10, 50];
        params_fit = lsqcurvefit(rpm_model, params0, t_fit, X_fit, lb, ub, options);
        k_nls   = params_fit(1);
        psi_nls = params_fit(2);
    catch
        warning('闈炵嚎鎬ф嫙鍚堟湭鏀舵暃锛屼娇鐢ㄧ嚎鎬у寲缁撴灉');
        k_nls   = k_lin;
        psi_nls = psi_lin;
    end

    %% 璁＄畻鏈€缁堢粨鏋?    X_pred  = RPM_invertF(k_nls .* t_data, psi_nls);
    X_pred  = max(0, min(1, X_pred));

    SS_res  = sum((X_fit - RPM_invertF(k_nls .* t_fit, psi_nls)).^2);
    SS_tot  = sum((X_fit - mean(X_fit)).^2);
    R2      = 1 - SS_res / SS_tot;

    %% 杈撳嚭
    rpm.k      = k_nls;
    rpm.psi    = psi_nls;
    rpm.R2     = R2;
    rpm.t      = t_data;
    rpm.X_data = X_data;
    rpm.X_fit  = X_pred;
    rpm.R2_scan   = R2_scan;
    rpm.psi_range = psi_range;

    fprintf('    绾挎€у寲鍒濆€? k=%.4f, 蠄=%.4f\n', k_lin, psi_lin);
    fprintf('    闈炵嚎鎬т紭鍖? k=%.4f, 蠄=%.4f, R虏=%.6f\n', k_nls, psi_nls, R2);
end


function X = RPM_invertF(F_val, psi)
%% RPM绉垎褰㈠紡鍙嶈В X:
%  F = 2/蠄 * [sqrt(1 - 蠄*ln(1-X)) - 1] = k*t
%  瑙? X = 1 - exp(-(psi/4)*(F + 2/psi)^2 + 1/psi)
%     绛変环浜? 1 - exp((1 - (psi*F/2 + 1)^2) / psi)

    inner = (psi .* F_val / 2 + 1).^2;
    X = 1 - exp((1 - inner) / psi);
    X = max(0, min(1, X));
end

