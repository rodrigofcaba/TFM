global attitudinal "unemployment_sit education_sit health_sit immigration_sit pensions_sit corruption_sit viol_wom_sit catalonia_sit"
global sociodemo "region sex age place_residence marit_status education occupation income religious"

* Logit model

* Baseline model:
eststo: logit vote_incumbent c.spanish_econ_assessment##c.AP_index party_id if wave > 2 & partid !=2
* + sociodemo controls
eststo: logit vote_incumbent c.spanish_econ_assessment##c.AP_index party_id $sociodemo if wave > 2 & partid !=2
* + attitudinal controls
eststo: logit vote_incumbent c.spanish_econ_assessment##c.AP_index party_id $attitudinal $sociodemo if wave > 2 & partid !=2

esttab using Paper/Figures/models.tex, replace label sfmt(%9.3g) booktabs nodep nomti nonum nogap pr2 obslast compress mlab("Baseline"  "+ Sociodemografic controls" "+ Attitudinal controls") refcat(unemployment_sit "Attitudinal controls" region "Sociodemografic controls", label(Yes)) drop(sex age place_residence marit_status education occupation income religious education_sit health_sit immigration_sit pensions_sit corruption_sit viol_wom_sit catalonia_sit)

esttab using Paper/Figures/modelsOR.tex, replace label sfmt(%9.3g) booktabs nodep nomti nonum nogap pr2 obslast compress mlab("Baseline"  "+ Sociodemografic controls" "+ Attitudinal controls") refcat(unemployment_sit "Attitudinal controls" region "Sociodemografic controls", label(Yes)) drop(sex age place_residence marit_status education occupation income religious education_sit health_sit immigration_sit pensions_sit corruption_sit viol_wom_sit catalonia_sit) eform

* COEFPLOT
coefplot, drop(_cons) xline(0, lpattern(dash)) msymbol(d) headings(spanish_econ_assessment = "{bf:Main results}" c.spanish_econ_assessment##c.AP_index = "{bf:Interaction term}" unemployment_sit="{bf:Attitudes}" region="{bf:Sociodemografic controls}")  coeflabels(1.lockdown = "Lockdown" 1.lockdown#c.polarization = "Lockdown x Affective Polarization", interaction(" x ") labs(small)) note("N=3,607") name("logit_coefplot", replace)
graph export Paper/Figures/model_3_coefplot.png, replace

eststo clear
logit vote_incumbent c.spanish_econ_assessment##c.AP_index
eststo: mfx

sum AP_index, d

global aeg  "`r(mean)'"

margins if !AP_index_dummy, at(spanish_econ_assessment=(1(1)5))

marginsplot , title("Less polarized than the average", size(medsmall)) ytitle("Predicted probability of voting for the incumbent") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall)) xlabel(1 "A lot worse" 5 "A lot better", axis(1) labs(vsmall)) ///
name("margins1", replace)

margins if AP_index_dummy, at(spanish_econ_assessment=(1(1)5))

marginsplot , title("More polarized than the average", size(medsmall)) ytitle("") ///
ylabel(0(.25)1, format(%12.2f) labs(*.75)) ///
yline(.5 , lwidth(medthin) lpattern(dash))  ///
xtitle("Economic assessment", axis(1) size(medsmall)) xlabel(1 "A lot worse" 5 "A lot better", axis(1) labs(vsmall)) ///
name("margins2", replace)

graph combine margins1 margins2, rows(1)

graph export  Paper/Figures/marginsplot.png, replace 

* Evaluation of the economy by partisanship

reg spanish_econ_assessment i.partid AP_index_dummy $attitudinal $sociodemo 
coefplot, xline(0)