function PlotCoreResults(data, iso, rpm, params)
%PLOTCORESULTS Plot TGA, DTG, RPM fit, and psi scan figures.

    style = PaperStyle();

    figure('Name', 'TGA Curve', 'Color', style.figureColor, 'Position', style.figSizeMid);
    yyaxis left
    plot(data.t, data.m, '-', 'Color', style.colors.blue, 'LineWidth', style.lineWidth);
    ylabel('Mass (%)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylim([0, 105]);

    yyaxis right
    plot(data.t, data.T, '-', 'Color', style.colors.red, 'LineWidth', style.thinLineWidth);
    ylabel('Temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);

    xlabel('Time (min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend({'Mass (%)', 'Temperature (C)'}, 'Location', 'northeast', ...
        'FontName', style.fontName, 'FontSize', style.legendFontSize, 'Box', 'off');
    xline(iso.t(1) + data.t(1), '--', 'Isothermal start', ...
        'Color', style.colors.gray, 'LineWidth', style.thinLineWidth, ...
        'LabelVerticalAlignment', 'bottom', 'FontName', style.fontName, 'FontSize', 10);
    ApplyFigureFormat(gcf);
    if params.save_figures
        ExportFigure(gcf, 'Fig1_TGA');
    end

    figure('Name', 'DTG Curve', 'Color', style.figureColor, 'Position', style.figSizeMid);
    plot(data.T, data.dmdt, '-', 'Color', style.colors.blue, 'LineWidth', style.lineWidth);
    xlabel('Temperature (C)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('dm/dt (%/min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    hold on;
    [min_val, min_idx] = min(data.dmdt);
    plot(data.T(min_idx), min_val, 'v', ...
        'MarkerSize', style.markerSize, ...
        'MarkerFaceColor', style.colors.red, ...
        'MarkerEdgeColor', style.colors.red);
    text(data.T(min_idx) + 5, min_val, ...
        sprintf('T_peak = %.0f C\n%.3f %%/min', data.T(min_idx), min_val), ...
        'FontName', style.fontName, 'FontSize', 10, 'Color', style.colors.red);
    ApplyFigureFormat(gcf);
    if params.save_figures
        ExportFigure(gcf, 'Fig2_DTG');
    end

    figure('Name', 'RPM Fit', 'Color', style.figureColor, 'Position', style.figSizeMid);
    plot(rpm.t, rpm.X_data, 'o', ...
        'MarkerSize', 4, ...
        'Color', style.colors.black, ...
        'MarkerFaceColor', style.colors.black, ...
        'DisplayName', 'Experiment');
    hold on;
    plot(rpm.t, rpm.X_fit, '-', ...
        'Color', style.colors.red, ...
        'LineWidth', style.lineWidth, ...
        'DisplayName', sprintf('RPM fit  k = %.4f, psi = %.4f', rpm.k, rpm.psi));
    xlabel('Isothermal time (min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('Conversion X', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend('Location', 'northwest', 'FontName', style.fontName, ...
        'FontSize', style.legendFontSize, 'Box', 'off');
    ylim([0, 1.05]);
    annotation_str = sprintf(' k = %.4f min^{-1}\n psi = %.4f\n R2 = %.5f', ...
        rpm.k, rpm.psi, rpm.R2);
    annotation('textbox', [0.62 0.18 0.25 0.18], 'String', annotation_str, ...
        'FitBoxToText', 'on', 'BackgroundColor', [1 1 0.85], ...
        'EdgeColor', 'k', 'FontName', style.fontName, 'FontSize', 11);
    ApplyFigureFormat(gcf);
    if params.save_figures
        ExportFigure(gcf, 'Fig3_RPM_fit');
    end

    figure('Name', 'Psi Scan', 'Color', style.figureColor, 'Position', style.figSizeCompact);
    plot(rpm.psi_range, rpm.R2_scan, '-', ...
        'Color', style.colors.blue, 'LineWidth', style.lineWidth);
    hold on;
    plot(rpm.psi, rpm.R2, 'v', ...
        'MarkerSize', style.markerSize, ...
        'MarkerFaceColor', style.colors.red, ...
        'MarkerEdgeColor', style.colors.red, ...
        'DisplayName', sprintf('Best psi = %.3f', rpm.psi));
    xlabel('Structure parameter psi', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('R2', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend('R2(psi)', sprintf('Best psi = %.3f', rpm.psi), ...
        'Location', 'best', 'FontName', style.fontName, ...
        'FontSize', style.legendFontSize, 'Box', 'off');
    ApplyFigureFormat(gcf);
    if params.save_figures
        ExportFigure(gcf, 'Fig4_psi_scan');
    end

    fprintf('    Plotting complete: 4 figures generated.\n');
end

