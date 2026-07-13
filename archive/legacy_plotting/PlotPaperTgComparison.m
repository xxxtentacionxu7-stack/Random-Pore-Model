function PlotPaperTgComparison(data850, data900, data950)
%% PlotPaperTgComparison - Publication-quality TG comparison figure

    style = PaperStyle();
    figure('Color', style.figureColor, 'Position', style.figSizeWide);
    hold on;

    plot(data850.t, data850.m, 'Color', style.colors.blue, ...
        'LineWidth', style.lineWidth);
    plot(data900.t, data900.m, 'Color', style.colors.red, ...
        'LineWidth', style.lineWidth);
    plot(data950.t, data950.m, 'Color', style.colors.green, ...
        'LineWidth', style.lineWidth);

    xlabel('Time (min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('Mass (%)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend({'850 掳C', '900 掳C', '950 掳C'}, 'Location', 'northeast', ...
        'Box', 'off', 'FontName', style.fontName, 'FontSize', style.legendFontSize);

    ApplyFigureFormat(gcf);
    set(gca, 'FontName', style.fontName, 'FontSize', style.axesFontSize, ...
        'LineWidth', 1.3, 'Box', 'on', 'TickDir', 'in');

    ExportFigure(gcf, 'Fig3_1_TG');
end

