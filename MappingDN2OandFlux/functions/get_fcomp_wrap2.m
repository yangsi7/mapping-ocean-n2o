function [cmpclim] = get_fcomp_wrap(cmpclim,ttmp,varargin)
A.clim=0;
A.l=0;
A=parse_pv_pairs(A,varargin);

cmpclim{1} = cmpclim{1} + ttmp.Flx;

if ~A.clim
    cmpclim{2}= cmpclim{2} + ttmp.AbarUbarNbar;
    cmpclim{3} = cmpclim{3} + ttmp.AseasUbarNbar;
    cmpclim{4} = cmpclim{4} + ttmp.AbarUseasNbar;
    cmpclim{5} = cmpclim{5} + ttmp.AbarUbarNseas;
    cmpclim{6} = cmpclim{6} + ttmp.AseasUseasNbar;
    cmpclim{7} = cmpclim{7} + ttmp.AbarUseasNseas;
    cmpclim{8} = cmpclim{8} + ttmp.AseasUbarNseas;
    cmpclim{9} = cmpclim{9} + ttmp.AseasUseasNseas;

    if ~isempty(ttmp.B)
        cmpclim{10} = cmpclim{10} + ttmp.B;
    end
 else
     cmpclim{2} = cmpclim{2} + ttmp.A;
     cmpclim{3} = cmpclim{3} + ttmp.U;
    if ~isempty(ttmp.B)
        cmpclim{4} = cmpclim{4} + ttmp.B;
    end
 end

