function Xdaily = interpdailyfromclim(X,date)

 % Fast linear interpolation of a climatology to a given date (without using interp1/2/3). 
 dd=date(1);mm=date(2);yy=date(3); 
 daysInMonths = [31 28 31 30 31 30 31 31 30 31 30 31];
 Leapyears=(1900:4:2020);
 if sum(yy == Leapyears) == 1
     daysInMonths(2)=29;
 else
     daysInMonths(2)=28;
 end
 daysInMonthscum = cumsum(daysInMonths);
 % interpolate dn2o and salinity to current day
 % Set padded time axis
 inmonth = (-0.5:1.0:12.5)/12;
 inmonthidx = [12,(1:12),1];
 % Get cumulative days to date for the current year
 if mm == 1; dmcum = 0; else; dmcum=daysInMonthscum(mm-1); end

 % Get fractional year time for current day
 indday = (dmcum+dd-0.5)/sum(daysInMonths);
 % Find bounding months
 [~, ordidx]= sort(abs(inmonth-indday));
 indm1idx = find(min(inmonth(ordidx(1:2)))==inmonth);indm1 = inmonthidx(indm1idx);indm1t = inmonth(indm1idx);
 indm2idx = find(max(inmonth(ordidx(1:2)))==inmonth);indm2 = inmonthidx(indm2idx);indm2t = inmonth(indm2idx);
 Xdaily = (X(:,:,indm1).*(indm2t-indday) + X(:,:,indm2).*(indday-indm1t))./(indm2t-indm1t);
