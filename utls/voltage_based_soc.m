classdef voltage_based_soc

    properties
        open_circuit
        terminal
        drop

        ocv_params = [-9.082; 103.087; -18.185; 2.062; -0.102; ...
            -76.604; 141.199; -1.117]; % curve fitters characterized offline
        R0
        R1
        R2
        I1
        I2
        H
    end

    properties(Hidden)
        SOC
    end

    methods
        function obj = voltage_based_soc(SOC)
            obj.SOC  = SOC;
            obj.open_circuit = obj.get_ocv(obj.ocv_params, obj.SOC);
        end

        function obj = R_int(obj, ik, R0)
            % simple (internal resistance) model
            obj.R0               = R0;
            obj.drop     = ik*obj.R0;
            obj.terminal = obj.open_circuit + obj.drop;
        end
    end

    methods(Static)
        function SOC = SOC_lookup(res, scaling_factor, ocv_params, ocv)
            SOC = nan(size(ocv)); 
            min_soc = soc_scaling(0,scaling_factor,'forward'); 
            max_soc = soc_scaling(1,scaling_factor,'forward'); 

            for k = 1:length(ocv)
                SOC(k) = lookup(min_soc, max_soc, res, ocv_params, ocv(k));
            end
            function SOC = lookup(min_soc, max_soc, res, ocv_params, ocv)
                ea      = 1;
                xr      = double((min_soc + max_soc)/2);
                i       = 0;
                while(ea > res)
                    fxl = voltage_based_soc.get_ocv(ocv_params, min_soc) - ocv;
                    fxr = voltage_based_soc.get_ocv(ocv_params, xr) - ocv;
                    if(fxl*fxr<=0)
                        max_soc = xr;
                    elseif(fxl*fxr>0)
                        min_soc = xr;
                    end
                    xr_new  = (min_soc + max_soc)/2;
                    ea      = (abs(xr_new-xr)/xr_new);
                    ea      = ea*100;
                    i       = i+1;
                    xr      = xr_new;
                end
                SOC  = xr_new;
            end
        end

        function ocv = get_ocv(ocv_params, SOC)
            % OCV characterization using "combined +3" model
            % [1]. Pattipati, B., Balasingam, B., Avvari, G. V., Pattipati,
            % K. R., & Bar-Shalom, Y. (2014). Open circuit voltage
            % characterization of lithium-ion batteries. Journal of
            % Power Sources, 269, 317-333.
            ocv = ocv_params(1) + ocv_params(2).*(1./SOC) ...
                + ocv_params(3).*(1./(SOC.^2)) ...
                + ocv_params(4).*(1./(SOC.^3)) ...
                + ocv_params(5).*(1./(SOC.^4)) ...
                + ocv_params(6).*SOC + ocv_params(7).*(log(SOC)) ...
                + ocv_params(8).*(log(1-SOC));
        end

        function zk_v = add_noise(voltage, voltage_noise)
            zk_v = voltage + voltage_noise*randn(size(voltage));
        end
    end
end

