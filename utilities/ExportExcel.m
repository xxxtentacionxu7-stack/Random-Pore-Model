function ExportExcel(results)
%% ExportExcel 鈥?瀵煎嚭姹囨€荤粨鏋滃埌 Excel
%
%  Sheet1: RPM鍙傛暟姹囨€?+ Arrhenius缁撴灉
%  Sheet2~N: 鍚勬俯搴︽亽娓╂璇︾粏鏁版嵁锛圶, dX/dt, RPM鎷熷悎锛?
    filename_out = 'TGA_results_summary.xlsx';

    %% Sheet1: 鍙傛暟姹囨€?    n = length(results);
    T_list   = arrayfun(@(r) r.T_exp, results)';
    k_list   = arrayfun(@(r) r.k,    results)';
    psi_list = arrayfun(@(r) r.psi,  results)';
    R2_list  = arrayfun(@(r) r.R2,   results)';
    ash_list = arrayfun(@(r) r.mass_ash, results)';

    header1 = {'瀹為獙娓╁害(掳C)', '鐏板垎(%)', 'k (min^-1)', 'psi', 'R2'};
    data1   = [T_list, ash_list, k_list, psi_list, R2_list];

    writecell(header1, filename_out, 'Sheet', 'RPM鍙傛暟姹囨€?, 'Range', 'A1');
    writematrix(data1, filename_out, 'Sheet', 'RPM鍙傛暟姹囨€?, 'Range', 'A2');

    %% Arrhenius 鍐欏叆鍚屼竴Sheet
    R_gas = 8.314e-3;
    T_K   = T_list + 273.15;
    ln_k  = log(k_list);
    p     = polyfit(1./T_K, ln_k, 1);
    Ea    = -p(1) * R_gas;
    A_pre = exp(p(2));

    ln_k_fit = polyval(p, 1./T_K);
    R2_arr   = 1 - sum((ln_k - ln_k_fit).^2) / sum((ln_k - mean(ln_k)).^2);

    arr_header = {'', 'Ea (kJ/mol)', 'A (min^-1)', 'Arrhenius R2'};
    arr_data   = {'Arrhenius', Ea, A_pre, R2_arr};
    row_offset = n + 4;
    writecell(arr_header, filename_out, 'Sheet', 'RPM鍙傛暟姹囨€?, ...
        'Range', sprintf('A%d', row_offset));
    writecell(arr_data, filename_out, 'Sheet', 'RPM鍙傛暟姹囨€?, ...
        'Range', sprintf('A%d', row_offset+1));

    %% Sheet2~N: 鍚勬俯搴﹁缁嗘暟鎹?    for i = 1:n
        sheet_name = sprintf('%d掳C鏁版嵁', results(i).T_exp);
        header_i   = {'鏃堕棿(min)', '杞寲鐜嘪_iso', 'RPM鎷熷悎X', 'dX/dt(min^-1)'};
        data_i     = [results(i).rpm.t, ...
                      results(i).rpm.X_data, ...
                      results(i).rpm.X_fit, ...
                      results(i).iso.dXdt];

        writecell(header_i, filename_out, 'Sheet', sheet_name, 'Range', 'A1');
        writematrix(data_i, filename_out, 'Sheet', sheet_name, 'Range', 'A2');
    end

    fprintf('    Excel宸插鍑? %s\n', filename_out);
    fprintf('    鍖呭惈 %d 涓猄heet锛堝弬鏁版眹鎬?+ %d 涓俯搴﹁鎯咃級\n', n+1, n);
end

