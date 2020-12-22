function [] = run_LME(measure, smoothLevel,cores,outputDir)
%[] = run_LME(measure, smoothLevel, cores) Run lme analysis
%   Detailed explanation goes here

%--------------------------------------------------------------------------
    [sortedqdec, subjects, ni, lhmeasure, lhmri, lhsphere, lhcortex, rhmeasure, rhmri, rhsphere, rhcortex] = load_data(measure, smoothLevel);
    X = table2array(readtable([outputDir '/model.dat']));
    [m,n] = size(X);
    
    description = [ 'int' ];
    X(1:5,:)

    display('********************************************************');
    display(['measure: ', measure]);
    display(['smoothness: ', num2str(smoothLevel)]);
    display(['description: ', description]);
    display('********************************************************');

    [lhTh0, lhRe] = lme_mass_fit_EMinit(X, [1], lhmeasure, ni, lhcortex, 5,cores); % left hemisphere
    [rhTh0, rhRe] = lme_mass_fit_EMinit(X, [1], rhmeasure, ni, rhcortex, 5,cores); % right hemisphere

    [lhRgs, lhRgMeans] = lme_mass_RgGrow(lhsphere, lhRe, lhTh0, lhcortex, 2, 95);
    [rhRgs, rhRgMeans] = lme_mass_RgGrow(rhsphere, rhRe, rhTh0, rhcortex, 2, 95);
    % Save for qc later
    save([outputDir '/covariance_maps/' measure '_' description '.mat'], 'lhTh0', 'lhRe', 'rhTh0', 'rhRe', 'lhRgs', 'lhRgMeans', 'rhRgs', 'rhRgMeans')

    lhstats = lme_mass_fit_Rgw(X, [1], lhmeasure, ni, lhTh0, lhRgs, lhsphere,[],'euc','exp',cores);
    rhstats = lme_mass_fit_Rgw(X, [1], rhmeasure, ni, rhTh0, rhRgs, rhsphere,[],'euc','exp',cores);

    display('********************************************************');
    display('********************** TESTS ***************************');
    display('********************************************************');
    
    contrast = zeros(1,n);
    contrast(2) = 1;
    CM.C = contrast;
    contrastName = 'C';
    
    maketest(CM, contrastName, measure, description, lhstats, lhmri, rhstats, rhmri, lhcortex, rhcortex,cores, outputDir);
    display('********************************************************');
end
