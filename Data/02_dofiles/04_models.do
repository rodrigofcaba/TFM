// global attitudinal "unemployment_sit education_sit health_sit immigration_sit pensions_sit corruption_sit viol_wom_sit catalonia_sit"
global sociodemo "region sex age place_residence marit_status education occupation income religious"

* Logit model

eststo: logit vote_incumbent c.spanish_econ_assessment##c.AP_index_dummy opposition
eststo: logit vote_incumbent c.spanish_econ_assessment##c.AP_index_dummy opposition $sociodemo 

esttab using Paper/Figures/preferred_model.tex, replace ///
mgroups("Likelihood of voting for the incumbent", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) eqlabel(none) ///
label sfmt(%9.3g) booktabs nodep nomti nonum nogap pr2 obslast compress mlab("Baseline"  "+ Sociodemografic controls") refcat(region "Sociodemografic controls", label(" ")) addn("NOTE: The AP dichotomous variable splits the sample between those avobe and below the average AP level.")

eststo clear

* COEFPLOT
coefplot, drop(_cons) xline(0, lpattern(dash)) msymbol(d) headings(spanish_econ_assessment = "{bf:Main results}") label coeflabels(, interaction(" x ") labs(small)) note("N=3,607") name("logit_coefplot", replace)
graph export Paper/Figures/preferred_model.png, replace

sum AP_index, d
global aeg  "`r(mean)'"

***************************
* CONTINUE OPPO VS INCUMB *
***************************

eststo clear
eststo: logit vote_incumbent c.spanish_econ_assessment##c.AP_index opposition
eststo: logit vote_incumbent c.spanish_econ_assessment##c.AP_index opposition $sociodemo 

margins if !AP_index_dummy, at(spanish_econ_assessment=(-2(1)2) opposition=(1 0))
marginsplot , title("Less polarized than the average", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall)) xlabel(-2 "A lot worse" 2 "A lot better", axis(1) labs(vsmall)) ///
name("margins1", replace) legend(rows(1))

margins if AP_index_dummy, at(spanish_econ_assessment=(-2(1)2) opposition=(1 0))
marginsplot , title("More polarized than the average", size(medsmall)) ytitle("") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall)) xlabel(-2 "A lot worse" 2 "A lot better", axis(1) labs(vsmall)) ///
name("margins2", replace)

esttab using Paper/Figures/continue_opposition.tex, replace ///
mgroups("Likelihood of voting for the incumbent", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) eqlabel(none) ///
label sfmt(%9.3g) booktabs nodep nomti nonum nogap pr2 obslast compress mlab("Baseline"  "+ Sociodemografic controls") refcat(region "Sociodemografic controls", label("Yes")) drop(sex age place_residence marit_status education occupation income religious _cons region)

****
* DUMMY OPPO IMCUMB
*
eststo:logit vote_incumbent c.spanish_econ_assessment##c.AP_index_dummy opposition 
eststo:logit vote_incumbent c.spanish_econ_assessment##c.AP_index_dummy opposition $sociodemo 

margins if !AP_index_dummy, at(spanish_econ_assessment=(-2(1)2) opposition=(1 0))
marginsplot , title("Less polarized than the average", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall)) xlabel(-2 "A lot worse" 2 "A lot better", axis(1) labs(vsmall)) ///
name("margins3", replace) legend(rows(1))

margins if AP_index_dummy, at(spanish_econ_assessment=(-2(1)2) opposition=(1 0))
marginsplot , title("More polarized than the average", size(medsmall)) ytitle("") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall)) xlabel(-2 "A lot worse" 2 "A lot better", axis(1) labs(vsmall)) ///
name("margins4", replace)


***
* INCUMBENTS VS OPPOSITION :
*

// logit vote_incumbent c.spanish_econ_assessment##i.groups i.opposition##i.groups $sociodemo
// coefplot, drop(_cons) xline(0, lpattern(dash)) msymbol(d) headings(spanish_econ_assessment = "{bf:Main results}") label coeflabels(, interaction(" x ") labs(small)) note("N=3,607") name("logit_coefplot", replace)
// graph export Paper/Figures/all.png, replace



eststo clear
// eststo:logit vote_incumbent c.spanish_econ_assessment##i.groups opposition
// eststo:logit vote_incumbent c.spanish_econ_assessment##i.groups opposition $sociodemo

eststo: logit vote_incumbent spanish_econ_assessment if ! opposition
eststo: logit vote_incumbent c.spanish_econ_assessment##i.groups  if ! opposition
eststo: logit vote_incumbent c.spanish_econ_assessment##i.groups $sociodemo if ! opposition

coefplot, drop(_cons) xline(0, lpattern(dash)) msymbol(d) headings(spanish_econ_assessment = "{bf:Main results}") label coeflabels(, interaction(" x ") labs(small)) note("N=812") name("logit_coefplot", replace)
graph export Paper/Figures/new.png, replace
//
// logit vote_incumbent c.spanish_econ_assessment##i.groups opposition $sociodemo if opposition
//
// coefplot, drop(_cons) xline(0, lpattern(dash)) msymbol(d) headings(spanish_econ_assessment = "{bf:Main results}") label coeflabels(, interaction(" x ") labs(small)) note("N=2,647") name("logit_coefplot", replace)
// graph export Paper/Figures/new_oppo.png, replace
//
// logit vote_incumbent c.spanish_econ_assessment##i.groups opposition $sociodemo  if ! opposition
//
// coefplot, drop(_cons) xline(0, lpattern(dash)) msymbol(d) headings(spanish_econ_assessment = "{bf:Main results}") label coeflabels(, interaction(" x ") labs(small)) note("N=812") name("logit_coefplot", replace)
// graph export Paper/Figures/new_incum.png, replace

