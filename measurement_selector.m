function [measurement_model, R] = measurement_selector(model)

switch upper(model)
    case 'RINT'
        measurement_model = @(OCV, I, R0) OCV + I*R0;  
        R     = @(R0, current_noise, voltage_noise) R0*current_noise^2 + voltage_noise^2; 
    case 'RC'
         measurement_model = @(OCV, I, I1, R0, R1) OCV + I*R0 + I1*R1;
    case '2RC'
         measurement_model = @(OCV, I, I1, I2, R0, R1, R2) OCV + I*R0 + I1*R1 + I2*R2;
    case 'ESC'
        measurement_model = @(OCV, I, I1, I2, R0, R1, R2, H) I*R0 + I1*R1 + I2*R2 + H;
    otherwise
        error('invalid measurement model')
end 

end 