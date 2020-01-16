% 28/11/19
% fairly neat clean code
%
% gradient of KL divergence between forward fly data and reverse fly data
%
% 6 total inputs in the form of cells
% input the three cell** files for forward
    % cellinit is {fly,ch,lam,a} of initial probabilities (column vectors)
    % celltran0 is {fly,ch,lam,a} of trans matrix for emitting0
    % celltran1 is same but for emitting 1
% same but reverse verseoinse
    %rcellinit
    %rcelltran0 and rcelltran1
% output
    % rate of KL divergence between the two - are they the same machine?
%

tic

gradKL_f_r = nan(13,15,11,2); %initialize
gradKL_r_f = nan(13,15,11,2);
gradKL_symm_f_r = nan(13,15,11,2);

for fly = 1:13
for ch = 1:15
for lam = 2:11
for a = 1:2
    %
    textFileName = ['fly' num2str(fly) 'ch' num2str(ch) 'a' num2str(a) 'lam' num2str(lam)];
    %%%%%%%%
    % get the normal transition matrices from input files forward time cells and reverse time rcells%
    %%%%%%%%
    if ( ~isempty(celltran0{fly,ch,lam,a}) && ~isempty(celltran1{fly,ch,lam,a}) && ~isempty(cellinit{fly,ch,lam,a}) && ~isempty(rcelltran0{fly,ch,lam,a}) && ~isempty(rcelltran1{fly,ch,lam,a}) && ~isempty(rcellinit{fly,ch,lam,a}) ) % forward and reverse time stuff needs to be non-empty
        fprintf('attempting %s now.\n', textFileName);
        % forward form
        init = cellinit{fly,ch,lam,a}';
        T0 = sparse(celltran0{fly,ch,lam,a});
        T1 = sparse(celltran1{fly,ch,lam,a});
        % reverse form
        rinit = rcellinit{fly,ch,lam,a}';
        R0 = sparse(rcelltran0{fly,ch,lam,a});
        R1 = sparse(rcelltran1{fly,ch,lam,a});
 
        %%--%% 
        %gradKL for each
        %%--%% 
        for n = 12:13 % putting this loop or at least "sequence" further out would be smarter.
            sequence = (dec2bin(2^n-1:-1:0)-'0')+1; % 2^n rows, n columns each row is one possible observable sequence. 1 is a 0, 2 is a 1 lol
            f_Pro = zeros(2^n,1);
            r_Pro = zeros(2^n,1);
            for k = 1:2^n
                f_Pro(k,1) = fa_hmm_sparse(sequence(k,:),T0,T1,init); %runs Forward algorithm on all possible sequences, creating a column vector with length 2^n
                r_Pro(k,1) = fa_hmm_sparse(sequence(k,:),R0,R1,rinit);
            end
            % Computer KL divergence between 
            kldummy = f_Pro.*log2(f_Pro./r_Pro); % P = forward, Q reverse
            qpdummy = r_Pro.*log2(r_Pro./f_Pro); % opposite to above
            %
            kldummy(isnan(kldummy))=0; %sets NaN values due to 0*log(0/Q) to =0
            kldummy(kldummy == Inf)=0; %sets Inf values due to P*log(P/0) to =0
            qpdummy(isnan(qpdummy))=0; %sets NaN values due to 0*log(0/Q) to =0
            qpdummy(qpdummy == Inf)=0; %sets Inf values due to P*log(P/0) to =0
            %
            dummy_KL_f_r(n-11) = sum(kldummy); % KL(P|Q)
            dummy_KL_r_f(n-11) = sum(qpdummy); % KL(Q|P)
            %dummy_KLdiv(n-11) = sum(kldummy)+ sum(qpdummy); % KL(P|Q) + KL(Q|P)
            %
            clear kldummy qpdummy k sequence
            %
        end% n loop

        gradKL_f_r(fly,ch,lam,a) = dummy_KL_f_r(2) - dummy_KL_f_r(1); % n13 - n12 for gradient
        gradKL_r_f(fly,ch,lam,a) = dummy_KL_r_f(2) - dummy_KL_r_f(1);
        gradKL_symm_f_r(fly,ch,lam,a) = gradKL_f_r(fly,ch,lam,a) + gradKL_r_f(fly,ch,lam,a);
        %%--%% 
        % END gradKL
        %%--%%
        clear dummy_KL_f_r dummy_KL_r_f n
    
    else % if the entry is empty we cannot compute the rate of KL divergence between the two
        fprintf('File %s does not exist NAN NAN NAN NAN NAN NAN NAN NAN.\n', textFileName);
        gradKL_f_r(fly,ch,lam,a) = NaN; % n13 - n12 for gradient
        gradKL_r_f(fly,ch,lam,a) = NaN;
        gradKL_symm_f_r(fly,ch,lam,a) = NaN;
    end % if CSSR empty check
end %a
end %lam
end %ch
end %fly

toc
clear fly ch lam a textFileName
clear T0 T1 R0 R1 r_Pro f_Pro init rinit

