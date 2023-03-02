/*******************************************************************************

PROJECT:		Scorecard data analysis, "low-financial-value" programs
AUTHOR:			Katharine Meyer
FILE PURPOSE:	Scorecare tables and figures
DATE LAUNCHED:	2/14/2023	

*******************************************************************************/

*Tables and Figures
use "${stata}/scorecard_field_clean.dta", clear

*Figure: Debt burden by credential level
	graph bar debt_20per_fail debt_12per_fail debt_8per_fail if credlev==1 | credlev==2 | credlev==3 | credlev==5 | credlev==7, over(credlev, relabel(1 "Undergraduate certificate/diploma" 2 "Associates" 3 "Bachelor's Degree" 4 "Master's Degree" 5 "First Professional Degree")) blabel(total, format(%5.2f)) ///
	title("Figure 3. Share of programs failing debt burden benchmarks, by credential level", size(medsmall)) ///
	graphregion(color(white)) ytitle("Share of unique programs", size(small)) ///
	legend(on label(1 "Benchmark: Debt <20% monthly income") label(2 "Benchmark: Debt <12% monthly income") label(3 "Benchmark: Debt <8% monthly income") col(1) size(small))
		graph save "${output}/faild2e_bycredential.gph", replace
		graph export "${output}/faild2e_bycredential.png", replace
	
	*Figure 3 data export
	use "${stata}/scorecard_field_clean.dta", clear
		preserve
			gen x = 1
			foreach var in debt_20per_fail debt_12per_fail debt_8per_fail {
				egen share_`var'_all = mean(`var')
			}
			collapse (mean) share_debt_20per_fail_all share_debt_12per_fail_all share_debt_8per_fail_all debt_20per_fail debt_12per_fail debt_8per_fail (sum) x, by(creddesc)
			export excel using "${output}\fig3_data.xls", firstrow(variables) replace
		restore
	
*Table: Professional Degrees and debt burden
use "${stata}/scorecard_field_clean.dta", clear
	gen x = 1
	collapse (mean) monthly_wages debt_all_stgp_eval_mdn10yrpay debt_burden (sum) x if inlist(cipdesc, "Law.", "Medicine.", "Pharmacy, Pharmaceutical Sciences, and Administration."), by(cipdesc debt_20per_fail)