/*******************************************************************************

PROJECT:		PSEO data analysis, "low-financial-value" programs
AUTHOR:			Katharine Meyer
FILE PURPOSE:	Clean and append
DATE LAUNCHED:	2/14/2023	

*EARNINGS IN 2020 $
*Poverty line in 2020 for individual: https://aspe.hhs.gov/topics/poverty-economic-mobility/poverty-guidelines/prior-hhs-poverty-guidelines-federal-register-references/2020-poverty-guidelines

*******************************************************************************/

*Analysis/clean
foreach state in va mt in tx {
	
**EARNINGS**
	use "${stata}/`state'_earnings_raw.dta", clear

	foreach var in y1_p25_earnings y1_p50_earnings y1_p75_earnings y1_grads_earn y5_p25_earnings y5_p50_earnings y5_p75_earnings y5_grads_earn y10_p25_earnings y10_p50_earnings y10_p75_earnings y10_grads_earn y1_ipeds_count y5_ipeds_count y10_ipeds_count {
			destring `var', replace
		}
		
	*Set poverty benchmarks
	gen benchmark_poverty = 12760 //HHS 2020 poverty level
	gen benchmark_poverty_150 = benchmark_poverty*1.5
	gen benchmark_poverty_225 = benchmark_poverty*2.25
	gen benchmark_hsequivalent_a = 25000 //Cellini paper benchmark 
	gen benchmark_hsequivalent_b = 36600 //NCES: https://nces.ed.gov/programs/coe/indicator/cba/annual-earnings, for 2020, workers 25-34

	*Tag unique programs for analysis
	gen ciplevel_two = cip_level == "2"
	gen ciplevel_four = cip_level == "4"
	gen unique_program = ciplevel_four == 1 & grad_cohort == "0000" //flags the distinct programs at a school that have enough to aggregate across cohorts
		replace unique_program = 1 if grad_cohort == "0000" & label_degree_level=="Masters" & ciplevel_two==1
	gen unique_program_data = unique_program==1 & y5_p50_earnings!=.

	egen total_programs = sum(unique_program), by(institution)
	egen total_programs_data = sum(unique_program_data), by(institution)

	*Flag passing benchmarks
	egen institution_flag = tag(institution)

	foreach benchmark in poverty poverty_150 poverty_225 hsequivalent_a hsequivalent_b {
		
		gen met_`benchmark' = y5_p50_earnings>=benchmark_`benchmark' & unique_program_data==1 //0 if not focal row or didn't meet
		gen fail_`benchmark' = y5_p50_earnings<benchmark_`benchmark' & unique_program_data==1
			
	*By institution
		egen tot_met_`benchmark' = sum(met_`benchmark'), by(institution)	
		egen tot_fail_`benchmark' = sum(fail_`benchmark'), by(institution)
		gen share_met_`benchmark' = tot_met_`benchmark'/total_programs_data
		gen share_failed_`benchmark' = tot_fail_`benchmark'/total_programs_data
		egen any_fail_`benchmark' = max(fail_`benchmark'), by(institution)
	}
	
	*Limit sample for easier analysis
	keep if unique_program_data == 1

	gen state = "`state'"
	
	save "${stata}/`state'_earnings_clean.dta", replace
	
**EMPLOYMENT**
	use "${stata}/`state'_employment_raw.dta", clear
	
	*Calculate employment rates (hopefully right?)
	foreach cohort in 1 5 10 {
		destring y`cohort'_grads_emp y`cohort'_grads_nme y`cohort'_grads_emp_instate, replace
		gen y`cohort'_total = y`cohort'_grads_emp+y`cohort'_grads_nme
		gen share_y`cohort'_employed = y`cohort'_grads_emp/y`cohort'_total 
	}
	
	gen ciplevel_two = cip_level == "2"
	gen unique_program = ciplevel_two == 1 & grad_cohort == "0000" //flags the distinct programs at a school that have enough to aggregate across cohorts
	gen unique_program_data = unique_program==1 & y5_grads_emp!=.

	egen total_programs = sum(unique_program), by(institution)
	egen total_programs_data = sum(unique_program_data), by(institution)

	gen fail_50percent = share_y5_employed<.5
	gen fail_60percent = share_y5_employed<.6

	*Limit sample for easier analysis
	keep if unique_program_data == 1

	gen state = "`state'"

	save "${stata}/`state'_employment_clean.dta", replace

}

*Append for all state analysis
use "${stata}/va_earnings_clean.dta", clear
	append using "${stata}/mt_earnings_clean.dta"
	append using "${stata}/in_earnings_clean.dta"
	append using "${stata}/tx_earnings_clean.dta"
save "${stata}/pooled_earnings_clean.dta", replace
		
use "${stata}/va_employment_clean.dta", clear
	append using "${stata}/mt_employment_clean.dta"
	append using "${stata}/in_employment_clean.dta"
	append using "${stata}/tx_employment_clean.dta"	
save "${stata}/pooled_employment_clean.dta", replace
		
