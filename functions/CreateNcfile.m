function CreateNcfile(outfile, var, xyzdim, tdim, varargin)

% % % % % % % % % % % % % % % % % % % % % %
% % % % % %  CreateNcfile v1.0 % % % % %  % 
% % % % % % % % % % % % % % % % % % % % % %

%% Example -- create an nc file with an empty variable t_an that has woa18 dimensions: 
%%     outfile='/data/project4/yangsi/Data/woa18/temperature/0p25/temp_clim_woa18.nc'
%%     vars = {'t_an'};
%%     snames = {'temp'};
%%     lnames = {'temperature'};
%%     units = {'C'};
%%     xyzdim = 'woa18';
%%     tdim = 'clim';
%%     CreateNcfile(outfile, vars, snames, lnames, units, xyzdim, tdim);

%%% Required Arguments
% outfile -- string, path of netcdf file to be created (e.g. '/data/project4/yangsi/')
% vars -- cell array, variables to add (e.g. {'t_an', 's_an'})
% snames -- cell array, default names (e.g. {'temp', 'salt'})
% lnames -- cell array, long names (e.g. {'temperature', 'salinity'})
% units -- cell array, units (e.g. {'Degree C', 'PSU'}) 
% xyzdim -- string, spatial dimension type. Valid values are: 'woa18', 'woa13' or custom 
% tdims -- strings, time dimension type. Valid values are: 'clim', 'yrday', 'custom'

%%% Optional Arguments
% lon -- array, longitudes for x-axis
% lat -- array, latitude for y-axis
% depth -- array, Depths for z-axis
% Hz -- array, thickness of z layers
% time -- array, time for t-axis
% year -- integer, processing year if tdims is 'yrday' 
% tstart -- integer, starting day if tdims is 'yrday'
% tstep -- integer, days between steps if tdims is 'yrday'
% startday -- string, reference time (e.g. 'days since 1979-01-01 00:00:00')
% format -- string, netcdf format (see help on nccreate for options)
% comp -- integer, netcdf compression level (min compression:1, max compression is 9)
% shuffle -- logical, turns on shufling of netcdf bytes 

% % % % % % % % % % % % % % % % % % % % % %

%%% Simon Yang @ UCLA, March 27th 2019

% If file already exists, remove it.
if exist(outfile, 'file') == 2
    display('File already exists... Deleting')
    [status,cmdout] = system(['rm ',outfile]);
end

% Unpack var structure
if isfield(var,'varnames') varnames=var.varnames;, else error('var structure does not contain varnames'), end
if isfield(var,'dims') dims=var.dims;, else error('var structure does not contain dims'), end
if isfield(var,'snames') snames = var.snames;, else snames = cell(size(varnames));, end
if isfield(var,'lnames') lnames = var.lnames;, else lnames = cell(size(varnames));, end
if isfield(var,'units') units = var.units;, else units = cell(size(varnames));, end

% if xyz template is woa18 (1/4 degree)
if strcmp(xyzdim,'woa18')
        defaultLon = (-179.8750:0.25:179.8750);
        defaultLat = (-89.8750:0.25:89.8750);
        % WOA Depth and thickness
        defaultDepth = [(0:5:100),(125:25:500), (550:50:2000), (2100:100:5500)];
        defaultHz=nan(size(defaultDepth));
        defaultHz(1)=2.5; defaultHz(2:20)=5; defaultHz(21)=15; defaultHz(22:36)=50;
        defaultHz(37) = 37.5; defaultHz(38:66)=50;defaultHz(67)=75;
        defaultHz(68:end-1)=100;defaultHz(end)=50;
        if strcmp(tdim,'custom')
                display('custom... Don''t forget to specify the time dimension');
        elseif strcmp(tdim,'yrdaily')
                display('yrdaily... Don''t forget to specify the year and step');
        elseif ~strcmp(tdim,'clim') 
                error(['Invalid tdim value:',tdim,'. Refer to the description.']);
        end
% if xyz template is woa13 (1 degree)        
elseif strcmp(xyzdim,'woa13')
        defaultLon = (-179.5:1.0:179.5);
        defaultLat = (-89.5:1.0:89.5);
        % WOA Depth and thickness
        defaultDepth = [(0:5:100),(125:25:500), (550:50:2000), (2100:100:5500)];
        defaultHz=nan(size(defaultDepth));
        defaultHz(1)=2.5; defaultHz(2:20)=5; defaultHz(21)=15; defaultHz(22:36)=50;
        defaultHz(37) = 37.5; defaultHz(38:66)=50;defaultHz(67)=75;
        defaultHz(68:end-1)=100;defaultHz(end)=50;
        if strcmp(tdim,'custom')
                display('custom... Don''t forget to specify the time dimension');
        elseif strcmp(tdim,'yrdaily')
                display('yrdaily... Don''t forget to specify the year and tstep');
                defaultTime = [];
        elseif ~strcmp(tdim,'clim')
                error(['Invalid tdim value:',tdim,'. Refer to the description.']);
        end
