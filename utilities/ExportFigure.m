function ExportFigure(fig, basename)
%% ExportFigure - Export PNG and PDF with publication quality

    if nargin < 1 || isempty(fig)
        fig = gcf;
    end
    if nargin < 2 || isempty(basename)
        basename = 'Figure';
    end

    style = PaperStyle();
    set(fig, 'Renderer', 'painters');
    drawnow;

    png_name = [basename '.png'];
    pdf_name = [basename '.pdf'];
    eps_name = [basename '.eps'];

    if exist('exportgraphics', 'file') || exist('exportgraphics', 'builtin')
        exportgraphics(fig, png_name, 'Resolution', style.exportResolution);
        exportgraphics(fig, pdf_name, 'ContentType', 'vector');
        exportgraphics(fig, eps_name, 'ContentType', 'vector');
    else
        print(fig, png_name, '-dpng', sprintf('-r%d', style.exportResolution));
        print(fig, pdf_name, '-dpdf', '-painters');
        print(fig, eps_name, '-depsc2', '-painters');
    end
end

