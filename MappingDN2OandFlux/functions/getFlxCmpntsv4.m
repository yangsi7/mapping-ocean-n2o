function [fn2o,fn2o_int,tinfo] = getflux(dn2o,varargin)

 A.period = [1980, 2015];
 A.nworkers = 1;
 A.clim = 1;
 A.bubbles=1;
 A.datapath = '/oasis/scratch/comet/yangsi/temp_project/Data/';
 A.decompclim = [];
 A =  parse_pv_pairs(A,varargin);
 
% Initialization % %
 addpath(genpath('/oasis/scratch/comet/yangsi/temp_project/MATLAB/n2oflux/allinone/'));
 era5path=[A.datapath,'era5/'];
 ccmppath=[A.datapath,'ccmp/'];
 sstoipath=[A.datapath,'sstoi/'];
 % load salinity
% s_woa_daily_path = 'xxx.nc';
 s_woa_month = squeeze(ncread([A.datapath,'dataForFlux/salt_woa18_clim.nc'],'salt',[1,1,1,1],[inf,inf,1,inf]));
 load([A.datapath,'dataForFlux/Kw_ccmp_pera5_0904.mat'],'Kw_avg'); 
 cstar.ccmp = 0.251*16.5/nanmean(Kw_avg.kw.ccmp(:));
 cstar.era5 = 0.251*16.5/nanmean(Kw_avg.kw.era5(:));
 if A.bubbles == 1
     bscale.ccmp = real(16.5./(nanmean(Kw_avg.ks.ccmp(:))+nanmean(Kw_avg.kbstar.ccmp(:))));
     bscale.era5 = real(16.5./(nanmean(Kw_avg.ks.era5(:))+nanmean(Kw_avg.kbstar.era5(:))));
 else
     bscale.ccmp=[];
     bscale.era5=[];
 end
 % Set variables to grab from each product
 vvar.era5={'u10', 'v10', 'ci','sst','msl'}; % ERA5
 vvar.ccmp={'uwnd', 'vwnd'}; %CCMP
 vvar.sstoi={'sst','ice'}; % NOAA 1/4 deg optimum interpolation.

 % Get grid info for each product
 wcoord = getWOAcoord(0.25); % WOA 1/4 deg
 wcoord.LON = single(wcoord.LON);
 wcoord.LAT = single(wcoord.LAT);
 warea=load([A.datapath,'dataForFlux/woaarea_0p25.mat']);
 msk=load([A.datapath,'dataForFlux/masks_aug20.mat']);

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
 % Get seasonality of DN2O if A.decompclim is provided
 if ~isempty(A.decompclim)
     for fw = 1 : length(fnameOut.wind)
         for fp = 1 : length(fnameOut.param)
             if fw == 1
                     A.decompclim.(fnameOut.param{fp}).(fnameOut.wind{fw}).N = dn2o - repmat(nanmean(dn2o,3),1,1,12);
             else
                     A.decompclim.(fnameOut.param{fp}).(fnameOut.wind{fw}).N = dn2o - repmat(nanmean(dn2o,3),1,1,12);
            end
         end
     end
 end
 % Set up everything relate to time
 % Days in months
 daysInMonths = [31 28 31 30 31 30 31 31 30 31 30 31];
 % Leap years
 Leapyears=(1976:4:2020);
 % NUmber of years in selected period
 nyrs = A.period(2)-A.period(1)+1;
 % Max extent of each wind product
 ccmp_y = [1988, 2017]; ccmp_nyrs = ccmp_y(2)-ccmp_y(1)+1; % span of CCMP
 era5_y = [1979, 2017]; era5_nyrs = era5_y(2)-era5_y(1)+1; % span of ERA5
 % Initialize timestep counter
% for fw = 1 : length(fnameOut.wind)
%     for fp = 1 : length(fnameOut.param)
%         for fc = 1 : length(fnameOut.all)
%             fn2o.(fnameOut.param{fp}).(fnameOut.wind{fw}).(fnameOut.all{fc}) = repmat(zeros(size(wcoord.LON)),1,1,12);
%         end
%     end
% end
 lfw = length(fnameOut.wind);
 lfp = length(fnameOut.param);
 lfc = length(fnameOut.all);
 totfields = lfw.*lfp.*lfc;
 tsteps_ccmp_total=zeros(1,12); 
 tsteps_era5_total=zeros(1,12); 
 fn2o_int_qe=nan(12,nyrs,lfc);
 fn2o_int_be=nan(12,nyrs,lfc);
 fn2o_int_qc=nan(12,nyrs,lfc);
 fn2o_int_bc=nan(12,nyrs,lfc);
