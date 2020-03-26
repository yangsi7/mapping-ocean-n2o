function woacoord = getWOAcoord(res, varargin)
    A.extra = {'none'};
    A = parse_pv_pairs(A,varargin);

        woa = makeclims_init;
    if res == 0.25
        woacoord.lon = ncread([woa{1}.path,woa{1}.nc.varnames{1},'_woa18_clim.nc'],'lon');
        woacoord.lat = ncread([woa{1}.path,woa{1}.nc.varnames{1},'_woa18_clim.nc'],'lat');
        woacoord.depth = ncread([woa{1}.path,woa{1}.nc.varnames{1},'_woa18_clim.nc'],'depth');
        woacoord.dz = ncread([woa{1}.path,woa{1}.nc.varnames{1},'_woa18_clim.nc'],'Hz');
    elseif res == 1
        woacoord.lon = ncread([woa{3}.path,woa{3}.nc.varnames{1},'_woa18_clim.nc'],'lon');
        woacoord.lat = ncread([woa{3}.path,woa{3}.nc.varnames{1},'_woa18_clim.nc'],'lat');
        woacoord.depth = ncread([woa{3}.path,woa{3}.nc.varnames{1},'_woa18_clim.nc'],'depth');
        woacoord.dz = ncread([woa{3}.path,woa{3}.nc.varnames{1},'_woa18_clim.nc'],'Hz');
    end       

    woacoord.diml(1) = length(woacoord.lon);
    woacoord.diml(2) = length(woacoord.lat);
    woacoord.diml(3) = length(woacoord.depth); 
    [woacoord.LAT woacoord.LON] = meshgrid(woacoord.lat, woacoord.lon);

    if sum(strcmp('area', A.extra)) | sum(strcmp('volume', varargin))
        woacoord.area=LonLatArea(woacoord.lon,woacoord.lat);
    end
    if sum(strcmp('volume', A.extra))
        woacoord.volume=repmat(woacoord.area,1,1,woacoord.diml(3)) ...
        .*permute(repmat(woacoord.dz,1,woacoord.diml(1),woacoord.diml(2)),[2 3 1]);
    end
