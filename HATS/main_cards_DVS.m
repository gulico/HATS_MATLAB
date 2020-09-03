%=====================================================
%  HATS
%=====================================================

%% 
clear; clc; close;
addpath('../data/');
addpath('../events/');
addpath ('../usages/LinearSVM/');
addpath ('../usages/'); 
% accumulate the events into segments or not 是否将事件累积为分段
% isSkipProceeEvent = false;

dataSet = 'cards_100_seq';
% rand('state',4);% to reproduce our result 重现我们的结果？

% nEvt  = 100;       % 每个帧都包含nEvt事件。each frame consists of nEvt events.
tr_rate = 80;      % 将tr_rate百分比数据集用于培训目的，并将其余数据用于测试 use tr_rate percent data set for training purpose, and use the rest for testing
nRounds = 100;      % k折交叉验证 k-fold cross validation
img_width = 32;    % 列数 the number of columns
img_hight = 32;    % 行数the number of rows
n_class = 4;      % 分十类

K = 7;
R = 7;
index = containers.Map({-1,1},{1,2});%极性映射
width = 35;
heigth = 35;
n_polarities = 2;% 极性个数
cell_width = floor(width/K);
cell_height = floor(heigth/K);
n_cells = cell_width*cell_height;
% set path
% dir_data = fullfile('../data/', [dataSet '_nEvt' num2str(nEvt)]);
dir_event = fullfile('../events/',dataSet);

load(dir_event);% 加载未分段数据
%% 

% 训练

accuracy = zeros(1,nRounds);%准确率数组
tr_time = zeros(1,nRounds);%训练时间
tt_time = zeros(1,nRounds);%测试时间
tr_HATS_time = zeros(1,nRounds);%训练BOE时间
tt_HATS_time = zeros(1,nRounds);%测试BOE时间

for j = 1:nRounds %k折交叉验证

    % 将数据分为两部分进行培训和测试 split the data into two parts for training and testing
    idx = randperm (length(Labels));% 将所有样本随机排列，存储索引序号
    tr_num = round(length(Labels)*tr_rate/100);% 训练样本个数
    tt_num = length(Labels) - tr_num;% 测试样本个数
    tr_idx = idx(1:tr_num);% 训练样本序列
    tt_idx = idx(tr_num+1:end);% 测试样本序列

    tr_data = cell(1,tr_num);
    tt_data = cell(1,tt_num);
    tr_labels = zeros(1,tr_num);
    tt_labels = zeros(1,tt_num);

    model_set = zeros(n_cells*n_polarities*(2*R+1)*(2*R+1),tr_num);

    for i = 1:length(tr_idx)% 遍历训练样本
        tr_data(1,i) = CINs(1,tr_idx(i));% 将训练样本逐帧放入tr_data数组
        tr_labels(1,i) = Labels(1,tr_idx(i));% 将训练样本的序号按行形式加入tr_labels数组
    end
    for i = 1:length(tt_idx)% 遍历测试样本，操作同上
        tt_data(1,i) = CINs(1,tt_idx(i));
        tt_labels(1,i) = Labels(1,tt_idx(i));  
    end

    % 初始化hats类
    hats = HATS();

    % 训练
    tic;
    for i = 1:length(tr_idx)
        % fprintf("lable:%f\n",tr_labels(1,i));
        events = tr_data{1,i};
        hats = hats.reset();
        hats = hats.process_all(events);
        features = reshape(hats.histograms,[],1);%列
        model_set(:,i) = features;
    end
    tr_HATS_time(j);
    
    tic;
    SVMModel = train(tr_labels',sparse(model_set'));%按行，一行一个特征
    tr_time(j) = toc;

    tt_features  = zeros(n_cells*n_polarities*(2*R+1)*(2*R+1),tt_num);
    
    tic;
    for i = 1:length(tt_idx)
        %fprintf("real lable:%f",tt_labels(1,i));
        events = tt_data{1,i};
        hats = hats.reset();
        hats = hats.process_all(events);
        features = reshape(hats.histograms,[],1);
        tt_features(:,i) = features;
        %[pred(i,1)] = predict(tt_labels(1,i)', sparse(features'), SVMModel);
        %fprintf("real lable:%f\n",pred);
    end
    tt_HATS_time(j) = toc;
    
    tic;
    [pred] = predict(tt_labels', sparse(tt_features'), SVMModel);% 预测
    tt_time(j) = toc;
    accuracy(j) = sum(pred==tt_labels')/length(pred);

    fprintf('The recognition rate is %f\n', accuracy(j));
end

fprintf('\n=========================================================\n');
fprintf('The mean recognition rate is about %f and the std is about %f\n', mean(accuracy), std(accuracy));
fprintf('The mean hats training time for feature extraction is about %f and the std is about %f\n', mean(tr_HATS_time), std(tr_HATS_time));
fprintf('The mean hats testing time for feature extraction is about %f and the std is about %f\n', mean(tt_HATS_time), std(tt_HATS_time));

fprintf('The mean training time for feature extraction is about %f and the std is about %f\n', mean(tr_time), std(tr_time));
fprintf('The mean testing time for feature extraction is about %f and the std is about %f\n', mean(tt_time), std(tt_time));

save(['HATS_' dataSet '_trn' num2str(tr_rate) '_nRnd' num2str(nRounds)]);