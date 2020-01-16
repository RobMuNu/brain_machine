% 13/10/19
% Reverse time
% reads the state sequence from the _rstate_series files
tic
for fly = 1:13
    for ch = 1:15
        for lam = 2:3
            for a = 1:2
                % Create a string that is the text file name, and read the file if it exists.
                textFileName = ['fly' num2str(fly) 'ch' num2str(ch) 'a' num2str(a) 'lam' num2str(lam)];
                if exist([textFileName '_rstate_series' ], 'file')
                    fprintf('attempting %s reverse time states now.\n', textFileName);
                    rcellstates{fly,ch,lam,a} = readmatrix([textFileName '_rstate_series' ]);
                    if length(rcellstates{fly,ch,lam,a})>18000
                        rcellstates{fly,ch,lam,a}(18001) = []; %remove the last NaN SLOPPY code
                    else
                        rbadstates(fly,ch,lam,a) = NaN;
                    end
                else
                    fprintf('File %s does not exist NAN NAN NAN NAN NAN NAN NAN NAN.\n', textFileName);
                    rbadstates(fly,ch,lam,a) = NaN;
                end
                %clear textFileName
            end %a
        end %lam
    end %ch
end %fly
toc
done = 1
clear done fly ch lam a textFileName
