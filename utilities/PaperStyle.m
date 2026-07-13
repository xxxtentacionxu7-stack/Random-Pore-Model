function style = PaperStyle()
%PAPERSTYLE Return shared publication-style plotting settings.

    style.fontName = 'Times New Roman';
    style.labelFontSize = 12;
    style.titleFontSize = 14;
    style.legendFontSize = 10;
    style.axesFontSize = 12;
    style.lineWidth = 2.0;
    style.thinLineWidth = 1.4;
    style.markerSize = 6;
    style.figureColor = 'w';
    style.gridAlpha = 0.16;
    style.minorGridAlpha = 0.08;
    style.exportResolution = 600;

    style.figSizeWide = [80 80 780 460];
    style.figSizeMid = [80 80 720 420];
    style.figSizeTall = [80 80 760 560];
    style.figSizeCompact = [80 80 700 360];

    style.colors = struct( ...
        'blue', [0.12 0.47 0.71], ...
        'red', [0.84 0.15 0.16], ...
        'green', [0.17 0.63 0.17], ...
        'orange', [0.95 0.50 0.12], ...
        'purple', [0.58 0.40 0.74], ...
        'black', [0.10 0.10 0.10], ...
        'gray', [0.45 0.45 0.45], ...
        'lightBlue', [0.70 0.85 1.00]);
end