% for l = 1 : 12
%     for fw = 1 : lfw
%         for fp = 1 : lfp
%             for fc = 1 : lfc
%                 partmp{l}.(fnameOut.param{fp}).(fnameOut.wind{fw}).(fnameOut.all{fc}) = zeros(size(wcoord.LON));
%             end
%         end
%     end
% end
 % % % % % % % % %
 % start looping through years
 ttemplate=single(zeros(size(wcoord.LON)));
 fn2o_qe = cell(12,nyrs,lfc);
 fn2o_qe(:)={ttemplate};
 fn2o_qc = cell(12,nyrs,lfc);
 fn2o_qc(:)={ttemplate};
 fn2o_be = cell(12,nyrs,lfc);
 fn2o_be(:)={ttemplate};
 fn2o_bc = cell(12,nyrs,lfc);
 fn2o_bc(:)={ttemplate};
parpool(30)
 parfor yy = 1 : nyrs
    eracnt=1;ccmpcnt=1;daycnt=1;
    % recover current year
    if yy == 1
        yyr=[];
    end
    yyr=yy+A.period(1)-1;
    display(['Processing year ',num2str(yyr)])
    % Recover numbers of days in months
    daysInMonthstmp = daysInMonths;
    % Reassign days for February in Leap years
    if sum(yyr == Leapyears) == 1
        daysInMonthstmp(2)=29;
    else
        daysInMonthstmp(2)=28;
    end
    % calculate year-to-date cumulative days for the start of each month
    daysInMonthscum = cumsum(daysInMonthstmp);
    tsteps_ccmp=zeros(1,12);
    tsteps_era5=zeros(1,12);
    ttmp_qe = cell(12,lfc);
    ttmp_qe(:)={ttemplate};
    ttmp_qc = cell(12,lfc);
    ttmp_qc(:)={ttemplate};
    ttmp_be = cell(12,lfc);
    ttmp_be(:)={ttemplate};
    ttmp_bc = cell(12,lfc);
    ttmp_bc(:)={ttemplate};
    for mm = 1 : 12 % loop through months
        display(['Year ',num2str(yyr),', month ',num2str(mm)])
        decompclimera5 = init_decompclim();   
        decompclimccmp = init_decompclim();
        for dd = 1 : daysInMonthstmp(mm) % loop through days
             dn2odaily = interpdailyfromclim(dn2o,[dd,mm,yyr])./10^9;
             s_woa_month_daily = interpdailyfromclim(s_woa_month,[dd,mm,yyr]);
       %     s_woa_month_daily = ncread(s_woa_daily_path,[1,1,daycnt],[inf,inf,1]);
       %     dn2odaily = ncread(dn2odaily_path,[1,1,daycnt],[inf,inf,1])./10^9;
            if ~isempty(A.decompclim)
                decompclimera5.quad.A = interpdailyfromclim(A.decompclim.quad.era5.A,[dd,mm,yyr]);
                decompclimera5.quad.U = interpdailyfromclim(A.decompclim.quad.era5.U,[dd,mm,yyr]);
                decompclimera5.quad.N = interpdailyfromclim(A.decompclim.quad.era5.N,[dd,mm,yyr])*10^-9;
                decompclimera5.quad.B = [];
                if A.bubbles == 1
                    decompclimera5.bubbles.A = interpdailyfromclim(A.decompclim.bubbles.era5.A,[dd,mm,yyr]);
                    decompclimera5.bubbles.U = interpdailyfromclim(A.decompclim.bubbles.era5.U,[dd,mm,yyr]);
                    decompclimera5.bubbles.N = interpdailyfromclim(A.decompclim.bubbles.era5.N,[dd,mm,yyr])*10^-9;
                    decompclimera5.bubbles.B = interpdailyfromclim(A.decompclim.bubbles.era5.B,[dd,mm,yyr]);
                end
            else
                decompclimera5.quad = [];
                if A.bubbles == 1
                    decompclimera5.bubbles = [];
                end
            end
                for tt = 1 : 4
                    era5Uspeed = single(((ncread([era5path,'era5_',num2str(yyr),'.nc'],'u10',[1,1,eracnt],[inf,inf,1])).^2 ...
                    + (ncread([era5path,'era5_',num2str(yyr),'.nc'],'v10',[1,1,eracnt],[inf,inf,1])).^2).^0.5);
                    era5msl=single(ncread([era5path,'era5_',num2str(yyr),'.nc'],'msl',[1,1,eracnt],[inf,inf,1])./101325.0);
                    era5sst=single(ncread([era5path,'era5_',num2str(yyr),'.nc'],'sst',[1,1,eracnt],[inf,inf,1])-273.15);
                    era5ci=single(ncread([era5path,'era5_',num2str(yyr),'.nc'],'ci',[1,1,eracnt],[inf,inf,1]));
                    % Ge    t the flux for ERA5 -- quadratic formulation by Wanninkhof 1992 with c* scaled
                            [ctmp] = get_flux_comp(era5Uspeed,era5sst,s_woa_month_daily,...
                            dn2odaily,'SLP',era5msl,'cstar',cstar.era5,...
                            'CI',era5ci,'gas','n2o','decomp',1,'decompclim',decompclimera5.quad);
                             ttmp_qe(mm,:) = get_fcomp_wrap2(ttmp_qe(mm,:),ctmp,'clim',A.clim);
