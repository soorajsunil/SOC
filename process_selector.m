function [process_model, Q] = process_selector(process_model)
switch upper(process_model)
    case 'SIMPLE'
        process_model = @(soc_mk1, epsilon, eta, Cbatt, dt, i_mk1) soc_mk1 + (1-2*epsilon)*(eta/Cbatt)*(dt*i_mk1); 
        Q             = @(Cbatt, epsilon, dt, current_noise) ((1 - 2*epsilon)^2*(dt^2)*(current_noise^2))/Cbatt^2; 
    case ' ROBUST'
        % pending .... 

end 
end 
