function [ ] = compare_cov_maps( Theta0, RgMeans, sphere )
% [] = compare_cov_maps( Theta0, RgMeans, sphere )
%
% Visually compare ?hTheta0 and ?hRgMeans maps overlaid onto ?hsphere to
% ensure that they are similar enough - the essential spatial organization
% of the initial covariance estimates was not lost after the segmentation.
% Must be run separately for each hemisphere.

surf.faces = sphere.tri;
surf.vertices = sphere.coord';

figure; p1 = patch(surf);
set(p1, 'facecolor', 'interp', 'edgecolor', 'none', 'facevertexcdata', Theta0(1,:)');

figure; p2 = patch(surf);
set(p2, 'facecolor', 'interp', 'edgecolor', 'none', 'facevertexcdata', RgMeans(1,:)');


end

