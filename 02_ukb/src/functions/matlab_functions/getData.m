function [colValues] = getData(colName)
% USAGE:
%       [colValues] = getData(colName)
% DESCRIPTION:
%       A function which retrieves a data column (a vector) from
%       sortedQdec.mat table. 
% INPUT:
%       colName : column name in the table.
% OUTPUT:
%       colValues : returns a vector of column data.

if ~exist('sorted.qdec.table.dat', 'file')
    error('ERROR: sorted.qdec.table.dat file does not exist.');
end

sortedQdec = fReadQdec('sorted.qdec.table.dat');
tableCols = sortedQdec(1,:);                        % extract table columns
id = find(strcmp(colName,tableCols)==1);            % get column number
if ~isempty(id)
    colValues = str2double(sortedQdec(2:end,id));     % extract column data and convert to numeric
else
    error(['ERROR: Column name ' colName ' does not exist.']);
end