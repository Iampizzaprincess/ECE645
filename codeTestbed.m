% specify the test case
close all
clear all
sim = 'Turbo';          % should be BCJR or Turbo
msgLength = 256;        % specify the msg length
sigma = [.1:.01:2];           % noise stdev (scalar or vector of scalars) 
numIter = 10;            % number of iterations 
verbose = true;        % print any print statements
plotOpt = true;        % plot BER/CW err rate
turboItr = 15;           % num iter for turbo (can put whatever for BCJR)
%% do not modify below
    
    % init some parameters
    rng('shuffle')
    err = zeros([numIter,numel(sigma)]);
    Eb = 1;             % Energy per bit = 1 for bpsk
    
    % begin iterations 
    for k = 1:numIter
        fprintf('itr %d\n', k)
        for n = 1 : numel(sigma)
            
        % create and shuffle input bitseq    
            bitseq = [zeros([1,floor(msgLength/2)]),ones([1,floor(msgLength/2)])]; 
            idx = randperm(numel(bitseq));
%             bitseq = [1 0 1 0 0 0]; % for testing purposes
            bitseq = [bitseq(idx),0,0,0]; % add three trailing zeros for BCJR

        % simulation specific operations
            switch sim
                case 'BCJR'
                    
                    cw = convEnc(bitseq); 
                    cwN = bpsk(cw) + sigma(n) * randn(size(cw)); 
                    LLR = BCJRdec(cwN,Eb,sigma(n),'equal'); 
                    decoded = LLR > 0;
                    err(k,n) = sum(abs(bitseq-decoded))/numel(bitseq);
                    if verbose
                        fprintf('BCJR dec Bit Error = %.4f%%\n', err(k,n)/numel(bitseq)*100);
                    end
                    
                case 'Turbo'
                    % encode 
                    cw1 = convEnc(bitseq); 
                    [bitseq2, idxs] = interleave(bitseq, 3,0); 
                    cw2 = convEnc(bitseq2); 
                    % separate into parity and message bits 
                    msgBits = cw1(2:2:end);
                    pb1 = cw1(1:2:end); % parity bits for cw1
                    pb2 = cw2(1:2:end); % parity bits for cw2 
                    % Make the overall cw to be transmitted 
                    cw  = zeros([1,numel(msgBits) + numel(pb1) + numel(pb2)]);
                    cw(1:3:end) = msgBits;
                    cw(2:3:end) = pb1; 
                    cw(3:3:end) = pb2; 
                    % "transmit"
                    cwN = bpsk(cw) + sigma(n) *randn(size(cw)); 
                    % Turbo decoding 
                    LLR = turboDec(cwN, turboItr, Eb, sigma(n),idxs);
                    decoded = LLR > 0;
                    err(k,n) = sum(abs(bitseq-decoded))/numel(bitseq);
                    if verbose
                        fprintf('Turbo dec Bit Error = %.4f%%\n', err(k,n)/numel(bitseq)*100);
                    end
                otherwise 
                    error('Unwritten code simulation case, so sad.')
            end % end switch
            
        end
    end
    
    % plot ber and cer 
    if plotOpt
        figure(420)
        subplot(2,1,1) % plot the bit error rate
        EbNo = Eb./sigma.^2;
        semilogy(10*log10(EbNo), mean(err),'m:','LineWidth', 4.0)
        grid on
        titlestr = sprintf('BER curve for %s decoding',sim);
        title(titlestr);
        xlabel('E_b/N_o (dB)')
        ylabel('Bit error rate')
        xlim([-5,10])
        ylim([10^-6,1])
        subplot(2,1,2) % plot the codeword error rate
        cwErr = err > 0;
        semilogy(10*log10(EbNo),mean(cwErr),'m:','LineWidth', 4.0)
        grid on
        xlim([-5,10])
        titlestr = sprintf('Codeword error curve for %s decoding',sim);
        title(titlestr);
        xlabel('E_b/N_o (dB)')
        ylabel('Codeword error rate')
        ylim([10^-5,1])
    end