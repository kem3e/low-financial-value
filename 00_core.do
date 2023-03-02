/*******************************************************************************

PROJECT:		PSEO data analysis, "low-financial-value" programs
AUTHOR:			Katharine Meyer
FILE PURPOSE:	Core
DATE LAUNCHED:	2/14/2023	

*EARNINGS IN 2020 $
*Poverty line in 2020 for individual: https://aspe.hhs.gov/topics/poverty-economic-mobility/poverty-guidelines/prior-hhs-poverty-guidelines-federal-register-references/2020-poverty-guidelines

*******************************************************************************/

global project "V:\Katharine Meyer\low financial value programs"
global do "${project}/do files"
global output "${project}/output"
global raw "${project}/raw data"
global stata "${project}/stata files"

**************
**	IMPORT	**
**************
	*do "${do}/import.do"

**************
**	CLEAN	**
**************
	do "${do}/clean_pseo.do"
	do "${do}/import_scorecard" //import and clean

**************
**ANALYSIS**
**************
	do "${do}/analysis_pseo.do"
	do "${do}/analysis_scorecard.do"
	





