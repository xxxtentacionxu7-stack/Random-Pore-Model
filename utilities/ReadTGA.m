function data = ReadTGA(filename)
%READTGA Read a three-column TGA text file.
%
% Input:
%   filename - text file path.
%
% Output:
%   data.T - temperature (C)
%   data.t - time (min)
%   data.m - mass (%)
%
% Expected data format:
%   column 1: temperature (C)
%   column 2: time (min)
%   column 3: mass (%)

    raw = readmatrix(filename, 'Delimiter', '\t', 'FileType', 'text');

    data.T = raw(:, 1);
    data.t = raw(:, 2);
    data.m = raw(:, 3);

    valid = ~any(isnan(raw), 2);
    data.T = data.T(valid);
    data.t = data.t(valid);
    data.m = data.m(valid);

    fprintf('    Read complete: %d rows\n', length(data.T));
    fprintf('    Temperature range: %.1f to %.1f C\n', min(data.T), max(data.T));
    fprintf('    Time range: %.1f to %.1f min\n', min(data.t), max(data.t));
    fprintf('    Mass range: %.4f to %.4f %%\n', min(data.m), max(data.m));
end

