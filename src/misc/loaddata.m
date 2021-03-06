function data = loaddata(dataname, seed)
% Convenience function for loading datasets by name.
% Output: struct with fields .input, .target, .testinput, .testtarget

% Initialize random seed.
if nargin == 1
    seed = 1;
end
s = RandStream('mt19937ar', 'Seed', seed);
RandStream.setGlobalStream(s);

switch dataname
    case 'mnist1000'
        load('data/mnist/mnist1000.mat')
    case 'iris2class'
        load('../data/iris/iris2class.mat')
        data = randomOrder(data); %#ok<NODEF>
        data = splitForTestSet(data, 20);
    case 'jan8_processed'
        background = importdata('../atlas/data/2013-01-08/bg.txt');
        signal = importdata('../atlas/data/2013-01-08/signal.txt');
        data.input  = [background; signal];
        data.target = [zeros(size(background, 1), 1); ones(size(signal, 1), 1)];
        data = randomOrder(data);
        % Process
        for j = 1:size(data.input, 2)
            vec = data.input(:, j);
            if min(vec) < 0
                % Data is presumed to be Gaussian or uniform -- center and standardize
                vec = vec - mean(vec);
                vec = vec / std(vec);
            elseif max(vec) > 1
                % Data is presumed to be exponential -- set mean to 1.
                vec = vec / mean(vec);
            end
            data.input(:, j) = vec;
        end
        data = splitForTestSet(data, 10000);
    case 'jan8_processed_lowlevel21'
        % Only use the first 21 'lowlevel' features.
        data = loaddata('jan8_processed');
        data.input = data.input(:,1:21);
        data.testinput = data.testinput(:,1:21);
    case 'jan8_processed_highlevel7'
        % Only use the last 7 'highlevel' features.
        data = loaddata('jan8_processed');
        data.input = data.input(:,22:28);
        data.testinput = data.testinput(:,22:28);
    case 'testauto'
        data = load_simulated(10, 100, 100, 0.5, 0);
        %data = randomOrder(data);
        data = setupAuto(data);
    case 'testnoisyauto'
        data = load_simulated(10, 100, 100, 0.5, 0.05);
        data = randomOrder(data);
        data = setupAuto(data);
    case 'test'
        data = load_simulated(10, 100, 100, 0.5, 0);
    case 'testnoisy'
        data = load_simulated(10, 100, 100, 0.5, 0.05);
    case 'xor'
        data.input = randi([0,1], 1000, 2);
        data.target = double(xor(data.input(:,1), data.input(:,2)));
     
    case 'parity4'
        % Parity function.
        data.input = randi([0,1], 1000, 4);
        data.target = mod(sum(data.input, 2), 2);
    case 'parity8'
        % Parity function.
        data.input = randi([0,1], 10000, 8);
        data.target = mod(sum(data.input, 2), 2);
        data.testinput = randi([0,1], 1000, 8);
        data.testtarget = mod(sum(data.testinput, 2), 2);
    case 'parity16'
        % Parity function.
        data.input = randi([0,1], 10000, 16);
        data.target = mod(sum(data.input, 2), 2);
        data.testinput = randi([0,1], 1000, 16);
        data.testtarget = mod(sum(data.testinput, 2), 2);
    case 'endand128'
        % Target = AND(X(1), X(end))
        data.input = randi([0,1], 1000, 128);
        data.target = and(data.input(:,1), data.input(:,end)); 
    case 'simulated1000pp02'
        data = load_simulated(10, 100, 100, 0.02, 0.00);
        %data = randomOrder(data);
        data = setupAuto(data);
    case 'singlepp01'
        data = rand(1000, 1) < 0.01;
        data = setupAuto(data);
    case 'singlepp5'
        data = rand(1000, 1) < 0.5;
        data = setupAuto(data);
    case 'doublepp5'
        data = rand(1000, 2) < 0.5;
        data = setupAuto(data);
    case 'tenpp5'
        data = rand(1000, 10) < 0.5;
        data = setupAuto(data);
    % MNIST
    case 'mnist'
        % MNIST as struct
        data = load('mnist.mat');
