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

if(_rc==111){
cap net install grc1leg, from (http://www.stata.com/users/vwiggins)
}

*Combined graphs
grc1leg feel_psoe_dif_by_party feel_pp_dif_by_party  feel_up_dif_by_party feel_vox_dif_by_party feel_cs_dif_by_party, legendfrom(feel_pp_dif_by_party) name(combined_graph, replace) span rows(3)

graph export Paper/Figures/combinedfeelingsAP.png, replace

* GROUPS
sum AP_index

local m=r(mean)
local sd=r(sd)
local low = `m'-`sd'
local high=`m'+`sd'

 histogram AP_index , normal ///
	fc(none) lc(gray) ///
   xline(`low',  lp(dash)) xline(`high', lp(dash)) ///
   xlabel(`low' "-SD" `m' "Mean = `=string(`m',"%6.2f")'" `high' "+SD") xtitle("")

graph export Paper/Figures/groupsHist.png, replace


tab partid, nol
hist AP_index, by(partid, note("")) yti("")

tw  (hist AP_index if partid == 1, fcolor(gray) lcolor(gray)) (hist AP_index if partid == 0, fcolor(none) lcolor(red)), xti("Government partisan (red), Opposition partisan (gray)") legend(off)

ttest AP_index, by(partid)
oneway AP_index party_id, scheffe

graph export Paper/Figures/AP_index_by_partisanship.png, replace

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
	sum AP_index if party_id == `x'
	local m=r(mean)
	hist AP_index if party_id == `x', xlabel(0 2 6 8 `m' "`=string(`m',"%6.2f")'") fc(none) lc(`color') note("") yti("") xti("") xline(`m', lp(dash) ) title(`name') name(G`x', replace)
}
graph combine G1 G2 G3 G4 G5, name("AP_index_by_party_id", replace) rows(2)

graph export Paper/Figures/AP_index_by_party_id.png, replace

tabstat AP_index, c(statistics) s(mean sd n) by(party_id) 
oneway AP_index party_id, scheffe
** MARGINS:

grc1leg margins1 margins2, name("continue_oppo_incumb", replace)  rows(1)
graph export Paper/Figures/continue_oppo_incumb.png, replace
grc1leg margins3 margins4, name("dummy_oppo_incumb1", replace)  rows(1)
graph export Paper/Figures/dummy_oppo_incumb1.png, replace
grc1leg margins5 margins6, name("dummy_oppo_incumb2", replace)  rows(1)
graph export Paper/Figures/dummy_oppo_incumb2.png, replace
grc1leg margins7 margins8, name("dummy_parties", replace)  rows(1)
graph export Paper/Figures/dummy_parties.png, replace
grc1leg margins9 margins10, name("continue_parties", replace)  rows(1)
graph export Paper/Figures/continue_parties.png, replace