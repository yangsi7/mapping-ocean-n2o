function [var_out] = slinterp2_cyclic(var, spl)

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
 addpath('/data/project1/yangsi/MATLAB/functions/mex/splinterp/')

 if spl.ccase == 2 | spl.ccase == 3 
    for j = 1 : size(var,2)
        var(:,j) =circshift(squeeze(var(:,j)),spl.kshift) ;
    end
 end             

 var_out = interp2(vertcat(var(end,:), var, var(1,:)),spl.LAT_out,spl.LON_out);

