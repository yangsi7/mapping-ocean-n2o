function out = get_sstoi(year, month, day, varargin)

% Arguments
 A.format = 'global';
 A.lon = [];
 A.lat = [];
 A.var = {'sst'};
 A.getcoord = 0;
 A = parse_pv_pairs(A,varargin);

% % Set paths
 % Root path
 sstoiPath='/data/project1/data/NOAA_SSTOI/www.ncei.noaa.gov/data/sea-surface-temperature-optimum-interpolation/access/avhrr-only/';
 % First and last year
 yrstart = 1982; yrend = 2018;
 % Months
 daysInMonths = [31 28 31 30 31 30 31 31 30 31 30 31];
 % Leap years
 Leapyears=(1976:4:2020);
 
 % For now, use first and last years if outside of range
 if (year < yrstart)
    display('Selected year outside of range... using 1982')
    year = yrstart;
 elseif (year > yrend)
    display('Selected year outside of range... using 2018')
    year = yrend;
 end
 
 % Get the corresponfing ncfile path
 ncpath = [sstoiPath,num2str(year),num2str(month,'%.2d'),'/','avhrr-only-v2.',num2str(year),num2str(month,'%.2d'),num2str(day,'%.2d'),'.nc'];
 
 % Get lon and lat if specified
 if A.getcoord
     try
        out.lon = single(ncread(ncpath,'longitude'));
        out.lat = single(ncread(ncpath,'latitude'));
    catch
        out.lon = single(ncread(ncpath,'lon'));
        out.lat = single(ncread(ncpath,'lat'));
    end
    [out.LAT, out.LON] = meshgrid(out.lat, out.lon);
    out.LAT=single(out.LAT);out.LON=single(out.LON);
 end
 
 % get variables
 for f = 1 : length(A.var)
     out.(A.var{f}) = single(ncread(ncpath,A.var{f}));
 end

