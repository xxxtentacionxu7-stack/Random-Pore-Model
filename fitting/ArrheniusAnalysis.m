function arr = ArrheniusAnalysis(results, save_fig)
%% ArrheniusAnalysis - Arrhenius analysis

    style = PaperStyle();
    R_gas = 8.314e-3;

    n = length(results);
    T_K = zeros(n, 1);
    k_arr = zeros(n, 1);

    for i = 1:n
        T_K(i) = results(i).T_exp + 273.15;
        k_arr(i) = results(i).k;
    end

    inv_T = 1 ./ T_K;
    ln_k = log(k_arr);

    p = polyfit(inv_T, ln_k, 1);
    Ea = -p(1) * R_gas;
    A = exp(p(2));

    ln_k_fit = polyval(p, inv_T);
    SS_res = sum((ln_k - ln_k_fit).^2);
    SS_tot = sum((ln_k - mean(ln_k)).^2);
    R2 = 1 - SS_res / SS_tot;

    arr.Ea = Ea;
    arr.A = A;
    arr.R2 = R2;

    fprintf('    Ea = %.2f kJ/mol\n', Ea);
    fprintf('    A = %.4e min^-1\n', A);
    fprintf('    Arrhenius R2 = %.5f\n', R2);

    figure('Name', 'Arrhenius', 'Color', style.figureColor, 'Position', style.figSizeMid);
    hold on;

    plot(inv_T * 1000, ln_k, 'o', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', style.colors.blue, ...
        'MarkerEdgeColor', style.colors.black, ...
        'Color', style.colors.black, ...
        'DisplayName', 'Data');

    x_line = linspace(min(inv_T), max(inv_T), 100);
    y_line = polyval(p, x_line);
    plot(x_line * 1000, y_line, '-', ...
        'Color', style.colors.red, ...
        'LineWidth', style.lineWidth, ...
        'DisplayName', 'Arrhenius fit');

    for i = 1:n
        text(inv_T(i) * 1000 + 0.002, ln_k(i), sprintf('  %d C', results(i).T_exp), ...
            'FontName', style.fontName, 'FontSize', 10);
    end

    xlabel('1000/T  (K^{-1})', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('ln(k)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend('Location', 'best', 'FontName', style.fontName, 'FontSize', style.legendFontSize, 'Box', 'off');

    ann_str = sprintf(' Ea = %.2f kJ/mol\n A = %.3e min^{-1}\n R2 = %.5f', Ea, A, R2);
    annotation('textbox', [0.55 0.2 0.3 0.2], 'String', ann_str, ...
        'FitBoxToText', 'on', 'BackgroundColor', [1 1 0.85], ...
        'EdgeColor', 'k', 'FontName', style.fontName, 'FontSize', 11);

    ApplyFigureFormat(gcf);

    if save_fig
        ExportFigure(gcf, 'Fig_Arrhenius');
    end
end

