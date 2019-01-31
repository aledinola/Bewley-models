clear;clc;close all

%% This is the master file

% DESCRIPTION: Set parameters and flags in this file. Then choose whether
% you want to run the model for fixed parameters or you want to do
% calibration/comparative statics (set flag "do_comp" appropriately)

% Add COMPECON and its subfolders to matlab path
%addpath(genpath('COMPECON'))

folders.newSubFolder = 'results';
folders.SaveDir = [pwd '\results\'];

%-------------------------------------------------------------------------%
% PARALLEL COMPUTING options
params.do_parallel = 1;
if params.do_parallel==1
    p = gcp('nocreate');
    pool='local'; % select machine
    if isempty(p)
      c = parcluster;
      parpool(pool,c.NumWorkers)
      p = gcp('nocreate');
    end
end
%-------------------------------------------------------------------------%

%% Economic parameters - fixed
params.A         = 1; % rescale production function
params.sigma     = 2; % relative risk aversion consumption
params.beta      = 0.96;%0.95; % discount factor
params.alpha     = 0.36; % cobb-douglas capital
params.delta     = 0.08; % annual depreciation rate


% Define the utility function
sigma = params.sigma; %DO NOT MIX UP with sigma as stdev in AR(1)!!
params.uf = @(c) c.^(1-sigma)/(1-sigma);
params.muf = @(c) c.^(-sigma); % marginal utility of consumption
params.muf_inv = @(c) c.^(-1/sigma); % inverse of marginal utility of cons.


%% Parameters that change

rho_vec   = [0.3,0.3,0.6,0.9];
sigma_vec = [0.04 0.16];


%% Computational parameters

do_comp = 0; % 0= run for given parameters; 1= do comparative statics

% General equilibrium loop
ge.do_GE      =1; % 0= partial eq, 
                  % 1= general eq, rootfinding
                  % 2= general eq, fixed point with relaxation
                  % 3= grid for price/int.rate, draw graph for ED and check
                  % uniqueness of equilibrium
ge.fzero_algo = 0; % 0=mybrent, 1=matlab fzero, 2=bisect, 3=ridders
ge.tol_r      = 1e-8; % Tolerance for GE loop over r (if VFI with interp, I can set this very strict)
ge.qq_max     = 20;     % Max number iterations GE loop
ge.damp       = 0.99;   % dampening update of Kbar and Nbar (weight given to previous guess)

% Household's problem: solution method
params.flag_discrete = 2; % flag_discrete = 1 - only vfi on discrete grid
                          % flag_discrete = 2 - vfi with piecewise linear/cubic
                          % interpolation (discrete vfi used only as initial guess)
                          % flag_discrete = 3 - time iteration Euler eq.
                          % flag_discrete = 4 - EGM Euler eq.
params.interp        = 1; % 1 = linear interpolation, 2 = cubic (pchip)                 

% Grid spacing (best: 2 or 4)
params.grid_method   = 4; % choose how you want to space the capital grid:
                        % 1 = Equally spaced
                        % 2 = Logarithmic spacing 
                        % 3 = Chebyshev nodes
                        % 4 = Kindermann's method
                        % 5 = generalization of method 2
params.growth   = 0.01; % used ONLY if grid_method=4
params.growth5  = 1.5;  % used ONLY if grid_method=5

% Value Function Iteration
params.tol_v    = 1e-6;  % Tolerance for vfi
params.tol_v_d  = 1e-6;  % Tolerance for vfi (discrete)
params.tol_pfi  = 0.0001; % Tolerance for policy function iter
params.tolGSS   = 1e-7;   % Tolerance for golden section search (inside VFI)
params.maxiterv = 1000;   % Max number iterations value function 
params.maxiterv_d = 100;  % Max number iterations value function (discrete)
params.howard          = 1; % 0/1: Howard acceleration in VFI_interp 
params.howard_discrete = 1; % 0/1: Howard acceleration in VFI_discrete
params.algo_howard     = 2; % 1: (VFI_discrete) forever, 
                            % 2: Modified Howard algo, 
                            %    only finite number of iterations

% Distribution
params.tol_mu        = 1e-12;   % Tolerance for MU
params.iter_mu_max   = 50000; % Max number iterations for MU
params.tauchen_flag = 1; % 1= use Tauchen method,0=insert manually shock

% Related to display/figures/tables/extra results
params.show_fig     = 0; % Display figures inside excess_demand (0-1)
params.show_fig_results = 1; % Display figures inside "results" (0-1)
params.disp         = 0; % Display intermediate results (vfi,iterations etc.)
params.do_EEE       = 0; % 0/1: do Euler equation error analysis
params.do_gini      = 1; % 0/1: compute Lorenz curve and other distrib. statistics
params.do_save      = 0; % 0/1: save results as a mat file

%% Setup grids for capital/assets and for exogenous shocks
% params is a structure

params.amin    = 0;%1e-6;
params.amax    = 100;
params.na      = 1000;     % Number of points for capital
params.na_fine = params.na;%params.na*3; % Finer grid for distribution 
                            % ("na_fine" should be equal to or greater than "na")
params.nz      = 7;


%% Comparative statics loop

if do_comp==0
    % Calibration of Kindermann 2018
    params.rho = 0.6;
    dummy      = 0.04;
    params.sigma_eps = sqrt(dummy)*sqrt(1-params.rho^2);
    % Var(s) = sigma_eps^2/(1-rho^2) 
    outputvec = fun_model(params,ge,folders); %[r0,cv_cons]
else
    disp('START COMPARATIVE STATICS')
    fprintf(' \n');
    MyTable = zeros(length(rho_vec),length(sigma_vec),2);
    for rho_ind=1:length(rho_vec)
        for sigma_ind=1:length(sigma_vec)
            
            params.rho   = rho_vec(rho_ind);
            dummy        = sigma_vec(sigma_ind);
            params.sigma_eps = sqrt(dummy)*sqrt(1-params.rho^2);%0.08; % variance
            % Var(s) = sigma_eps^2/(1-rho^2) ==> Var(s) = 0.04
            
            fprintf('RHO   = %5.3f\n',params.rho);
            fprintf('SIGMA = %5.3f\n',dummy);
            fprintf(' \n');
            outputvec = fun_model(params,ge,folders); %[r0,cv_cons]
            % Fill in table for CV of consumption
            MyTable(rho_ind,sigma_ind,1) = outputvec(1);
            % Fill in table for Interest rate
            MyTable(rho_ind,sigma_ind,2) = outputvec(2);
        end
    end
    
%% Export table with comparative statics results to a tex file    
        
MyLatex( MyTable,folders.SaveDir );
    
end %end IF do_comp

