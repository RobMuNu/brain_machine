% 18/12/19
% For bidirectional machine
%
% input 2 files: the forward state series and the reverse state series
    %forward cells
        % cellstates is {fly,ch,lam,a}. each SHOULD be a string 18000 long,
        % however EMPTY cells and length<18000 exist
        % EMPTY due to no file to read
        % length<18000 due to faulty CSSR series thing
    %reverse cells
        % rcellstates is {fly,ch,lam,a}
% output
    % aligned{fly,ch,lam,a} has first row 17999 state series
    %                           second row is 17999 reverse series flipped
    %                           so they should line up at the same time.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Correct line up assumes format like example below ( a 5 symbol long
    % time series)
    % first row is emitted symbols
    % row 2 is time steps
    % row 3 f1 f2 etc are forward time causal states
    % row 4 r1 r2 etc are reverse time causal states
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     	1		0		1		1		0
% t0		t1		t2		t3		t4		t5		
%           f1		f2		f3		f4		f5		
% r5		r4		r3		r2		r1	

for fly = 1:13
    for ch = 1:15
        for lam = 2:3
            for a = 1:2
                     % read out what length n it is up to
                    textFileName = ['fly' num2str(fly) 'ch' num2str(ch) 'a' num2str(a) 'lam' num2str(lam)];
                    if ~( isempty(cellstates{fly,ch,lam,a}) || isempty(rcellstates{fly,ch,lam,a}) ) % if that or that is empty we skip
                        if ( length(cellstates{fly,ch,lam,a})==18000 && length(rcellstates{fly,ch,lam,a})==18000 )
                            fprintf('attempting %s now.\n', textFileName);
                            aligned{fly,ch,lam,a}(1,:) = cellstates{fly,ch,lam,a}(1:17999);
                            aligned{fly,ch,lam,a}(2,:) = flip(rcellstates{fly,ch,lam,a}(1:17999));
                        else
                            fprintf('Length not 18000 CSSR bad for %s LLLLLLLLLLLLLLLLLLLLLLLL.\n', textFileName);
                            aligned{fly,ch,lam,a} = [];
                        end
                    else % if the entry is empty
                        fprintf('File %s does not exist NAN NAN NAN NAN NAN NAN NAN NAN.\n', textFileName);
                        aligned{fly,ch,lam,a} = [];
                    end
                    %	fid = fopen(textFileName, 'rt');
                    %	textData = fread(fid);
                    %	fclose(fid); 
                    % else
                    %	
            end %a
        end %lam
    end %ch
end %fly
done = 1
clear done fly ch lam a textFileName