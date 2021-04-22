function codeword = convEnc(bitseq)
% This function encodes a message sequence according to the systematic
% encoder in fig. 1 of Jackie's super awesome report. Accepts a single row
% input array of 0 and 1's and returns the encoded sequence. 
   
% encode the bitsequence 
    % impulse response of convolutional encoder in Fig. 1
    g1 = [1 0 1];
    g2 = [1 0 0];
    
    % encode bits
    c1 = mod(conv(bitseq,g1),2);
    c2 = mod(conv(bitseq,g2),2);
    
    % concatenate output of encoder
    codeword = zeros([1,numel(bitseq)*2]);
    codeword(1:2:end) = c1(1:numel(bitseq));
    codeword(2:2:end) = c2(1:numel(bitseq));
end