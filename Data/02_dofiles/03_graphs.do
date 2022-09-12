********************************************************************************
********************************* GRAPHS ***************************************
********************************************************************************

** Differences in feelings according to partisanship **

foreach x in pp psoe up cs vox{
egen feel_avg_`x' = mean(feel_`x'_voters), by(party_id AP_index)


egen feel_median1_`x' = mean(feel_avg_`x') if AP_index_dummy == 0, by(party_id)
egen feel_median2_`x' = mean(feel_avg_`x') if AP_index_dummy == 1, by(party_id)
egen mean_fell_median1_`x' = mean(feel_median1_`x'), by(party_id)
egen mean_fell_median2_`x' = mean(feel_median2_`x'), by(party_id)
gen dif_feel_`x' = mean_fell_median2_`x' - mean_fell_median1_`x'

gr dot dif_feel_`x', over(party_id, sort(1)) yline(0, lpattern(dash) lcolor(red)) yti("") title("Difference in feelings towards `=strupper("`x'")' voters between more and less polarized", size(small))
gr export Data/05_graphs/punctual_diff_feel_`x'.png, replace

statsby if AP_index_dummy == 0, by(party_id) saving(Data/03_temp/`x'1.dta, replace):  ci means feel_`x'_voters
statsby if AP_index_dummy == 1, by(party_id) saving(Data/03_temp/`x'2.dta, replace):  ci means feel_`x'_voters

use Data/03_temp/`x'2, clear
append using Data/03_temp/`x'1, gen(ap)

twoway rcap lb ub party_id, horiz msiz(*0.8) xlabel(,labs(small)) legend(label (1 "95% confidence intervals") label (2 "More polarized than the average") label(3 "Less polarized than the average") size(small)) || scatter party_id  mean if ap == 0, mcolor(red)|| sc party_id mean if ap == 1, name("feel_`x'_dif_by_party", replace)  yti("") yla( 2 "PP" 4 "PSOE" 5 "UP" 3 "Ciudadanos" 1 "VOX", labsize(small)  tlc(none)) title(`=strupper("`x'")', size(medsmall))

* title("Difference in feelings towards `=strupper("`x'")' voters between more and less polarized", size(small))
 
graph export Paper/Figures/diff_feel_`x'.png, replace

use Data/03_temp/data, replace
}


** Install gtc1leg command:
if(_rc==111){
cap net install grc1leg, from (http://www.stata.com/users/vwiggins)
}


** Combined graph (all the parties)
grc1leg feel_psoe_dif_by_party feel_pp_dif_by_party  feel_up_dif_by_party feel_vox_dif_by_party feel_cs_dif_by_party, legendfrom(feel_pp_dif_by_party) name(combined_graph, replace) span rows(3)

graph export Paper/Figures/combinedfeelingsAP.png, replace

********************************************************************************
******************************* GROUPS *****************************************
********************************************************************************

********************************************************************************
*********************** Histogram of API by SD *********************************
********************************************************************************
sum AP_index2

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

histogram AP_index2 , normal ///
fc(none) lc(gray) ///
xline(`low',  lp(dash)) xline(`high', lp(dash)) ///
xlabel(`low' "-SD" `m' "Mean = `=string(`m',"%6.2f")'" `high' "+SD") xtitle("") name(ap)

// sum final
//
// local m=r(mean)
// local sd=r(sd)
// local low = `m'-`sd'
// local high=`m'+`sd'
//
// histogram final , normal ///
// fc(none) lc(gray) ///
// xline(`low',  lp(dash)) xline(`high', lp(dash)) ///
// xlabel(`low' "-SD" `m' "Mean = `=string(`m',"%6.2f")'" `high' "+SD") xtitle("") name(final)
// gr combine ap final

graph export Paper/Figures/groupsHist.png, replace

********************************************************************************
************ Histogram of API government vs opposition partisans ***************
********************************************************************************


tw  (hist AP_index2 if partid == 1, fcolor(gray) lcolor(gray)) (hist AP_index2 if partid == 0, fcolor(none) lcolor(red)), xti("Government partisan (red), Opposition partisan (gray)") legend(off) name(d1)

// tw  (hist final if partid == 1, fcolor(gray) lcolor(gray)) (hist final if partid == 0, fcolor(none) lcolor(red)), xti("Government partisan (red), Opposition partisan (gray)") legend(off) name(d2)
//
// gr combine d1 d2

ttest AP_index2, by(partid)
oneway AP_index2 party_id, scheffe

graph export Paper/Figures/AP_index_by_partisanship.png, replace


********************************************************************************
************************ Parties AP index distributions ************************
********************************************************************************

forvalues x = 1/5 {
if(`x' == 1 ){
local color "green"
local name "Vox"
}
else if (`x' == 2){
local color "blue"
local name "PP"
}
else if (`x' == 3){
local color "orange"
local name "Ciudadanos"
}
else if (`x' == 4){
local color "red"
local name "PSOE"
}
else if (`x' == 5){
local color "purple"
local name "Unidas Podemos"
}
	sum AP_index2 if party_id == `x'
	local m=r(mean)
	hist AP_index2 if party_id == `x', xlabel(0 20 `m' "`=string(`m',"%6.2f")'" 80 100) fc(none) lc(`color') note("") yti("") xti("") xline(`m', lp(dash) ) title(`name') name(G`x', replace)
}
graph combine G1 G2 G3 G4 G5, name("AP_index_by_party_id", replace) rows(2)

graph export Paper/Figures/AP_index_by_party_id.png, replace

tabstat AP_index2, c(statistics) s(mean sd n) by(party_id) 
oneway AP_index party_id, scheffe


** MARGINS:
grc1leg margins, name("margins", replace) rows(1) 
graph export Paper/Figures/margins.png, replace
grc1leg positive_margins, name("positive_margins", replace)  rows(1)
graph export Paper/Figures/positive_margins.png, replace
grc1leg negative_margins, name("negative_margins", replace)  rows(1)
graph export Paper/Figures/negative_margins.png, replace

********************************************************************************
************** SCATTER POSITIVE VS NEGATIVE PARTISANSHIP ***********************
********************************************************************************

tw (scatter positive_partisanship negative_partisanship if government_id, yline(50) xline(50) ti("total")  name(G3, replace))  
tw (scatter positive_partisanship negative_partisanship if party_id == 4, yline(50) xline(50) ti("PSOE") mcolor(red) name(G1, replace))  
tw (scatter positive_partisanship negative_partisanship if party_id == 5, yline(50) xline(50) ti("UP")mcolor(purple) name(G2, replace)) 

** PARTIES
tw (scatter positive_partisanship negative_partisanship if party_id==4, mcolor(red)) ///
(scatter positive_partisanship negative_partisanship if party_id==5, mcolor(purple)) ///
(scatter positive_partisanship negative_partisanship if party_id==1, mcolor(green)) ///
(scatter positive_partisanship negative_partisanship if party_id==2,  mcolor(blue)) ///
(scatter positive_partisanship negative_partisanship if party_id==3, mcolor(orange) ///
xline(50) yline(50) ///
legend(rows(1) label(1 "PSOE") label(2 "Unidas Podemos") label(3 "VOX") label(4 "PP") label(5 "Cs")) ///
xlabel(0 50 80) ylabel(0 50 80) ///
name(G4, replace))

scatter positive_partisanship negative_partisanship if party_id==4, mcolor(red) ///
xline(50) yline(50) ///
name(PSOE, replace)

scatter positive_partisanship negative_partisanship if party_id==5 & wave ==4, mcolor(purple) ///
xline(50) yline(50) ///
name(UP, replace)

scatter positive_partisanship negative_partisanship if party_id==2, mcolor(blue) ///
xline(50) yline(50) ///
name(PP, replace)

scatter positive_partisanship negative_partisanship if party_id==3, mcolor(orange) ///
xline(50) yline(50) ///
name(CS, replace)

scatter positive_partisanship negative_partisanship if party_id==1, mcolor(green) ///
xline(50) yline(50) ///
name(VOX, replace)

graph combine PSOE UP PP CS VOX

** OPPOSITION VS INCUMBENT
tw (scatter positive_partisanship negative_partisanship if opposition_id, mcolor(blue) legend(label(2 "Incumbent supporter") label(1 "Opposition supporter")))  (scatter positive_partisanship negative_partisanship if government_id, mcolor(red)) 

** LEVELS OF AFFECTIVE POLAIRZATION (ONLY INCUMBENT)
// tw ///
// (lfit positive_partisanship negative_partisanship if groups==0 & government, lcolor(green)) ///
// (lfit positive_partisanship negative_partisanship if groups==1 & government, lcolor(blue)) ///
// (lfit positive_partisanship negative_partisanship if groups==2 & government, lcolor(red) ///
// ytitle("In-group feelings") ///
// legend(label(1 "Supporters") label(2 "Regular partsians") label(3 "Fans")) ///
// name(lfit_groups, replace)) 

gr hbox negative_partisanship, by(groups)
sum negative_partisanship if government
tw ///
(scatter positive_partisanship negative_partisanship if groups==0 & government, mcolor(green) ) ///
(scatter positive_partisanship negative_partisanship if groups==1 & government, mcolor(blue) ) ///
(scatter positive_partisanship negative_partisanship if groups==2 & government, mcolor(red)  ///
yline(50) xline(50) ///
legend(rows(1) label(1 "Supporters") label(2 "Regular partisans") label(3 "Fans")) ///
name(scatter_groups, replace))

// graph combine lfit_groups scatter_groups

********************************************************************************
******* Relationship between API and positive vs negative partisanship *********
********************************************************************************

// gsort -AP_index2
// br AP_index2 positive_partisanship negative_partisanship
//
// tw scatter AP_index2 positive_partisanship, mcolor(green) name(pos, replace)
// scatter AP_index2 negative_partisanship, mcolor(red) name(neg,replace)
//
// graph combine pos neg
//
// tw (lfit AP_index2 positive_partisanship, lcolor(green)) (lfit AP_index2 negative_partisanship, lcolor(red))

********************************************************************************

// tw (scatter positive_partisanship negative_partisanship if party_id==1, xline(50) yline(50) mcolor(green)) (scatter positive_partisanship negative_partisanship if party_id==2,  mcolor(blue))
// graph combine G3 G1 G2 G4, rows(2)

// tw (scatter AP_index2 positive_partisanship if party_id == 4 , mcolor(red)) (scatter AP_index2 positive_partisanship if party_id == 5 , mcolor(purple) name(G5, replace))
//
// tw (scatter AP_index2 negative_partisanship if party_id == 4 , mcolor(red)) (scatter AP_index2 negative_partisanship if party_id == 5 , mcolor(purple) name(G6, replace))
//
// graph combine G5 G6