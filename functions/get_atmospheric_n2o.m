function Xn2o_atm = get_atmospheric_n2o(day, month, year, varargin)

A.lat = 0;
A=parse_pv_pairs(A,varargin);
A.lat=double(A.lat);
if size(A.lat,2) == 1; A.lat = A.lat'; end;

noaafl = load('n2o_noaaflasks.mat');
noaafl.n2o_1d.lat(7)=double(noaafl.n2o_1d.lat(7)+0.0001); % two measurements at same station. Make it monotonic
noaafl.n2o_1d.yeardec = double(noaafl.n2o_1d.year + noaafl.n2o_1d.month/12.0);

% calculate atmospheric n2o based on a fit to atmopsheric n2o concentrations (Buitenhuis et al. 2018)
 daysInMonths = [31 28 31 30 31 30 31 31 30 31 30 31];
 Leapyears=(1900:4:2020);
 if sum(year == Leapyears) == 1
     daysInMonths(2)=29;
 else
     daysInMonths(2)=28;
 end
 daysInMonthscum = cumsum(daysInMonths);
 % Get cumulative days to date for the current year
 if month == 1; dmcum = 0;else dmcum=daysInMonthscum(month-1);end;
 % Get fractional year time for current day
 yr_decim = repmat(year + (dmcum+day-0.5)/sum(daysInMonths),1,length(A.lat));

 Xn2o_atm = interp2(noaafl.n2o_1d.lat,noaafl.n2o_1d.yeardec,noaafl.n2o_1d.val,A.lat,yr_decim);
 
 if sum(~isnan(Xn2o_atm(:))) < 1
        display('fail')
        Xn2o_atm = 0.000009471353.*yr_decim.^3 - 0.052147139.*yr_decim.^2 + 95.68066.*yr_decim-58228.41;
    else
        if sum(~isnan(Xn2o_atm(:))) == 1
            Xn2o_atm(:)=squeeze(nanmean(Xn2o_atm(:)));
        elseif sum(~isnan(Xn2o_atm(:)))>1
            %Xn2o_atm=fillmissing(Xn2o_atm,'nearest');
            Xn2o_atm=inpaint_nans(Xn2o_atm);
        else
            error('Couldn''t get atmospheric N2O')
        end
 end

end

