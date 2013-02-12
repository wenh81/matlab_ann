clear all
maxNumCompThreads(16);

data = loaddata('mnistclassify');

% n = netdt_dropout([300 300 300], data);
% n = netdt_dropout([1000 500 100], data);
% n = netdt_dropout([5000 1000], data);
% n = netdt_dropout([1000 100 1000], data);
% n = netdt_dropout([100], data);
% n = netdt_dropout([8 8 8 8 8], data);


% n = convert2threshold(n);
% Convert hidden layers to threshold.
for i = 1:n.nlayers-1
    n.layers{i}.TransferFcn = 'threshold';
    n.layers{i}.ErrorFcn = 'Hamming';
end
% Last layer
n.layers{end}.ErrorFcn = 'MulticlassCrossEntropyError'; % 
n.ErrorFcn = 'MulticlassCrossEntropyError';
n.ErrorFcn_Targets = 'SumSquaredError';  % Speeds up target finding
% n.ErrorFcn_Targets = 'MulticlassCrossEntropyError';  % Speeds up target finding


n.initscale = 1;
n = initialize(n);
n.nsamp = 0;
%n.mu = 0.01;
n.momentum = 0;
n.nu = 1e-4;%1e-6; %1e-5;

n.batchsize = 100;
n.notdrop = 10;
n.nupdate = 10;
n.nepoch = 100;

n
n = train(n, data);
savenet(n);

% % Save results to file.
% resultsdir = 'results';
% [~,~,~] = mkdir(resultsdir);
% save([resultsdir, '/', n.param2str], 'n');
% 
% % Analysis
% X = getActivations(n, data.input);
% imagesc([X{1}, X{2}, X{end}])