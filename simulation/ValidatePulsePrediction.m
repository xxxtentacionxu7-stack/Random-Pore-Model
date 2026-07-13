function comp = ValidatePulsePrediction(pulse_data, mass_ash, rpm_co2, rpm_h2o, SF, t_on, t_off, smooth_span)
%% ValidatePulsePrediction 鈥?鑴夊啿瀹炴祴鏁版嵁 vs RPM+鍗忓悓妯″瀷棰勬祴瀵规瘮
%
%  杈撳叆:
%    pulse_data   鈥?鏉ヨ嚜 TGA_readPulseCSV 鐨勭粨鏋勪綋 (t, m)锛屽凡鍓旈櫎寮€澶村皷宄?%    mass_ash     鈥?鐏板垎(%)锛岀敤浜庤绠楀疄娴嬭浆鍖栫巼
%    rpm_co2      鈥?绾疌O2 RPM鍙傛暟 (k, psi)
%    rpm_h2o      鈥?绾疕2O RPM鍙傛暟 (k, psi)
%    SF           鈥?鍗忓悓鍥犲瓙锛堟爣閲忥紝鏉ヨ嚜AnalyzeSynergy锛?%    t_on, t_off  鈥?鑴夊啿H2O寮€/鍏虫椂闀?min)锛屽亣璁句粠t=0寮€濮嬪嵆涓?寮€"
%    smooth_span  鈥?DTG骞虫粦绐楀彛
%
%  杈撳嚭: comp 鈥?缁撴瀯浣擄紝鍚疄娴?棰勬祴鐨?t, X锛屼互鍙?RMSE, MAE

    %% 1. 璁＄畻瀹炴祴杞寲鐜?    m0 = pulse_data.m(1);
    X_meas = (m0 - pulse_data.m) / (m0 - mass_ash);
    X_meas = max(0, min(1, X_meas));
    t_meas = pulse_data.t;

    %% 2. 鐢ㄧ浉鍚岀殑鑴夊啿鏂规鐢熸垚棰勬祴鏇茬嚎
    t_total = t_meas(end);
    dt = 0.05;
    pred = SimulatePulse(rpm_co2, rpm_h2o, struct('SF_mean', SF), t_total, t_on, t_off, dt);

    %% 3. 鎻掑€煎榻愶紝璁＄畻璇樊
    X_pred_interp = interp1(pred.t, pred.X, t_meas, 'linear', 'extrap');

    resid = X_meas - X_pred_interp;
    RMSE  = sqrt(mean(resid.^2));
    MAE   = mean(abs(resid));

    % R虏 (浠ュ疄娴嬩负鍩哄噯)
    SS_res = sum(resid.^2);
    SS_tot = sum((X_meas - mean(X_meas)).^2);
    R2 = 1 - SS_res/SS_tot;

    %% 杈撳嚭
    comp.t_meas   = t_meas;
    comp.X_meas   = X_meas;
    comp.t_pred   = pred.t;
    comp.X_pred   = pred.X;
    comp.valve    = pred.valve;
    comp.RMSE     = RMSE;
    comp.MAE      = MAE;
    comp.R2       = R2;
    comp.SF_used  = SF;
    comp.t_on     = t_on;
    comp.t_off    = t_off;

    fprintf('    瀹炴祴 vs 棰勬祴瀵规瘮:\n');
    fprintf('      RMSE = %.4f\n', RMSE);
    fprintf('      MAE  = %.4f\n', MAE);
    fprintf('      R虏   = %.4f\n', R2);
    fprintf('      瀹炴祴鏈€缁圶 = %.4f,  棰勬祴鏈€缁圶 = %.4f\n', X_meas(end), X_pred_interp(end));
end

