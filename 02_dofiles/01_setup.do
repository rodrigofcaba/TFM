clear all
set more off

global projectdir "C:/Users/Rodrigo/Desktop/TFM"

cd $projectdir

use 01_raw/E-DEM-Waves-Dataset, clear

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
p35a_ /// //party id
p37a_ p37b_ p38a_ ///
p72a_ p72b_ p72c_ p72e_ p72l_ p72f_ ///
p75_ ///
p74a_ p74b_ p74c_ p74e_ p74l_ p74f_ , ///
i(g1a_0) j(wave)


rename g1a_0 id
rename p4a_ unemployment_sit
rename p4b_ education_sit
rename p4c_ health_sit
rename p4d_ immigration_sit
rename p4e_ pensions_sit
rename p4f_ corruption_sit
rename p4g_ viol_wom_sit
rename p4h_ catalonia_sit
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

drop p??_? p???_? p????_? p?????_? trust* g?_0

*Party id recode:
recode p35a_ (1 = 1 "PP") (2=2 "PSOE") (3 4 = 3 "UP + IU") (5 = 4 "Ciudadanos") (13 = 5 "VOX") (6/12 = .) , into(party_id)
tab party_id
gen vote_incumbent = .
recode vote_incumbent . = 1 if vote_intention == 1 | vote_intention == 4
recode vote_incumbent . = 0 
la var vote_incumbent "Intention to vote for the incumbent"


* Parties share per wave:
foreach x in pp psoe up cs vox erc {
gen `x'_share = .
}

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

* Respondent's affect for parties
foreach x in pp psoe up cs vox erc{
gen `x'_affect = `x'_like*`x'_share
}

* Respondent's Average party affect:
egen average_party_affect = rowmean(*_affect)

foreach x in pp psoe up cs vox erc{
gen `x'_pol = `x'_share*(`x'_like-average_party_affect)^2
}

* Respondent's affective polarization index:
gen AP_index = sqrt(pp_pol + psoe_pol + up_pol + cs_pol + vox_pol + erc_pol)

* AP dummy
gen AP_index_dummy = .
su AP_index
recode AP_index_dummy . = 0 if AP_index < r(mean)
recode AP_index_dummy . = 1 if AP_index >= r(mean)
la def AP_index_dummy 0 "Bellow the Affective Polarization median" 1 "Above Affective Polarization the median"
la val AP_index_dummy AP_index_dummy


* p74 (probability of voting): only waves 3 and 4.
* cannot know probability of voting the incumbent before moción de censura.
* p38 (satisfaction with government): only waves 2 and 3.

recode spanish_econ_assessment (1 2 = 1 "Worse") (4 5 = 2 "Better") (3 = .), into(spanish_econ_assessment_dummy)
la var spanish_econ_assessment_dummy "Assessment of the economic situation of the country"

save 03_temp/data.dta, replace