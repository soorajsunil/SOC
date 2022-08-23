classdef current_simulator
    % simulates current signal for charging and discharging batteries
    % assumes positive current for charging and negative for discharging

    properties
        sampling_period(1,1)       % in secs
        signal_duration(1,1)       % in secs
        frequency(1,1)             % in hertz
        phase(1,1)                 % in radians
        amplitude(1,1)             % in Ampheres
        charge_pattern
    end

    properties(Dependent)
        current              % discrete-time current samples
        time                 % discrete-time in secs
        sample_length
    end

    properties(Dependent, Hidden)
        sampling_rate
    end

    methods
        function obj = current_simulator(varargin)
            % default values
            sampling_period = 0.1;    % in secs
            signal_duration = 10*60;    % in secs
            frequency       = 0.01;   % in hertz
            phase           = 0;      % in radians
            amplitude       = 1;      % in Ampheres
            charge_pattern  = 'constant';
            expectedPatterns = {'constant', 'pulse', 'alternate pulse'};

            p        = inputParser;
            validate = @(x) isnumeric(x) && isscalar(x);

            addOptional(p,'sampling_period', sampling_period, validate);
            addOptional(p,'signal_duration', signal_duration, validate);
            addOptional(p,'frequency',frequency, validate);
            addOptional(p,'phase',phase, validate);
            addOptional(p,'amplitude', amplitude, validate);
            addOptional(p, 'charge_pattern', charge_pattern, @(x) any(validatestring(x,expectedPatterns)));

            parse(p,varargin{:});

            obj.sampling_period =p.Results.sampling_period;
            obj.signal_duration =p.Results.signal_duration;
            obj.frequency =p.Results.frequency;
            obj.phase =p.Results.phase;
            obj.amplitude =p.Results.amplitude;
            obj.charge_pattern = p.Results.charge_pattern;
        end

        function sample_length = get.sample_length(obj)
            sample_length = obj.signal_duration*obj.sampling_rate;
        end

        function sampling_rate = get.sampling_rate(obj)
            sampling_rate = 1/obj.sampling_period;
        end

        function time = get.time(obj)
            time = (0:obj.sample_length-1)*obj.sampling_period;
        end

        function samples = get.current(obj)
            switch upper(obj.charge_pattern)
                case  'CONSTANT'
                    samples = obj.amplitude*ones(1,obj.sample_length);
                case 'PULSE'
                    samples = obj.amplitude*sign(sin(2*pi*obj.frequency*obj.time + obj.phase));
                    if obj.amplitude > 0
                        samples(samples<0)=0;
                    else
                        samples(samples>0) = 0;
                    end
                case 'ALTERNATE PULSE'
                    samples = obj.amplitude*sign(cos(2*pi*obj.frequency*obj.time + obj.phase));
                    % >> add more cases:
                    % random discharge profile - hint: used stairs function

                    % standard current profiles
            end
        end

        function plot(obj)
            figure(Name='Current')
            plot(obj.time, obj.current, 'b-', LineWidth=2)
            grid on; box on
            xlabel('Time (s)')
            ylabel('Current (A)')
            axis('padded')
        end
    end

end

