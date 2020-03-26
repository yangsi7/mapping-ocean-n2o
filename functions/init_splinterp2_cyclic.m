function Ntarget = init_splinterp2_cyclic(longitude,latitude,lon_out, lat_out, varargin)


A.vb = 0;
 A = parse_pv_pairs(A,varargin);

 Ntarget.ccase=1;
 if min(lon_out(:))>= 0
         dispv('[0 360] output longitude format detected')
         if min(longitude(:)) >= 0
             dispv('[0 360] input longitude format detected: no change',A.vb)
             if size(longitude,1) ==1 | size(longitude,2) == 1
                  [LAT LON] = meshgrid(latitude,longitude);
             else
                 LAT=latitude;
                 LON=longitude;
             end
         else
             if size(longitude,1) ==1 | size(longitude,2) == 1
                 Ntarget.kshift=sum(longitude<=0);
                 dispv('[-180 180] input longitude format detected',A.vb)
                 dispv('1-D Longitude detected....wrapping',A.vb)
                 lon_wrapped = circshift(longitude,Ntarget.kshift); lon_wrapped(lon_wrapped<0)=lon_wrapped(lon_wrapped<0)+360;
                 [LAT LON] = meshgrid(latitude,lon_wrapped);
             else
                 Ntarget.kshift=sum(longitude(:,1)<=0);
                 dispv('2-D Longitude detected....wrapping',A.vb)
                 LON = circshift(longitude,Ntarget.kshift,1); LON(LON<0)=LON(LON<0)+360;
                 LAT = latitude;
             end
             Ntarget.ccase=2;
         end
 else
         dispv('[-180 180] longitude format detected',A.vb)
         if min(longitude(:)) >= 0
             dispv('[0 360] input longitude format detected:',A.vb)
             if size(lon_out,1) == 1 | size(lon_out,2) == 1
                 Ntarget.kshift=sum(longitude>=180);
                 dispv('1-D Longitude detected....wrapping',A.vb)
                 lon_wrapped = circshift(longitude,Ntarget.kshift); lon_wrapped(lon_wrapped>=180)=lon_wrapped(lon_wrapped>=180)-360;
                 [LAT LON] = meshgrid(latitude,lon_wrapped);
             else
                 Ntarget.kshift=sum(longitude(:,1)>=180);
                 dispv('2-D Longitude detected....wrapping',A.vb)
                 LON = circshift(longitude,Ntarget.kshift,1); LON(LON>=180)=LON(LON>=180)-360;
                 LAT = latitude;
             end
             Ntarget.ccase=3
         else
             dispv('[-180 180] input longitude format detected: no change',A.vb)
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

 LONpadded = vertcat(LON(end,:)-360, LON, LON(1,:)+360);
 LATpadded = vertcat(LAT(end,:), LAT, LAT(1,:));

 [LAT_Idx LON_Idx] = meshgrid((1:size(LONpadded,2)),(1:size(LONpadded,1)));
 minlon=min(LONpadded(:,1));
 maxlon=max(LONpadded(:,1));
 minlat=min(LATpadded(1,:));
 maxlat=max(LATpadded(1,:));                 
 Ntarget.LON_out = (LON_out-minlon)./(maxlon-minlon).*(size(LON_Idx,1)-1.0)+1.0;
 Ntarget.LAT_out = (LAT_out-minlat)./(maxlat-minlat).*(size(LAT_Idx,2)-1.0)+1.0;
