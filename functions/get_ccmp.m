function out = get_ccmp(year, month, day, varargin)
% Get CCMP variables for a given date

% Arguments
 A.format = 'global';
 A.lon = [];
 A.lat = [];
 A.var = {'uwnd', 'vwnd'};
 A.getcoord = 0;
 A = parse_pv_pairs(A,varargin);
 daysInMonths = [31 28 31 30 31 30 31 31 30 31 30 31];
 % Leap years
 Leapyears=(1976:4:2020);
 if sum(year == Leapyears) == 1
     daysInMonths(2)=29;
 else
     daysInMonths(2)=28;
 end

     % Root path
     ccmpPath=''; % Change to your path to the reanalysis or add to matlab path
     % First and last year
     yrstart = 1988; yrend = 2018;
     % For now, use first and last years if outside of range
     if (year < yrstart)
        display('Selected year outside of range... using 1988')
        year = yrstart;
     elseif (year > yrend)
        display('Selected year outside of range... using 2017')
        year = yrend;
     end
     
     % Get the corresponfing ncfile path
     ncpath = [ccmpPath,'Y',num2str(year),'/M',num2str(month,'%.2d'),...
              '/CCMP_Wind_Analysis_',num2str(year),num2str(month,'%.2d'),...
              num2str(day,'%.2d'),'_V02.0_L3.0_RSS.nc'];
     ncpath2 = [ccmpPath,'Y',num2str(year),'/M',num2str(month,'%.2d'),...
              '/mCCMP_Wind_Analysis_',num2str(year),num2str(month,'%.2d'),...
              num2str(day,'%.2d'),'_V02.0_L3.0_RSS.nc'];
     % Get lon and lat if specified
     if A.getcoord
         try
            out.lon = single(ncread(ncpath,'longitude'));
            out.lat = single(ncread(ncpath,'latitude'));
        catch
            out.lon = single(ncread(ncpath,'lon'));
            out.lat = single(ncread(ncpath,'lat'));
        end
        if out.lat(1) > 0
            tmplat=out.lat
        else 
            tmplat=flipud(out.lat);
        end
            [out.LAT, out.LON] = meshgrid(tmplat, out.lon);
            out.LAT=single(out.LAT);out.LON=single(out.LON);
     end
     
     % get variables
     for f = 1 : length(A.var)
        try
            out.(A.var{f}) = single(flip(ncread(ncpath,A.var{f}),2));
        catch
             out.(A.var{f}) = single(flip(ncread(ncpath2,A.var{f}),2));
         end
     end

