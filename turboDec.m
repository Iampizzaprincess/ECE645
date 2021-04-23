function LLR = turboDec(cwN, turboItr, Eb, sigma,idxs)
% turboDec: Thus function performs turbo decoding on the input sequence.
% This function accepts a noisy codeword, the number of turbo code
% iterations, the Eb, the noise sigma, and the idxs of the interleaver. 
% This function returns the final LLR of the decoded sequence. 

    % Decoder 1
    cw1 = zeros([1,numel(cwN)*2/3]);
    cw1(1:2:end) = cwN(2:3:end);            % extract pb1 
    cw1(2:2:end) = cwN(1:3:end);            % extract message bits 
    aPriori = 'equal';                      % a priori for first iteration
    LLR1 = BCJRdec(cw1,Eb,sigma,aPriori);   % get llr1
%     LLR1(find(LLR1>1000)) = 1000;             % correct overflow (by clipping)
%     LLR1(find(LLR1<-1000)) = -1000; 
    Le1 = zeros(size(LLR1));                % aPriori LLR is just zero
    Lc  = 2 * Eb/(sigma)^2 * cw1(2:2:end);  % channel info (constant)
    Le1 = LLR1 - Le1 - Lc;                  % compute enc 1 extrinsic info         
%     Le1 = Le1 / max(abs(Le1));              % normalize 
    Le1(find(Le1>100)) = 100;
    Le1(find(Le1<-100)) = -100;
    aPriori = interleave(Le1,3,idxs); % interleave a priori 

    % Decoder 2 
    cw2 = zeros([1,numel(cwN)*2/3]);
    cw2(1:2:end) = cwN(3:3:end);            % extract pb2
    [cw2(2:2:end),~] = interleave(cwN(1:3:end),3,idxs);% extract intlvd msg bits 
    LLR2 = BCJRdec(cw2,Eb,sigma,aPriori);
%     LLR2(find(LLR2>1000)) = 1000;             % correct overflow (by clipping)
%     LLR2(find(LLR2<-1000)) = -1000; 
    Le2 = LLR2 - aPriori - Lc;                  % this could be a problem
%     Le2 = Le2 / max(abs(Le2)); 
    Le2(find(Le2>1000)) = 1000;
    Le2(find(Le2<-1000)) = -1000;
    aPriori = deinterleave(Le2,idxs,3);  % deinterleave a priori    
    
    if turboItr > 1
        for k = [1 : 1 : turboItr - 1]
            LLR1 = BCJRdec(cw1,Eb,sigma,aPriori);   % get llr1
%             LLR1(find(LLR1>1000)) = 1000;             % correct overflow (by clipping)
%             LLR1(find(LLR1<-1000)) = -1000; 
            Le1 = LLR1 - aPriori - Lc;               % compute enc 1 extrinsic info         
%             Le1 = Le1 / max(abs(Le1));              % normalize 
            Le1(find(Le1>1000)) = 1000;
            Le1(find(Le1<-1000)) = -1000;
            aPriori = interleave(Le1,3,idxs);        % interleave a priori          
            LLR2 = BCJRdec(cw2,Eb,sigma,aPriori);   % get llr1
            Le2 = LLR2 - aPriori - Lc;        
%             LLR2(find(LLR2>1000)) = 1000;             % correct overflow (by clipping)
%             LLR2(find(LLR2<-1000)) = -1000; 
              % compute enc 1 extrinsic info         
%             Le2 = Le2 / max(abs(Le2));              % normalize 
            Le2(find(Le2>1000)) = 1000;
            Le2(find(Le2<-1000)) = -1000;
            aPriori = deinterleave(Le2,idxs,3);
        end
    end
    LLR = LLR1; 
end