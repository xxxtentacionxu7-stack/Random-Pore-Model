function PlotBatchComparison(results, save_fig)
%PLOTBATCHCOMPARISON Plot multi-temperature comparison figures.

    style = PaperStyle();
    n = length(results);
    colors = lines(n);

    T_list = arrayfun(@(r) r.T_exp, results);
    k_list = arrayfun(@(r) r.k, results);
    psi_list = arrayfun(@(r) r.psi, results);
    R2_list = arrayfun(@(r) r.R2, results);

    figure('Name', 'TGA Comparison', 'Color', style.figureColor, 'Position', style.figSizeMid);
    hold on;
    for i = 1:n
        plot(results(i).data.T, results(i).data.m, ...
            'Color', colors(i, :), 'LineWidth', style.lineWidth, ...
            'DisplayName', sprintf('%d C', results(i).T_exp));
    end
    xlabel('Temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('Mass (%)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend('Location', 'northeast', 'FontName', style.fontName, ...
        'FontSize', style.legendFontSize, 'Box', 'off');
    ApplyFigureFormat(gcf);
    if save_fig
        ExportFigure(gcf, 'FigA_TGA_compare');
    end

    figure('Name', 'DTG Comparison', 'Color', style.figureColor, 'Position', style.figSizeMid);
    hold on;
    for i = 1:n
        plot(results(i).data.T, results(i).data.dmdt, ...
            'Color', colors(i, :), 'LineWidth', style.lineWidth, ...
            'DisplayName', sprintf('%d C', results(i).T_exp));
    end
    xlabel('Temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('dm/dt (%/min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend('Location', 'best', 'FontName', style.fontName, ...
        'FontSize', style.legendFontSize, 'Box', 'off');
    ApplyFigureFormat(gcf);
    if save_fig
        ExportFigure(gcf, 'FigB_DTG_compare');
    end

    figure('Name', 'X vs t Comparison', 'Color', style.figureColor, 'Position', style.figSizeMid);
    hold on;
    for i = 1:n
        plot(results(i).rpm.t, results(i).rpm.X_data, 'o', ...
            'Color', colors(i, :), 'MarkerSize', 3, 'HandleVisibility', 'off');
        plot(results(i).rpm.t, results(i).rpm.X_fit, '-', ...
            'Color', colors(i, :), 'LineWidth', style.lineWidth, ...
            'DisplayName', sprintf('%d C  k = %.4f  psi = %.3f  R2 = %.4f', ...
                results(i).T_exp, results(i).k, results(i).psi, results(i).R2));
    end
    xlabel('Isothermal time (min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('Conversion X', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend('Location', 'northwest', 'FontName', style.fontName, ...
        'FontSize', style.legendFontSize, 'Box', 'off');
    ylim([0, 1.05]);
    ApplyFigureFormat(gcf);
    if save_fig
        ExportFigure(gcf, 'FigC_RPM_compare');
    end

    figure('Name', 'k and psi vs T', 'Color', style.figureColor, 'Position', style.figSizeMid);
    yyaxis left
    bar(T_list, k_list, 0.4, 'FaceColor', style.colors.blue, 'FaceAlpha', 0.75);
    ylabel('Rate constant k (min^{-1})', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    yyaxis right
    plot(T_list, psi_list, 'o-', 'Color', style.colors.red, ...
        'LineWidth', style.lineWidth, 'MarkerSize', style.markerSize, ...
        'MarkerFaceColor', style.colors.red);
    ylabel('Structure parameter psi', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    xlabel('Experiment temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    xticks(T_list);
    legend({'k', 'psi'}, 'Location', 'northwest', ...
        'FontName', style.fontName, 'FontSize', style.legendFontSize, 'Box', 'off');
    ApplyFigureFormat(gcf);
    if save_fig
        ExportFigure(gcf, 'FigD_params_vs_T');
    end

    fprintf('\n%-8s  %10s  %8s  %8s\n', 'T(C)', 'k(min^-1)', 'psi', 'R2');
    fprintf('%s\n', repmat('-', 1, 42));
    for i = 1:n
        fprintf('%-8d  %10.4f  %8.4f  %8.5f\n', ...
            T_list(i), k_list(i), psi_list(i), R2_list(i));
    end
end

