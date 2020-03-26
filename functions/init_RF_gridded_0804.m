function [pred, out] = init_RF_gridded(compilation,var,fnames,varargin)
A.mask=[];
A=parse_pv_pairs(A,varargin);

load(compilation);
if isempty(A.mask)
    indx = find(~isnan(dn2o.res0p25.val));
else
    indx = find(~isnan(dn2o.res0p25.val) & ~isnan(A.mask));
end

for f = 1 : length(fnames.train)
    pred.(fnames.train{f}) = var.(fnames.clim{f})(indx);
end
out.n2o = dn2o.res0p25.val(indx)';