% custom dimensions defaults set to []
elseif strcmp(xyzdim,'custom') || strcmp(xyzdim,'roms')
        display('Custom netcdf... Don''t forget to specify dimensions');
        defaultLon = [];
        defaultLat = [];
        defaultDepth = [];
        defaultHz = [];
        defaultTime = [];        
end

% defaults for yrdaily tdim option
defaultYear=1979; % year
defaultTstart=1; %
defaultTstep=1;
% defaults for clim tdim option
if strcmp(tdim,'clim')
        defaultStartday = 'months since 1955-01-01 00:00:00';
        defaultTime = (1:12);
else
        defaultStartday='days since 1979-01-01 00:00:00';
end

% default netcdf format and compression
defaultFormat = 'netcdf4';
defaultComp = 3;
defaultShuffle = true;
defaultextra_uldim = false;
% Parsing arguments
p = inputParser;
addRequired(p,'outfile');
addRequired(p,'varnames');
addRequired(p,'snames');
addRequired(p,'lnames');
addRequired(p,'units');
addRequired(p,'xyzdim');
addRequired(p,'tdim');
addOptional(p,'lon', defaultLon);
addOptional(p,'lat', defaultLat);
addOptional(p,'depth', defaultDepth);
addOptional(p,'Hz', defaultHz);
addOptional(p,'time', defaultTime);
addOptional(p,'year', defaultYear);
addOptional(p,'tstart', defaultTstart);
addOptional(p,'tstep', defaultTstep);
addOptional(p,'startday', defaultTstep);
addOptional(p,'format', defaultFormat);
addOptional(p,'comp', defaultComp);
addOptional(p,'shuffle', defaultShuffle);
addOptional(p,'extra_uldim',defaultextra_uldim);
parse(p,outfile,varnames,snames,lnames,units,xyzdim,tdim,varargin{:});

% If tdim option set to yrdaily, retrieve year length in days.
if strcmp(tdim,'yrdaily')
        lyrs = (1972:4:2020);
        if sum(lyrs==p.Results.year)==1
                lenyr = 366;
                p.Results.time = (p.Results.Tstart:defaultTstep:lenyr);
        else
                lenyr = 365;
                p.Results.time = (p.Results.Tstart:defaultTstep:lenyr);
        end
end
        
% Retrieve length of all dimension
if strcmp(xyzdim,'roms')
    llat=size(p.Results.lon,2);
    llon=size(p.Results.lon,1);
else
    llat=length(p.Results.lat);
    llon= length(p.Results.lon);
end
ldepth=length(p.Results.depth);
ltime=length(p.Results.time);

if strcmp(xyzdim,'roms')
    % Create latitude dimension
    nccreate(p.Results.outfile,'lat','Dimensions',{'lon' llon 'lat' llat}...
    ,'Format',p.Results.format,'DeflateLevel', p.Results.comp,'Shuffle',p.Results.shuffle);
    ncwriteatt(p.Results.outfile, 'lat', 'standard_name', 'latitude');
    ncwriteatt(p.Results.outfile, 'lat', 'long_name', 'latitude');
    ncwriteatt(p.Results.outfile, 'lat', 'units', 'native Y grid point');
    ncwriteatt(p.Results.outfile, 'lat', '_CoordinateAxisType', 'Lat');
    % Create longitude dimension
    nccreate(p.Results.outfile,'lon','Dimensions',{'lon' llon 'lat' llat}...
    ,'Format',p.Results.format,'DeflateLevel', p.Results.comp,'Shuffle',p.Results.shuffle);
    ncwriteatt(p.Results.outfile, 'lon', 'standard_name', 'longitude');
    ncwriteatt(p.Results.outfile, 'lon', 'long_name', 'longitude');
    ncwriteatt(p.Results.outfile, 'lon', 'units', 'native X grid point');
    ncwriteatt(p.Results.outfile, 'lon', '_CoordinateAxisType', 'Lon');