margins if ! opposition, at(spanish_econ_assessment=(-2(1)2) groups=(0 1 2))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(-2 "A lot worse" 2 "A lot better", axis(1) labs(vsmall)) ///
name("margins5", replace) legend(rows(1))

cap grc1leg margins5 margins6, name("dummy_oppo_incumb2", replace)  rows(1)
graph export Paper/Figures/dummy_oppo_incumb2.png, replace


esttab using Paper/Figures/new.tex, replace ///
mgroups("Likelihood of voting for the incumbent", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) eqlabel(none) ///
label sfmt(%9.3g) booktabs nodep nomti nonum nogap pr2 obslast compress mlab("Baseline"  "+ Sociodemografic controls") refcat(0.groups "Ref. category: Supporters", label(" ")) nobase 
**********
* BY PARTY:
*****

*****
* DUMMY PARTIES

eststo clear
eststo:logit vote_incumbent c.spanish_econ_assessment##c.AP_index_dummy ib4.party_id
eststo:logit vote_incumbent c.spanish_econ_assessment##c.AP_index_dummy ib4.party_id $sociodemo 

margins if !AP_index_dummy, at(spanish_econ_assessment=(1(1)5) party_id=(1 2 3 4))
marginsplot , title("Less polarized than the average", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall)) xlabel(1 "A lot worse" 5 "A lot better", axis(1) labs(vsmall)) ///
name("margins7", replace)  legend(rows(1))

margins if AP_index_dummy, at(spanish_econ_assessment=(1(1)5) party_id=(1 2 3 4))
marginsplot , title("More polarized than the average", size(medsmall)) ytitle("") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall)) xlabel(1 "A lot worse" 5 "A lot better", axis(1) labs(vsmall)) ///
name("margins8", replace)

esttab using Paper/Figures/dummy_parties.tex, replace ///
mgroups("Likelihood of voting for the incumbent", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) eqlabel(none) ///
label sfmt(%9.3g) booktabs nodep nomti nonum nogap pr2 obslast compress mlab("Baseline"  "+ Sociodemografic controls") refcat(1.party_id "Ref. category: PSOE (incumbent)", label(" ")) nobase drop(sex age place_residence marit_status education occupation income religious _cons region) addn("NOTE: The AP dichotomous variable splits the sample between those avobe and below the average AP level.")


******
* CONTINUE PARTIES
**

eststo clear
eststo:logit vote_incumbent c.spanish_econ_assessment##c.AP_index ib4.party_id
eststo:logit vote_incumbent c.spanish_econ_assessment##c.AP_index ib4.party_id $sociodemo 

margins if !AP_index_dummy, at(spanish_econ_assessment=(-2(1)2) party_id=(1 2 3 4))
marginsplot , title("Less polarized than the average", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall)) xlabel(-2 "A lot worse" 2 "A lot better", axis(1) labs(vsmall)) ///
name("margins9", replace) legend(rows(1))

margins if AP_index_dummy, at(spanish_econ_assessment=(-2(1)2) party_id=(1 2 3 4))
marginsplot , title("More polarized than the average", size(medsmall)) ytitle("") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall)) xlabel(-2 "A lot worse" 2 "A lot better", axis(1) labs(vsmall)) ///
name("margins10", replace)

esttab using Paper/Figures/continuous_parties.tex, replace ///
mgroups("Likelihood of voting for the incumbent", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) eqlabel(none) ///
label sfmt(%9.3g) booktabs nodep nomti nonum nogap pr2 obslast compress mlab("Baseline"  "+ Sociodemografic controls") refcat(1.party_id "Ref. category: PSOE (incumbent)", label(" ")) nobase drop(sex age place_residence marit_status education occupation income religious _cons region)







logit vote_incumbent i.spanish_econ_assessment_dummy opposition $sociodemo
logit vote_incumbent i.spanish_econ_assessment_dummy AP_index2 opposition $sociodemo
logit vote_incumbent i.spanish_econ_assessment_dummy##c.AP_index2 opposition $sociodemo 
logit vote_incumbent  i.spanish_econ_assessment_dummy positive_partisanship negative_partisanship opposition $sociodemo


sum AP_index2

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if ! opposition, at(spanish_econ_assessment_dummy=(1 2) AP_index2=(`low' `m' `high'))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(1 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("margins", replace) legend(rows(1))


logit vote_incumbent  i.spanish_econ_assessment_dummy##c.positive_partisanship negative_partisanship opposition $sociodemo

sum positive_partisanship

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if ! opposition, at(spanish_econ_assessment_dummy=(1 2) positive_partisanship=(`low' `m' `high'))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(1 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("margins", replace) legend(rows(1))


logit vote_incumbent i.spanish_econ_assessment_dummy##c.negative_partisanship positive_partisanship  opposition $sociodemo

sum negative_partisanship

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

margins if ! opposition, at(spanish_econ_assessment_dummy=(1 2) negative_partisanship=(`low' `m' `high'))
marginsplot , title("Incumbent's potential voters", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall))  xlabel(1 "Worse" 2 "Better", axis(1) labs(vsmall)) ///
ylabel(0.75 1) name("margins", replace) legend(rows(1))



* Evaluation of the economy by partisanship
hist AP_index2, normal
reg spanish_econ_assessment i.partid AP_index_dummy $sociodemo 
coefplot, xline(0)
