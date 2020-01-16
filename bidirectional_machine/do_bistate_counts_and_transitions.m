% For bidirectional machine
%
% input: the aligned state series. aligned{fly,ch,lam,2}
    % aligned{fly,ch,lam,a} has first row 17999 state series
    %                           second row is 17999 reverse series flipped
    %                           so they should line up at the same time.
    
tic
for fly = 1:13
    for ch = 1:15
        for lam = 2:3%
            for a = 1:2%
                textFileName = ['fly' num2str(fly) 'ch' num2str(ch) 'a' num2str(a) 'lam' num2str(lam)];
                if ~( isempty(aligned{fly,ch,lam,a}) ) % if that is empty we skip
                    fprintf('attempting %s now.\n', textFileName);
                    statepair = aligned{fly,ch,lam,a} + 1; %The +1 is because matlab can't index from 0. states go from 1:Numstates. each cell should be 2 by 17999 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% +1 done here
                    num_fstates = max(statepair(1,:));
                    num_rstates = max(statepair(2,:));
                    bistate_count{fly,ch,lam,a} = zeros(num_fstates,num_rstates); % initiali
                    bitrans_count{fly,ch,lam,a} = zeros(num_fstates,num_rstates,num_fstates,num_rstates);
                    bitrans_probs{fly,ch,lam,a} = zeros(num_fstates,num_rstates,num_fstates,num_rstates);% initalizing
                    for k = 1:length(statepair(1,:))
                        m = statepair(1,k); % the forward time state
                        n = statepair(2,k); % the reverse time state
                        if (~isnan(m) && ~isnan(n))
                            bistate_count{fly,ch,lam,a}(m,n) = bistate_count{fly,ch,lam,a}(m,n)+1;
                            if k<length(statepair(1,:)) %can't do a transition when we are at 17999 the last state
                                q = statepair(1,k+1); % the forward time state being transitioned to forwards
                                r = statepair(2,k+1); % the reverse time state being transitioned to forwards
                                if (~isnan(q) && ~isnan(r)) %making sure we are not transitioning to a nan state.
                                    bitrans_count{fly,ch,lam,a}(m,n,q,r) = bitrans_count{fly,ch,lam,a}(m,n,q,r)+1;
                                end
                            end% % bi trans count loop
                        end 
                    end % bi state count loop
                    clear m n statepair q r k
                    %
                    % calculate Bi-directional Cmu
                    totalcounts = sum(bistate_count{fly,ch,lam,a},'all'); %how many valid state pairs there are
                    sfrprobs = bistate_count{fly,ch,lam,a}/totalcounts;
                    frdummy = -sfrprobs.*log2(sfrprobs);
                    frdummy(isnan(frdummy)) = 0; %sets NaN values due to 0*log(0) to =0
                    bi_sc(fly,ch,lam,a) = sum(frdummy,'all');
                    clear totalcounts sfrprobs frdummy
                    %
                    % calculate bi-directional forward transition matrix.
                    % we have a counts of transition from state m,n to
                    % state q,r in (m,n,q,r). We want it as a probability ,
                    % so we need to divide by the amount of times m,n
                    % appeared. This is bistate_count(m,n)
                    %
                    % Turn counts into probabilities of transition.
                    for m = 1:num_fstates
                        for n = 1:num_rstates
                            bitrans_probs{fly,ch,lam,a}(m,n,:,:) = bitrans_count{fly,ch,lam,a}(m,n,:,:)./bistate_count{fly,ch,lam,a}(m,n);
                        end % n
                    end % m
                    bitrans_probs{fly,ch,lam,a}(isnan(bitrans_probs{fly,ch,lam,a})) = 0; % Set NaN due to 0/0=Nan back to zero
                %
                %
                clear num_fstates num_rstates m n
                else % if the entry is empty
                    fprintf('File %s does not exist NAN NAN NAN NAN NAN NAN NAN NAN.\n', textFileName);
                    bistate_count{fly,ch,lam,a} = [];
                    bitrans_probs{fly,ch,lam,a} = [];
                    bi_sc(fly,ch,lam,a) = NaN;
                end
            end %a
        end %lam
    end %ch
end %fly
toc
clear fly ch lam a textFileName