%                            partmp{mm}.quad.era5 = get_fcomp_wrap(partmp{mm}.quad.era5,ctmp,'clim',A.clim);
                    % Ge    t the flux for ERA5 -- Liang et al. 2013
                            if A.bubbles == 1
                                [ctmp] = get_flux_comp(era5Uspeed,era5sst,s_woa_month_daily,...
                                dn2odaily,'SLP',era5msl,'param','liang2013','decomp',1,...
                            'date',[dd,mm,yyr],'lat',wcoord.lat,'ci',era5ci,'gas','n2o','decompclim',decompclimera5.bubbles,'bscale',bscale.era5);
                                ttmp_be(mm,:) = get_fcomp_wrap2(ttmp_be(mm,:),ctmp,'clim',A.clim); 
%                                partmp{mm}.bubbles.era5 = get_fcomp_wrap(partmp{mm}.bubbles.era5,ctmp,'clim',A.clim);
                            end
                    % Up    date ERA5 time step counter for month
                    tsteps_era5(mm)=tsteps_era5(mm)+1;
                    eracnt=eracnt+1;
                end

                sstoisst = single(ncread([sstoipath,'sstoi_',num2str(yyr),'.nc'],'sst',[1,1,daycnt],[inf,inf,1]));
                sstoiice = single(ncread([sstoipath,'sstoi_',num2str(yyr),'.nc'],'ice',[1,1,daycnt],[inf,inf,1]));
                sstoiice(isnan(sstoiice))=0;
                if ~isempty(A.decompclim)
                    decompclimccmp.quad.A = interpdailyfromclim(A.decompclim.quad.ccmp.A,[dd,mm,yyr]);
                    decompclimccmp.quad.U = interpdailyfromclim(A.decompclim.quad.ccmp.U,[dd,mm,yyr]);
                    decompclimccmp.quad.N = interpdailyfromclim(A.decompclim.quad.ccmp.N,[dd,mm,yyr])*10^-9;
                    decompclimccmp.quad.B = [];
                    if A.bubbles == 1
                        decompclimccmp.bubbles.A = interpdailyfromclim(A.decompclim.bubbles.ccmp.A,[dd,mm,yyr]);
                        decompclimccmp.bubbles.U = interpdailyfromclim(A.decompclim.bubbles.ccmp.U,[dd,mm,yyr]);
                        decompclimccmp.bubbles.N = interpdailyfromclim(A.decompclim.bubbles.ccmp.N,[dd,mm,yyr])*10^-9;
                        decompclimccmp.bubbles.B = interpdailyfromclim(A.decompclim.bubbles.ccmp.B,[dd,mm,yyr]);
                    end
                else
                    decompclimccmp.quad = [];
                    decompclimccmp.bubbles = [];
                end
                for tt = 1 : 4
                    ccmpUspeed = single((ncread([ccmppath,'ccmp_',num2str(yyr),'.nc'],'uwnd',[1,1,ccmpcnt],[inf,inf,1]).^2 ...
                    +ncread([ccmppath,'ccmp_',num2str(yyr),'.nc'],'vwnd',[1,1,ccmpcnt],[inf,inf,1]).^2).^0.5);
                    [ctmp]=get_flux_comp(ccmpUspeed,sstoisst,s_woa_month_daily,dn2odaily,...
                            'SLP',era5msl,'cstar',cstar.ccmp,'ci',sstoiice,'gas','n2o','decomp',1,'decompclim',decompclimccmp.quad); 
                         ttmp_qc(mm,:) = get_fcomp_wrap2(ttmp_qc(mm,:),ctmp,'clim',A.clim); 
