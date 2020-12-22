function [sortedqdec, subjects, ni, lhmeasure, lhmri, lhsphere, lhcortex, rhmeasure, rhmri, rhsphere, rhcortex] = load_data(measure, fwhm, target)
% INPUT:
%
% OUTPUT:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 2
    error('The function must have two input arguments.');
elseif nargin == 2
    target='fsaverage';
end;
SUBJECTS_DIR = getenv('SUBJECTS_DIR');
lhmeasure = ['ALL.lh.' measure '.' target '.sm' num2str(fwhm) '.mgh'];
rhmeasure = ['ALL.rh.' measure '.' target '.sm' num2str(fwhm) '.mgh'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first check whether all necessary files exist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('ALL.sorted.qdec.table.dat', 'file') || ~exist('ALL.ni.mat', 'file')
    error('Longitudinal data is not prepared. Missing sorted.qdec.table.dat and/or ni.mat files.');
end
if ~exist(lhmeasure, 'file') || ~exist(rhmeasure, 'file')
    error(['One or both of ?h.' measure '.' target '.' num2str(fwhm) '.mgh do not exist.']);
end
if ~exist([SUBJECTS_DIR '/' target], 'dir')
    error(['Cannot find ' SUBJECTS_DIR '/' target]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load all neccessary data for LME mass-univariate analysis into matlab
% workspace. Loads both hemispheres.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sortedqdec = fReadQdec('ALL.sorted.qdec.table.dat');
subjects = size(sortedqdec, 1) - 1;
load('ALL.ni.mat');
% lh hemisphere
[lhmeasure, lhmri] = fs_read_Y(lhmeasure);
lhsphere = fs_read_surf([SUBJECTS_DIR '/' target '/surf/lh.sphere']);
lhcortex = fs_read_label([SUBJECTS_DIR '/' target '/label/lh.cortex.label']);
% rh hemisphere
[rhmeasure, rhmri] = fs_read_Y(rhmeasure);
rhsphere = fs_read_surf([SUBJECTS_DIR '/' target '/surf/rh.sphere']);
rhcortex = fs_read_label([SUBJECTS_DIR '/' target '/label/rh.cortex.label']);

end
