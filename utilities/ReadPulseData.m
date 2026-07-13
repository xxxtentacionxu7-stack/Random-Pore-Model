function pulse_data = ReadPulseData(filename, delimiter)
%% ReadPulseData 鈥?璇诲彇涓ゅ垪鑴夊啿鏁版嵁 (鏃堕棿, 璐ㄩ噺%)
%
%  閫傜敤鍦烘櫙: 浣犲凡缁忎粠Origin/MATLAB/Excel鎶婅剦鍐插疄楠屾暟鎹墜鍔ㄦ彁鍙栨垚
%            骞插噣鐨勪袱鍒楁枃浠? 绗?鍒?鏃堕棿(min), 绗?鍒?璐ㄩ噺(%)
%            锛堜笉鍚俯搴﹀垪锛屽洜涓鸿剦鍐叉暟鎹€氬父鏁存閮藉湪鎭掓俯娈碉級
%
%  杈撳叆:
%    filename  鈥?鏂囦欢璺緞 (.txt 鎴?.csv)
%    delimiter 鈥?鍒嗛殧绗︼紝榛樿 '\t'锛圱ab锛夛紱鑻ユ槸csv鐢?','
%
%  杈撳嚭: pulse_data 鈥?缁撴瀯浣擄紝鍚?t(鏃堕棿,宸查噸缃负0璧风偣), m(璐ㄩ噺%)

    if nargin < 2
        delimiter = '\t';
    end

    raw = readmatrix(filename, 'Delimiter', delimiter, 'FileType', 'text');

    t_all = raw(:,1);
    m_all = raw(:,2);

    valid = ~any(isnan(raw(:,1:2)), 2);
    t_all = t_all(valid);
    m_all = m_all(valid);

    % 鏃堕棿閲嶇疆涓?璧风偣
    pulse_data.t = t_all - t_all(1);
    pulse_data.m = m_all;

    fprintf('    璇诲彇鑴夊啿鏁版嵁瀹屾垚: %d 涓偣\n', length(pulse_data.t));
    fprintf('    鏃堕棿鑼冨洿: 0 ~ %.1f min\n', pulse_data.t(end));
    fprintf('    璐ㄩ噺鑼冨洿: %.4f ~ %.4f %%\n', min(pulse_data.m), max(pulse_data.m));
end

