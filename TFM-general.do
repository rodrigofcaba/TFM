********************************************************************************
* Name: TFM General
* Author: Rodrigo Fernández Caba
********************************************************************************

clear all
set more off

cd "C:\Users\Rodrigo\Desktop\TFM\Data"

* Set up github repository:
! echo # github-tutorial  >> README.md
! git init
! git add README.md
! git commit -m "initial commit, only README"
! git remote add origin https://github.com/rodrigofcaba/TFM.git
! git push -u origin master


file close _all
file open gitignore using .gitignore, write replace
file write gitignore "*.bat" _n
file close gitignore

file open git using mygit.bat, write replace
file write git "git remote add origin " `"""' "https://github.com/rodrigofcaba/TFM.git" `"""' _n
file write git "git add --all" _n
file write git "git commit -m "
file write git `"""' "initial commit" `"""' _n
file write git "git push" _n
file close git

! mygit.bat

* RUN TO PUSH CHANGES TO GITHUB:
file close _all
file open git using mygit.bat, write replace
file write git "git pull"
file write git "git add --all" _n
file write git "git commit -m "
file write git `"""' "new change, now testing gitignore" `"""' _n
file write git "git push" _n
file close git

! mygit.bat


use E-DEM-Waves-Dataset, clear

tab p37a_2 //Spanish economic situation
tab p37b_2 //Household economic situation

* Reshape wide to long format for panel data:
unab vars: *_1
local stubs : subinstr local vars "_1" "", all

local y_vars
foreach x of local stubs{
local y_vars `y_vars' `x'_
}

reshape long "`y_vars'" p4g_ p7l_ p9l_ p11q_ p11r_ p11s_ p13k_ p14h_ p37a_ p72a_ p72b_ p72c_ p72e_ p72l_ p72f_ p37b_ p38a_ p74a_ p74b_ p4h_ p10i_ p80_, i(g1a_0) j(wave)

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

tab p80_, nol
gen vote_incumbent = .
recode vote_incumbent . = 1 if p80_ == 1 | p80_ == 4
recode vote_incumbent . = 0 

tab vote_incumbent
tab p37a_
recode p

* Logit model
logit vote_incumbent c.p37a_##c.AP_index 
logit vote_incumbent p37a_##c.AP_index if wave ==4

hist AP_index, by(wave)

browse *_like *_affect *_pol average_party_affect AP_index

help xtset

describe g1a_0
xtset g1a_0 wave

xtreg p37a_ AP_index

tab p38a_ wave
tab p37a_ wave

browse g1a_0 p38a_ p37a_ AP_index wave

* vote for the incumbent:
reg pa_ p37a_##c.AP_index if wave != 1