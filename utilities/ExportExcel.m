function ExportExcel(results)
%EXPORTEXCEL Export batch fitting results to an Excel workbook.

    filename_out = 'TGA_results_summary.xlsx';

    n = length(results);
    T_list = arrayfun(@(r) r.T_exp, results)';
    k_list = arrayfun(@(r) r.k, results)';
    psi_list = arrayfun(@(r) r.psi, results)';
    R2_list = arrayfun(@(r) r.R2, results)';
    ash_list = arrayfun(@(r) r.mass_ash, results)';

    header1 = {'Temperature_C', 'Ash_mass_percent', 'k_min_1', 'psi', 'R2'};
    data1 = [T_list, ash_list, k_list, psi_list, R2_list];

    writecell(header1, filename_out, 'Sheet', 'RPM_parameters', 'Range', 'A1');
    writematrix(data1, filename_out, 'Sheet', 'RPM_parameters', 'Range', 'A2');

    R_gas = 8.314e-3;
    T_K = T_list + 273.15;
    ln_k = log(k_list);
    p = polyfit(1 ./ T_K, ln_k, 1);
    Ea = -p(1) * R_gas;
    A_pre = exp(p(2));

    ln_k_fit = polyval(p, 1 ./ T_K);
    R2_arr = 1 - sum((ln_k - ln_k_fit).^2) / sum((ln_k - mean(ln_k)).^2);

    arr_header = {'', 'Ea_kJ_mol', 'A_min_1', 'Arrhenius_R2'};
    arr_data = {'Arrhenius', Ea, A_pre, R2_arr};
    row_offset = n + 4;
    writecell(arr_header, filename_out, 'Sheet', 'RPM_parameters', ...
        'Range', sprintf('A%d', row_offset));
    writecell(arr_data, filename_out, 'Sheet', 'RPM_parameters', ...
        'Range', sprintf('A%d', row_offset + 1));

    for i = 1:n
        sheet_name = sprintf('%dC_data', results(i).T_exp);
        header_i = {'Time_min', 'Conversion_X', 'RPM_fit_X', 'dXdt_min_1'};
        data_i = [results(i).rpm.t, ...
                  results(i).rpm.X_data, ...
                  results(i).rpm.X_fit, ...
                  results(i).iso.dXdt];

        writecell(header_i, filename_out, 'Sheet', sheet_name, 'Range', 'A1');
        writematrix(data_i, filename_out, 'Sheet', sheet_name, 'Range', 'A2');
    end

    fprintf('    Excel file exported: %s\n', filename_out);
    fprintf('    Workbook contains %d sheets.\n', n + 1);
end

