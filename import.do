/*******************************************************************************

PROJECT:		PSEO data analysis, "low-financial-value" programs
AUTHOR:			Katharine Meyer
FILE PURPOSE:	Import PSEO
DATE LAUNCHED:	2/14/2023	

*******************************************************************************/

*IMPORT PSEO (this takes a long time)
foreach state in va mt in tx {
	*Earnings
	import excel "${raw}/pseo_`state'.xlsx", sheet("Earnings") firstrow case(lower) clear
		drop in 1/4
		foreach var of varlist * {
		   rename `var' `=`var'[1]'
		}
		drop in 1
		
		*Restrict sample
		keep if strpos(label_geography, "National")!=0 //keep if find National inside label_geography
			capture drop label_geography geography geo_level label_geo_level //all constants now
		keep if industry=="00" //look at employment regardless of career field
			capture drop industry label_industry label_ind_level //all constants now
		
		*Label
		foreach i in 1 5 10 {
			label var y`i'_grads_earn "Count of Employed Graduates in Year `i'"
			label var y`i'_ipeds_count "Count of IPEDS Reported Graduates of Programs Included in Year `i' Earnings"
		}
	save "${stata}/`state'_earnings_raw.dta", replace
	
	*Employment
	import excel "${raw}/pseo_`state'.xlsx", sheet("Flows") firstrow case(lower) clear
	
		drop in 1/5
		foreach var of varlist * {
		   rename `var' `=`var'[1]'
		}
		drop in 1
		keep if strpos(label_geography, "National")!=0 //keep if find National inside label_geography
			capture drop label_geography geography geo_level label_geo_level //all constants now
		keep if industry=="00" //look at employment regardless of career field
			capture drop industry label_industry label_ind_level //all constants now
		
	save "${stata}/`state'_employment_raw.dta", replace

}