 function initout = initgetFlxCmpntsv2(dn2o,A)
 % Initialization script for getFlxCmpntsv2.m

 % Set paths
 addpath(genpath('/data/project1/yangsi/MATLAB/'));
 savepath='/data/project2/yangsi/analysis/n2oFluxPaper/processing/n2oflux/out/';
 figpath='/data/project2/yangsi/analysis/n2oFluxPaper/processing/n2oflux/figs/';
 processed='/data/project2/yangsi/analysis/n2oFluxPaper/processing/n2oflux/components/out/processed/';
 
 % Set up parpool
 if A.nworkers ~= 1
     p = gcp('nocreate'); % If no pool, do not create new one.
     if isempty(p)
         p = parpool(A.nworkers);
     else
     end
     parforArg = Inf;
 else
     parforArg = 0;
 end

 % load dn2o and salinity
 load('/data/project4/yangsi/Data/woa18/salinity/0p25/salinity_climatology_woa18.mat','s_woa_month_inpaint_surface');
 s_woa_month = s_woa_month_inpaint_surface; clear s_woa_month_inpaint_surface; % rename

 % load scaling factors for piston velocities
 load('/data/project2/yangsi/analysis/n2oFluxPaper/processing/n2oflux/Kw660/out/Kw_ccmp_pera5_0603.mat','Kw_avg')
 initout.cstar.ccmp = 0.251*16.5/nanmean(Kw_avg.kw.ccmp(:));
 initout.cstar.era5 = 0.251*16.5/nanmean(Kw_avg.kw.era5(:));
 if A.bubbles == 1
     initout.bscale.ccmp = real((16.5 - nanmean(Kw_avg.ks.ccmp(:)))/nanmean(Kw_avg.kbstar.ccmp(:)));
     initout.bscale.era5 = real((16.5 - nanmean(Kw_avg.ks.era5(:)))/nanmean(Kw_avg.kbstar.era5(:)));
 else
     initout.bscale.ccmp=[];
     initout.bscale.era5=[];
 end

 % Set variables to grab from each product
 initout.vvar.era5={'u10', 'v10', 'ci','sst','msl'}; % ERA5
 initout.vvar.ccmp={'uwnd', 'vwnd'}; %CCMP
 initout.vvar.sstoi={'sst','ice'}; % NOAA 1/4 deg optimum interpolation.

 % Get grid info for each product
 initout.wcoord = getWOAcoord(0.25); % WOA 1/4 deg
 initout.ccmpcoord = get_ccmp(2000,10,1,'getcoord',1); % CCMP
 initout.era5coord = get_era5(2000,10,1,'getcoord',1); % ERA5
 initout.sstoicoord = get_sstoi(2000,10,1,'getcoord',1); % NOAA OI
 initout.wcoord.LON = single(initout.wcoord.LON);
 initout.wcoord.LAT = single(initout.wcoord.LAT);


 % Get grid area for each product
 try
    tmpera5 = load('/data/project2/yangsi/Data/ERA5/gridfiles/era5_grid_area.mat');
    tmpsstoi =load('/data/project1/data/NOAA_SSTOI/gridfiles/area_sstoi.mat');
    area.era5 = tmpera5.area_era5; clear tmpera5;
    area.sstoi = tmpsstoi.area_sstoi; clear tmpsstoi;
 catch
    area.era5 = LonLatArea(initout.era5coord.LON(:,1), initout.era5coord.LAT(1,:)');
    area.sstoi = LonLatArea(double(initout.sstoicoord.LON(:,1)),double(initout.sstoicoord.LAT(1,:)'));
 end
 initout.area{1} = area.sstoi;
 initout.area{2} = area.era5;
 % Create mask for NOAA's OI
 tmp=get_sstoi(2000,10,1,'var',{'sst'});sstoicoord.mask=tmp.sst; clear tmp;
 sstoicoord.mask(~isnan(sstoicoord.mask))=1;
 initout.sstoicoord.mask=sstoicoord.mask;
 % Get mask for WOA
 initout.mask = getWOAmask(0.25,'xyt');

 % interpolate and inpaint nans for dn2o. (Load if file exists, calculate from source data otherwise)
display('Inpainting and interpolating to ERA5 and NOAAOI grids');
%load([processed,'dn2ointerp.mat']);
%load([processed,'saltinterp.mat']);
initout.dn2ointerp_ccmp=nan([size(initout.sstoicoord.LON),12]);
initout.saltinterp_ccmp=nan([size(initout.sstoicoord.LON),12]);
initout.dn2ointerp_era5=nan([size(initout.era5coord.LON),12]);
initout.saltinterp_era5=nan([size(initout.era5coord.LON),12]);
for l = 1 : 12
   display(['Processing month ',num2str(l),' out of 12'])
   tmp = single(inpaint_nans_bc(double(dn2o(:,:,l)),4));
   initout.dn2ointerp_ccmp(:,:,l) = single(interp2_cyclic(double(initout.wcoord.LON),double(initout.wcoord.LAT),double(tmp),double(initout.sstoicoord.LON),double(initout.sstoicoord.LAT)));
   initout.saltinterp_ccmp(:,:,l) = single(interp2_cyclic(double(initout.wcoord.LON),double(initout.wcoord.LAT),double(s_woa_month(:,:,l)),double(initout.sstoicoord.LON),double(initout.sstoicoord.LAT)));
   initout.dn2ointerp_era5(:,:,l) = single(interp2_cyclic(double(initout.wcoord.LON),double(initout.wcoord.LAT),double(tmp),double(initout.era5coord.LON),double(initout.era5coord.LAT)));
   initout.saltinterp_era5(:,:,l) = single(interp2_cyclic(double(initout.wcoord.LON),double(initout.wcoord.LAT),double(s_woa_month(:,:,l)),double(initout.era5coord.LON),double(initout.era5coord.LAT)));
end
%initout.dn2ointerp_ccmp=dn2ointerp_ccmp;initout.dn2ointerp_era5=dn2ointerp_era5;
%initout.saltinterp_ccmp=saltinterp_ccmp;initout.saltinterp_era5=saltinterp_era5;

% Set up names of fields for structures. Name convention is:  fn2o.(param).(wind product).(variable)
fnameOut.wind = {'ccmp', 'era5'};
if A.bubbles
    fnameOut.param = {'quad', 'bubbles'};
else
    fnameOut.param = {'quad'};
end
if A.clim ~= 1
    fnameOut.all= {'flux','AbarUbarNbar', 'AseasUbarNbar', 'AbarUseasNbar', 'AbarUbarNseas', ...
                  'AseasUseasNbar', 'AbarUseasNseas', 'AseasUbarNseas', 'AseasUseasNseas','B'};
else
    fnameOut.all= {'flux','A','U','B'};
end
initout.fnameOut=fnameOut;
% Get seasonality of DN2O if A.decompclim is provided
if ~isempty(A.decompclim)
    for fw = 1 : length(fnameOut.wind)
        for fp = 1 : length(fnameOut.param)
            if fw == 1
                    A.decompclim.(fnameOut.param{fp}).(fnameOut.wind{fw}).N = initout.dn2ointerp_ccmp - repmat(nanmean(initout.dn2ointerp_ccmp,3),1,1,12);
            else
                    A.decompclim.(fnameOut.param{fp}).(fnameOut.wind{fw}).N = initout.dn2ointerp_era5 - repmat(nanmean(initout.dn2ointerp_era5,3),1,1,12);
           end
        end
    end
end

% Set up fast interpolation. (load grids and calculate grid stuff in order to use the fast  mex slpinterp2)
 initout.era5ToSstoi = init_splinterp2_cyclic(initout.era5coord.LON,initout.era5coord.LAT,initout.sstoicoord.LON, initout.sstoicoord.LAT);
 initout.ccmpToSstoi = init_splinterp2_cyclic(initout.ccmpcoord.lon,flipud(initout.ccmpcoord.lat),initout.sstoicoord.lon,initout.sstoicoord.lat);

% Set up everything relate to time
 % Days in months
 initout.daysInMonths = [31 28 31 30 31 30 31 31 30 31 30 31];
 % Leap years
 initout.Leapyears=(1976:4:2020);
 % NUmber of years in selected period 
 nyrs = A.period(2)-A.period(1)+1;
 % Max extent of each wind product
 ccmp_y = [1988, 2016]; ccmp_nyrs = ccmp_y(2)-ccmp_y(1)+1; % span of CCMP
 era5_y = [1979, 2015]; era5_nyrs = era5_y(2)-era5_y(1)+1; % span of ERA5
 % Find which years intesect with selected period
 yridx_ccmp=zeros(1,nyrs); yridx_era5=yridx_ccmp;
 yridx{1} =  yridx_ccmp;  yridx{2} = yridx_era5;
 [~,idx] = intersect((A.period(1):A.period(2)),(ccmp_y(1):ccmp_y(2)));
 yridx_ccmp(idx) = 1;initout.yridx_ccmp=yridx_ccmp;
 [~,idx] = intersect((A.period(1):A.period(2)),(era5_y(1):era5_y(2)));
 yridx_era5(idx) = 1;initout.yridx_era5=yridx_era5;

 % Initialize timestep counter
 clear tsteps_ccmp; clear tsteps_era5; clear cmpclim;
 tsteps_ccmp{nyrs,12} = [];  tsteps_ccmp(:) = {nan};
 tsteps_era5{nyrs,12} = []; tsteps_era5(:) = {nan};
 initout.tsteps_ccmp=tsteps_ccmp;initout.tsteps_era5=tsteps_era5;
 tmpinit{1} = zeros([size(initout.sstoicoord.LON)]);% ccmp
 tmpinit{2} = zeros([size(initout.era5coord.LON)]); % era5
 initout.tmpinit=tmpinit;
 initout.nyrs = nyrs;
 initout.A=A;

 for fw = 1 : length(fnameOut.wind)
     for fp = 1 : length(fnameOut.param)
         for fc = 1 : length(fnameOut.all)
             initout.fn2o.(fnameOut.param{fp}).(fnameOut.wind{fw}).(fnameOut.all{fc}) = repmat(initout.tmpinit{fw},1,1,12);
         end
     end
 end

