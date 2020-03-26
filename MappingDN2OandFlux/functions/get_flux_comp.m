function [cmpnts] = get_flux(U, T, S, dX, varargin)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% This function calculates the flux of a gas out of the ocean in g/m2/day 
% Fields:
%       U -- wind speed in m/s
%       T -- Sea surface temperature in degrees C
%       S -- Sea surface salinity in g/kg
%       dX -- is the desequilibrium in ((atm. mole frac.) - (seawater mole frac.))  
%       Optional arguments 
%               'SLP' -- Sea Level Pressure in atm. Default pressure is spatially 
%                        uniform at 1 atm.
%               'CI' -- Sea ice fraction (0 to 1; 0 -> no sea ice). Default is no 
%                        sea-ice;.
%               'gas' -- concerned gas. Default is n2o.
%               'param' -- Flux calculation parameterization. Default is 
%                          the quadratic formulation by Wanninkhof et al. 1992 'wkf'. 
%                          Another option is the formulation by Liang et al. 2013, 
%                          'liang2013', which takes into account the effect of 
%                          bubbles on the flux.
%               'cstar' -- Coefficient for quadratic formulation. Default is the
%                          value retrieve by Wanninkhof 2014, by matching radiocarbon 
%                          emissions using his quadratic formulation of Kw and the 
%                          CCMP wind product at 6 hourly resolution. 
%               'date' -- time of calculation as [day, month, year].
%                         needed in order to retrieve Xa in the liang2013
%                         parameterization
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %             
% Default arguments
A.gas='n2o';
A.date = [1, 1, 2000]; %  Day/Month/Year
A.param = 'wkf'; % Wanninkhof's quadratic formulation
A.cstar = 0.251; % Wanninkhof 2014 using the CCMP wind product
A.SLP = 1.0; % Default is 1 atmosphere
A.ci = 0; % Sea ice fraction. Default is no sea-ice.
A.lat = 0; % latitude axis for Liang 2013. Default is 0.
A.decomp = 0; % Switch on for component decomposition
A.decompclim = [];  % If empty, get clim of components, else do full decomposition.
A.bscale = 1;
% Parse arguments
A = parse_pv_pairs(A,varargin);

mmolpm2ps_to_gpm2pday = (1./1000)*(2*14.0067)*(3600*24);

if strcmp(A.gas,'n2o')
    % Get Schmidt number
    Sc = get_Sc(T,'n2o');
    % Get solbility
    Sa = n2o_solubility(T,S); % mmol/m3
    if strcmp(A.param,'liang2013')
        Xa=get_atmospheric_n2o(A.date(1),A.date(2),A.date(3),'lat',A.lat)./10^9;
        if length(Xa(:)) ~= 1
            Xa = repmat(Xa,size(Sc,1),1);
        end
        Xw = dX+Xa;
    end
end

if strcmp(A.param,'wkf')
    Kw = A.cstar.*U.^2 .*(Sc./660).^(-0.5)/100.0/3600.0;% m/s
    cmpnts.Flx = (1-A.ci).*Kw.*Sa.*dX.*A.SLP; %(m/s)*(mmol/(m3.atm))*(atm)=mmol/(m2.s)
    cmpnts.Flx=cmpnts.Flx*mmolpm2ps_to_gpm2pday; % g/m2/d
    if A.decomp % sum is in mmol/(m2.s)
        cmpnts.A = (1-A.ci).*Sa.*A.SLP;
        cmpnts.U = Kw;
        cmpnts.B = [];
    end
    if ~isempty(A.decompclim)
        % Get deaseasonalized components
        cmpnts.Abar = cmpnts.A - A.decompclim.A; %Remove seasonality
        cmpnts.Ubar = cmpnts.U - A.decompclim.U; %Remove seasonality
        cmpnts.Nbar = dX - A.decompclim.N; %This is just seasonal;
        % get all components % convert units to g/m2/d
        cmpnts.AbarUbarNbar = cmpnts.Abar.*cmpnts.Ubar.*cmpnts.Nbar*mmolpm2ps_to_gpm2pday;
        cmpnts.AbarUseasNbar = cmpnts.Abar.*A.decompclim.U.*cmpnts.Nbar*mmolpm2ps_to_gpm2pday;
        cmpnts.AbarUbarNseas = cmpnts.Abar.*cmpnts.Ubar.*A.decompclim.N*mmolpm2ps_to_gpm2pday;
        cmpnts.AbarUseasNseas = cmpnts.Abar.*A.decompclim.U.*A.decompclim.N*mmolpm2ps_to_gpm2pday;
        cmpnts.AseasUbarNbar = A.decompclim.A.*cmpnts.Ubar.*cmpnts.Nbar*mmolpm2ps_to_gpm2pday;
        cmpnts.AseasUseasNbar = A.decompclim.A.*A.decompclim.U.*cmpnts.Nbar*mmolpm2ps_to_gpm2pday;
        cmpnts.AseasUbarNseas = A.decompclim.A.*cmpnts.Ubar.*A.decompclim.N*mmolpm2ps_to_gpm2pday;
        cmpnts.AseasUseasNseas = A.decompclim.A.*A.decompclim.U.*A.decompclim.N*mmolpm2ps_to_gpm2pday;
        clear cmpnts.Abar;clear cmpnts.Ubar; clear cmpnts.Nbar;
    end
