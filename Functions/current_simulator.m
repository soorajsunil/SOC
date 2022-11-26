classdef current_simulator
    % simulates battery current profiles
    % >> assumes positive current for charging and negative for discharging
    properties
        current                % discrete-time current samples
        time                   % discrete-time in secs
        sampling_period(1,1)   % in secs
        duration(1,1)          % signal duration in secs
        sample_length          % sample length
        profile                % options: {options: 'pulse', 'random'}

        %  sinusoid signal properties for pulse control:
        frequency  % in hertz
        phase      % in radians
        amplitude  % in Ampheres
    end

    properties(Hidden)
        Fs   % sampling rate in hertz
        Tend
    end

    methods
        function obj = current_simulator(varargin)

            % default values for properties:
            sampling_period = 0.1;     % in secs
            duration        = 600;     % in secs
            profile         = 'pulse';
            expectedProfiles= {'pulse', 'random'};
            frequency       = 1;       % in hertz
            phase           = 0;       % in radians
            amplitude       = 1;       % in Ampheres

            % parser code to pick default values:
            p        = inputParser;
            validate = @(x) isnumeric(x) && isscalar(x);
            addOptional(p,'sampling_period', sampling_period, validate);
            addOptional(p,'duration', duration, validate);
            addOptional(p,'frequency',frequency, validate);
            addOptional(p,'phase',phase, validate)
            addOptional(p,'amplitude', amplitude, @(x) isnumeric(x));
            addOptional(p, 'profile', profile, ...
                @(x) any(validatestring(x,expectedProfiles)));
            parse(p,varargin{:});
            obj.sampling_period = p.Results.sampling_period;
            obj.duration        = p.Results.duration;
            obj.profile         = p.Results.profile;
            obj.frequency       = p.Results.frequency;
            obj.phase           = p.Results.phase;
            obj.amplitude       = p.Results.amplitude;

            obj = sampling(obj);            % sampling
            obj = simulate_profile(obj);    % simulate
        end

        function obj = sampling(obj)
            obj.Fs   = 1/obj.sampling_period; % sampling frequency (F=1/Ts)
            obj.Tend = obj.Fs*obj.duration;
            obj.time = (0:obj.Tend-1)*obj.sampling_period ;
            obj.sample_length = length(obj.time);
        end

        function obj = simulate_profile(obj)
            switch upper(obj.profile)
                case 'PULSE'
                    switch length(obj.amplitude)
                        case 1
                            obj.current = obj.amplitude*sign( ...
                                sin(2*pi*obj.frequency*obj.time + obj.phase));
                            if obj.amplitude > 0
                                obj.current(obj.current<0) = 0;
                            elseif obj.amplitude < 0
                                obj.current(obj.current>0) = 0;
                            end
                        case 2
                            obj.current = sign( ...
                                sin(2*pi*obj.frequency*obj.time + obj.phase));
                            obj.current(obj.current==1) = obj.amplitude(1);
                            obj.current(obj.current==-1) = obj.amplitude(2);
                        otherwise
                            error('check amplitude dimensions!')
                    end
                case 'RANDOM'
                    % check:: has some issue for lower sampling period 
                    obj.current = zeros(size(obj.time));
                    n = 0;
                    amp_range  = [-1,1]; 
                    freq_range = [0,1]; 
                    for i = 1:floor(obj.Tend/obj.Fs)
                        t_i = obj.time((n*obj.Fs+1):((n+1)*obj.Fs));
                        f_i = obj.frequency*randi(freq_range);
                        a_i = obj.amplitude*randi(amp_range);
                        obj.current((n*obj.Fs+1):((n+1)*obj.Fs)) = ...
                            a_i*sign(cos(2*pi*f_i*t_i + obj.phase));
                        n = n + 1;
                    end
            end
        end
    end
end

