function data = CalculateConversion(data, mass_ash, smooth_span)
%% CalculateConversion 鈥?妯″潡2锛氳绠楄浆鍖栫巼 X 鍜屽井鍒嗙儹閲?DTG
%
%  杈撳叆:
%    data        鈥?鏉ヨ嚜 ReadTGA 鐨勭粨鏋勪綋
%    mass_ash    鈥?鐏板垎娈嬩綑璐ㄩ噺鐧惧垎姣?(%)
%    smooth_span 鈥?Savitzky-Golay 骞虫粦绐楀彛瀹藉害锛堝鏁帮級
%
%  杈撳嚭: data 杩藉姞瀛楁:
%    X     鈥?纰宠浆鍖栫巼 [0, 1]
%    dXdt  鈥?dX/dt (min^-1)锛屽凡骞虫粦
%    dmdt  鈥?dm/dt (%/min)锛屽凡骞虫粦

    m0  = data.m(1);       % 鍒濆璐ㄩ噺 (%)
    m_f = mass_ash;        % 鏈€缁堢伆鍒嗚川閲?(%)

    % 杞寲鐜? X = (m0 - m) / (m0 - m_f)
    data.X = (m0 - data.m) ./ (m0 - m_f);
    data.X = max(0, min(1, data.X));  % 闄愬埗鍦?[0,1]

    % DTG: 瀵硅川閲忔眰鏃堕棿瀵兼暟锛屼娇鐢?Savitzky-Golay 婊ゆ尝骞虫粦
    % 鍏堣绠楀師濮嬪鏁帮紙涓績宸垎锛?    dt   = gradient(data.t);
    dm   = gradient(data.m);
    dmdt_raw = dm ./ dt;

    dX   = gradient(data.X);
    dXdt_raw = dX ./ dt;

    % Savitzky-Golay 骞虫粦 (澶氶」寮忛樁鏁?3)
    poly_order = 3;
    if smooth_span < poly_order + 2
        smooth_span = poly_order + 2;
        if mod(smooth_span, 2) == 0; smooth_span = smooth_span + 1; end
    end
    if mod(smooth_span, 2) == 0; smooth_span = smooth_span + 1; end

    data.dmdt  = sgolayfilt(dmdt_raw,  poly_order, smooth_span);
    data.dXdt  = sgolayfilt(dXdt_raw,  poly_order, smooth_span);

    fprintf('    鍒濆璐ㄩ噺: %.4f %%,  鐏板垎: %.4f %%\n', m0, m_f);
    fprintf('    鏈€缁堣浆鍖栫巼: X_max = %.4f\n', max(data.X));
end

