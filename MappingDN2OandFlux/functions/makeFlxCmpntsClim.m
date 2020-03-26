function [fn2o_annual,fn2o_seasonal] = makeFlxCmpntsClim(fn2o,varargin)
A.bubbles=0;
A=parse_pv_pairs(A,varargin);

fnameOut.wind = {'ccmp', 'era5'};
if A.bubbles
    fnameOut.param = {'quad', 'bubbles'};
else
    fnameOut.param = {'quad'};
end
fnameOut.all= {'flux','A','U','B'};

for fw = 1 : length(fnameOut.wind)
    for fp = 1 : length(fnameOut.param)
        for fc = 1 : length(fnameOut.all)
            fn2o_annual.(fnameOut.param{fp}).(fnameOut.wind{fw}).(fnameOut.all{fc}) ...
                = nanmean(fn2o.(fnameOut.param{fp}).(fnameOut.wind{fw}).(fnameOut.all{fc}),3);
            fn2o_seasonal.(fnameOut.param{fp}).(fnameOut.wind{fw}).(fnameOut.all{fc}) ...
                = fn2o.(fnameOut.param{fp}).(fnameOut.wind{fw}).(fnameOut.all{fc}) - ...
                repmat(fn2o_annual.(fnameOut.param{fp}).(fnameOut.wind{fw}).(fnameOut.all{fc}),1,1,12);
        end
    end
end
