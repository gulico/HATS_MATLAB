%=====================================================
%  HATS
%=====================================================

%% 
clear; clc; close;
addpath('../data/');
addpath('../events/');
addpath ('../usages/LinearSVM/');
addpath ('../usages/'); 
% accumulate the events into segments or not �Ƿ��¼��ۻ�Ϊ�ֶ�
% isSkipProceeEvent = false;

dataSet = 'cards_100_seq';
% rand('state',4);% to reproduce our result �������ǵĽ����

% nEvt  = 100;       % ÿ��֡������nEvt�¼���each frame consists of nEvt events.
tr_rate = 80;      % ��tr_rate�ٷֱ����ݼ�������ѵĿ�ģ����������������ڲ��� use tr_rate percent data set for training purpose, and use the rest for testing
nRounds = 100;      % k�۽�����֤ k-fold cross validation
img_width = 32;    % ���� the number of columns
img_hight = 32;    % ����the number of rows
n_class = 4;      % ��ʮ��

K = 7;
R = 7;
index = containers.Map({-1,1},{1,2});%����ӳ��
width = 35;
heigth = 35;
n_polarities = 2;% ���Ը���
cell_width = floor(width/K);
cell_height = floor(heigth/K);
n_cells = cell_width*cell_height;
% set path
% dir_data = fullfile('../data/', [dataSet '_nEvt' num2str(nEvt)]);
dir_event = fullfile('../events/',dataSet);

load(dir_event);% ����δ�ֶ�����
%% 

% ѵ��

accuracy = zeros(1,nRounds);%׼ȷ������
tr_time = zeros(1,nRounds);%ѵ��ʱ��
tt_time = zeros(1,nRounds);%����ʱ��
tr_HATS_time = zeros(1,nRounds);%ѵ��BOEʱ��
tt_HATS_time = zeros(1,nRounds);%����BOEʱ��

for j = 1:nRounds %k�۽�����֤

    % �����ݷ�Ϊ�����ֽ�����ѵ�Ͳ��� split the data into two parts for training and testing
    idx = randperm (length(Labels));% ����������������У��洢�������
    tr_num = round(length(Labels)*tr_rate/100);% ѵ����������
    tt_num = length(Labels) - tr_num;% ������������
    tr_idx = idx(1:tr_num);% ѵ����������
    tt_idx = idx(tr_num+1:end);% ������������

    tr_data = cell(1,tr_num);
    tt_data = cell(1,tt_num);
    tr_labels = zeros(1,tr_num);
    tt_labels = zeros(1,tt_num);

    model_set = zeros(n_cells*n_polarities*(2*R+1)*(2*R+1),tr_num);

    for i = 1:length(tr_idx)% ����ѵ������
        tr_data(1,i) = CINs(1,tr_idx(i));% ��ѵ��������֡����tr_data����
        tr_labels(1,i) = Labels(1,tr_idx(i));% ��ѵ����������Ű�����ʽ����tr_labels����
    end
    for i = 1:length(tt_idx)% ������������������ͬ��
        tt_data(1,i) = CINs(1,tt_idx(i));
        tt_labels(1,i) = Labels(1,tt_idx(i));  
    end

    % ��ʼ��hats��
    hats = HATS();

    % ѵ��
    tic;
    for i = 1:length(tr_idx)
        % fprintf("lable:%f\n",tr_labels(1,i));
        events = tr_data{1,i};
        hats = hats.reset();
        hats = hats.process_all(events);
        features = reshape(hats.histograms,[],1);%��
        model_set(:,i) = features;
    end
    tr_HATS_time(j);
    
    tic;
    SVMModel = train(tr_labels',sparse(model_set'));%���У�һ��һ������
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
    [pred] = predict(tt_labels', sparse(tt_features'), SVMModel);% Ԥ��
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