clear all 

%% Parameter Init
seq_ids_set_3 = { ... 
    '2014-12-09-13-21-02', '2015-02-03-08-45-10', ...
    '2015-03-10-14-18-10', '2015-08-13-16-02-58', ...
    '2014-07-14-14-49-50', '2014-12-12-10-45-15', ...
    '2015-05-19-14-06-38'}'; 
 
seq_ids_set_4 = { ... 
    '2014-12-09-13-21-02', '2015-02-03-08-45-10', ...
    '2015-03-10-14-18-10', '2015-08-13-16-02-58', ...
    '2014-07-14-14-49-50', '2014-12-12-10-45-15', ...
    '2015-05-19-14-06-38', '2014-11-18-13-20-12', ...
    '2014-11-28-12-07-13', '2014-12-02-15-30-08', ...
    '2015-02-13-09-16-26'}'; 

tvt = 'val'
posDistThr = 25; 
nonTrivPosDistSqThr = 100; 
query_ratio = 0.2;

%% Parse dataset 
dataset = oxfordRobotCarParser(tvt, seq_ids_set_3, posDistThr, nonTrivPosDistSqThr); 

%% Split into query and database images, build dbStruct
dbStruct.whichSet = dataset.whichSet;
dbStruct.posDistThr = posDistThr;
dbStruct.nonTrivPosDistSqThr = nonTrivPosDistSqThr;
dbStruct.posDistSqThr = posDistThr * posDistThr;

qImageFns = {};
dbImageFns = {};
utmQ = [];
utmDb = [];
for j = 1:length(dataset.seqTimeStamp) 
    mask = dataset.seqIdx == j;
    image_filenames = dataset.imageFns(mask, :);
    image_positions = dataset.utm(mask, :);
    num_images = size(image_filenames, 1);
    num_queries = round(query_ratio * num_images);
    num_dbs = num_images - num_queries;
    seq_query_mask = randsample(num_images, num_queries);
    seq_db_mask = setdiff(1:num_images, seq_query_mask);
    qImageFns = [qImageFns; image_filenames(seq_query_mask, :)];
    dbImageFns = [dbImageFns; image_filenames(seq_db_mask, :)];
    utmQ = [utmQ; image_positions(seq_query_mask, :)];
    utmDb = [utmDb; image_positions(seq_db_mask, :)];
end

dbStruct.qImageFns = qImageFns;
dbStruct.dbImageFns = dbImageFns;
dbStruct.numImages = size(dbImageFns, 1);
dbStruct.numQueries = size(qImageFns, 1);
dbStruct.utmQ = utmQ.';
dbStruct.utmDb = utmDb.';

%%
paths = localPaths();
specDir = paths.dsetSpecDir;
save([specDir sprintf('robotcar_%s', dbStruct.whichSet)], 'dbStruct')


%% plot image positions 
figure(1); 
positions = dataset.utm(dataset.seqIdx == 1, :);
plot(positions(:, 1), positions(:, 2)); 
hold on;
positions2 = dataset.utm(dataset.seqIdx == 3, :);
plot(positions2(:, 1), positions2(:, 2)); 
axis equal; 
 
%% Testing set: Easting > 620105 
figure(2); 
plotPositions2D(dataset.utm(dataset.seqIdx == 1 & ... 
    dataset.utm(:, 2) > 620105, 1:2)); 
axis equal; 
 
%% Validation set: Easting < 620105 && Northing > 573600 
% figure(3); 
hold on; 
plotPositions2D(dataset.utm(dataset.seqIdx == 1 & ... 
    dataset.utm(:, 2) < 620105 ... 
    & dataset.utm(:, 1) > 5735800, 1:2)); 
axis equal; 
 
%% Training set: Easting < 620105 && Northing > 573600 
% figure(4); 
hold on; 
plotPositions2D(dataset.utm(dataset.seqIdx == 1 & ... 
    dataset.utm(:, 2) < 620105 & dataset.utm(:, 1) < 5735800, 1:2)); 
axis equal;


