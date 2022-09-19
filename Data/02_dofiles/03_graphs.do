********************************************************************************
********************************* GRAPHS ***************************************
********************************************************************************

global psoe_color "218 41 28"
global pp_color "119 181 254"
global up_color "97 45 98"
global cs_color "251 80 0"
global vox_color "99 172 51"


tw (scatter AP_index AP_wagner) (lfit AP_index AP_wagner, legend(off) xtitle(Wagner's (2021) WAP index) yti(Affective Polarization Index))
graph export Paper/Figures/api_wagner_scatter.png, replace
corr AP_index AP_wagner


** Differences in feelings according to partisanship **

foreach x in pp psoe up cs vox{
egen feel_avg_`x' = mean(feel_`x'_voters), by(party_id AP_index)


egen feel_median1_`x' = mean(feel_avg_`x') if AP_index_dummy == 0, by(party_id)
egen feel_median2_`x' = mean(feel_avg_`x') if AP_index_dummy == 1, by(party_id)
egen mean_fell_median1_`x' = mean(feel_median1_`x'), by(party_id)
egen mean_fell_median2_`x' = mean(feel_median2_`x'), by(party_id)
gen dif_feel_`x' = mean_fell_median2_`x' - mean_fell_median1_`x'

gr dot dif_feel_`x', over(party_id, sort(1) label(labsize(small))) yline(0, lpattern(dash) lcolor(red)) yti("") title("`=strupper("`x'")'", size(small)) ylabel(,labs(small)) ylabel(-40(20)40)  name(`x'_dot, replace)
gr export Paper/Figures/punctual_diff_feel_`x'.png, replace

statsby if AP_index_dummy == 0, by(party_id) saving(Data/03_temp/`x'1.dta, replace):  ci means feel_`x'_voters
statsby if AP_index_dummy == 1, by(party_id) saving(Data/03_temp/`x'2.dta, replace):  ci means feel_`x'_voters

use Data/03_temp/`x'2, clear
append using Data/03_temp/`x'1, gen(ap)

twoway rcap lb ub party_id, horiz msiz(*0.8) xlabel(0(20)100,labs(small)) legend(label (1 "95% confidence intervals") label (2 "More polarized than the average") label(3 "Less polarized than the average") size(small)) || scatter party_id  mean if ap == 0, mcolor(red)|| sc party_id mean if ap == 1, name("feel_`x'_dif_by_party", replace)  yti("") yla( 2 "PP" 4 "PSOE" 5 "UP" 3 "Ciudadanos" 1 "VOX", labsize(small)  tlc(none)) title(`=strupper("`x'")', size(medsmall))

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


gr combine psoe_dot pp_dot up_dot vox_dot cs_dot , name(combined_dot_graph, replace)  rows(3)

gr export Paper/Figures/combined_dot_feelingsAP.png, replace

********************************************************************************
******************************* GROUPS *****************************************
********************************************************************************

********************************************************************************
*********************** Histogram of API by SD *********************************
********************************************************************************
sum AP_index

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

histogram AP_index , normal ///
fc(none) lc(gray) ///
xline(`low',  lp(dash)) xline(`high', lp(dash)) ///
xlabel(`low' "-SD" `m' "Mean = `=string(`m',"%6.2f")'" `high' "+SD") xtitle("") name(ap,replace)

graph export Paper/Figures/groupsHist.png, replace

sum AP_wagner

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

histogram AP_wagner , normal ///
fc(none) lc(gray) ///
xline(`low',  lp(dash)) xline(`high', lp(dash)) ///
xlabel(`low' "-SD" `m' "Mean = `=string(`m',"%6.2f")'" `high' "+SD") xtitle("") name(ap_wagner,replace)


graph export Paper/Figures/groupsHist_wagner.png, replace

********************************************************************************
************ Histogram of API government vs opposition partisans ***************
********************************************************************************


tw  (hist AP_index if partid == 1, fcolor(gray) lcolor(gray)) (hist AP_index if partid == 0, fcolor(none) lcolor(red)), xti("Government partisan (red), Opposition partisan (gray)") legend(off) name(inc_oppo_hist, replace)

ttest AP_index, by(partid)
oneway AP_index party_id, scheffe

graph export Paper/Figures/AP_index_by_partisanship.png, replace

tw  (hist AP_wagner if partid == 1, fcolor(gray) lcolor(gray)) (hist AP_wagner if partid == 0, fcolor(none) lcolor(red)), xti("Government partisan (red), Opposition partisan (gray)") legend(off) name(inc_oppo_hist_wagner, replace)

ttest AP_wagner, by(partid)
oneway AP_wagner party_id, scheffe

graph export Paper/Figures/AP_index_by_partisanship_wagner.png, replace


********************************************************************************
************************ Parties AP index distributions ************************
********************************************************************************

program compute_parties_distributions

forvalues x = 1/5 {
if(`x' == 1 ){
local color ""$vox_color""
local name "Vox"
}
else if (`x' == 2){
local color ""$pp_color""
local name "PP"
}
else if (`x' == 3){
local color ""$cs_color""
local name "Ciudadanos"
}
else if (`x' == 4){
local color ""$psoe_color""
local name "PSOE"
}
else if (`x' == 5){
local color ""$up_color""
local name "Unidas Podemos"
}
	
	if (party_id != 5) {
	sum `1' if party_id == `x'
	local m=r(mean)
	hist `1' if party_id == `x', xlabel(`m' "`=string(`m',"%6.2f")'") fc(none) lc(`color') note("") yti("") xti("") xline(`m', lp(dash) ) title(`name') name(G`x', replace)
	}
	else
	{
	sum `1' if party_id == `x' & wave ==4
	local m=r(mean)
	hist `1' if party_id == `x' & wave == 4, xlabel(`m' "`=string(`m',"%6.2f")'") fc(none) lc(`color') note("") yti("") xti("") xline(`m', lp(dash) ) title(`name') name(G`x', replace)
	}
	
}
graph combine G1 G2 G3 G4 G5, name("AP_index_by_party_id", replace) rows(2)
end

compute_parties_distributions AP_index

graph export Paper/Figures/AP_index_by_party_id.png, replace

tabstat AP_index, c(statistics) s(mean sd n) by(party_id) 
oneway AP_index party_id, scheffe

compute_parties_distributions AP_wagner

graph export Paper/Figures/AP_index_by_party_id_wagner.png, replace

tabstat AP_wagner, c(statistics) s(mean sd n) by(party_id) 
oneway AP_wagner party_id, scheffe


********************************************************************************
************** SCATTER POSITIVE VS NEGATIVE PARTISANSHIP ***********************
********************************************************************************

** POS NEG BY PARTY

tw (function y = x, ra(-20 20) lpattern(dash)) scatter positive_partisanship negative_partisanship if party_id==4 & wave ==4, mcolor("$psoe_color") ///
xline(0, lpattern(dash)) yline(0, lpattern(dash)) ///
ylabel(-20(10)20) ///
legend(off) ///
title(PSOE) name(PSOE, replace)

tw (function y = x, ra(-20 20) lpattern(dash)) scatter positive_partisanship negative_partisanship if party_id==5 & wave ==4, mcolor("$up_color") ///
xline(0, lpattern(dash)) yline(0, lpattern(dash)) ///
ylabel(-20(10)20) ///
legend(off) ///
title("Unidas Podemos") name(UP, replace)

tw (function y = x, ra(-20 20) lpattern(dash)) scatter positive_partisanship negative_partisanship if party_id==2, mcolor("$pp_color") ///
xline(0, lpattern(dash)) yline(0, lpattern(dash)) ///
ylabel(-20(10)20) ///
legend(off) ///
title(PP) name(PP, replace)

tw (function y = x, ra(-20 20) lpattern(dash)) scatter positive_partisanship negative_partisanship if party_id==3, mcolor("$cs_color") ///
xline(0, lpattern(dash)) yline(0, lpattern(dash)) ///
ylabel(-20(10)20) ///
legend(off) ///
title(Ciudadanos) name(CS, replace)

tw (function y = x, ra(-20 20) lpattern(dash))scatter positive_partisanship negative_partisanship if party_id==1, mcolor("$vox_color") ///
xline(0, lpattern(dash)) yline(0, lpattern(dash)) ///
ylabel(-20(10)20) ///
legend(off) ///
title(Vox) name(VOX, replace)

graph combine PSOE UP PP CS VOX

graph export Paper/Figures/pos_neg_parties.png, replace

** LEVELS OF AFFECTIVE POLAIRZATION (ONLY INCUMBENT)

tw ///
(function y = x, ra(-10 10) lpattern(dash)) ///
(scatter positive_partisanship negative_partisanship if groups==0 & ! partid, mcolor(black*0.25) msymbol(o) ) ///
(scatter positive_partisanship negative_partisanship if groups==1 & ! partid , mcolor(black*0.5) msymbol(d) ) ///
(scatter positive_partisanship negative_partisanship if groups==2 & ! partid, mcolor(black) msymbol(s)  ///
yline(0, lpattern(dash)) xline(0, lpattern(dash)) ///
ylabel(-10(10)20) ///
legend(rows(1) order(2 "Supporters" 3 "Regular partisans" 4 "Fans")) ///
name(scatter_groups, replace))


graph export Paper/Figures/pos_neg_groups.png, replace


********************************************************************************
******* Relationship between API and positive vs negative partisanship *********
********************************************************************************

gsort -AP_index
br AP_index positive_partisanship_w negative_partisanship_w

tw scatter AP_index positive_partisanship_w, mcolor(green) name(pos, replace)
scatter AP_index negative_partisanship_w, mcolor(red) name(neg,replace)

graph combine pos neg