else
    % Create latitude dimension
    nccreate(p.Results.outfile,'lat','Dimensions',{'lat' llat}...
            ,'Format',p.Results.format,'DeflateLevel', p.Results.comp,'Shuffle',p.Results.shuffle);
    ncwriteatt(p.Results.outfile, 'lat', 'standard_name', 'latitude');
    ncwriteatt(p.Results.outfile, 'lat', 'long_name', 'latitude');
    ncwriteatt(p.Results.outfile, 'lat', 'units', 'degrees north');
    ncwriteatt(p.Results.outfile, 'lat', '_CoordinateAxisType', 'Lat');
    % Create longitude dimension
    nccreate(p.Results.outfile,'lon','Dimensions',{'lon' llon}...
            ,'Format',p.Results.format,'DeflateLevel', p.Results.comp,'Shuffle',p.Results.shuffle);
    ncwriteatt(p.Results.outfile, 'lon', 'standard_name', 'longitude');
    ncwriteatt(p.Results.outfile, 'lon', 'long_name', 'longitude');
    ncwriteatt(p.Results.outfile, 'lon', 'units', 'degrees north');
    ncwriteatt(p.Results.outfile, 'lon', '_CoordinateAxisType', 'Lon');
end
if ldepth >= 1
    % Create depth dimension
    nccreate(p.Results.outfile,'depth','Dimensions',{'depth' ldepth}...
            ,'Format',p.Results.format,'DeflateLevel', p.Results.comp,'Shuffle',p.Results.shuffle);
    ncwriteatt(p.Results.outfile, 'depth', 'standard_name', 'depth');
    ncwriteatt(p.Results.outfile, 'depth', 'long_name', 'depth');
    ncwriteatt(p.Results.outfile, 'depth', 'units', 'm');
    ncwriteatt(p.Results.outfile, 'depth', '_CoordinateAxisType', 'Z');
    % Create layer thickness variable
    kk=strfind(dims,'z'); 
    if length(kk{:}) == 1
       nccreate(p.Results.outfile,'Hz','Dimensions',{'depth' ldepth}...
               ,'Format',p.Results.format,'DeflateLevel', p.Results.comp,'Shuffle',p.Results.shuffle);
       ncwriteatt(p.Results.outfile, 'depth', 'standard_name', 'dz');
       ncwriteatt(p.Results.outfile, 'depth', 'long_name', 'Layer thickness');
       ncwriteatt(p.Results.outfile, 'depth', 'units', 'm');
    end
end
% Create time dimension
nccreate(p.Results.outfile,'time','Dimensions',{'time' ltime}...
        ,'Format',p.Results.format,'DeflateLevel', p.Results.comp,'Shuffle',p.Results.shuffle);
ncwriteatt(p.Results.outfile, 'time', 'long_name', 'Time variable');
ncwriteatt(p.Results.outfile, 'time', 'units', p.Results.startday);
ncwriteatt(p.Results.outfile, 'time', '_CoordinateAxisType', 'Time');

% Write dimensions and layer thickness
ncwrite(p.Results.outfile,'lat',p.Results.lat);
ncwrite(p.Results.outfile,'lon',p.Results.lon);
if ~isempty(p.Results.depth)
if length(p.Results.depth) ~= 0
    ncwrite(p.Results.outfile,'depth',p.Results.depth);
end
if length(p.Results.Hz) ~= 0 & length(kk{:}) == 1
    ncwrite(p.Results.outfile,'Hz',p.Results.Hz);
end
end
ncwrite(outfile,'time',p.Results.time);

% Create all variables
for i = 1 : length(varnames)
        dd = cell(1,length(dims{i})*2); 
        ii=strfind(dims{i},'x'); if length(ii)==1 dd{ii*2-1}='lon';dd{ii*2}=llon;, end
        jj=strfind(dims{i},'y'); if length(jj)==1 dd{jj*2-1}='lat';dd{jj*2}=llat;, end
        kk=strfind(dims{i},'z'); if length(kk)==1 dd{kk*2-1}='depth';dd{kk*2}=ldepth;, end
        tt=strfind(dims{i},'t'); if length(tt)==1 dd{tt*2-1}='time';dd{tt*2}=ltime;, end
        pp=strfind(dims{i},'p'); if length(pp)==1 dd{pp*2-1}='extra_dim';dd{pp*2}=inf;, end
        nccreate(p.Results.outfile,p.Results.varnames{i},'Dimensions', dd ...
        ,'Format',p.Results.format,'DeflateLevel', p.Results.comp,'Shuffle',p.Results.shuffle,'FillValue',NaN);
        ncwriteatt(p.Results.outfile, p.Results.varnames{i}, 'standard_name', p.Results.snames{i});
        ncwriteatt(p.Results.outfile, p.Results.varnames{i}, 'long_name', p.Results.lnames{i});
        ncwriteatt(p.Results.outfile, p.Results.varnames{i}, 'units', p.Results.units{i});
end

