function mask = getWOAasmk(res,dim)
        woa = makeclims_init;
    if res == 0.25
        if strcmp(dim,'xy')
            mask = squeeze(ncread([woa{1}.path,woa{1}.nc.varnames{1},...
            '_woa18_clim.nc'],'temp',[1 1 1 1], [inf, inf, 1, 1]));
            mask(~isnan(mask))=1;
        elseif strcmp(dim,'xyz')
            mask = squeeze(ncread([woa{1}.path,woa{1}.nc.varnames{1}...
            ,'_woa18_clim.nc'],'temp',[1 1 1 1], [inf, inf, inf, 1]));
            mask(~isnan(mask))=1;
        elseif strcmp(dim,'xyt')
            mask = squeeze(ncread([woa{1}.path,woa{1}.nc.varnames{1}...
            ,'_woa18_clim.nc'],'temp',[1 1 1 1], [inf, inf, 1, inf]));
            mask(~isnan(mask))=1;
        elseif strcmp(dim,'xyzt')
            mask = ncread([woa{1}.path,woa{1}.nc.varnames{1}...
            ,'_woa18_clim.nc'],'temp');
            mask(~isnan(mask))=1;
        else            
            error('Incorrect dimension specified. Valid values are xy, xyz, xyzt.');
        end
    elseif res == 1
        if strcmp(dim,'xy')
            mask = squeeze(ncread([woa{3}.path,woa{3}.nc.varnames{1},...
            '_woa18_clim.nc'],'o2',[1 1 1 1], [inf, inf, 1, 1]));
        elseif strcmp(dim,'xyz')
            mask = squeeze(ncread([woa{3}.path,woa{3}.nc.varnames{1}...
            ,'_woa18_clim.nc'],'o2',[1 1 1 1], [inf, inf, inf, 1]));
            mask(~isnan(mask))=1;
        elseif strcmp(dim,'xyt')
            mask = squeeze(ncread([woa{3}.path,woa{3}.nc.varnames{1}...
            ,'_woa18_clim.nc'],'o2',[1 1 1 1], [inf, inf, 1, inf]));
            mask(~isnan(mask))=1;
        elseif strcmp(dim,'xyzt')
            mask = ncread([woa{3}.path,woa{3}.nc.varnames{1}...
            ,'_woa18_clim.nc'],'o2');
            mask(~isnan(mask))=1;
        else
            error('Incorrect dimension specified. Valid values are xy, xyt, xyz, xyzt.');
        end
    end        

