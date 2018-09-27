cfg             = [];
cfg.ntrials     = 500;
cfg.triallength = 1;
cfg.fsample     = 200;
cfg.nsignal     = 3;
cfg.method      = 'ar';
% 
% cfg.params(:,:,1) = [ 0.8    0    0 ; 
%                         0  0.9  0.5 ;
%                       0.4    0  0.5];
%                       
% cfg.params(:,:,2) = [-0.5    0    0 ; 
%                         0 -0.8    0 ; 
%                         0    0 -0.2];
%                         
% cfg.noisecov      = [ 0.3    0    0 ;
%                         0    1    0 ;
%                         0    0  0.2];

cfg.params(:,:,1) = [ 0    0    0 ; 
                      0    0    0 ;
                      0    0    0];

% cfg.params(:,:,1) = [ .3    0    0 ; 
%                       0    .4    .5 ;
%                       .4    0    .25];
                  
cfg.params(:,:,2) = [0    0    0 ; 
                     0    0    0 ; 
                     0    0    0];
                        
cfg.noisecov      = [ 0.3    0    0 ;
                        0    1    0 ;
                        0    0  0.2];

data              = ft_connectivitysimulation(cfg);

% %%
% 
% figure
% plot(data.time{1}, data.trial{1}) 
% legend(data.label)
% xlabel('time (s)')

%%

cfg           = [];
cfg.method    = 'mtmfft';
cfg.taper     = 'dpss';
cfg.output    = 'fourier';
cfg.tapsmofrq = 2;
cfg.foi = .5:.5:55;
freq          = ft_freqanalysis(cfg, data);

%%

cfgconn = [];
cfgconn.method = 'wpli_debiased';
% cfgconn.method = 'wpli';
cfgconn.jackknife = 'yes';
wpli = ft_connectivityanalysis(cfgconn, freq);

% %%
% 
% figure
cfg           = [];
cfg.parameter = [cfgconn.method 'spctrm'];

% % cfg.zlim      = [0 1];
% wpli_plus = wpli;
% wpli_plus.(cfg.parameter) = wpli.(cfg.parameter) + wpli.([cfg.parameter 'sem']) ;
% wpli_minus = wpli;
% wpli_minus.(cfg.parameter) = wpli.(cfg.parameter)  - wpli.([cfg.parameter 'sem']);
% 
% ft_connectivityplot(cfg, wpli_plus, wpli_minus);


%%

np1 = 2;

output = mean(mean(wpli.(cfg.parameter)(1:np1, (np1+1):end, :),1),2);
outputsem = mean(mean(wpli.([cfg.parameter 'sem'])(1:np1, (np1+1):end, :),1),2);

figure;
shadedErrorBar(freq.freq,output,outputsem)






