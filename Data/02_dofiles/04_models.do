********************************************************************************
** MODELS **
********************************************************************************

********************************************************************************
* INCUMBENT
********************************************************************************

global sociodemo "region sex age place_residence marit_status education occupation income religious"

eststo clear
eststo: logit vote_incumbent ib2.spanish_econ_assessment_dummy $sociodemo if government_id == 1 //1
eststo: logit vote_incumbent ib2.spanish_econ_assessment_dummy c.AP_index $sociodemo if government_id == 1 //2
eststo: logit vote_incumbent ib2.spanish_econ_assessment_dummy##c.AP_index $sociodemo if government_id == 1 //3

sum AP_index if government_id == 1

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if government_id == 1, at(spanish_econ_assessment_dummy=(0 2) AP_index=(`low' `m' `high'))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(0 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("margins", replace) legend(rows(1) order(4 "Supporters" 5 "Regular partisans" 6 "Fans"))
graph export Paper/Figures/margins.png, replace



eststo: logit vote_incumbent ib2.spanish_econ_assessment_dummy c.AP_wagner $sociodemo if government_id == 1 //2
eststo: logit vote_incumbent ib2.spanish_econ_assessment_dummy##c.AP_wagner $sociodemo if government_id == 1 //3

sum AP_wagner if government_id == 1

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'


margins if government_id == 1, at(spanish_econ_assessment_dummy=(0 2) AP_wagner=(`low' `m' `high'))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(0 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("margins2", replace) legend(rows(1) order(4 "Supporters" 5 "Regular partisans" 6 "Fans"))
graph export Paper/Figures/margins_wagner.png, replace

esttab using Paper/Figures/new.tex, replace ///
mgroups("Likelihood of voting for the incumbent", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) eqlabel(none) ///
label sfmt(%9.3g) booktabs nodep nomti nogap pr2 obslast compress noomit nobase refcat(0.spanish_econ_assessment_dummy "Economic assessment (ref.: Better)", nolabel) drop(1.spanish_econ_assessment_dummy 1.spanish_econ_assessment_dummy#c.AP_index 1.spanish_econ_assessment_dummy#c.AP_wagner sex age place_residence marit_status education occupation income religious _cons region) eform addnotes("NOTE: All the specifications include the following control variables: sex, age, place of residence, marital status," "education, occupation, income and religious beliefs. They are excluded from the table for clarity reasons.")


*********************************************************************************
eststo clear
eststo: logit vote_incumbent  i.spanish_econ_assessment_dummy c.positive_partisanship c.negative_partisanship $sociodemo if government_id == 1 //4

eststo: logit vote_incumbent  i.spanish_econ_assessment_dummy##c.positive_partisanship c.negative_partisanship $sociodemo if government_id == 1 //5

sum positive_partisanship if government_id == 1

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if government_id == 1, at(spanish_econ_assessment_dummy=(0 2) positive_partisanship=(`low' `m' `high'))
marginsplot , title("Positive partisanship", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(0 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.5 0.75 1) name("positive_margins", replace) legend(rows(1) order(4 "-SD" 5 "Average" 6 "+SD"))
// graph export Paper/Figures/positive_margins.png, replace


eststo: logit vote_incumbent i.spanish_econ_assessment_dummy##c.negative_partisanship c.positive_partisanship $sociodemo if government_id == 1 //6

sum negative_partisanship if government_id == 1

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if government_id == 1, at(spanish_econ_assessment_dummy=(0 2) negative_partisanship=(`low' `m' `high'))
marginsplot , title("Negative partisanship", size(medsmall)) ytitle("") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(0 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.5 0.75 1) name("negative_margins", replace) legend(rows(1) order(4 "-SD" 5 "Average" 6 "+SD"))
// graph export Paper/Figures/negative_margins.png, replace

grc1leg positive_margins negative_margins, legendfrom(positive_margins)
gr export Paper/Figures/pos-neg.png, replace

esttab using Paper/Figures/pos-neg.tex, replace ///
mgroups("Likelihood of voting for the incumbent", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) eqlabel(none) ///
label sfmt(%9.3g) booktabs nodep nomti nogap pr2 obslast compress noomit nobase refcat(2.spanish_econ_assessment_dummy "Economic assessment (ref.: Worse)", nolabel) drop(1.spanish_econ_assessment_dummy 1.spanish_econ_assessment_dummy#c.positive_partisanship 1.spanish_econ_assessment_dummy#c.negative_partisanship sex age place_residence marit_status education occupation income religious _cons region) eform addnotes("NOTE: All the specifications include the following control variables: sex, age, place of residence, marital status," "education, occupation, income and religious beliefs. They are excluded from the table for clarity reasons.")


********************************************************************************
* OPPO
********************************************************************************


eststo clear
eststo: logit vote_incumbent i.spanish_econ_assessment_dummy $sociodemo if opposition_id == 1 //1
eststo: logit vote_incumbent i.spanish_econ_assessment_dummy c.AP_index $sociodemo if opposition_id == 1 //2
eststo: logit vote_incumbent i.spanish_econ_assessment_dummy##c.AP_index $sociodemo if opposition_id == 1 //3

sum AP_index if opposition_id == 1

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if opposition_id == 1, at(spanish_econ_assessment_dummy=(0 2) AP_index=(`low' `m' `high'))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(0 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("margins", replace) legend(rows(1) order(4 "Supporters" 5 "Regular partisans" 6 "Fans"))
graph export Paper/Figures/margins_oppo.png, replace



eststo: logit vote_incumbent i.spanish_econ_assessment_dummy c.AP_wagner $sociodemo if opposition_id == 1 //2
eststo: logit vote_incumbent i.spanish_econ_assessment_dummy##c.AP_wagner $sociodemo if opposition_id == 1 //3

sum AP_wagner if opposition_id == 1

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'


margins if opposition_id == 1, at(spanish_econ_assessment_dummy=(0 2) AP_wagner=(`low' `m' `high'))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(0 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("margins2", replace) legend(rows(1) order(4 "Supporters" 5 "Regular partisans" 6 "Fans"))
graph export Paper/Figures/margins_wagner_oppo.png, replace

esttab using Paper/Figures/opposition.tex, replace ///
mgroups("Likelihood of voting for the incumbent", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) eqlabel(none) ///
label sfmt(%9.3g) booktabs nodep nomti nogap pr2 obslast compress noomit nobase refcat(2.spanish_econ_assessment_dummy "Economic assessment (ref.: Worse)", nolabel) drop(1.spanish_econ_assessment_dummy 1.spanish_econ_assessment_dummy#c.AP_index 1.spanish_econ_assessment_dummy#c.AP_wagner sex age place_residence marit_status education occupation income religious _cons region) eform addnotes("NOTE: All the specifications include the following control variables: sex, age, place of residence, marital status," "education, occupation, income and religious beliefs. They are excluded from the table for clarity reasons.")



*********************************************************************************
eststo clear
eststo: logit vote_incumbent  i.spanish_econ_assessment_dummy c.positive_partisanship c.negative_partisanship $sociodemo if opposition_id == 1 //4

eststo: logit vote_incumbent  i.spanish_econ_assessment_dummy##c.positive_partisanship c.negative_partisanship $sociodemo if opposition_id == 1 //5

sum positive_partisanship if opposition_id == 1

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if opposition_id == 1, at(spanish_econ_assessment_dummy=(0 2) positive_partisanship=(`low' `m' `high'))
marginsplot , title("Positive partisanship", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(0 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("positive_margins", replace) legend(rows(1) order(4 "-SD" 5 "Average" 6 "+SD"))
graph export Paper/Figures/positive_margins_oppo.png, replace


eststo: logit vote_incumbent i.spanish_econ_assessment_dummy##c.negative_partisanship c.positive_partisanship $sociodemo if opposition_id == 1 //6

sum negative_partisanship if opposition_id == 1

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if opposition_id == 1, at(spanish_econ_assessment_dummy=(0 2) negative_partisanship=(`low' `m' `high'))
marginsplot , title("Negative partisanship", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(0 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("negative_margins", replace) legend(rows(1) order(4 "-SD" 5 "Average" 6 "+SD"))
graph export Paper/Figures/negative_margins_oppo.png, replace


esttab using Paper/Figures/pos-neg_oppo.tex, replace ///
mgroups("Likelihood of voting for the incumbent", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) eqlabel(none) ///
label sfmt(%9.3g) booktabs nodep nomti nogap pr2 obslast compress noomit nobase refcat(2.spanish_econ_assessment_dummy "Economic assessment (ref.: Worse)", nolabel) drop(1.spanish_econ_assessment_dummy 1.spanish_econ_assessment_dummy#c.positive_partisanship 1.spanish_econ_assessment_dummy#c.negative_partisanship sex age place_residence marit_status education occupation income religious _cons region) eform addnotes("NOTE: All the specifications include the following control variables: sex, age, place of residence, marital status," "education, occupation, income and religious beliefs. They are excluded from the table for clarity reasons.")


