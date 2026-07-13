function pulse_data = ReadPulseData(filename, delimiter)
%READPULSEDATA Read two-column pulsed experiment data.
%
% Input:
%   filename  - text or CSV file path.
%   delimiter - delimiter, default is tab.
%
% Output:
%   pulse_data.t - time (min), reset to zero.
%   pulse_data.m - mass (%)
%
% Expected data format:
%   column 1: time (min)
%   column 2: mass (%)

    if nargin < 2
        delimiter = '\t';
    end

    raw = readmatrix(filename, 'Delimiter', delimiter, 'FileType', 'text');

    t_all = raw(:, 1);
    m_all = raw(:, 2);

    valid = ~any(isnan(raw(:, 1:2)), 2);
    t_all = t_all(valid);
    m_all = m_all(valid);

    pulse_data.t = t_all - t_all(1);
    pulse_data.m = m_all;

    fprintf('    Pulse data read complete: %d points\n', length(pulse_data.t));
    fprintf('    Time range: 0 to %.1f min\n', pulse_data.t(end));
    fprintf('    Mass range: %.4f to %.4f %%\n', min(pulse_data.m), max(pulse_data.m));
end

