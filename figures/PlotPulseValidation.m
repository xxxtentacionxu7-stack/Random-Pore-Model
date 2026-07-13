function PlotPulseValidation(comp, save_fig)
%PLOTPULSEVALIDATION Plot measured-vs-predicted pulse validation figures.

    style = PaperStyle();

    figure('Name', 'Pulse Validation', 'Color', style.figureColor, 'Position', style.figSizeTall);
    subplot(4, 1, [1 2 3]);
    hold on;
    plot(comp.t_meas, comp.X_meas, '-', ...
        'Color', style.colors.blue, 'LineWidth', style.lineWidth, ...
        'DisplayName', 'Measured');
    plot(comp.t_pred, comp.X_pred, '--', ...
        'Color', style.colors.red, 'LineWidth', style.lineWidth, ...
        'DisplayName', sprintf('Predicted (RPM + SF = %.3f)', comp.SF_used));

    cycle_len = comp.t_on + comp.t_off;
    n_cycles = ceil(comp.t_pred(end) / cycle_len);
    for c = 0:n_cycles-1
        x_start = c * cycle_len;
        x_end = x_start + comp.t_on;
        if x_start < comp.t_pred(end)
            patch([x_start x_end x_end x_start], [0 0 1.05 1.05], ...
                style.colors.lightBlue, 'EdgeColor', 'none', ...
                'FaceAlpha', 0.25, 'HandleVisibility', 'off');
        end
    end

    ylabel('Conversion X', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend('Location', 'southeast', 'FontName', style.fontName, ...
        'FontSize', style.legendFontSize, 'Box', 'off');
    ylim([0, 1.05]);

    subplot(4, 1, 4);
    stairs(comp.t_pred, comp.valve, '-', ...
        'Color', style.colors.red, 'LineWidth', style.thinLineWidth);
    ylim([-0.2, 1.2]);
    yticks([0 1]);
    yticklabels({'Off', 'On'});
    xlabel('Time (min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('H2O valve', 'FontName', style.fontName, 'FontSize', 10);

    ApplyFigureFormat(gcf);
    if save_fig
        ExportFigure(gcf, 'Fig_PulseValidation');
    end

    figure('Name', 'Pulse Residual', 'Color', style.figureColor, 'Position', style.figSizeCompact);
    X_pred_interp = interp1(comp.t_pred, comp.X_pred, comp.t_meas, 'linear', 'extrap');
    resid = comp.X_meas - X_pred_interp;
    plot(comp.t_meas, resid, '-', ...
        'Color', style.colors.black, 'LineWidth', style.thinLineWidth);
    hold on;
    yline(0, '--', 'Color', style.colors.red, 'LineWidth', 1);
    xlabel('Time (min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('Residual (measured - predicted)', ...
        'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ApplyFigureFormat(gcf);

    if save_fig
        ExportFigure(gcf, 'Fig_PulseResidual');
    end

    fprintf('    Plotting complete: validation and residual figures.\n');
end

