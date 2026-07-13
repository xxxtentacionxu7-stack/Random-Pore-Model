function pulse = SimulatePulse(co2_rpm, h2o_rpm, syn, t_total, t_on, t_off, dt)
%% SimulatePulse 鈥?鑴夊啿姘斿寲棰勬祴
%
%  瀹為獙璁惧畾: CO2鍏ㄧ▼鎸佺画閫氬叆锛汬2O鑴夊啿閫氬叆 (寮€t_on鍒嗛挓锛屽叧t_off鍒嗛挓锛屽惊鐜?
%
%  鍙嶅簲閫熺巼鍒囨崲閫昏緫锛堝熀浜庡綋鍓嶈浆鍖栫巼X锛岄€愭椂闂存绉垎锛?
%    H2O寮€锛堣剦鍐睴N锛夋椂:
%        (dX/dt) = SF_mean * [ rate_CO2(X) + rate_H2O(X) ]   鈫?鍗忓悓淇鍚庣殑娣峰悎閫熺巼
%    H2O鍏筹紙鑴夊啿OFF锛夋椂:
%        (dX/dt) = rate_CO2(X)                                 鈫?鍙湁CO2鍦ㄥ弽搴?%
%  杈撳叆:
%    co2_rpm  鈥?绾疌O2 RPM鍙傛暟 (k, psi)锛岃娓╁害涓?%    h2o_rpm  鈥?绾疕2O RPM鍙傛暟 (k, psi)锛岃娓╁害涓?%    syn      鈥?鍗忓悓鍒嗘瀽缁撴灉锛堟彁渚?SF_mean锛夛紝瀵瑰簲鎵€閫夋祦閲忛厤姣?%    t_total  鈥?鎬诲弽搴旀椂闀?(min)锛屽 60
%    t_on     鈥?H2O姣忔寮€鍚椂闀?(min)锛屽 10
%    t_off    鈥?H2O姣忔鍏抽棴鏃堕暱 (min)锛屽 10
%    dt       鈥?绉垎姝ラ暱 (min)锛屽缓璁?0.05~0.1
%
%  杈撳嚭: pulse 鈥?缁撴瀯浣擄紝鍚?t, X, valve_state(H2O寮€鍏崇姸鎬?, rate

    n_steps = round(t_total / dt);
    t_vec   = (0:n_steps) * dt;
    X_vec   = zeros(size(t_vec));
    rate_vec   = zeros(size(t_vec));
    valve_vec  = zeros(size(t_vec));  % 1=寮€, 0=鍏?
    cycle_len = t_on + t_off;
    SF = syn.SF_mean;

    X_vec(1) = 0;

    for i = 1:n_steps
        t_now = t_vec(i);
        X_now = X_vec(i);

        % 鍒ゆ柇褰撳墠鏃跺埢 H2O 闃€闂ㄧ姸鎬侊紙鑴夊啿鍛ㄦ湡鍐呯殑鐩镐綅锛?        phase = mod(t_now, cycle_len);
        is_on = phase < t_on;
        valve_vec(i) = is_on;

        % 璁＄畻鐬椂鍙嶅簲閫熺巼
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

        % 鍓嶅悜娆ф媺绉垎锛堟闀垮灏忔椂瓒冲绮剧‘锛屼篃鍙崲RK4鎻愰珮绮惧害锛?        X_vec(i+1) = min(X_now + rate_now * dt, 1);
    end

    % 鏈€鍚庝竴涓榾闂ㄧ姸鎬佽ˉ榻?    phase_end = mod(t_vec(end), cycle_len);
    valve_vec(end+1) = phase_end < t_on; %#ok<NASGU>
    valve_vec = valve_vec(1:length(t_vec));

    pulse.t      = t_vec;
    pulse.X      = X_vec;
    pulse.rate   = rate_vec;
    pulse.valve  = valve_vec;
    pulse.SF_used = SF;
    pulse.t_on   = t_on;
    pulse.t_off  = t_off;

    fprintf('    鑴夊啿棰勬祴瀹屾垚: 鎬绘椂闀?%.0fmin, 寮€/鍏?%.0f/%.0fmin, SF=%.3f\n', ...
        t_total, t_on, t_off, SF);
    fprintf('    棰勬祴鏈€缁堣浆鍖栫巼 X(%.0fmin) = %.4f\n', t_total, X_vec(end));
end

