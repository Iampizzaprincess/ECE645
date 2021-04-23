function [bitsInt,iLeaveIdx] = interleave(bits,n,iLeaveIdx)
%INTERLEAVE This function randomly interleaves the input bits and preserves
%the last n trailing zeros
% this function returns the interleaved bitsequence and the indexes of the
% interleaver so the original order may be restored. 
    if iLeaveIdx == 0  % make an interleave idx
        iLeaveIdx = randperm(numel(bits)-n); 
        bitsInt = bits(iLeaveIdx); 
        bitsInt = [bitsInt zeros([1,n])]; 
    else
        bitsInt = bits(iLeaveIdx); 
        bitsInt = [bitsInt zeros([1,n])]; 
    end
end

