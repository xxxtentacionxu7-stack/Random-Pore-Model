function data = ReadTGA(filename)
%% ReadTGA 鈥?妯″潡1锛氳鍙朤GA鍘熷txt鏁版嵁
%
%  杈撳叆:  filename 鈥?txt鏂囦欢璺緞
%  杈撳嚭:  data     鈥?缁撴瀯浣擄紝鍖呭惈 T(娓╁害), t(鏃堕棿), m(璐ㄩ噺%)
%
%  鏁版嵁鏍煎紡鍋囪: Tab鍒嗛殧锛?鍒?[娓╁害(掳C), 鏃堕棿(min), 璐ㄩ噺(%)]锛屾棤琛ㄥご

    raw = readmatrix(filename, 'Delimiter', '\t', 'FileType', 'text');

    % 鑷姩璇嗗埆鍒楋紙鎸夋暟鍊艰寖鍥村垽鏂級
    % 娓╁害鍒? 鏈€澶у€?> 100掳C
    % 鏃堕棿鍒? 鍗曡皟閫掑锛岃寖鍥磋緝灏?    % 璐ㄩ噺鍒? 0~100涔嬮棿
    data.T = raw(:, 1);   % 娓╁害 (掳C)
    data.t = raw(:, 2);   % 鏃堕棿 (min)
    data.m = raw(:, 3);   % 璐ㄩ噺 (%)

    % 鍘婚櫎NaN琛?    valid = ~any(isnan(raw), 2);
    data.T = data.T(valid);
    data.t = data.t(valid);
    data.m = data.m(valid);

    fprintf('    璇诲彇瀹屾垚: %d 琛屾暟鎹甛n', length(data.T));
    fprintf('    娓╁害鑼冨洿: %.1f ~ %.1f 掳C\n', min(data.T), max(data.T));
    fprintf('    鏃堕棿鑼冨洿: %.1f ~ %.1f min\n', min(data.t), max(data.t));
    fprintf('    璐ㄩ噺鑼冨洿: %.4f ~ %.4f %%\n', min(data.m), max(data.m));
end

