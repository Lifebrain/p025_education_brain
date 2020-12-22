function [  ] = maketest( CM, contrastName, measure, description, lhstats, lhmri, rhstats, rhmri, lhcortex, rhcortex,cores,outputDir)
% [  ] = maketest( CM, contrastName, measure, description, lhstats, lhmri, rhstats, rhmri, lhcortex, rhcortex, cores)
%   Detailed explanation goes here

%--------------------------------------------------------------------------
    display('CM.C');
    display(CM.C);

    F_lhstats = lme_mass_F(lhstats, CM, cores);
    F_rhstats = lme_mass_F(rhstats, CM, cores);

    fileName = [outputDir, '/p_maps/sig.lh.', measure, '_', description, '_', contrastName, '.mgh'];
    display(['Saved as: ', fileName]);
    fs_write_fstats(F_lhstats, lhmri, fileName, 'sig');

    fileName = [outputDir, '/p_maps/sig.rh.', measure, '_', description, '_', contrastName, '.mgh'];
    display(['Saved as: ', fileName]);
    fs_write_fstats(F_rhstats, rhmri, fileName, 'sig');
    
    % Correct for multiple comparison
    [lh_dvtx, lh_sided_pval, lh_pth] = lme_mass_FDR2(F_lhstats.pval, F_lhstats.sgn, lhcortex, 0.05, 0); % left hemi
    [rh_dvtx, rh_sided_pval, rh_pth] = lme_mass_FDR2(F_rhstats.pval, F_rhstats.sgn, rhcortex, 0.05, 0); % right hemi

    save([outputDir '/p_maps/' measure '_' description '.mat'], 'rh_sided_pval', 'lh_sided_pval', 'lhmri', 'rhmri')

    % To be able to use fs_write_Y
    rhmri.volsz(4) = 1;
    lhmri.volsz(4) = 1;

    fileName = [outputDir,'/p_maps/sig.rh.', measure, '_', description, '_', contrastName, '_spval.mgh'];
    display(['Saved as: ', fileName]);
    fs_write_Y(rh_sided_pval, rhmri, fileName)

    fileName = [outputDir,'/p_maps/sig.lh.', measure, '_', description, '_', contrastName, '_spval.mgh'];
    display(['Saved as: ', fileName]);
    fs_write_Y(lh_sided_pval, lhmri, fileName)

end

