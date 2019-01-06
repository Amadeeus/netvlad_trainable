function net= loadNet(netID, layerName)
    if nargin<2, layerName= '_relja_none_'; end
    
    switch netID
        case 'vd16'
            netname= 'imagenet-vgg-verydeep-16.mat';
        case 'vd19'
            netname= 'imagenet-vgg-verydeep-19.mat';
        case 'caffe'
            netname= 'imagenet-caffe-ref.mat';
        case 'places'
            netname= 'places-caffe.mat';
        case 'vd16_pitts30k'
            netname= 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white.mat';
        otherwise
            error( 'Unknown network ID', netID );
    end
    
    paths= localPaths();
    if strcmp(netID, 'vd16_pitts30k')
        net= load( sprintf('%s%s', paths.pretrainedCNNs, netname), 'net');
        net= net.net
        %net= load( fullfile(paths.pretrainedCNNs, netname), 'net');
    else
        net= load( fullfile(paths.pretrainedCNNs, netname));
    end
    
    net= vl_simplenn_tidy(net); % matconvnet beta17 or newer is needed
    
    if isfield(net.meta, 'classes')
        net.meta= rmfield(net.meta, 'classes');
    end
    
    if ~strcmp(layerName, '_relja_none_')
        net= relja_cropToLayer(net, layerName);
        layerNameStr= ['_', layerName];
    else
        layerNameStr= '';
    end
    net= relja_swapLayersForEfficiency(net);
    
    net.meta.netID= netID;
    
    net.meta.sessionID= sprintf('%s_offtheshelf%s', netID, layerNameStr);
    net.meta.epoch= 0;
    
end
