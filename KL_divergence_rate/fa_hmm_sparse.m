function p=fa_hmm_sparse(o,trans0,trans1,ipi)
%Alterd 12/11/19 to see if sparse matrices make things faster. Only way I
%can think to use trans0 and trans1 in this case is by if statements
%
%INPUTS:
% o = Given observation sequence labellebd in numerics e.g. [1 2 2 1 2 1]
% ipi = initial probability of states in a row vector
% trans(i,j,k) = (N by N by |alphabet|) sized transition matrix (N by N by each possible emitted symbol). trans(:,:,1) is emitting a 1, k=2 emitting a two etc.

%OUTPUTS:
% P = probability of observing the given sequence from the given model

% initializing
T=length(o); % T is length of the observed sequence, o(1) is first symbol and o(T) is the last symbol
alpha = zeros(T,length(ipi)); %initialise alpha

% Forward Algorithm
% First time step t=1, first symbol emitted o(1), takes place row 1 of a
if o(1) == 1 %meaning first emitted is 0
    alpha(1,:) = ipi*trans0;
else
    alpha(1,:) = ipi*trans1;
end
    
for t=2:T      %Recursively calculate alpha for each timestep
    if o(t) == 1
        alpha(t,:) = alpha(t-1,:)*trans0; %
    else
        alpha(t,:) = alpha(t-1,:)*trans1;
    end
end
p=sum(alpha(T,:),2);
