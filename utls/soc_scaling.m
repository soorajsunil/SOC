function [scaled_soc] = soc_scaling(soc, epsilon, scaling_mode)
% SOC scaling to avoid numerical instabilities 
% for open circuit voltage characterization
% [1]. Ahmed, Mostafa Shaban, Sheikh Arif Raihan, and Balakumar
% Balasingam. "A scaling approach for improved state of charge
% representation in rechargeable batteries." Applied energy
% 267 (2020): 114880.
% >> epsilon = 0.175; % optimal value for soc scaling [1]

switch upper(scaling_mode)
    case 'FORWARD' % Forward scaling
        scaled_soc = soc.*(1-2*epsilon) + epsilon;
    case 'BACKWARD' % Backward scaling
        scaled_soc = (soc - epsilon)./(1-2*epsilon);
    otherwise
        error('select scaling_mode as forward or backward')
end
end
