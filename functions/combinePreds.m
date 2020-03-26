function cmb  = combinePred(fnames,varargin)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% This function is used as part of the Random Forest 
% and Neural Network prediction of N2O
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% This function combines all the predictors into one big matrice
    % % % output:
    % cmb.clim:   combined climatological predictor 
    % cmb.train:   combined training predictor
    % 
    % % % arguments
    % fnames:  cell array containing the names of the climatological 
    %          (fnames.clim) and training variables(fnames.predict)
    % optional 'clim':   structure containing the climatological variables
    % optional 'train':  structure containing the training variables
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Simon Yang, UCLA, April 4th 2019
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

A.mode = 'NN';
A.train = [];
A.clim = [];
A=parse_pv_pairs(A,varargin);

if strcmp(A.mode,'NN')
    if ~isempty(A.train)
        cmb.train = A.train.([fnames.train{1},'_scaled'])(:)';
    end
    if ~isempty(A.clim)
        cmb.clim = A.clim.([fnames.clim{1},'_scaled'])(:)';
    end

    for f = 2 : length(fnames.train)
        if ~isempty(A.train)
            cmb.train = [cmb.train; A.train.([fnames.train{f},'_scaled'])(:)'];
        end
        if ~isempty(A.clim)
            cmb.clim = [cmb.clim; A.clim.([fnames.clim{f},'_scaled'])(:)'];
        end
    end
    if ~isempty(A.train)
        A.train=A.train'';
    end
    if ~isempty(A.clim)
        A.clim=A.clim';
    end
elseif strcmp(A.mode,'RF')
    if ~isempty(A.train)    
        cmb.train = A.train.(fnames.train{1})(:)';
    end
    if ~isempty(A.clim)
        cmb.clim = A.clim.(fnames.clim{1})(:)';
    end
    
    for f = 2 : length(fnames.train)
        if ~isempty(A.train)
            cmb.train = [cmb.train; A.train.(fnames.train{f})(:)'];
        end
        if ~isempty(A.clim)
            cmb.clim = [cmb.clim; A.clim.(fnames.clim{f})(:)'];
        end
    end
    if ~isempty(A.train)    
        cmb.train=cmb.train';
    end
    if ~isempty(A.clim)
        cmb.clim=cmb.clim';
    end
end
