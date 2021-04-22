function out = bpsk(in)
% this function accepts a binary input sequence and encodes it to a unit
% antipodal symbol array. 
out = (in==0)*-1 + in; 
end