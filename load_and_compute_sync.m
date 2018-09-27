% Compute sychrony between pair of (regions) electrodes from EEGLAB files
% Leonardo S. Barbosa - Sept 2018
%

%% Define input variables 

inputfolder = '/data2/lucidcomplexity/dataset1/original';
inputfile = '_ICApruned_avgref_';

subjects = {'AB', 'DC', 'MC', 'RB'};
raw = struct;

freq = 1000;

% addpath('/home/leobar/matlab/eeg')

addpath('/home/leobar/matlab/fieldtrip')
ft_defaults

addpath('/home/leobar/projects/wSMI')

%% load files

for subject = subjects
    load([ inputfolder filesep subject{1} inputfile 'LUCID' ], 'lucid_epoched');
    load([ inputfolder filesep subject{1} inputfile 'REM' ], 'rem_epoched');
    raw.(subject{1}).lucid_epoched = lucid_epoched;
    raw.(subject{1}).rem_epoched = rem_epoched;
end

% EEG = pop_loadset('Lucid_hdEEG_exampledataset.set', inputfolder);

%% Compute connectivity

nsim = 100;

taus = [20 48 128];

% window = 10000;
% step = 1000;

%     pairs = { {[23], [101, 105, 100, 104]},...
%               {[55], [62, 68, 72, 73]}};

% pairs = { {[23, 24, 18, 19], [101, 105, 100, 104]},...
%           {[55, 56, 18, 51], [62, 68, 72, 73]}};
% pairs_label = {'Left', 'Right'};

pairs = { {[23, 24, 18, 19, 55, 56, 18, 51], [101, 105, 100, 104, 62, 68, 72, 73]} };
pairs_label = {'Left_and_Right'};

% % cross
% pairs = { {[23, 24, 18, 19], [62, 68, 72, 73]},...
%           {[55, 56, 18, 51], [101, 105, 100, 104]}};
          
fprintf('Computing ... \n');
ytic = tic;
results = struct;
for subject = subjects
    
    lucid = raw.(subject{1}).lucid_epoched;
    nlucid = size(lucid, 2);
    rem = raw.(subject{1}).rem_epoched;
    nrem = size(rem, 2);
    
    nmax = min(nlucid, nrem);
    
    lucid = lucid(:, 1:nmax);
    rem = rem(:, 1:nmax);
    
    fprintf('Computing for subject %s... \n',subject{1});
    xtic = tic;
    results.(subject{1}) = compute_connectivity2(lucid, rem, pairs, freq, taus, nsim);
    fprintf('done subject. Took %2.2f minutes\n', toc(xtic)/60);

end
fprintf('Total time %2.2f minutes\n', toc(ytic)/60);

save(sprintf('/data2/lucidcomplexity/dataset1/results/wsmi_nsim_%d_electrodes_%s.mat', nsim, sprintf('%s_', pairs_label{:})), 'results')

%% Plot results

% load(sprintf('/data2/lucidcomplexity/dataset1/results/wsmi_nsim_%d_electrodes_%s.mat', nsim, sprintf('%s_', pairs_label{:})), 'results')

% figure
computations = {'Linear', sprintf('wSMI %d',taus(1)), sprintf('wSMI %d',taus(2)), sprintf('wSMI %d',taus(3))};
ncomp = 4;
nlin = 4; ncol = length(subjects);

for r = 1:size(result, 1)

    figure('name', sprintf('%s', pairs_label{r}))
    
    for is = 1:length(subjects)
        subject = subjects{is};
        result = results.(subject);

        for comp = 1:ncomp
            subplot(nlin, ncol, comp + (is-1)*ncomp)

    %         errorbar(r, result.mean(r, comp), result.var(r,comp))
    %         hold on
    %         plot(r, result.real(r, comp), 'k*');
    
            histogram(result.sur(r,comp,:))
            hold on
            line(result.real(r, comp) .* [1,1], ylim, 'color', 'r', 'linewidth', 2);
            P = sum(result.sur(r,comp,:) < result.real(r,comp)) / size(result.sur,3);
            if P>.9 || P<.1
                set(gca, 'color', [.6, .6, .6])
            end
            title(sprintf('%s (P %2.2f)', computations{comp}, P))
            
            if comp == 1
                ylabel(subject)
            end
        end

    end
end

% legend({'Lucid Left', 'Lucid Right', 'REM left', 'REM right'})

%%






