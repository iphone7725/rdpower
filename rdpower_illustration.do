******************************************************************************** 
** RDPOWER Stata Package 
** Do-file for Empirical Illustration
** Authors: Matias D. Cattaneo, Rocio Titiunik and Gonzalo Vazquez-Bare
** Date: 09-Oct-2018
********************************************************************************
** hlp2winpdf, cdn(rdpower) replace
** hlp2winpdf, cdn(rdsampsi) replace
********************************************************************************
** net install rdpower, from(http://www-personal.umich.edu/~cattaneo/software/rdpower/stata) replace
********************************************************************************
clear all
set more off
set linesize 90
mata: mata mlib index


********************************************************************************
** Summary Stats
********************************************************************************
sjlog using output/out0, replace
use rdpower_senate.dta, clear
sum demmv demvoteshfor2 population dopen dmidterm
sjlog close, replace


********************************************************************************
** RDPOWER
********************************************************************************

********************************************************************************
** rdpower against tau = 5
********************************************************************************
sjlog using output/out1, replace
rdpower demvoteshfor2 demmv, tau(5)
sjlog close, replace


********************************************************************************
** rdpower with covariates
********************************************************************************
sjlog using output/out2, replace
rdpower demvoteshfor2 demmv, tau(5) covs(population dopen dmidterm)
sjlog close, replace


********************************************************************************
** rdpower with user-specified plot options
********************************************************************************
sjlog using output/out3, replace
rdpower demvoteshfor2 demmv, tau(5) plot graph_range(-9 9) graph_step(2) ///
		                     graph_options(title(Power function) ///
							 xline(0, lcolor(black) lpattern(dash)) ///
							 yline(.05, lpattern(shortdash) lcolor(black)) ///
							 xtitle(tau) ytitle(power) ///
							 graphregion(fcolor(white))) 
sjlog close, replace
graph export output/figure1.pdf, replace


********************************************************************************
** rdpower with rdrobust options
********************************************************************************
sjlog using output/out4, replace
rdpower demvoteshfor2 demmv, tau(5) h(16 18) b(18 20)
sjlog close, replace

sjlog using output/out5, replace
rdpower demvoteshfor2 demmv, tau(5) kernel(uniform) vce(cluster state)
sjlog close, replace

sjlog using output/out6, replace
rdpower demvoteshfor2 demmv, tau(5) bwselect(certwo) vce(hc3) scaleregul(0) rho(1)
sjlog close, replace


********************************************************************************
** rdpower with conventional inference
********************************************************************************
sjlog using output/out7, replace
rdpower demvoteshfor2 demmv, tau(5) all
sjlog close, replace


********************************************************************************
** rdpower with user-specified bias and variance
********************************************************************************
sjlog using output/out8, replace
qui rdrobust demvoteshfor2 demmv

local samph = e(h_l)
local sampsi_l = e(N_h_l)
local sampsi_r = e(N_h_r)

local bias_l = e(bias_l)/e(h_l)
local bias_r = e(bias_r)/e(h_r)

mat VL_RB = e(V_rb_l)
mat VR_RB = e(V_rb_r)

local Vl_rb = e(N)*e(h_l)*VL_RB[1,1]
local Vr_rb = e(N)*e(h_r)*VR_RB[1,1]

rdpower demvoteshfor2 demmv, tau(5) bias(`bias_l' `bias_r') ///
                             var(`Vl_rb' `Vr_rb') ///
							 samph(`samph') sampsi(`sampsi_l' `sampsi_r')
sjlog close, replace


********************************************************************************
** rdpower manually increasing variance by 20%
********************************************************************************
sjlog using output/out9, replace
qui rdrobust demvoteshfor2 demmv

mat VL_RB = e(V_rb_l)
mat VR_RB = e(V_rb_r)

local Vl_rb = e(N)*e(h_l)*VL_RB[1,1]*1.2
local Vr_rb = e(N)*e(h_r)*VR_RB[1,1]*1.2

rdpower demvoteshfor2 demmv, tau(5) var(`Vl_rb' `Vr_rb')
sjlog close, replace


********************************************************************************
** rdpower without data
********************************************************************************

sjlog using output/out10, replace
qui rdpower demvoteshfor2 demmv, tau(5)
rdpower, tau(5) nsamples(r(N_l) r(N_h_l) r(N_r) r(N_h_r)) ///
		 bias(r(bias_l) r(bias_r)) ///
		 var(r(Vl_rb) r(Vr_rb)) sampsi(r(sampsi_l) r(sampsi_r)) ///
		 samph(r(samph_l) r(samph_r))
sjlog close, replace

********************************************************************************
** comparing ex-post power across specifications
********************************************************************************

sjlog using output/out11, replace
rdpower demvoteshfor2 demmv, tau(5) p(1) h(20) plot
sjlog close, replace
graph export output/figure2_1.pdf, replace

sjlog using output/out12, replace
rdpower demvoteshfor2 demmv, tau(5) p(2) h(20) plot
sjlog close, replace
graph export output/figure2_2.pdf, replace	

sjlog using output/out13, replace
rdpower demvoteshfor2 demmv, tau(5) p(1) plot
sjlog close, replace
graph export output/figure2_3.pdf, replace

sjlog using output/out14, replace
rdpower demvoteshfor2 demmv, tau(5) p(2) plot
sjlog close, replace
graph export output/figure2_4.pdf, replace
	

********************************************************************************
** RDSAMPSI
********************************************************************************

********************************************************************************
** rsampsi with tau = 5
********************************************************************************
sjlog using output/out15, replace
rdsampsi demvoteshfor2 demmv, tau(5)
sjlog close, replace

********************************************************************************
** rsampsi with tau = 5 setting bandwdith and nratio with plot
********************************************************************************
sjlog using output/out16, replace
rdsampsi demvoteshfor2 demmv, tau(5) beta(.9) samph(18 19) nratio(.5) plot
sjlog close, replace
graph export output/figure3.pdf, replace

********************************************************************************
** rsampsi with conventional inference
********************************************************************************
sjlog using output/out17, replace
rdsampsi demvoteshfor2 demmv, tau(5) all
sjlog close, replace

********************************************************************************
** rsampsi vs rdpower
********************************************************************************
sjlog using output/out18, replace
qui rdsampsi demvoteshfor2 demmv, tau(5)
rdpower demvoteshfor2 demmv, tau(5) sampsi(r(sampsi_h_l) r(sampsi_h_r))
sjlog close, replace

********************************************************************************
** rsampsi without data
********************************************************************************

sjlog using output/out19, replace
qui rdsampsi demvoteshfor2 demmv, tau(5)
local init = r(init_cond)
rdsampsi, tau(5) nsamples(r(N_l) r(N_h_l) r(N_r) r(N_h_r)) ///
				 bias(r(bias_l) r(bias_r)) ///
				 var(r(var_l) r(var_r)) ///
				 samph(r(samph_l) r(samph_r)) ///
				 init_cond(`init')
sjlog close, replace

********************************************************************************
** comparing sample sizes across designs
********************************************************************************

sjlog using output/out20, replace
rdsampsi demvoteshfor2 demmv, tau(5) p(0) h(20) plot
sjlog close, replace
graph export output/figure4_1.pdf, replace

sjlog using output/out21, replace
rdsampsi demvoteshfor2 demmv, tau(5) p(1) h(20) plot
sjlog close, replace
graph export output/figure4_2.pdf, replace

sjlog using output/out22, replace
rdsampsi demvoteshfor2 demmv, tau(5) p(0) plot
sjlog close, replace
graph export output/figure4_3.pdf, replace

sjlog using output/out23, replace
rdsampsi demvoteshfor2 demmv, tau(5) p(1) plot
sjlog close, replace
graph export output/figure4_4.pdf, replace
