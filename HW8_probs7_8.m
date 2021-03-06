%  HW 8 problems 7, 8 

% Initialization
clear ; close all; clc
K = 10; % K-fold cross-validation
N = 100; % Number of runs
C = [0.0001, 0.001, 0.01, 0.1, 1];
numC = length(C);
Q = 2; % degree of the kernel polynomial

% set path to libsvm
addpath('~/Documents/Matlab/libsvm-3.20/matlab/');

% read in the train and test data
trainData = double(csvread('features.train.txt', 0, 0));
testData = double(csvread('features.test.txt', 0, 0));
trainlabels = trainData(:,1);
trainfeatures = trainData(:, 2:end);
testlabels = testData(:,1);
testfeatures = testData(:, 2:end);

%%%%%%%%%%%%%%%%%1 vs. 5 classifier
% Subset the data to include data with 1 or 5 only
indicesTrain15 = find(trainlabels == 1 | trainlabels == 5);
trainData15 = trainData(indicesTrain15, :);
indicesTest15 = find(testlabels == 1 | testlabels == 5);
testData15 = testData(indicesTest15, :);

trainlabels15 = trainData15(:,1);
trainfeatures15 = trainData15(:, 2:end);
testlabels15 = testData15(:,1);
testfeatures15 = testData15(:, 2:end);

testlabels15(testlabels15 == 1) = 1;
testlabels15(testlabels15 == 5) = -1;
trainlabels15(trainlabels15 == 1) = 1;
trainlabels15(trainlabels15 == 5) = -1;

Ecv = zeros(N, numC);
minEcvIndex = zeros(N,1);

for i = 1:N
    % Generate random permutaiton of the training data matrix
    trainData15rand = trainData15(randperm(length(trainlabels15)), :);
    for j=1:numC
        svmOpts = sprintf('-t 1 -d %f -r 1 -g 1 -c %f -v %u -q', Q, C(j), K);
        model = svmtrain(trainData15rand(:,1), trainData15rand(:,2:end), svmOpts);
        Ecv(i,j) = (100 - model)/100;
    end;
    [~, minEcvIndex(i,1)] = min(Ecv(i,:));
end;

% Find index of maximum occurrence of minimum Ecv
z = tabulate(minEcvIndex);
[~, Cindex] = max(z(:,2));
mostFrequentC = C(Cindex)

% Average Ecv for most frequent C
meanEcv = mean(Ecv(:,Cindex))
