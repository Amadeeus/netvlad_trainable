classdef oxfordRobotCarParser<handle 
     
    properties 
        imageFns; 
        imageTimeStamp; 
        posDisThr; 
        seqIdx; 
        seqTimeStamp; 
        utm; 
        nonTrivPosDistThr; 
        whichSet;
        tvt;
    end 
     
    methods 
        function obj= oxfordRobotCarParser(whichSet, seqTimeStamp, posDisThr, ... 
                nonTrivPosDistThr) 
                  
            obj.posDisThr= posDisThr; 
            obj.nonTrivPosDistThr= nonTrivPosDistThr; 
            
            assert( ismember(whichSet, {'train', 'val', 'test'}) );
            
            if strcmp(whichSet, 'train')
                obj.tvt= 'training';
            elseif strcmp(whichSet, 'val') 
                obj.tvt= 'validation';
            elseif strcmp(whichSet, 'test')
                obj.tvt= 'testing';
            end
            
            obj.whichSet= whichSet;
            
            paths = localPaths(); 
            datasetRoot= paths.dsetRootRobotCar; 
            subsetRoot = paths.subsetsRootRobotCar;
            
            datasetPathList = cell(size(seqTimeStamp));  
            for i = 1:length(seqTimeStamp) 
                datasetPathList{i} = {[datasetRoot seqTimeStamp{i} ... 
                    '/rect_scaled_rgb_images/left/']}; 
            end 
             
            imageFnsAllSeq = []; 
            seqIdx = []; 
            for j = 1:length(datasetPathList) 
                dir_contents = dir(char(fullfile(datasetPathList{j}, '*.jpg'))); 
                path = [subsetRoot seqTimeStamp{j} '/' 'image_index_' obj.tvt '_subset.txt'];
                mask_file = fopen(path);
                mask = cell2mat(textscan(mask_file, '%u'));
                mask = mask + 1
                fclose(mask_file); 

                imageFoldersSingleSeq = char(dir_contents.folder); 
                imageFoldersSingleSeq = imageFoldersSingleSeq(mask, :);
                fnames = {dir_contents.name};
                fnames = sort(fnames);
                imageNamesSingleSeq = char(fnames);
                imageNamesSingleSeq = imageNamesSingleSeq(mask, :);
                imageFnsSingleSeq = cellstr(strcat(string(... 
                    imageFoldersSingleSeq(:,end-46:end)), ... 
                    '/', string(imageNamesSingleSeq))); 
                imageFnsAllSeq = [imageFnsAllSeq; imageFnsSingleSeq]; 
                seqIdx = [seqIdx; j*ones(length(imageFnsSingleSeq), 1)]; 
            end 
             
            obj.imageFns = imageFnsAllSeq; 
            obj.seqIdx = seqIdx; 
            obj.seqTimeStamp = seqTimeStamp; 
            obj.loadUTMPosition(); 
        end 
         
        function loadUTMPosition(obj) 
            % Estimate image positions by applyiimageTimeStampng linear interpolation on GPS 
            % measurements based on image timestamps 
            paths = localPaths; 
            imageGPSPositions = []; 
            datasetRoot = paths.dsetRootRobotCar;
            subsetRoot = paths.subsetsRootRobotCar;
            % gpsDataRoot = paths.gpsDataRootRobotCar;          
            
            for i = 1:length(obj.seqTimeStamp) 
                % Load GPS+INS measurements. 
                % ins_file = [gpsDataRoot obj.seqTimeStamp{i} '/gps/ins.csv']; 
                t_wc_file = [datasetRoot obj.seqTimeStamp{i} '/T_W_C.txt'];
                path = [subsetRoot obj.seqTimeStamp{i} '/' 'image_index_' obj.tvt '_subset.txt'];
                mask_file = fopen(path);
                mask = cell2mat(textscan(mask_file, '%u'));
                mask = mask + 1;
                fclose(mask_file); 
                
                imageGPSPositionsSingleSeq = ... 
                    getUTMPosition(t_wc_file); 
                imageGPSPositionsSingleSeq = imageGPSPositionsSingleSeq(mask, :);
                imageGPSPositions  = ... 
                    [imageGPSPositions; imageGPSPositionsSingleSeq]; 
            end 
            % Store keyframe position estimate from GPS+INS measurements 
            obj.utm = imageGPSPositions; 
        end 
    end 
end 

