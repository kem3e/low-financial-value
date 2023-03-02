/*******************************************************************************

PROJECT:		PSEO data analysis, "low-financial-value" programs
AUTHOR:			Katharine Meyer
FILE PURPOSE:	PSEO figures
DATE LAUNCHED:	2/14/2023	

*EARNINGS IN 2020 $
*Poverty line in 2020 for individual: https://aspe.hhs.gov/topics/poverty-economic-mobility/poverty-guidelines/prior-hhs-poverty-guidelines-federal-register-references/2020-poverty-guidelines

*******************************************************************************/

*Tables and Figures
	*Figure 1
	use "${stata}/pooled_earnings_clean.dta", clear

	graph bar fail_poverty_225 fail_hsequivalent_b if inlist(Degree, "01", "02", "03", "05", "07"), over(label_degree_level) blabel(total, format(%5.2f)) ///
	title("Figure 1. Share of programs failing earnings benchmarks by credential level", size(medsmall)) ///
	graphregion(color(white)) ytitle("Share of unique programs", size(small)) ///
	legend(on label(1 "Benchmark: 225% of federal poverty line") label(2 "Benchmark: Average high school graduate wage") col(1) size(small))
		graph save "${output}/failearnings_bycredential.gph", replace
		graph export "${output}/failearnings_bycredential.png", replace
	*Note: Compares the median earnings five years following program completion to listed earnings benchmarks. Program refers to a unique field-of-study and credential level combination. Programs reported at the four-digit CIP level. Uses pooled cohort data (includes graduating cohorts of 2001-2016, with exact cohorts varying by program and institution). Limited to states reporting data on more than 75% of graduates (Indiana, Montana, Texas, and Virginia). Thresholds and earnings adjusted to 2020 dollars. Graph does not separatley present doctoral/first professional degree programs or 2-4 year certificates due to small sample size, but programs are included in estimating overall rates.
	*Source: Author's calculations using the U.S. Census Post-Secondary Employment Outcomes data.
	
	*Figure 1 data
	use "${stata}/pooled_earnings_clean.dta", clear
	preserve
		gen x = 1
		egen share_fail_poverty_225_all = mean(fail_poverty_225)
		egen share_fail_hsequivalent_b_all = mean(fail_hsequivalent_b)
		collapse (mean) fail_poverty_225 fail_hsequivalent_b share_fail_poverty_225_all share_fail_hsequivalent_b_all (sum) x, by(label_degree_level)
		export excel using "${output}\fig1_data.xls", firstrow(variables) replace
	restore

	*Programs failing earnings
	use "${stata}/pooled_earnings_clean.dta", clear
	preserve
		gen x = 1
		collapse (mean) fail_poverty_225 fail_hsequivalent_b (sum) x (first) cipcode, by(label_cipcode label_degree_level)
		gsort -fail_poverty
		br if x>=40
	restore


	*Figure 2, employment outcomes
	use "${stata}/pooled_employment_clean.dta", clear
	
	graph bar fail_50percent fail_60percent if inlist(Degree, "01", "02", "03", "05", "07"), over(label_degree_level) blabel(total, format(%5.2f)) ///
	title("Figure 2. Share of programs failing employment benchmarks by credential level", size(medsmall)) ///
	graphregion(color(white)) ytitle("Share of unique programs", size(small)) ///
	legend(on label(1 "Benchmark: >=50% graduates employed") label(2 "Benchmark: >=60% graduates employed") col(1) size(small))
		graph save "${output}/failemploy_bycredential.gph", replace
		graph export "${output}/failemploy_bycredential.png", replace

	
	*Figure 2 data
	use "${stata}/pooled_employment_clean.dta", clear
	preserve
		gen x = 1
		egen share_fail_50percent = mean(fail_50percent)
		egen share_fail_60percent = mean(fail_60percent)
		collapse (mean) fail_50percent fail_60percent share_fail_50percent share_fail_60percent (sum) x, by(label_degree_level)
		export excel using "${output}\fig2_data.xls", firstrow(variables) replace
	restore

	*Programs failing employment
	use "${stata}/pooled_employment_clean.dta", clear
	preserve
		gen x = 1
		collapse (mean) fail_50percent fail_60percent (sum) x (first) cipcode, by(label_cipcode label_degree_level)
		gsort -fail_50percent
		br if x>=40
	restore
	

