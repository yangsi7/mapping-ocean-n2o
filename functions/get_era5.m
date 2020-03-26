function out = get_era5(year, month, day, varargin)

% Arguments
 A.format = 'global';
 A.lon = [];
 A.lat = [];
 A.var = {'u10', 'v10'};
 A.getcoord = 0;
 A = parse_pv_pairs(A,varargin);

% % Set paths
 % Root path
 era5Path=''; % Change to your path to the reanalysis or add to matlab path
 % First and last year
 yrstart = 1979; yrend = 2017;
 % Months
 daysInMonths = [31 28 31 30 31 30 31 31 30 31 30 31];
 % Leap years
 Leapyears=(1976:4:2020);
 clim=0;
 % For now, use first and last years if outside of range
 if (year < yrstart)
    display('Selected year outside of range... using clim')
    clim = 1;
 elseif (year > yrend)
    display('Selected year outside of range... using clim')
    clim = 1;
 end
 
 if year == 1979
     daysInMonths(1)=30;
 end
 if sum(year == Leapyears) == 1
     daysInMonths(2)=29;
 else
     daysInMonths(2)=28;
 end
 
 % Get cumulative days in year
 dInMcumsum = cumsum(daysInMonths);

 % Get the corresponfing ncfile path
 if clim
    ncpath = 'ERA5clim.nc';
 else
    ncpath = [era5Path,'ERA5_',num2str(year),'.nc'];
 end
 
 % Get time indeces for the day
 if month == 1
     tt1 =  (day-1)*4 + 1;
 else
     tt1 =  dInMcumsum(month-1)*4 + (day-1)*4 + 1;
 end

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
    out.LAT=single(out.LAT);
    out.LON = single(out.LON);
 end
 
 % get variables
 for f = 1 : length(A.var)
     if clim
         out.(A.var{f}) = single(repmat(ncread(ncpath,A.var{f},[1 1 month], [inf, inf, 1]),1,1,4));
     else
        out.(A.var{f}) = single(ncread(ncpath,A.var{f},[1 1 tt1], [inf, inf, 4]));
     end
 end

