function output = compute_connectivity(input, pairs, freq, window, step)

    ninput = size(input,2);
    noutput = floor((ninput-window)/step);
    output = zeros(2, noutput, 4);          
    
    taus = [2 4 8 16];
%     ntau = length(taus);

    for npair = 1:length(pairs)
        pair = pairs{npair};
        np1 = length(pair{1});
        np2 = length(pair{2});
        for nstep = 1:noutput
            
            s0 = (nstep-1)*step+1;
            interval = s0:(s0+window);
            if interval(end) > ninput, continue; end
            
            data = input([pair{1} pair{2}], interval);

            % correlation
            corrout = corr(data');
            output(npair, nstep, 1) = mean(mean(corrout(1:np1, (np1+1):end)));

            % PLI
%             ft_connectivity_wpli

            % wSMI
            cfg = struct;
            cfg.chan_sel = 1:size(data,1);  % compute for all pairs of channels
            cfg.sf       = freq;  % sampling frequency
            cfg.taus     = taus;
            cfg.kernel   = 3; % kernel = 3 (3 samples per symbol)
            cfg.over_trials       = 0; 

            cfg.data_sel = 1:size(data,2); % compute using all samples
            [sym, count, smi, wsmi_tmp] = smi_and_wsmi(data, cfg);

            output(npair, nstep, 3) = mean(mean(wsmi_tmp{4}(1:np1, (np1+1):end)));
%             wsmi(:,:,ic,is) = mean(wsmi_tmp{1}, 3);
            
            % granger
        end
    end
    
end