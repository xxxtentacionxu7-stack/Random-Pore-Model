function syn = AnalyzeSynergy(mix_data, co2_rpm, h2o_rpm, label)
%% AnalyzeSynergy 鈥?鍗忓悓鏁堝簲鍒嗘瀽
%
%  鎬濊矾:
%    绾挎€у彔鍔犲亣璁? 濡傛灉CO2鍜孒2O浜掍笉褰卞搷锛屾贩鍚堟皵鍖栨椂
%    鎬诲弽搴旈€熺巼 = CO2鍗曠嫭璐＄尞鐨勯€熺巼 + H2O鍗曠嫭璐＄尞鐨勯€熺巼锛堟寜鍚勮嚜鍔ㄥ姏瀛︼級
%
%    瀹為檯鍋氭硶: 鐢?RPM 鐨勫井鍒嗗舰寮?%      (dX/dt)_CO2  = k_CO2 * (1-X) * sqrt(1 - psi_CO2*ln(1-X))
%      (dX/dt)_H2O  = k_H2O * (1-X) * sqrt(1 - psi_H2O*ln(1-X))
%      (dX/dt)_predict_linear = (dX/dt)_CO2 + (dX/dt)_H2O   [绾挎€у彔鍔犻娴媇
%
%    鍗忓悓鍥犲瓙瀹氫箟:
%      SF(X) = (dX/dt)_瀹炴祴娣峰悎  /  (dX/dt)_绾挎€у彔鍔犻娴?%      SF > 1  鈫?姝ｅ崗鍚岋紙娣峰悎姣斿崟绾彔鍔犳洿蹇級
%      SF < 1  鈫?璐熷崗鍚?鎶戝埗
%      SF 鈮?1  鈫?鏃犲崗鍚岋紝绠€鍗曞彔鍔?%
%  杈撳叆:
%    mix_data 鈥?娣峰悎瀹為獙鎭掓俯娈电粨鏋勪綋 (鍚?t, X_iso, dXdt)
%    co2_rpm  鈥?璇ユ俯搴︿笅绾疌O2鐨凴PM鎷熷悎缁撴灉 (鍚?k, psi)
%    h2o_rpm  鈥?璇ユ俯搴︿笅绾疕2O鐨凴PM鎷熷悎缁撴灉 (鍚?k, psi)
%    label    鈥?鏍囩瀛楃涓诧紝濡?'100mL'
%
%  杈撳嚭: syn 鈥?缁撴瀯浣擄紝鍚?SF(鍗忓悓鍥犲瓙搴忓垪), X, t, rate_mix, rate_linear

    X  = mix_data.X_iso;
    t  = mix_data.t;

    % 瀹炴祴娣峰悎閫熺巼锛堝凡骞虫粦杩囩殑 dX/dt锛?    rate_mix = mix_data.dXdt;

    % 鐢–O2鍜孒2O鍚勮嚜鐨凴PM鍙傛暟锛岃绠?鍋囪鍚勮嚜鐙珛鍙嶅簲"鏃跺湪鐩稿悓X涓嬬殑閫熺巼
    valid = (X > 0) & (X < 0.999);

    rate_co2  = zeros(size(X));
    rate_h2o  = zeros(size(X));

    arg_co2 = 1 - co2_rpm.psi .* log(1 - X(valid));
    arg_h2o = 1 - h2o_rpm.psi .* log(1 - X(valid));
    arg_co2(arg_co2 < 0) = 0;
    arg_h2o(arg_h2o < 0) = 0;

    rate_co2(valid) = co2_rpm.k .* (1 - X(valid)) .* sqrt(arg_co2);
    rate_h2o(valid) = h2o_rpm.k .* (1 - X(valid)) .* sqrt(arg_h2o);

    rate_linear = rate_co2 + rate_h2o;  % 绾挎€у彔鍔犻娴嬮€熺巼

    % 鍗忓悓鍥犲瓙
    SF = nan(size(X));
    nz = rate_linear > 1e-8;
    SF(nz) = rate_mix(nz) ./ rate_linear(nz);

    % 骞冲潎鍗忓悓鍥犲瓙锛堟帓闄ゅご灏惧櫔澹拌緝澶х殑鍖洪棿锛屽彧鍙?X in [0.05, 0.95]锛?    mid = (X > 0.05) & (X < 0.95) & ~isnan(SF) & isfinite(SF);
    SF_mean = mean(SF(mid));
    SF_std  = std(SF(mid));

    %% 杈撳嚭
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

    fprintf('    [%s] 骞冲潎鍗忓悓鍥犲瓙 SF = %.3f 卤 %.3f\n', label, SF_mean, SF_std);
    if SF_mean > 1.05
        fprintf('        鈫?姝ｅ崗鍚屾晥搴旓紙娣峰悎姘斿寲琚績杩涳級\n');
    elseif SF_mean < 0.95
        fprintf('        鈫?璐熷崗鍚?鎶戝埗鏁堝簲\n');
    else
        fprintf('        鈫?鎺ヨ繎绾挎€у彔鍔狅紝鏃犳樉钁楀崗鍚孿n');
    end
end

