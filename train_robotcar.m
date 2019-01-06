%% Set the MATLAB paths
clear all;
setup;

%%
dbTrain= dbOxfordRobotCar('train');
dbVal= dbOxfordRobotCar('val');
lr= 0.0001;

netID= 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white';
paths= localPaths();
load( sprintf('%s%s.mat', paths.ourCNNs, netID), 'net' );
net= relja_simplenn_tidy(net);

%% --- Train the VGG-16 network +w NetVLAD, tuning down to conv5_1
sessionID= trainWeakly(dbTrain, dbVal, ...
    'netID', 'vd16_pitts30k', 'layerName', '_relja_none_', 'backPropToLayer', 'conv5_3', ...
    'method', 'vlad_preL2_intra', 'learningRate', lr, ...
    'batchSize', 10, ...
    'useGPU', true, 'numThreads', 12, ...
    'doDraw', true);

%% Get the best network
% This can be done even if training is not finished, it will find the best network so far
[~, bestNet]= pickBestNet(sessionID);

% Either use the above network as the image representation extractor (do: finalNet= bestNet), or do whitening (recommended):
%finalNet= addPCA(bestNet, dbTrain, 'doWhite', true, 'pcaDim', 4096);