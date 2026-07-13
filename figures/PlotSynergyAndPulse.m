function PlotSynergyAndPulse(syn_all, pulse, save_fig)
%PLOTSYNERGYANDPULSE Plot synergy factor and pulse prediction figures.

    style = PaperStyle();
    n = length(syn_all);
    colors = lines(max(n, 3));

    figure('Name', 'Synergy Factor', 'Color', style.figureColor, 'Position', style.figSizeMid);
    hold on;
    for i = 1:n
        s = syn_all{i};
        plot(s.X, s.SF, '-', 'Color', colors(i, :), ...
            'LineWidth', style.lineWidth, ...
            'DisplayName', sprintf('%s  (SF_{avg} = %.2f)', s.label, s.SF_mean));
    end
    yline(1, '--', 'Color', style.colors.gray, ...
        'LineWidth', style.thinLineWidth, 'DisplayName', 'Baseline SF = 1');
    xlabel('Conversion X', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('Synergy factor SF = rate_{mix}/rate_{linear}', ...
        'FontName', style.fontName, 'FontSize', style.labelFontSize - 1);
    legend('Location', 'best', 'FontName', style.fontName, ...
        'FontSize', style.legendFontSize, 'Box', 'off');
    ylim_auto = ylim;
    ylim([max(0, ylim_auto(1)), ylim_auto(2)]);
    ApplyFigureFormat(gcf);
    if save_fig
        ExportFigure(gcf, 'Fig_SynergyFactor');
    end

    figure('Name', 'Rate Comparison', 'Color', style.figureColor, 'Position', style.figSizeMid);
    hold on;
    for i = 1:n
        s = syn_all{i};
        plot(s.X, s.rate_mix, '-', 'Color', colors(i, :), ...
            'LineWidth', style.lineWidth, ...
            'DisplayName', sprintf('%s measured', s.label));
        plot(s.X, s.rate_linear, '--', 'Color', colors(i, :), ...
            'LineWidth', style.thinLineWidth, ...
            'DisplayName', sprintf('%s linear prediction', s.label));
    end
    xlabel('Conversion X', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    ylabel('dX/dt (min^{-1})', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
    legend('Location', 'best', 'FontName', style.fontName, ...
        'FontSize', style.legendFontSize, 'Box', 'off');
    ApplyFigureFormat(gcf);
    if save_fig
        ExportFigure(gcf, 'Fig_RateComparison');
    end

    if ~isempty(pulse)
        figure('Name', 'Pulse Prediction', 'Color', style.figureColor, 'Position', style.figSizeTall);

        subplot(3, 1, [1 2]);
        hold on;
        plot(pulse.t, pulse.X, '-', 'Color', style.colors.blue, 'LineWidth', style.lineWidth);
        ylabel('Predicted conversion X', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
        ylim([0, 1.05]);
        xlim([0, pulse.t(end)]);

        cycle_len = pulse.t_on + pulse.t_off;
        n_cycles = ceil(pulse.t(end) / cycle_len);
        for c = 0:n_cycles-1
            x_start = c * cycle_len;
            x_end = x_start + pulse.t_on;
            if x_start < pulse.t(end)
                patch([x_start x_end x_end x_start], [0 0 1.05 1.05], ...
                    style.colors.lightBlue, 'EdgeColor', 'none', ...
                    'FaceAlpha', 0.3, 'HandleVisibility', 'off');
            end
        end
        legend({'Predicted X'}, 'Location', 'southeast', ...
            'FontName', style.fontName, 'FontSize', style.legendFontSize, 'Box', 'off');

        subplot(3, 1, 3);
        stairs(pulse.t, pulse.valve, '-', ...
            'Color', style.colors.red, 'LineWidth', style.thinLineWidth);
        ylim([-0.2, 1.2]);
        yticks([0 1]);
        yticklabels({'Off', 'On'});
        xlabel('Time (min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
        ylabel('H2O valve', 'FontName', style.fontName, 'FontSize', 11);
        xlim([0, pulse.t(end)]);

        ApplyFigureFormat(gcf);
        if save_fig
            ExportFigure(gcf, 'Fig_PulsePrediction');
        end

        figure('Name', 'Pulse vs Continuous', 'Color', style.figureColor, 'Position', style.figSizeMid);
        plot(pulse.t, pulse.X, '-', ...
            'Color', style.colors.blue, 'LineWidth', style.lineWidth, ...
            'DisplayName', 'Pulse H2O prediction');
        xlabel('Time (min)', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
        ylabel('Conversion X', 'FontName', style.fontName, 'FontSize', style.labelFontSize);
        legend('Location', 'best', 'FontName', style.fontName, ...
            'FontSize', style.legendFontSize, 'Box', 'off');
        ylim([0, 1.05]);
        ApplyFigureFormat(gcf);
        if save_fig
            ExportFigure(gcf, 'Fig_PulseFinal');
        end
    end
end

