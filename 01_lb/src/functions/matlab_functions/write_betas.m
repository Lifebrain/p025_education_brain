function [betas] = write_betas (stats, outname, mri)
% save all the betas in maps that c
numberOfBetas = size(stats(1).Bhat,1);
nv = length(stats);
betas = zeros(numberOfBetas,nv);
for i=1:nv
    if ~isempty(stats(i).Bhat)
    for beta=1:numberOfBetas
        betas(beta,i) = stats(i).Bhat(beta);
    end
    end
end

mri.volsz(4) = 1;

for beta=1:numberOfBetas
    fs_write_Y(betas(beta,:),mri, strcat(outname, '_beta', num2str(beta), '.mgh'));
end