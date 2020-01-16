% Print a .dot file that has the forward-time, reverse-time and bidirectional machine together in a single picture. 
%
% input: 
% The bi_trans_probs{fly,ch,lam,a} cell that contains (m,n,q,r) bistate
% transition probabilities - transition from bidirectional state (m,n) to
% bidirectional state (q,r). (first index is forward time state, second is
% reverse time state. 
%
% output
% The all 3 machines - forward machine, reverse machine and bidirectional
% machine together in a single .dot file

tic
for fly = 7%:13
    for ch = 5%:15
        for lam = 3%:3%
            for a = 1:2%
                textFileName = ['fly' num2str(fly) 'ch' num2str(ch) 'a' num2str(a) 'lam' num2str(lam) '_all3.dot'];
                %header = ['digraph bidirectional_fly' num2str(fly) 'ch' num2str(ch) 'a' num2str(a) 'lam' num2str(lam) ' {ratio = auto;node [shape = circle];node [fontsize = 24];edge [fontsize = 24];'];
                head1 = 'digraph G {subgraph cluster0 {node [style=filled,color=white];style=filled;color=lightgrey;';
                
                if ~( isempty(bitrans_probs{fly,ch,lam,a}) ) % if that is empty we skip
                    fprintf('attempting %s now.\n', textFileName);
                    %
                    % print header of .dot file
                    fid = fopen(textFileName,'wt');
                    fprintf(fid,'%s\n',head1);
                    %
                    num_fstates = size(bitrans_probs{fly,ch,lam,a},1);
                    num_rstates = size(bitrans_probs{fly,ch,lam,a},2);
                    %
                    % print forward machine transitions
                    for u = 1:num_fstates
                        for v = 1:num_fstates
                            prob0 = celltran0{fly,ch,lam,a}(u,v);
                            prob1 = celltran1{fly,ch,lam,a}(u,v);
                                    if prob0 > 0
                                        symbol = 0;
                                        string_trans = ['"' num2str(u-1) '" -> "' num2str(v-1) '" [label = " ' num2str(symbol) ':' num2str(round(prob0*100)) '   "];'];
                                        fprintf(fid,'%s\n',string_trans);
                                    end % if it was zero we don't have a transition to put down.
                                    if prob1 > 0
                                        symbol = 1;
                                        string_trans = ['"' num2str(u-1) '" -> "' num2str(v-1) '" [label = " ' num2str(symbol) ':' num2str(round(prob1*100)) '   "];'];
                                        fprintf(fid,'%s\n',string_trans);
                                    end
                        end % v the column
                    end % u the row
                    %
                    % print head2
                    head2 = 'label = "Forward machine";}subgraph cluster1 {node [style=filled,color=white];style=filled;color=lightblue;';
                    fprintf(fid,'%s\n',head2);
                    %
                    % print reverse machine transitions
                    for u = 1:num_rstates
                        for v = 1:num_rstates
                            prob0 = rcelltran0{fly,ch,lam,a}(u,v);
                            prob1 = rcelltran1{fly,ch,lam,a}(u,v);
                                    if prob0 > 0
                                        symbol = 0;
                                        string_trans = ['"' num2str(u-1) '`" -> "' num2str(v-1) '`" [label = " ' num2str(symbol) ':' num2str(round(prob0*100)) '   "];'];
                                        fprintf(fid,'%s\n',string_trans);
                                    end % if it was zero we don't have a transition to put down.
                                    if prob1 > 0
                                        symbol = 1;
                                        string_trans = ['"' num2str(u-1) '`" -> "' num2str(v-1) '`" [label = " ' num2str(symbol) ':' num2str(round(prob1*100)) '   "];'];
                                        fprintf(fid,'%s\n',string_trans);
                                    end
                        end % v the column
                    end % u the row
                    clear prob0 prob1 u v symbol string_trans
                    %
                    % print head3
                    head3 = 'label = "Reverse Machine";}subgraph cluster2 {node [style=filled];';
                    fprintf(fid,'%s\n',head3);
                    %
                    % print the bi-transitions, they should look like:
                    % "A,C" -> "B,D" [label = "1: 0.5   "];
                    % sub-optimal code ahead
                    for m = 1:num_fstates
                        for n = 1:num_rstates % (m,m) is state we are transitioning from
                            for q = 1:num_fstates
                                for r = 1:num_rstates % (q,r) is state we are transitioning to
                                    prob = bitrans_probs{fly,ch,lam,a}(m,n,q,r);
                                    if prob > 0
                                        if celltran0{fly,ch,lam,a}(m,q)>0 %only transitions between forward states
                                            symbol = 0;
                                        else
                                            symbol = 1;
                                        end
                                        string_trans = ['"' num2str(m-1) ',' num2str(n-1) '" -> "' num2str(q-1) ',' num2str(r-1) '" [label = " ' num2str(symbol) ':' num2str(round(prob*100)) '   "];'];
                                        fprintf(fid,'%s\n',string_trans);
                                    end % if it was zero we don't have a transition to put down.
                                end %r loop
                            end % q loop
                        end % n loop
                    end %m loop
                    tail = 'label = "Bidirectional Machine";color=black}}';
                    fprintf(fid,'%s\n',tail); % this should be the end of the file.    
                    fclose(fid);
                    %
                end % empty check
            end %a
        end %lam
    end %ch
end %fly
toc
clear fly ch lam a textFileName
clear symbol head1 head2 head3 tail m n q r prob num_fstates num_rstates string_trans fid