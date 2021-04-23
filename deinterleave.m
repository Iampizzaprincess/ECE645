function out = deinterleave(bits,idx,n)
% this function deinterleaves according to a given set of interleaver idx
%     out = bits(idx);
    out = zeros([1,numel(bits)-n]);
    idxct = 1; % idx count 
    for k = 1 : (numel(bits)-n)
        index = find(idx==idxct);
        out(k) = bits(index);
        idxct = idxct+1; 
    end
    out = [out zeros([1,n])];
end