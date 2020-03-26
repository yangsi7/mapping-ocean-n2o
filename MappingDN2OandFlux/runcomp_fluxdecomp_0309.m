pathToScript = [pwd,'/'];
dataPath = [pathToScript,'Data/'];
addpath(genpath(pathToScript));

wcoord=getWOAcoord(0.25);
mask=getWOAmask(0.25,'xyt');

dn2opath='dn2o_RF_0825.nc';
var.varnames = {'flux' 'A' 'U' 'B' 'AbarUbarNbar' 'AseasUbarNbar' 'AbarUseasNbar' ...
   'AbarUbarNseas' 'AseasUseasNbar' 'AbarUseasNseas' 'AseasUbarNseas' 'AseasUseasNseas'};
var.dims={'xytp' 'xytp' 'xytp' 'xytp' 'xytp' 'xytp' 'xytp' 'xytp' 'xytp' 'xytp' 'xytp' 'xytp'};
var.snames={'flux' 'A' 'U' 'B' 'AbarUbarNbar' 'AseasUbarNbar' 'AbarUseasNbar' 'AbarUbarNseas' ...
   'AseasUseasNbar' 'AbarUseasNseas' 'AseasUbarNseas' 'AseasUseasNseas'};
var.lnames={'Total flux' 'A' 'U' 'B' 'AbarUbarNbar' 'AseasUbarNbar' 'AbarUseasNbar' ...
   'AbarUbarNseas' 'AseasUseasNbar' 'AbarUseasNseas' 'AseasUbarNseas' 'AseasUseasNseas'};
var.units={'gN y-1' 'mm' 'mm' 'mm' 'mm' 'mm' 'mm' 'mm' 'mm' 'mm' 'mm' 'mm'};
outfile  = [pathToScript,'/quad_ccmp.nc'];
outfile2 = [pathToScript,'/quad_era5.nc'];
outfile3 = [pathToScript,'/bubbles_ccmp.nc'];
outfile4 = [pathToScript,'/bubbles_era5.nc'];
savepath = [pathToScript,'/'];

dyears=[1988 2017];

