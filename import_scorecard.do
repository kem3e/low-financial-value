/*******************************************************************************

PROJECT:		Scorecard data analysis, "low-financial-value" programs
AUTHOR:			Katharine Meyer
FILE PURPOSE:	Scorecard cost data
DATE LAUNCHED:	2/14/2023	

*******************************************************************************/


/*import
import delimited "${raw}\scorecard\Most-Recent-Cohorts-Field-of-Study.csv", clear 
save "${stata}/scorecard_field_raw.dta", replace
*/

*Clean
use "${stata}/scorecard_field_raw.dta", clear

	replace ipedscount2 = "" if ipedscount2=="NULL"
	destring ipedscount2, replace
	keep if ipedscount2>40 & ipedscount2!=. //at least 40 program graduates
	*The number of awards earned in this field of study represent completions amongst all students, not just students who received federal financial aid. These counts are specific to the branch location displayed in this school profile, exclusive of any other related locations. The number of individuals receiving these awards may be smaller than the number of awards conferred due to individuals receiving multiple awards in this field of study category.
	
	foreach var in debt_all_stgp_eval_mdn debt_all_stgp_eval_mdn10yrpay earn_ne_mdn_3yr {
		qui replace `var' = "" if `var' == "PrivacySuppressed"
		qui destring `var', replace
		qui drop if `var' == .
	}
	label var earn_ne_mdn_3yr "Median earnings of graduates not enrolled 3 years after completing highest credential"
	label var debt_all_stgp_eval_mdn10yrpay "Median estimated monthly payment for Stafford and Grad PLUS loan debt disbursed at this institution"
	label var earn_pell_ne_mdn_3yr "Median earnings of graduates who received a Pell Grant and were not enrolled 3 years after completing highest credential"
	label var earn_nopell_ne_mdn_3yr "Median earnings of graduates who did not receive a Pell Grant and were not enrolled 3 years after completing highest credential"

	gen monthly_wages = earn_ne_mdn_3yr/12
	gen debt_burden = debt_all_stgp_eval_mdn10yrpay/monthly_wages
	
	gen debt_12per_fail = debt_burden>.12
	gen debt_8per_fail = debt_burden>.08
	gen debt_20per_fail = debt_burden>.2
	
save "${stata}/scorecard_field_clean.dta", replace