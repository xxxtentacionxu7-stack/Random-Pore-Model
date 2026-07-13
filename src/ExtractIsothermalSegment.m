function iso = ExtractIsothermalSegment(data, T_iso_start, mass_drop_thresh)
%% ExtractIsothermalSegment 鈥?妯″潡3锛氭彁鍙栫瓑娓╂皵鍖栨鏁版嵁锛堝惈姝绘椂闂磋嚜鍔ㄥ墧闄わ級
%
%  鑳屾櫙:
%    瀹炴祴鍙戠幇鏌愪簺姘旀皼锛堝H2O銆佹贩鍚堟皵锛夊湪娓╁害鍒拌揪鎭掓俯闃堝€煎悗锛?%    瀛樺湪涓€娈?姝绘椂闂?锛坉ead time锛夆€斺€旇川閲忓嚑涔庝笉鍙橈紝
%    鍙兘鐢辫澶囬榾闂ㄥ垏鎹㈠欢杩熴€佷紶鎰熷櫒鍝嶅簲寤惰繜绛夐€犳垚锛?%    骞堕潪鐪熷疄鍙嶅簲琛屼负銆傝嫢涓嶅墧闄わ紝浼氫弗閲嶆壄鏇睷PM鎷熷悎锛坧si銆乲澶辩湡锛孯虏楠ら檷锛夈€?%
%  鍋氭硶:
%    1. 鍏堟寜娓╁害闃堝€兼壘鍒版亽娓╂璧风偣 idx_T
%    2. 鍦ㄨ璧风偣涔嬪悗锛屾壂鎻忚川閲忔洸绾匡紝鎵惧埌璐ㄩ噺鐩稿idx_T澶?%       棣栨涓嬮檷瓒呰繃 mass_drop_thresh 鐨勭偣锛屼綔涓?鐪熷疄鍙嶅簲璧风偣" idx_react
%    3. 鐪熷疄鍙嶅簲璧风偣涔嬪墠鐨勯儴鍒嗭紙姝绘椂闂达級琚墧闄わ紝
%       鎭掓俯娈垫暟鎹粠 idx_react 寮€濮嬭鏃讹紙t=0锛?%
%  杈撳叆:
%    data              鈥?瀹屾暣鏁版嵁缁撴瀯浣?%    T_iso_start        鈥?鎭掓俯娈佃捣濮嬫俯搴﹂槇鍊?(掳C)
%    mass_drop_thresh   鈥?鍒ゅ畾"鐪熷疄鍙嶅簲寮€濮?鐨勮川閲忎笅闄嶉槇鍊?%)锛岄粯璁?.5
%
%  杈撳嚭: iso 鈥?浠呭惈鐪熷疄鍙嶅簲娈电殑缁撴瀯浣擄紝鏃堕棿浠?閲嶇疆
%        iso.dead_time 鈥?妫€娴嬪埌鐨勬鏃堕棿闀垮害(min)锛屼緵妫€鏌?璁板綍鐢?
    if nargin < 3
        mass_drop_thresh = 1.0;
    end

    idx_T = find(data.T >= T_iso_start, 1, 'first');
    if isempty(idx_T)
        error('鏈壘鍒版俯搴?>= %.0f掳C 鐨勬暟鎹偣锛岃璋冩暣 T_iso_start', T_iso_start);
    end

    % 鍦ㄦ亽娓╂鍐呮壂鎻忥紝瀵绘壘璐ㄩ噺棣栨鏄捐憲涓嬮檷鐨勭偣
    m_ref = data.m(idx_T);
    idx_react = idx_T;  % 榛樿鍊硷紝鑻ユ棤鏄捐憲涓嬮檷鍒欑瓑鍚屼簬娓╁害璧风偣
    for ii = idx_T:length(data.m)
        if (m_ref - data.m(ii)) > mass_drop_thresh
            idx_react = ii;
            break;
        end
    end

    dead_time = data.t(idx_react) - data.t(idx_T);

    idx_start = idx_react;
    idx = idx_start : length(data.T);

    iso.T    = data.T(idx);
    iso.t    = data.t(idx) - data.t(idx_start);  % 鐪熷疄鍙嶅簲鏃堕棿浠?寮€濮?(min)
    iso.m    = data.m(idx);
    iso.X    = data.X(idx);
    iso.dXdt = data.dXdt(idx);
    iso.dmdt = data.dmdt(idx);
    iso.dead_time = dead_time;

    % 閲嶆柊褰掍竴鍖栬浆鍖栫巼锛堜互鐪熷疄鍙嶅簲璧风偣涓哄熀鍑嗭級
    X0_iso   = iso.X(1);
    iso.X_iso = (iso.X - X0_iso) ./ (1 - X0_iso);
    iso.X_iso = max(0, min(1, iso.X_iso));

    fprintf('    娓╁害鎭掓俯璧风偣: idx=%d, t=%.1fmin, T=%.1f掳C\n', idx_T, data.t(idx_T), data.T(idx_T));
    if dead_time > 1e-6
        fprintf('    *** 妫€娴嬪埌姝绘椂闂?= %.1f min锛堣川閲忓湪姝ゆ湡闂村熀鏈笉鍙橈紝宸插墧闄わ級\n', dead_time);
    end
    fprintf('    鐪熷疄鍙嶅簲璧风偣: idx=%d, t=%.1fmin\n', idx_start, data.t(idx_start));
    fprintf('    鍙嶅簲娈垫暟鎹偣鏁? %d,  鎸佺画鏃堕棿: %.1f min\n', length(iso.t), iso.t(end));
    fprintf('    鍙嶅簲娈佃浆鍖栫巼鑼冨洿: %.4f ~ %.4f\n', min(iso.X_iso), max(iso.X_iso));
end

