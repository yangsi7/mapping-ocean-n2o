
% Add paths of script (assuming you are in its directory)
pathToScript = [pwd,'/'];
addpath(genpath(pathToScript));

% Load predictors
var=load([pathToScript,'/surf_predictors_april3.mat']);

% Get masks and coords
wcoord = getWOAcoord(0.25);
mask = getWOAmask(0.25,'xyt');
[dxi,dyi,dti] = ind2sub(size(mask),find(ones(size(mask))));
msk=load([pathToScript,'/woa0p25_basins.mat']);

% Set paths for the various N2O compilations
load([pathToScript,'/validconfig_0513.mat']);
comppath = [pathToScript,'/compilation_gridded_l0p02_180719.mat'];
compathall=[pathToScript,'/compilation_gridded_all_180719.mat]'

% Create netcdf for reconstructed dn2o
var.varnames = {'dn2o'};
var.dims={'xytp'};
var.snames={'dn2o'};
var.lnames={'dn2o'};
var.units={'ppb'};
outfile=[pathToScript,'dn2o_RF.nc';
CreateNcfile(outfile,var, 'woa18', 'clim','comp',5)

bmsk.peru = repmat(msk.bmsk.peru,1,1,12);
bmsk.peru(~isnan(bmsk.peru))=1;
[wweights] = getweightPeru(bmsk,mask);

% Get npar workers in parallel
npar = 12;
parpool(npar)
paroptions = statset('UseParallel',true);

for v = 1 : 100
    %%%% Training and validation %%%%
    % % % % % % % % % % % % % % % % % 

    %randomly select predictor combination
    pk=randperm(length(predcomb.keys));
    display(['Predicting ', num2str(v), ' out of 100']);
    fnames = init_prednames_0513(predcomb.keys{pk(1)});

    % get pred and target
    [pred, target] = init_RF_gridded_0804(comppath,var,fnames);
    [predPeru, targetPeru] = init_RF_gridded_0804(compathall,var,fnames,'mask',bmsk.peru);

    % Combined clim and training predictors into one matrice (Nxp)
    cmb = combinePreds(fnames,'train', pred, 'clim', var,'mode', 'RF');
    cmbPeru = combinePreds(fnames,'train', predPeru, 'clim', var,'mode', 'RF');

    % Set number of trees in forest (random between 100 and 400)
    treestart=200;treerange=200;
    ntrees = randperm(treerange)+treestart;
    % Set MinLeafsize randomly between 1 and 4
    mlsrange=4;
    MinLeafsize = randperm(mlsrange);

    % Train ensemble of regression trees
    Mdl = TreeBagger(ntrees(1),cmb.train,target.n2o,'Method','regression',...
      'OOBPrediction','On','MinLeafsize',MinLeafsize(1),'Options',paroptions);
    MdlPeru = TreeBagger(ntrees(1),cmbPeru.train,targetPeru.n2o,'Method','regression',...
      'OOBPrediction','On','MinLeafsize',MinLeafsize(1),'Options',paroptions);

    % Calculate out of bag R2 and RMSE
    dn2oNT(v).stats = RFstats_0513(Mdl, cmb.train, target.n2o,'oob',1);
    dn2oNTPeru(v).stats = RFstats_0513(MdlPeru, cmbPeru.train, targetPeru.n2o,'oob',1);

    %%%% Prediction %%%%
    % % % % % % % % % % %

    % Split data for 12 workers
    % (1) get indexes
    for i = 1 : 12  
        i
        idxclim{i} = find(dti==i & ~isnan(cmb.clim(:,1)));
        tmpclim{i} = cmb.clim(idxclim{i},:);
    end
    % (2) Predict for each subset 
    parfor t = 1 : 12
        t
        RFout{t} = predict(Mdl,tmpclim{t});
    end
    % (3) concatenate all subset into one martix
    tmpdn2o = nan(size((cmb.clim(:,1))));
    for t = 1 : 12
        t
        tmpdn2o(idxclim{t}) = RFout{t};
    end
    tmpdn2o = reshape(tmpdn2o,wcoord.diml(1),wcoord.diml(2),12);

    % Combine Peru and Global solution
    idxPeru=find(~isnan(bmsk.peru));
    tmpdn2oPeru=predict(MdlPeru,cmb.clim(idxPeru,:));
    tmpweightsPeru=repmat(wweights.Peru,1,1,12);
    tmpdn2o_merge = tmpdn2o.*repmat(wweights.Global,1,1,12);tmpdn2o_merge(idxPeru)=tmpdn2o_merge(idxPeru)+tmpdn2oPeru.*tmpweightsPeru(idxPeru);

    % Write to netcdf
    ncwrite(outfile, 'dn2o', tmpdn2o_merge,[1 1 1 v])
end

% save oob predictions and statistics
save([pathToScript,'/dn2o_RF.mat'],'dn2oNT','dn2oNTPeru');