elseif strcmp(A.param,'liang2013')
    % Specific gas constants
    Rd = 287.058; % dry air in J/(kg·K)
    Rv = 461.495; % water vapor in J/(kg·K)
    R = 8.314;  % units: m3 Pa K-1 mol-1
    % Partial pressure of water vapor and dry air.decompclim.U
    ppw = 6.102.*10.^((7.5.*T)./(T+237.8));
    ppa_dry = A.SLP.*101325 - ppw;
    % Density of humid air in kg/m3
    rho_ha = ppa_dry./(Rd.*(T+273.15)) + ppw./(Rv.*(T+273.15));
    % Density of sea water in kg/m3
    Pdb = A.SLP./0.987.*10; % surface pressure in db
    rho_sw = double(sw_dens(S,T,Pdb));
    % Drag coefficient from Large and Pond 1981
    Cd=nan(size(U));
    Cd(U<11.0)=0.0012;
    Cd(U>=11.0&U<20.0) = (0.49+0.065.*U(U>=11.0&U<20))*10^(-3);
    Cd(U>=20.0)=0.0018;
    % ua and uw are the air and water side friction velocities
    Uw=U.*(rho_ha.*Cd./rho_sw).^0.5;
    %0.034.*(Cd).^(0.5).*U;
    Ua = U.*Cd.^0.5;
    %%%
    lam = 13.3;
    AA = 1.3;
    phi = 1;
    tkt = 0.01;
    hw=lam./AA./phi;
    ha=lam;
    alc = ((Sa./1000)/1.01325e5).*R.*(T+273.15);
    % air-side schmidt number
    ScA = 0.9;
    % water-side resistance to transfer
    rwt = sqrt(rho_sw./rho_ha).*(hw.*sqrt(Sc)+(log(0.5./tkt)/0.4));
    % air-side resistance to transfer
    rat = ha.*sqrt(ScA)+1.0./sqrt(Cd)-5.0+0.5.*log(ScA)/0.4;
    % Ks (piston velocity with no bubbles (Jeffery et al., 2010))
    Ks = Ua./(rwt+rat.*alc); % m/s    
    % Kb (piston velocity due to bubbles (Liang et al. 2013))
    Kb = 1.98*10^6.*Uw.^2.76.*(Sc./660).^(-2/3)/100/3600; % m/s
    % Kc flux due to movement of air upon collapsing of small bubbles
    Kc = 5.56.*Uw.^(3.86)*1000; % mmol/m2/s
    % DelP
    DelP = 1.52.*Uw.^1.06;
    % Fs, Flux without bubbles
    Fs = Ks.*Sa.*dX.*A.SLP; %(m/s)(mmol/m3/atm)(atm) = mmol/m2/s
    % Fb, Flux due to large bubles
    Fb = Kb.*Sa.*(Xw-(1+DelP).*Xa).*A.SLP; %(m/s)(mmol/m3/atm)(atm) = mmol/m2/s
    % Fc, flux due to colapse of small bubbles
    Fc = Kc.*Xa; % mmol/m2/s
    cmpnts.Flx = A.bscale.*(Fs+Fb+Fc).*(1.0-A.ci); % mmol/m2/s
%    Kbstar=Kb+Xa./(dX).*(Kc./(Sa.*A.SLP)+Kb.*DelP);
%    cmpnts.Flx = (1-A.ci).*(Sa.*A.SLP).*A.bscale.*(Ks.*Kbstar).*dX;
    cmpnts.Flx=real(cmpnts.Flx*mmolpm2ps_to_gpm2pday); % g/m2/d
    if A.decomp % sum is in mmol/(m2.s)
        cmpnts.A = real((1-A.ci).*Sa.*A.SLP);
        cmpnts.U = real(A.bscale.*(Ks+Kb));
%        cmpnts.Ks=Ks;cmpnts.Kb=Kb;cmpnts.Cd=Cd;
        cmpnts.B = real((1-A.ci).*Xa.*A.bscale.*(Kc+Kb.*Sa.*A.SLP.*DelP));
    end
    if ~isempty(A.decompclim)
        % Get deaseasonalized components
        cmpnts.Abar = real(cmpnts.A - A.decompclim.A); %Remove seasonality
        cmpnts.Ubar = real(cmpnts.U - A.decompclim.U); %Remove seasonality
        cmpnts.Nbar = real(dX-A.decompclim.N); %This is just seasonal;
        % get all components % convert units to g/m2/d
        cmpnts.AbarUbarNbar = real(cmpnts.Abar.*cmpnts.Ubar.*cmpnts.Nbar*mmolpm2ps_to_gpm2pday);
        cmpnts.AbarUseasNbar = real(cmpnts.Abar.*A.decompclim.U.*cmpnts.Nbar*mmolpm2ps_to_gpm2pday);
        cmpnts.AbarUbarNseas = real(cmpnts.Abar.*cmpnts.Ubar.*A.decompclim.N*mmolpm2ps_to_gpm2pday);
        cmpnts.AbarUseasNseas = real(cmpnts.Abar.*A.decompclim.U.*A.decompclim.N*mmolpm2ps_to_gpm2pday);
        cmpnts.AseasUbarNbar = real(A.decompclim.A.*cmpnts.Ubar.*cmpnts.Nbar*mmolpm2ps_to_gpm2pday);
        cmpnts.AseasUseasNbar = real(A.decompclim.A.*A.decompclim.U.*cmpnts.Nbar*mmolpm2ps_to_gpm2pday);
        cmpnts.AseasUbarNseas = real(A.decompclim.A.*cmpnts.Ubar.*A.decompclim.N*mmolpm2ps_to_gpm2pday);
        cmpnts.AseasUseasNseas = real(A.decompclim.A.*A.decompclim.U.*A.decompclim.N*mmolpm2ps_to_gpm2pday);
        cmpnts.FlxB = real(cmpnts.B*mmolpm2ps_to_gpm2pday);
        clear cmpnts.Abar; clear cmpnts.Ubar; clear cmpnts.Nbar
    end    
end

