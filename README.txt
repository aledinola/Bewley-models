This folder contains:

v0: Neoclassical growth model with/without endogenous labor supply.

v1: Bewley model...

v2: Bewley model...

v3: Bewley model with exogenous labor supply. Household problem: discrete grid and
    then VFI with interpolation. Vectorized Howard accelation method. Solves GE in <30 
    seconds. Accuracy checks (EEE) are also implemented. EEE takes occasionally
    binding constraints into account.

v3_2: Replication of paper by Badshah, Muffasir, Paul Beaumont and Anuj Srivastava.2013. 
      "Computing Equilibrium Wealth Distributions in Models with Heterogeneous-Agents, 
      Incomplete Markets and Idiosyncratic Risk." 
      Computational Economics, Vol. 41, No. 2: 171-193.
      GE loop is implemented via iteration on aggregate K, using binary search.

v4: Similar to v3 but with some small functions added. Also some polishing done.

v5: Bewley model with endogenous labor supply. To be implemented yet.

Release: Files to be uploaded on my Github profile.


%------------------------------------------------------------------------------%
% STRUCTURE
%------------------------------------------------------------------------------%

- main. Set all parameters and flags here
  - fzero or any other nonlinear equation solver
    - excess_demand
      - prices: given r, compute capital and wage from 
                firm FOCs  
      - solve_household
      	- VFI_discrete: 
        	- ReturnFn
      	- VFI_interp:
        	- ReturnFn, bellman
      - get_distribution
      - aggregation and compute excess demand = demand-supply

Users need to change only the following functions:
ReturnFn, prices, aggregate

%------------------------------------------------------------------------------%
% RESOURCES
%------------------------------------------------------------------------------%

- Markus Poschke, RED article. Endogen labor supply (VFI discrete and EGM continuous)
- Mitman MIT shocks paper. EGM with endo labor supply. NO VFI :(
- Villaverde, comparison JEDC 2006 (see VFI with endog labor supply)
- Paul Klein problem sets, see neoclassical growth model with endog LS
- Jochen Mankhart? 
   a) useful for EE error in case occasionally binding constraints
   b) useful also for bisection

- This software is based on that of Lilia  Maliar and Serguei Maliar for 
solving 
  the neoclassical stochastic growth model with elastic labor supply
 using four 
  alternative solution methods, as described in the paper 
 
  "Envelope Condition Method versus Endogenous Grid Method for Solving Dynamic Programming Problems" 
  by Lilia Maliar and Serguei Maliar, Economics 
Letters (2013), 120, 262-266 (henceforth, MM, 2013).

- Neoclassical growth model with elastic labor supply:
  Section 5.6 of the Chapter by Fernandez-Villaverde,
  Rubio-Ramirez and Schorfheide in the Handbook of Macroeconomics 2016

********************************************************************************

TO DO LIST

1) Function "prices" DONE
2) Function "aggregates". Computes EA using mu and policies. DONE
   Computes also ED. Check Robert's files
3) Two main additions: endogenous labor supply (see resources above)
   and government loop (see Kaymak and Poschke and R.Kirkby)


