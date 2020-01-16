% 12/12/19 for bi-directional machine2
% Forward time
% reads the state sequence from the _state_series files
%
%   MATLAB shits itself if the delimiter isn't a comma, so the bash file
%   'fixdelimiter' simply changes all delimiters from ; to , . 
%   Run that beforehand
%
% OUTPUT is cellstates{fly,ch,lam,a} which each entry is a row vector that should have length 18000
% if ******_state_series file doesn't exist, or it is less than 18 000 it a
% binary flag will appear in "isbadstates"
%
% PROBLEM? this still puts the state series in if it is less than 18000
tic
for fly = 1:13
    for ch = 1:15
        for lam = 2:3
            for a = 1:2
                % Create a string that is the text file name, and read the file if it exists.
                textFileName = ['fly' num2str(fly) 'ch' num2str(ch) 'a' num2str(a) 'lam' num2str(lam)];
                if exist([textFileName '_state_series' ], 'file')
                    fprintf('attempting %s forward time states now.\n', textFileName);
                    cellstates{fly,ch,lam,a} = readmatrix([textFileName '_state_series' ]);
                    if length(cellstates{fly,ch,lam,a})>18000
                        cellstates{fly,ch,lam,a}(18001) = []; %remove the last NaN SLOPPY code
                    else
                        fbadstates(fly,ch,lam,a) = NaN;
                    end
                else
                    fprintf('File %s does not exist NAN NAN NAN NAN NAN NAN NAN NAN.\n', textFileName);
                    fbadstates(fly,ch,lam,a) = NaN;
                end
                %clear textFileName
            end %a
        end %lam
    end %ch
end %fly
toc
done = 1
clear done fly ch lam a textFileName
