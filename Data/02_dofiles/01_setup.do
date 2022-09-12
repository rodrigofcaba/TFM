clear all
set more off

use Data/01_raw/E-DEM-Waves-Dataset, clear

* Reshape wide to long format for panel data:
unab vars: *_1
local stubs : subinstr local vars "_1" "", all

local y_vars
foreach x of local stubs{
local y_vars `y_vars' `x'_
}

reshape long  ///
s0_ s1_ s2_ s2R_ s3a_ s4a_ s8_ /// //sociodemografic vars
p4a_ p4b_ p4c_ p4d_ p4e_ p4f_ p4g_ p4h_ ///
p11f_ p11g_ p11h_ p11i_ p11r_ /// //feelings towards party voters
p7l_ p9l_ p14h_ ///
p35_ p35a_ /// //party id
p37a_ p37b_ p38a_ ///
p72a_ p72b_ p72c_ p72e_ p72l_ p72f_ ///
p75_ ///
p74a_ p74b_ p74c_ p74e_ p74l_ p74f_ , ///
i(g1a_0) j(wave)


rename g1a_0 id

rename p11f_ feel_pp_voters
rename p11g_ feel_psoe_voters
rename p11h_ feel_cs_voters
rename p11i_ feel_up_voters
rename p11r_ feel_vox_voters

rename p37a_ spanish_econ_assessment
rename p37b_ household_econ_assessment
rename p72a_ pp_like
rename p72b_ psoe_like
rename p72c_ up_like
rename p72e_ cs_like
rename p72l_ vox_like
rename p72f_ erc_like
rename p75_ vote_intention
rename p74a_ prob_vote_pp
rename p74b_ prob_vote_psoe
rename p74c_ prob_vote_up
rename p74e_ prob_vote_cs
rename p74l_ prob_vote_vox
rename p74f_ prob_vote_erc

la var spanish_econ_assessment "Economic assessment"

* Attitudes controls
rename p4a_ unemployment_sit
rename p4b_ education_sit
rename p4c_ health_sit
rename p4d_ immigration_sit
rename p4e_ pensions_sit
rename p4f_ corruption_sit
rename p4g_ viol_wom_sit
rename p4h_ catalonia_sit

la var unemployment_sit "Unemployment situation"
la var education_sit "Education situation"
la var health_sit "Healthcare situation"
la var immigration_sit "Immigration situation"
la var pensions_sit "Pensions situation"
la var corruption_sit "Corruption situation"
la var viol_wom_sit "Situation of violence against women"
la var catalonia_sit "Situation in Catalonia"


* Sociodemo controls
rename s0_ region
rename s1_ sex
rename s2_ age
rename s3a_ place_residence
rename s5_ marit_status
rename s4a_ education
rename s8_ occupation
rename s12_ income
rename s14_ religious

la var region Region
la var sex Sex
la var age Age
la var place_residence "Habitat (Nr. of inhabitants)"
la var marit_status "Marital Status"
la var education "Education level"
la var occupation "Occupation"
la var income "Income"
la var religious "Belongs to a church"

drop p??_? p???_? p????_? p?????_? trust* g?_0
drop if wave == 1

*Party id recode:
recode p35a_ (1 = 2 "PP") (2=4 "PSOE") (3 4 = 5 "UP") (5 = 3 "Ciudadanos") (13 = 1 "VOX") (6/12 = .) , into(party_id)
tab party_id
la var party_id "Party ID"

gen government_id = .
gen opposition_id = .
gen no_id = .

recode government_id . = 1 if party_id == 4 | (party_id == 5 & wave == 4)
recode government_id . = 0

// recode opposition_id . = 1 if ///
// (party_id == 2 ) | ///
// (party_id == 1 ) | ///
// (party_id == 3 )
recode opposition_id . = 0 if party_id == 4 | (party_id == 5 & wave == 4)
recode opposition_id . = 1

recode no_id . = 1 if p35_ == 0
recode no_id . = 0

gen partid = .
// forvalues wave = 1/4 {
recode partid . = 0 if government_id
recode partid . = 1 if opposition_id
recode partid . = 2 if no_id
// }

la var opposition_id "Opposition supporter"
label def opposition_id 0 "Incumbent supporter" 1 "Opposition supporter"
la val opposition_id opposition_id
la var partid "Party ID"
la def partid 0 "Government partisan" 1 "Opposition partisan" 2 "No party id"
la val partid partid

********************************************************************************
****************************** DEPENDENT VARIABLES *****************************
********************************************************************************

gen vote_incumbent = .
recode vote_incumbent . = 1 if (vote_intention == 2 & wave == 3) | (prob_vote_psoe >= 5  & wave == 4) | (prob_vote_up >= 5  & wave == 4) 
recode vote_incumbent . = 0 
la var vote_incumbent "Intention to vote for the incumbent"

gen vote_psoe = .
recode vote_psoe . = 1 if (vote_intention == 2 & wave == 3) | (prob_vote_psoe >=5 & wave == 4)
recode vote_psoe . = 0
la var vote_psoe "Intention to vote for the incumbent (PSOE)"


********************************************************************************
***************************** ECONOMIC ASSESSMENT*******************************
********************************************************************************

recode spanish_econ_assessment (1=-2) (2=-1) (3=0) (4=1) (5=2)
la def spanish_econ_assessment -2 "A lot worse" -1 "A little worse" 0 "No difference" 1 "A little better" 2 "A lot better"
la val spanish_econ_assessment spanish_econ_assessment


