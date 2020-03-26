pathToScript = [pwd,'/'];
addpath(genpath(pathToScript));
outpath=pathToScript;

load([outpath,'n2oDataYang2020PNAS.mat']);
mask=getWOAmask(0.25,'xy');

% Get surface data and remove extremes for one of the gridded products
sortedn2o= sort(compilation.dn2o_ppb);
indx=(1:length(sortedn2o));
indxcum=indx/indx(end)*100;
[a,idx0p02]=min(abs(indxcum-99.85));
A
thresh=sortedn2o(idx0p02);
filter1 = compilation.dn2o_ppb<thresh;
filter2 = compilation.depth<10;

% Set bounds and initialize
lonbounds0p25=(-180:0.25:180);latbounds0p25 =(-90:0.25:90);
lonbounds1p0=(-180:1:180);latbounds1p0 =(-90:1:90);
lonbounds5p0=(-180:5:180);latbounds5p0 =(-90:5:90);
dn2o.res0p25.val = nan(length(lonbounds0p25)-1,length(latbounds0p25)-1,12);
dn2o.res0p25.scount = nan(length(lonbounds0p25)-1,length(latbounds0p25)-1,12);
temp.res0p25.val = nan(length(lonbounds0p25)-1,length(latbounds0p25)-1,12);
temp.res0p25.scount = nan(length(lonbounds0p25)-1,length(latbounds0p25)-1,12);
salt.res0p25.val = nan(length(lonbounds0p25)-1,length(latbounds0p25)-1,12);
salt.res0p25.scount = nan(length(lonbounds0p25)-1,length(latbounds0p25)-1,12);
dn2o.res1p0.val = nan(length(lonbounds1p0)-1,length(latbounds1p0)-1,12);
dn2o.res1p0.scount = nan(length(lonbounds1p0)-1,length(latbounds1p0)-1,12);
dn2o.res5p0.val = nan(length(lonbounds5p0)-1,length(latbounds5p0)-1,12);
dn2o.res5p0.scount = nan(length(lonbounds5p0)-1,length(latbounds5p0)-1,12);
lontmp = compilation.longitude; lontmp(lontmp>180)=lontmp(lontmp>180)-360;

% Start gridding
for l = 1 : 12
    l
    idx = find(filter1.*filter2.*(compilation.month==l));
    % 0.25degree woa18 nominal resolution
    [dn2o.res0p25.val(:,:,l) dn2o.res0p25.scount(:,:,l)]  = ...
      scatter_density_ll(compilation.dn2o_ppb(idx),lontmp(idx), ...
      compilation.latitude(idx),lonbounds0p25,latbounds0p25,'mask',mask);
    [temp.res0p25.val(:,:,l) temp.res0p25.scount(:,:,l)]  = ...
      scatter_density_ll(compilation.temperature(idx),lontmp(idx), ...
      compilation.latitude(idx),lonbounds0p25,latbounds0p25,'mask',mask);
    [salt.res0p25.val(:,:,l) salt.res0p25.scount(:,:,l)]  = ...
      scatter_density_ll(compilation.salinity(idx),lontmp(idx), ...
      compilation.latitude(idx),lonbounds0p25,latbounds0p25,'mask',mask);
    
    % 1.0 degree woa18 nominal resolution
    [dn2o.res1p0.val(:,:,l) dn2o.res1p0.scount(:,:,l)]  = ...
      scatter_density_ll(compilation.dn2o_ppb(idx),lontmp(idx), ...
      compilation.latitude(idx),lonbounds1p0,latbounds1p0);
    
    % 5.0 degrees nominal resolution
    [dn2o.res5p0.val(:,:,l) dn2o.res5p0.scount(:,:,l)]  = ...
      scatter_density_ll(compilation.dn2o_ppb(idx),lontmp(idx), ...
      compilation.latitude(idx),lonbounds5p0,latbounds5p0);
end
% save gridded compilation whrere extremes over Peru have been removed
save([outpath,'compilation_gridded_l0p02_180719.mat'],'dn2o','temp','salt');

% Filter
filter1 = compilation.depth<10;
lonbounds0p25=(-180:0.25:180);latbounds0p25 =(-90:0.25:90);
lonbounds1p0=(-180:1:180);latbounds1p0 =(-90:1:90);
lonbounds5p0=(-180:5:180);latbounds5p0 =(-90:5:90);
dn2o.res0p25.val = nan(length(lonbounds0p25)-1,length(latbounds0p25)-1,12);
dn2o.res0p25.scount = nan(length(lonbounds0p25)-1,length(latbounds0p25)-1,12);
dn2o.res1p0.val = nan(length(lonbounds1p0)-1,length(latbounds1p0)-1,12);
dn2o.res1p0.scount = nan(length(lonbounds1p0)-1,length(latbounds1p0)-1,12);
dn2o.res5p0.val = nan(length(lonbounds5p0)-1,length(latbounds5p0)-1,12);
dn2o.res5p0.scount = nan(length(lonbounds5p0)-1,length(latbounds5p0)-1,12);
lontmp = compilation.longitude; lontmp(lontmp>180)=lontmp(lontmp>180)-360;
for l = 1 : 12
    l
    idx = find(filter1.*(compilation.month==l));
    % 0.25degree woa18 nominal resolution
    [dn2o.res0p25.val(:,:,l) dn2o.res0p25.scount(:,:,l)]  = ...
      scatter_density_ll(compilation.dn2o_ppb(idx),lontmp(idx), ...
      compilation.latitude(idx),lonbounds0p25,latbounds0p25,'mask',mask);
    [temp.res0p25.val(:,:,l) temp.res0p25.scount(:,:,l)]  = ...
      scatter_density_ll(compilation.temperature(idx),lontmp(idx), ...
      compilation.latitude(idx),lonbounds0p25,latbounds0p25,'mask',mask);
    [salt.res0p25.val(:,:,l) salt.res0p25.scount(:,:,l)]  = ...
      scatter_density_ll(compilation.salinity(idx),lontmp(idx), ...
      compilation.latitude(idx),lonbounds0p25,latbounds0p25,'mask',mask);

    % 1.0 degree woa18 nominal resolution
    [dn2o.res1p0.val(:,:,l) dn2o.res1p0.scount(:,:,l)]  = ...
      scatter_density_ll(compilation.dn2o_ppb(idx),lontmp(idx), ...
      compilation.latitude(idx),lonbounds1p0,latbounds1p0);

    % 5.0 degrees nominal resolution
    [dn2o.res5p0.val(:,:,l) dn2o.res5p0.scount(:,:,l)]  = ...
      scatter_density_ll(compilation.dn2o_ppb(idx),lontmp(idx), ...
      compilation.latitude(idx),lonbounds5p0,latbounds5p0);
end
% save gridded compilation which includes ALL data.
save([outpath,'compilation_gridded_all_180719.mat'],'dn2o','temp','salt');
