********************************************************************************
** MODELS **
********************************************************************************

global sociodemo "region sex age place_residence marit_status education occupation income religious"

eststo clear
eststo: logit vote_incumbent i.spanish_econ_assessment_dummy $sociodemo if government //1
eststo: logit vote_incumbent i.spanish_econ_assessment_dummy final $sociodemo if government //2
eststo: logit vote_incumbent i.spanish_econ_assessment_dummy##c.final $sociodemo if government //3

sum final if government

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if ! opposition, at(spanish_econ_assessment_dummy=(1 2) final=(`low' `m' `high'))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(1 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("margins", replace) legend(rows(1) order(1 "Supporters" 2 "Regular partisans" 3 "Fans"))
graph export Paper/Figures/margins.png, replace

eststo: logit vote_incumbent  i.spanish_econ_assessment_dummy positive_partisanship negative_partisanship $sociodemo if government //4

eststo: logit vote_incumbent  i.spanish_econ_assessment_dummy##c.positive_partisanship negative_partisanship $sociodemo if government //5

sum positive_partisanship if government

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if ! opposition, at(spanish_econ_assessment_dummy=(1 2) positive_partisanship=(`low' `m' `high'))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(1 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("positive_margins", replace) legend(rows(1) label(1 "Supporters" 2 "Regular partisans" 3 "Fans"))
graph export Paper/Figures/positive_margins.png, replace


eststo: logit vote_incumbent i.spanish_econ_assessment_dummy##c.negative_partisanship positive_partisanship $sociodemo if government //6

sum negative_partisanship if government

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if ! opposition, at(spanish_econ_assessment_dummy=(1 2) negative_partisanship=(`low' `m' `high'))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(1 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("negative_margins", replace) legend(rows(1) label(1 "Supporters" 2 "Regular partisans" 3 "Fans"))
graph export Paper/Figures/negative_margins.png, replace


esttab using Paper/Figures/new.tex, replace ///
mgroups("Likelihood of voting for the incumbent", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) eqlabel(none) ///
label sfmt(%9.3g) booktabs nodep nomti nogap pr2 obslast compress noomit nobase refcat(2.spanish_econ_assessment_dummy "Economic assessment (ref.: Worse)", nolabel) drop(sex age place_residence marit_status education occupation income religious _cons region) eform

* Evaluation of the economy by partisanship
hist AP_index2, normal
reg spanish_econ_assessment i.partid AP_index_dummy $sociodemo 
coefplot, xline(0)
