function [var_out LON LAT] = interp2_cyclic(longitude, latitude, var, lon_out, lat_out, varargin)

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Usage:
 % interp2_cyclic(latitude, longitude, var, lat_out, lon_out, method) 
 %
 % interpolates 2-D regular cyclic data onto new regular grid
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Arguments:
 % latitude: 1-D, or 2-D meshgrid latitudes
 % longitude: 1-D, or 2-D meshgrid longitude
 % var: variable to interpolate
 % lon_out: 1-D, or 2-D meshgrid ouput longitudes 
 % lat_out:  1-D, or 2-D meshgrid ouput latitude
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 5
     method = 'linear';
     vb = 0;
end

if nargin == 6 
      if islogical(varargin{1})
        vb = varargin{1};
        method = 'linear';
      else
        method = varargin{1};  
        vb = 0;
      end
end

if nargin == 7
      if islogical(varargin{1})
        vb = varargin{1};
        method = varargin{2};
     else
         vb = varargin{2};
         method = varargin{1};
     end
end


if min(lon_out(:))>= 0
        dispv('[0 360] output longitude format detected')
        if min(longitude(:)) >= 0
            dispv('[0 360] input longitude format detected: no change')
            if size(longitude,1) ==1 | size(longitude,2) == 1
                 [LAT LON] = meshgrid(latitude,longitude);
            else
                LAT=latitude;
                LON=longitude;
            end
        else
            if size(longitude,1) ==1 | size(longitude,2) == 1
                kshift=sum(longitude<=0);
                dispv('[-180 180] input longitude format detected')
                dispv('1-D Longitude detected....wrapping',vb)
                lon_wrapped = circshift(longitude,kshift); lon_wrapped(lon_wrapped<0)=lon_wrapped(lon_wrapped<0)+360;
                [LAT LON] = meshgrid(latitude,lon_wrapped);
            else
                kshift=sum(longitude(:,1)<=0);
                dispv('2-D Longitude detected....wrapping',vb)
                LON = circshift(longitude,kshift,1); LON(LON<0)=LON(LON<0)+360;
                LAT = latitude;
            end
            for j = 1 : size(var,2)
                var(:,j) =circshift(squeeze(var(:,j)),kshift) ;
            end
        end
else
        dispv('[-180 180] longitude format detected',vb)
        if min(longitude(:)) >= 0
            dispv('[0 360] input longitude format detected:')
            if size(lon_out,1) == 1 | size(lon_out,2) == 1
                kshift=sum(longitude>=180);
                dispv('1-D Longitude detected....wrapping',vb)
                lon_wrapped = circshift(longitude,kshift); lon_wrapped(lon_wrapped>=180)=lon_wrapped(lon_wrapped>=180)-360;
                [LAT LON] = meshgrid(latitude,lon_wrapped);
            else
                kshift=sum(longitude(:,1)>=180);  
                dispv('2-D Longitude detected....wrapping',vb)
                LON = circshift(longitude,kshift,1); LON(LON>=180)=LON(LON>=180)-360;
                LAT = latitude;
            end
            for j = 1 : size(var,2)
                 var(:,j) =circshift(squeeze(var(:,j)),kshift) ;
            end
        else
            dispv('[-180 180] input longitude format detected: no change')
            if size(longitude,1) ==1 | size(longitude,2) == 1
                [LAT LON] = meshgrid(latitude,longitude);
            else
                LAT=latitude;
                LON=longitude;
            end
        end
end

if size(lon_out,1) ==1 | size(lon_out,2) == 1
    [LAT_out LON_out] = meshgrid(lat_out,lon_out);
else
    LAT_out=lat_out;
    LON_out=lon_out;
end

varpadded = vertcat(var(end,:), var, var(1,:));
LONpadded = vertcat(LON(end,:)-360, LON, LON(1,:)+360);
LATpadded = vertcat(LAT(end,:), LAT, LAT(1,:));

var_out = interp2(LATpadded,LONpadded,varpadded,LAT_out,LON_out,method);