* DUMMY VERSION:
recode spanish_econ_assessment (-2 -1 = 1 "Worse") (1 2 = 2 "Better") (0 = .), into(spanish_econ_assessment_dummy)
la var spanish_econ_assessment_dummy "Assessment of the economic situation of the country"


********************************************************************************
********************************* AP INDEX *************************************
********************************************************************************

* Parties share per wave:
foreach x in pp psoe up cs vox erc {
gen `x'_share = .
}

gen total_share = .

recode total_share . = 89.95 if wave < 4
recode total_share . = 88.17 if wave == 4

*PP
recode pp_share . = 33.01 if wave != 4
recode pp_share . = 16.69 if wave == 4
*PSOE
recode psoe_share . = 22.63 if wave != 4
recode psoe_share . = 28.67 if wave == 4
*UP
recode up_share . = 21.15 if wave != 4
recode up_share . = 16.69 if wave == 4
*CS
recode cs_share . = 13.06 if wave != 4
recode cs_share . = 15.86 if wave == 4
*VOX
recode vox_share . = 0 if wave != 4
recode vox_share . = 10.26 if wave == 4
*ERC
recode erc_share . = 2.63 if wave != 4
recode erc_share . = 3.89 if wave == 4


* Standarize party vote shares to range from 0 to 1:
foreach x in pp psoe up cs vox {
gen `x'_standard_share = `x'_share/total_share
}


** FIRST OPTION (like party):

	* Respondent's affect for parties:
	foreach x in pp psoe up cs vox {
	gen `x'_affect = `x'_like*`x'_standard_share
	}
	
	* Respondent's Average party affect:
	egen average_party_affect = rowmean(*_affect)

	foreach x in pp psoe up cs vox {
	gen `x'_pol = `x'_standard_share*(`x'_like-average_party_affect)^2
	}
	
	* Respondent's affective polarization index:
	gen AP_index = sqrt(pp_pol + psoe_pol + up_pol + cs_pol + vox_pol)

	*Drop 0 when individual answers 0 affect to all parties
	recode AP_index 0 = . if pp_affect  == 0 & psoe_affect == 0 & up_affect == 0 ///
	& cs_affect == 0 & vox_affect == 0
	
	la var AP_index "Alternative AP index"

** ALTERNATIVE (affects towards voters): 

	* Respondent's affect for parties' voters:
	foreach x in pp psoe up cs vox {
	gen `x'_alt = feel_`x'_voters*`x'_standard_share
	}
	
	* Respondent's Average party affect (alt):
	egen average_party_affect_alt = rowmean(*_alt)

	foreach x in pp psoe up cs vox {
	gen `x'_pol2 = `x'_standard_share*(feel_`x'_voters-average_party_affect)^2
	}
	
	* Respondent's affective polarization index:
	gen AP_index2 = sqrt(pp_pol2 + psoe_pol2 + up_pol2 + cs_pol2 + vox_pol2)

	*Drop 0 when individual answers 0 affect to all parties
	recode AP_index2 0 = . if pp_alt  == 0 & psoe_alt == 0 & up_alt == 0 ///
	& cs_alt == 0 & vox_alt == 0
	
	la var AP_index2 "AP index"


	
	
** POSITIVE VS NEGATIVE PARTISANSHIP

// gen positive_partisanship = sqrt(psoe_pol2 + up_pol2) if ! partid
// gen negative_partisanship = sqrt(pp_pol2 + cs_pol2 + vox_pol2) if ! partid

egen in_aff = rowmean(feel_psoe_voters feel_up_voters)
egen out_aff = rowmean(feel_pp_voters feel_cs_voters feel_vox_voters)

gen positive_partisanship = in_aff if ! partid
gen negative_partisanship = 100 - out_aff if ! partid

replace positive_partisanship = out_aff if partid
replace negative_partisanship = 100 - in_aff if partid

gen AP_index3 = sqrt(positive_partisanship^2 + negative_partisanship^2)
gen final = AP_index3/141.4214
gsort -AP_index3

br id AP_index3 positive_partisanship negative_partisanship partid final
// replace positive_partisanship = sqrt(pp_pol2 + cs_pol2 + vox_pol2)  if partid
// replace negative_partisanship = sqrt(psoe_pol2 + up_pol2) if partid

la var positive_partisanship "Positive partisanship"
la var negative_partisanship "Negative partisanship"

recode positive_partisanship 100 = . if pp_alt  == 0 & psoe_alt == 0 & up_alt == 0 ///
	& cs_alt == 0 & vox_alt == 0
recode negative_partisanship 100 = . if pp_alt  == 0 & psoe_alt == 0 & up_alt == 0 ///
	& cs_alt == 0 & vox_alt == 0

* AP dummy
gen AP_index_dummy = .
su AP_index
recode AP_index_dummy . = 0 if AP_index < r(mean)
recode AP_index_dummy . = 1 if AP_index >= r(mean)
la def AP_index_dummy 0 "Below the Affective Polarization average" 1 "Above the Affective Polarization average"
la val AP_index_dummy AP_index_dummy
la var AP_index_dummy "AP index (dichotomous)"

*GROUPS

// sum AP_index
//
// local m=r(mean)
// local sd=r(sd)
// local low = `m'-`sd'
// local high=`m'+`sd'
// recode AP_index (0/`low' = 0 "Supporters") (`low'/`high' = 1 "Partisans") (`high'/max = 2 "Fans") ,into(groups)
// la var groups "Groups of voters"

sum final if government

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'
recode final (0/`low' = 0 "Supporters") (`low'/`high' = 1 "Partisans") (`high'/max = 2 "Fans") ,into(groups)
la var groups "Groups of voters"


save Data/03_temp/data.dta, replace