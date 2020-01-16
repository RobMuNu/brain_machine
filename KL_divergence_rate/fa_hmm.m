function p=fa_hmm(o,trans,ipi)
% IMPORTANT matlab doesn't index from 0, so a binary emitted sequence '0 0
% 1' is instead shifted to '1 1 2'.
%
%INPUTS:
% o = Given emitted sequence labelled in numerics e.g. [1 2 2 1 2 1]
% ipi = initial probability of states in a row vector
% trans(i,j,k) = (N by N by |alphabet|) sized transition matrix (N by N by each possible emitted symbol). trans(:,:,1) is emitting a 1, k=2 emitting a two etc.
% make sure symbols used in 'o' and 'trans' are consistent.
%OUTPUTS:
% p = probability of observing the given sequence from the given model

T=length(o); % T is length of the observed sequence, o(1) is first symbol and o(T) is the last symbol
% Aidans Forward Algorithm
% First time step t=1, first symbol emitted o(1), takes place row 1 of a
alpha(1,:) = ipi*trans(:,:,o(1));

for t=2:T      %Recursively calculate alpha for each timestep
    alpha(t,:) = alpha(t-1,:)*trans(:,:,o(t)); % o(t) is why emitted symbols can't be {0,1,2,..}, they must be {1,2,3,...}
end
p=sum(alpha(T,:),2); %The total probability that the sequence 'o' is emitted