for i = 94:100
    if i == 1
        CreateNcfile(outfile,var, 'woa18', 'clim','comp',5,'depth',[]);
        CreateNcfile(outfile2,var, 'woa18', 'clim','comp',5,'depth',[]);
        CreateNcfile(outfile3,var, 'woa18', 'clim','comp',5,'depth',[]);
        CreateNcfile(outfile4,var, 'woa18', 'clim','comp',5,'depth',[]);
    end
    display(['PROCESSING FLUX ',num2str(i)])
    dn2o=single(ncread(dn2opath,'dn2o',[1 1 1 i], [inf inf inf 1]));
    [fn2o, fn2o_int, tinfo] = getFlxCmpntsv4(dn2o,'clim',1,'bubbles',1,'period',dyears,'dataPath',dataPath);
    ncwrite(outfile,'flux',fn2o.quad.ccmp.flux, [1 1 1 i]);
    ncwrite(outfile2,'flux',fn2o.quad.era5.flux, [1 1 1 i]);
    ncwrite(outfile3,'flux',fn2o.bubbles.ccmp.flux, [1 1 1 i]);
    ncwrite(outfile4,'flux',fn2o.bubbles.era5.flux, [1 1 1 i]);

    if i == 1
        fn2o_int_all = cell(1,100); 
        fn2o_int_all{i}=fn2o_int;
        save([savepath,'fn2o_cmpclim_0815.mat'],'fn2o_int_all');
    else
        load([savepath,'fn2o_cmpclim_0815.mat']);
        fn2o_int_all{i}=fn2o_int;
        save([savepath,'fn2o_cmpclim_0815.mat'],'fn2o_int_all','-v7.3');
    end

    [fn2o_annual, fn2o_seas] = makeFlxCmpntsClim(fn2o,'bubbles',1);
    clear fn2o; clear fn2o_int;
    [fn2ocmnpts,fn2ocmnpts_int,tinfo_cmptns] = getFlxCmpntsv4(dn2o,'clim',0,'decompclim',fn2o_seas,'bubbles',1,'period',dyears,'dataPath',dataPath);

    ncwrite(outfile,'AbarUbarNbar',fn2ocmnpts.quad.ccmp.AbarUbarNbar, [1 1 1 i]);
    ncwrite(outfile2,'AbarUbarNbar',fn2ocmnpts.quad.era5.AbarUbarNbar, [1 1 1 i]);
    ncwrite(outfile3,'AbarUbarNbar',fn2ocmnpts.bubbles.ccmp.AbarUbarNbar, [1 1 1 i]);
    ncwrite(outfile4,'AbarUbarNbar',fn2ocmnpts.bubbles.era5.AbarUbarNbar, [1 1 1 i]);

    ncwrite(outfile,'AseasUbarNbar',fn2ocmnpts.quad.ccmp.AseasUbarNbar, [1 1 1 i]);
    ncwrite(outfile2,'AseasUbarNbar',fn2ocmnpts.quad.era5.AseasUbarNbar, [1 1 1 i]);
    ncwrite(outfile3,'AseasUbarNbar',fn2ocmnpts.bubbles.ccmp.AseasUbarNbar, [1 1 1 i]);
    ncwrite(outfile4,'AseasUbarNbar',fn2ocmnpts.bubbles.era5.AseasUbarNbar, [1 1 1 i]);

    ncwrite(outfile,'AbarUseasNbar',fn2ocmnpts.quad.ccmp.AbarUseasNbar, [1 1 1 i]);
    ncwrite(outfile2,'AbarUseasNbar',fn2ocmnpts.quad.era5.AbarUseasNbar, [1 1 1 i]);
    ncwrite(outfile3,'AbarUseasNbar',fn2ocmnpts.bubbles.ccmp.AbarUseasNbar, [1 1 1 i]);
    ncwrite(outfile4,'AbarUseasNbar',fn2ocmnpts.bubbles.era5.AbarUseasNbar, [1 1 1 i]);

    ncwrite(outfile,'AbarUbarNseas',fn2ocmnpts.quad.ccmp.AbarUbarNseas, [1 1 1 i]);
    ncwrite(outfile2,'AbarUbarNseas',fn2ocmnpts.quad.era5.AbarUbarNseas, [1 1 1 i]);
    ncwrite(outfile3,'AbarUbarNseas',fn2ocmnpts.bubbles.ccmp.AbarUbarNseas, [1 1 1 i]);
    ncwrite(outfile4,'AbarUbarNseas',fn2ocmnpts.bubbles.era5.AbarUbarNseas, [1 1 1 i]);

    ncwrite(outfile,'AseasUseasNbar',fn2ocmnpts.quad.ccmp.AseasUseasNbar, [1 1 1 i]);
    ncwrite(outfile2,'AseasUseasNbar',fn2ocmnpts.quad.era5.AseasUseasNbar, [1 1 1 i]);
    ncwrite(outfile3,'AseasUseasNbar',fn2ocmnpts.bubbles.ccmp.AseasUseasNbar, [1 1 1 i]);
    ncwrite(outfile4,'AseasUseasNbar',fn2ocmnpts.bubbles.era5.AseasUseasNbar, [1 1 1 i]);

    ncwrite(outfile,'AbarUseasNseas',fn2ocmnpts.quad.ccmp.AbarUseasNseas, [1 1 1 i]);
    ncwrite(outfile2,'AbarUseasNseas',fn2ocmnpts.quad.era5.AbarUseasNseas, [1 1 1 i]);
    ncwrite(outfile3,'AbarUseasNseas',fn2ocmnpts.bubbles.ccmp.AbarUseasNseas, [1 1 1 i]);
    ncwrite(outfile4,'AbarUseasNseas',fn2ocmnpts.bubbles.era5.AbarUseasNseas, [1 1 1 i]);

    ncwrite(outfile,'AseasUbarNseas',fn2ocmnpts.quad.ccmp.AseasUbarNseas, [1 1 1 i]);
    ncwrite(outfile2,'AseasUbarNseas',fn2ocmnpts.quad.era5.AseasUbarNseas, [1 1 1 i]);
    ncwrite(outfile3,'AseasUbarNseas',fn2ocmnpts.bubbles.ccmp.AseasUbarNseas, [1 1 1 i]);
    ncwrite(outfile4,'AseasUbarNseas',fn2ocmnpts.bubbles.era5.AseasUbarNseas, [1 1 1 i]);

    ncwrite(outfile,'AseasUseasNseas',fn2ocmnpts.quad.ccmp.AseasUseasNseas, [1 1 1 i]);
    ncwrite(outfile2,'AseasUseasNseas',fn2ocmnpts.quad.era5.AseasUseasNseas, [1 1 1 i]);
    ncwrite(outfile3,'AseasUseasNseas',fn2ocmnpts.bubbles.ccmp.AseasUseasNseas, [1 1 1 i]);
    ncwrite(outfile4,'AseasUseasNseas',fn2ocmnpts.bubbles.era5.AseasUseasNseas, [1 1 1 i]);

    if i == 1
        fn2o_int_all = cell(1,100);
        fn2o_int_all{i}=fn2ocmnpts_int;
        save([savepath,'fn2o_cmpnts_0815.mat'],'fn2o_int_all');
    else
        load([savepath,'fn2o_cmpnts_0815.mat']);
        fn2o_int_all{i}=fn2ocmnpts_int;
        save([savepath,'fn2o_cmpnts_0815.mat'],'fn2o_int_all','-v7.3');
    end
    clear fn2ocmnpts; clear fn2ocmnpts_int;

end


