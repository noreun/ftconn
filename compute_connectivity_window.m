function output = compute_connectivity_window(input, pairs, samp, window, step, foi)


    ninput = size(input,2);
    ntrials = floor((ninput-window)/step);
    output = zeros(length(pairs), length(foi), 2, 4);          

% data = 
% 
%   struct with fields:
% 
%       trial: {1×500 cell}
%        time: {1×500 cell}
%     fsample: 200
%       label: {3×1 cell}
%         cfg: [1×1 struct]

    
    for npair = 1:length(pairs)
        pair = pairs{npair};
        np1 = length(pair{1});
        np2 = length(pair{2});
        
        data = struct;
        data.trial = cell(1, ntrials);
        data.time = cell(1, ntrials);
        data.fsample = samp;
        data.label = cell(1, np1 + np2);
        for ip = 1:(np1+np2)
            data.label{ip} = sprintf('E%s', ip);
        end
        
        fprintf('Total number of trials : %d\n\n', ntrials)
        
        for nstep = 1:ntrials
            
            s0 = (nstep-1)*step+1;
            interval = s0:(s0+window);
            if interval(end) > ninput, continue; end
            
            data.trial{nstep} = input([pair{1} pair{2}], interval);
            data.time{nstep} = (0:(length(interval)-1))./samp;

        end

        cfg           = [];
        cfg.method    = 'mtmfft';
        cfg.taper     = 'dpss';
        cfg.output    = 'fourier';
        cfg.tapsmofrq = 2;
        cfg.foi       = foi;
        freq          = ft_freqanalysis(cfg, data);        
        
        
        
        cfgconn = [];
        cfgconn.jackknife = 'yes';
        
        % wpli
%         cfgconn.method = 'wpli_debiased';
        cfgconn.method = 'wpli';        
        wpli = ft_connectivityanalysis(cfgconn, freq);

        parameter = [cfgconn.method 'spctrm'];
        output(npair, :, 1, 1) = mean(mean(wpli.(parameter)(1:np1, (np1+1):end, :),1),2);
        output(npair, :, 2, 1) = mean(mean(wpli.([parameter 'sem'])(1:np1, (np1+1):end, :),1),2);

        % coherence
        cfgconn.method = 'coh';
        coh = ft_connectivityanalysis(cfgconn, freq);

        parameter = [cfgconn.method 'spctrm'];
        output(npair, :, 1, 2) = mean(mean(coh.(parameter)(1:np1, (np1+1):end, :),1),2);
        output(npair, :, 2, 2) = mean(mean(coh.([parameter 'sem'])(1:np1, (np1+1):end, :),1),2);

        % plv
        cfgconn.method = 'plv';
        coh = ft_connectivityanalysis(cfgconn, freq);

        parameter = [cfgconn.method 'spctrm'];
        output(npair, :, 1, 3) = mean(mean(coh.(parameter)(1:np1, (np1+1):end, :),1),2);
        output(npair, :, 2, 3) = mean(mean(coh.([parameter 'sem'])(1:np1, (np1+1):end, :),1),2);
        
%         cfg         = [];
%         cfg.order   = 5;
%         cfg.toolbox = 'bsmart';
%         cfg.foi       = foi;
%         mdata       = ft_mvaranalysis(cfg, data);
%         cfg        = [];
%         cfg.method = 'mvar';
%         mfreq      = ft_freqanalysis(cfg, mdata);

        % granger
        cfgconn.method = 'amplcorr';
        coh = ft_connectivityanalysis(cfgconn, freq);

        parameter = [cfgconn.method 'spctrm'];
        output(npair, :, 1, 4) = mean(mean(coh.(parameter)(1:np1, (np1+1):end, :),1),2);
        output(npair, :, 2, 4) = mean(mean(coh.([parameter 'sem'])(1:np1, (np1+1):end, :),1),2);
        
    end
    
end