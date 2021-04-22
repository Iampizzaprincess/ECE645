% specify the test case
sim = 'BCJR';       % should be BCJR or Turbo
msgLength = 256;    % specify the message length (ideally should be even)
sigma = .1;         % noise stdev (scalar or array of scalars) 
Eb = 1;             % Energy per bit
%% do not modify below
% create and shuffle input bitseq
    rng('shuffle')
    bitseq = [zeros([1,floor(msgLength/2)]),ones([1,floor(msgLength/2)])]; 
%     bitseq = [1 1 0 1]; % for debugging
    idx = randperm(numel(bitseq));
    bitseq = [bitseq(idx),0,0,0]; % add three trailing zeros for BCJR
    
% simulation specific operations
    switch sim
        case 'BCJR'
            cw = convEnc(bitseq); 
            cwN = bpsk(cw) + sigma * randn(size(cw)); 
            LLR = BCJRdec(cwN,Eb,sigma,'equal'); 
            decoded = LLR > 0;
            err = sum(abs(bitseq-decoded));
            fprintf('BCJR dec Bit Error = %.4f%%\n', err/numel(bitseq));
        case 'Turbo'
        otherwise 
            error('Unwritten code simulation case, so sad.')
    end