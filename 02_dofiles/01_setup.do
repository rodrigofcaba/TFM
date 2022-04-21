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

reshape long "`y_vars'" p4g_ p7l_ p9l_ p11q_ p11r_ p11s_ p13k_ p14h_ p37a_ p72a_ p72b_ p72c_ p72e_ p72l_ p72f_  p37b_ p38a_ p74a_ p74b_ p4h_ p10i_ p80_, i(g1a_0) j(wave)

rename p37a_ spanish_econ_assessment
rename p37b_ household_econ_assessment
rename p72a_ pp_like
rename p72b_ psoe_like
rename p72c_ up_like
rename p72e_ cs_like
rename p72l_ vox_like
rename p72f_ erc_like

drop p??_? p???_? p????_? p?????_? trust* g?_0

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

* p74 (probability of voting): only waves 3 and 4.
* cannot know probability of voting the incumbent before moción de censura.
* p38 (satisfaction with government): only waves 2 and 3.

gen vote_incumbent = .
recode vote_incumbent . = 1 if p80_ == 1 | p80_ == 4
recode vote_incumbent . = 0 
la var vote_incumbent "Intention to vote for the incumbent"

recode spanish_econ_assessment (1 2 = 1 "Worse") (4 5 = 2 "Better") (3 = .), into(spanish_econ_assessment_dummy)
la var spanish_econ_assessment_dummy "Assessment of the economic situation of the country"

save 03_temp/data.dta, replace