%                         partmp{mm}.quad.ccmp = get_fcomp_wrap(partmp{mm}.quad.ccmp,ctmp,'clim',A.clim);
                    % Get the flux for CCMP -- Liang et al. 2013
                    if A.bubbles == 1
                        [ctmp]=get_flux_comp(ccmpUspeed,sstoisst,s_woa_month_daily,dn2odaily,...
                            'SLP',era5msl,'param','liang2013','date',[dd,mm,yyr], ...
                            'lat',wcoord.lat,'ci',sstoiice,'gas','n2o','decomp',1,'decompclim',decompclimccmp.bubbles,'bscale',bscale.ccmp);
                        ttmp_bc(mm,:) = get_fcomp_wrap2(ttmp_bc(mm,:),ctmp,'clim',A.clim);
                        %partmp{mm}.bubbles.ccmp = get_fcomp_wrap(partmp{mm}.bubbles.ccmp,ctmp,'clim',A.clim);
                    end
                    % Get date CCMP time step counter for month
                    tsteps_ccmp(mm)=tsteps_ccmp(mm)+1;
                    ccmpcnt = ccmpcnt+1;
                end
        end
    end
    for fc = 1 : lfc
        for l = 1 : 12
             if ~strcmp(fnameOut.all{fc},'B')
                 tmp = ttmp_qe{l,fc}./tsteps_era5(l)*365.25.*warea.areawoa0p25/10^12.*msk.bmskv3.flux_nolake;
                 fn2o_qe{l,yy,fc} =  ttmp_qe{l,fc};
             else
                 tmp = nan;
             end
             fn2o_int_qe(l,yy,fc) = nansum(tmp(:));

             tmp = ttmp_be{l,fc}./tsteps_era5(l)*365.25.*warea.areawoa0p25/10^12.*msk.bmskv3.flux_nolake;
             fn2o_be{l,yy,fc} =  ttmp_be{l,fc};
             fn2o_int_be(l,yy,fc) = nansum(tmp(:));

             if ~strcmp(fnameOut.all{fc},'B')
                 tmp = ttmp_qc{l,fc}./tsteps_ccmp(l)*365.25.*warea.areawoa0p25/10^12.*msk.bmskv3.flux_nolake;
                 fn2o_qc{l,yy,fc} =  ttmp_qc{l,fc};
             else
                 tmp = nan;
             end
             fn2o_int_qc(l,yy,fc) = nansum(tmp(:));

             tmp = ttmp_bc{l,fc}./tsteps_ccmp(l)*365.25.*warea.areawoa0p25/10^12.*msk.bmskv3.flux_nolake;
             fn2o_bc{l,yy,fc} =  ttmp_bc{l,fc};
             fn2o_int_bc(l,yy,fc) = nansum(tmp(:));
        end
    end
    tsteps_era5_total=tsteps_era5_total+tsteps_era5;
    tsteps_ccmp_total=tsteps_ccmp_total+tsteps_ccmp;
    display('reached end of loop for year')
 end
 delete(gcp('nocreate'));
 for fc = 1 : length(fnameOut.all)
     fn2o_int.quad.era5.(fnameOut.all{fc}) = fn2o_int_qe(:,:,fc);
     fn2o_int.bubbles.era5.(fnameOut.all{fc}) = fn2o_int_be(:,:,fc);
     fn2o_int.quad.ccmp.(fnameOut.all{fc}) = fn2o_int_qc(:,:,fc);
     fn2o_int.bubbles.ccmp.(fnameOut.all{fc}) = fn2o_int_bc(:,:,fc);
     for l = 1 : 12
         if ~strcmp(fnameOut.all{fc},'B')
             tmp=squeeze(fn2o_qe(l,:,fc)); tmp=nansum(cat(3,tmp{:}),3); 
             fn2o.quad.era5.(fnameOut.all{fc})(:,:,l) = tmp./tsteps_era5_total(l).*msk.bmskv3.flux_nolake;
         else 
             fn2o.quad.era5.(fnameOut.all{fc})=[];
         end

         tmp=squeeze(fn2o_be(l,:,fc)); tmp=nansum(cat(3,tmp{:}),3);
         fn2o.bubbles.era5.(fnameOut.all{fc})(:,:,l) = tmp./tsteps_era5_total(l).*msk.bmskv3.flux_nolake;

         if ~strcmp(fnameOut.all{fc},'B')
             tmp=squeeze(fn2o_qc(l,:,fc)); tmp=nansum(cat(3,tmp{:}),3);
             fn2o.quad.ccmp.(fnameOut.all{fc})(:,:,l) = tmp./tsteps_ccmp_total(l).*msk.bmskv3.flux_nolake;
         else
             fn2o.quad.ccmp.(fnameOut.all{fc})=[]
         end

         tmp=squeeze(fn2o_bc(l,:,fc)); tmp=nansum(cat(3,tmp{:}),3);
         fn2o.bubbles.ccmp.(fnameOut.all{fc})(:,:,l) = tmp./tsteps_ccmp_total(l).*msk.bmskv3.flux_nolake;
     end
 end

 tinfo.tsteps_ccmp = tsteps_ccmp_total;
 tinfo.tsteps_era5 = tsteps_era5_total;

