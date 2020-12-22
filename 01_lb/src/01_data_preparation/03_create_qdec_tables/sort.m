% DESCRIPTION:
%      Prepares a longitudinal Qdec table for a univariate analysis. It sorts 
%      table according to the subject IDs (fsid-base) and time variable. The 
%      Qdec table must be of a certain format:
%           1st column : fsid
%           2nd column : fsid-base
%           3rd column : [time variable] e.g. years
%           X columns : X columns of assessment/data variables
%      IMPORTANT: all values except fsid and fsid-base columns must be
%      numeric. Otherwise it gets converted to NaN values. It also assumes
%      that 'qdec.table.dat' file exists and contains all the data to be
%      used for the analysis.
%
% INPUT:
%      NONE.
%
% OUTPUT:
%       sortedQdec.mat : sorted Qdec table without fsid and fsid-base columns.
%       ni.mat : a vector of repeated measures for each subject in the sortedQdec
%       table.
%       Outputs are saved to the current working directory.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Qdec = fReadQdec('qdec.table.dat');           % load longitudinal Qdec table into cell array
fieldNames = Qdec(1, :);                  % grab Qdec table's field names before removing it
longID = Qdec(2:end, 1:2);
Qdec = rmQdecCol(Qdec, 1);                    % remove the first column (fsid) from the table
sID = Qdec(2:end, 1);                         % grab all subject IDs (fsid-base) in the table
scanner = Qdec(2:end,end);
[m,n] = size(Qdec);
Qdec = rmQdecCol(Qdec, n);                    % remove the last column (scanner) from the table

% Change the base id to subject ID:
for k = 1:length(sID)
    array = split(sID{k},"_");
    sID{k} = char(array(1));
end

Qdec = rmQdecCol(Qdec, 1);                    % remove the first column (fsid-base) (actually the second column in the original Qdec table)
M = Qdec2num(Qdec);                           % convert to a numeric matrix. This removes table's field names as well
[M, longID, ni] = sortData(M, 1, longID, sID);          % sort M according to subjects and time. We don't want to ,split M so it is repeated twice
sortedQdec = num2cell(M);                     % convert to cell array in order to merge with fieldNames  
sortedQdec = [fieldNames; longID sortedQdec scanner];        % merge into one table
T = cell2table(sortedQdec);
writetable(T, 'sorted.qdec.table.dat', 'Delimiter', ' ', 'WriteVariableName', 0);
save('ni.mat', 'ni');
clear;