%         % Load MNIST data.
%         warning('off','MATLAB:dispatcher:pathWarning')
%         path(path, '../data/mnist');
%         path(path, '../../data/mnist'); % One of these should exist...
%         warning('on','MATLAB:dispatcher:pathWarning')
%         [batchdata, testbatchdata, batchtargets, testbatchtargets] = makebatches();    % Loads batchdata and testbatchdata.
%         % Make training data.
%         nbatches = 600; % 600 is everything.
%         data.input  = batchmatrix2full(batchdata(:,:,1:nbatches));
%         data.target = batchmatrix2full(batchtargets(:,:,1:nbatches));    
%         %data = randomOrder(data);         % Randomize order
%         % Make single matrix for test data. Batch again later if need be.
%         ntestbatches = 100; % 600 train, 100 test.
%         data.testinput  = batchmatrix2full(testbatchdata(:,:,1:ntestbatches));
%         data.testtarget = batchmatrix2full(testbatchtargets(:,:,1:ntestbatches));
    case 'mnistclassify' % deprecated
        data = loaddata('mnist'); 
    case 'mnistclassify_new'
        % Just a temp hack.
        data = loaddata('mnistclassify');
    case 'mnist_semi_10000'
        % MNIST, with only 10k labeled training examples.
        data = loaddata('mnistclassify');
        N = 10000;
        data.unlabeled = data.input(N+1:end,:);
        data.input = data.input(1:N,:);
        data.target = data.target(1:N,:);
    case 'mnist_semi_1000'
        % MNIST, with only 10k labeled training examples.
        data = loaddata('mnistclassify');
        N = 1000;
        data.unlabeled = data.input(N+1:end,:);
        data.input = data.input(1:N,:);
        data.target = data.target(1:N,:);
    case 'mnist_semi_100'
        % MNIST, with only 10k labeled training examples.
        data = loaddata('mnistclassify');
        N = 100;
        data.unlabeled = data.input(N+1:end,:);
        data.input = data.input(1:N,:);
        data.target = data.target(1:N,:);
    case 'mnist_semi_test'
        % MNIST, with only 1000 labels, some unlabeled.
        data = loaddata('mnistclassify');
        N = 1000;
        data.unlabeled = data.input(N+1:N+1000,:);
        data.input = data.input(1:N,:);
        data.target = data.target(1:N,:);
        data.testinput = data.testinput(1:N,:);
        data.testtarget = data.testtarget(1:N,:);
        
    case 'mnistauto'
        data = loaddata('mnistclassify');
        data.target = data.input;
        data.testtarget = data.testinput;
    case 'mnistautobinary'
        data = loaddata('mnistauto');
        data.input = data.input >= 0.5;
        data.target = data.target >= 0.5;
        data.testinput = data.testinput >= 0.5;
        data.testtarget = data.testtarget >= 0.5;
    case 'mnistautobinary1000'
        data = loaddata('mnistautobinary');
        data = getFirstN(data, 1000);
    case 'mnistautobinary5000'
        data = loaddata('mnistautobinary');
        data = getFirstN(data, 5000);
    case 'mnistautobinary10000'
        data = loaddata('mnistautobinary');
        data = getFirstN(data, 10000);
    case 'mnistauto1000'
        data = loaddata('mnistauto');
        data = getFirstN(data, 1000);
    case 'mnistauto5000'
        data = loaddata('mnistauto');
        data = getFirstN(data, 5000);
    case 'mnistclassify10'
        data = loaddata('mnistclassify');
        data = getFirstN(data, 10);
    case 'mnistclassify100'
        data = loaddata('mnistclassify');
        data = getFirstN(data, 100);
    case 'mnistclassify1000'
        data = loaddata('mnistclassify');
        data = getFirstN(data, 1000);
    case 'mnistclassify5000'
        data = loaddata('mnistclassify');
        data = getFirstN(data, 5000);
    case 'mnistclassify10000'
        data = loaddata('mnistclassify');
        data = getFirstN(data, 10000);
    
    % 1000 observations, autoencoding
    case 'simulated1000'
        data = load_simulated(10, 100, 100, 0.5, 0.05);
        %data = randomOrder(data);
        data = setupAuto(data);
    case 'usps1000'
        temp = loaddata_ae('usps');
        temp = randomOrder(temp);
        temp = temp(1:1000, :);
        data = setupAuto(temp);
    case 'olivettifaces'
        % 400 faces, 64x64 features, reduce to 28x28
        load('/home/pjsadows/ml/data/olivettifaces/olivettifaces.mat');
        faces = faces';
        [m, n] = size(faces);
        % Reduce image size.
        reduction = 28 / 64; % Reduction of orig image (64x64)
        data = zeros(m, 28^2);
        for i = 1:m
            temp = imresize(reshape(faces(i,:), [64, 64]), reduction);
            data(i,:) = reshape(temp, [1, 28^2]);
            %imagesc(reshape(data(1,:), [28,28]));
        end
        % Binary by applying threshold.
        data = applyMeanThreshold(data);
        data = randomOrder(data);
        data = setupAuto(data);
    case 'usps'
        % 1100*10 samples 16x16 pixel handwritten digits. Ordered 1,2,..0
        %rawdata = load('/home/pjsadows/ml/data/usps/usps_all.mat');
        %data.input = single(reshape(rawdata.data, 256, 11000)'); clear rawdata;
        %data.target = dummyvar(ceil((1:11000)/1100)); % targets
        %data = randomOrder(data);
        %save('/home/pjsadows/ml/data/usps/uspsdata.mat', 'data');
        load('/home/pjsadows/ml/data/usps/uspsdata.mat', 'data');
        %imagesc(reshape(data(3000,:), 16, 16))
        
    case '20news_w100'
        % Only 16242x100
        load('/home/pjsadows/ml/data/20news/20news_w100.mat');
        data = documents'; % 16242x100 
        data = randomOrder(data);
        data = setupAuto(data);
    % notMNIST
    case 'notmnistsmall'
        % Real valued features between [0,1]
        load('/home/pjsadows/ml/matlab/data/notMNIST/notMNIST_small.mat');
        images = permute(images, [2,1,3]);
        data.target = dummyvar(labels+1);
        data.input = reshape(images, [28^2,1, 18724]);
        data.input = squeeze(data.input)';
        data.input = data.input/255; % Make [0,1];
        data = randomOrder(data);
        data = makeTestSet(data, 1000);
    case 'notmnistlarge'
        % Real valued features between [0,1]
        load('/home/pjsadows/ml/data/matlab/notMNIST/notMNIST_large.mat');
        images = permute(images, [2,1,3]);
        data.target = dummyvar(labels+1);
        data.input = reshape(images, 28^2,1, []);
        data.input = squeeze(data.input)';
        data.input = data.input/255; % Make [0,1];
        data = randomOrder(data);
        data = makeTestSet(data, 10000);
    case 'notmnist_small'
        % Kept for legacy with thresholdgate nets. Use notmnistsmall
        load('/home/pjsadows/ml/data/matlab/notMNIST_small/notMNIST_small.mat');
        data = reshape(images, [28^2,1, 18724]);
        data = squeeze(data)' > 100;
        data = randomOrder(data);
        data = setupAuto(data);
        
%     case '20news10000'
%         [data, testdata, dataname] = load_20news10000();
%     case 'binomial_m=5000'
%         [data, testdata, ~] = load_binomial();
%         data = data(1:5000, :);
%     case 'mnist10000'
%         [data, testdata, ~] = load_mnist();
%         data = data(1:10000, :);
%     case '20news5000'
%         % Use first 5000 features (these are sorted by freq).
%         [data, testdata, ~] = load_20news10000();
%         data = data(:, 1:5000);
%         testdata = testdata(:, 1:5000);
    
    case 'sumregression'
        nin = 10;
        nobs = 1000;
        data.input = randn(nobs, nin);
        data.target = sum(data.input, 2);
        data.testinput = randn(nobs, nin);
        data.testtarget = sum(data.testinput, 2);
    case 'deg5polynomial'
        nin = 1;
        nobs = 1000;
        deg = 5;
        coef = randn(1, 5);
        data.input = 10*randn(nobs, nin);
        data.target = polyval(coef, data.input);
        data.testinput = 10*randn(nobs, nin);
        data.testtarget = polyval(coef, data.testinput);
% case 'sinwave'
        
    otherwise
        error('Error: Dataname not recognized!\n');
end
end

% Helper Functions
function data = applyMeanThreshold(data)
% Makes data binary by setting a threshold for each point equal to its
% mean. 
%   data = mxn matrix with m points and n features.
for k = 1:size(data,1)
    data(k,:) = data(k,:) > mean(data(k,:));
end
end

function data = setupAuto(data)
if ~isstruct(data)
    input = data;
    clear data;
    data.input = input;
    data.target = input;
    return
else
    data.target = data.input;
    if isfield(data, 'testinput')
        data.testtarget = data.testinput;
    end
end
end

function data = getFirstN(data, N)
% Make a smaller training and test set for convenience.
idxs = 1:N;
data.input = data.input(idxs,:);
data.target = data.target(idxs,:);
data.testinput = data.testinput(idxs,:);
data.testtarget = data.testtarget(idxs,:);
end

function data = makeTestSet(data, N)
% Make a test set from last N examples in data.
assert(~isfield(data, 'testinput'));
assert(size(data.input,1) > N);
tempinput = data.input;
temptarget = data.target;
data.input = tempinput(1:end-N,:);
data.target = temptarget(1:end-N,:);
data.testinput = tempinput(end-N+1:end,:);
data.testtarget = temptarget(end-N+1:end,:);
end


function data = splitForTestSet(data, ntest)
% Split off some .input samples and save them as .testinput.
data = randomOrder(data);
assert(~isfield(data, 'testinput'))
ntotal = size(data.input, 1);
assert(ntest < ntotal)
input = data.input;
target = data.target;
clear data
data.input     = input(1:ntotal-ntest, :);
data.target    = target(1:ntotal-ntest, :);
data.testinput = input(ntotal-ntest+1:end, :);
data.testtarget= target(ntotal-ntest+1:end, :);
end
