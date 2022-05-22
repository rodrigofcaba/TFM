foreach x in pp psoe up cs vox{
egen feel_avg_`x' = mean(feel_`x'_voters), by(party_id AP_index)


egen feel_median1_`x' = mean(feel_avg_`x') if AP_index_dummy == 0, by(party_id)
egen feel_median2_`x' = mean(feel_avg_`x') if AP_index_dummy == 1, by(party_id)
egen mean_fell_median1_`x' = mean(feel_median1_`x'), by(party_id)
egen mean_fell_median2_`x' = mean(feel_median2_`x'), by(party_id)
gen dif_feel_`x' = mean_fell_median2_`x' - mean_fell_median1_`x'
*tw sc party_id dif_feel_pp 

*gr dot feel_avg_`x', over(party_id) by(AP_index_dummy, cols(1) title("Feelings towards `=strupper("`x'")' voters by party"))  name("feel_`x'_by_party", replace)

gr dot dif_feel_`x', over(party_id, sort(1)) yline(0, lpattern(dash) lcolor(red)) yti("") title("Difference in feelings towards `=strupper("`x'")' voters between more and less polarized", size(small))
gr export Data/05_graphs/punctual_diff_feel_`x'.png, replace

statsby if AP_index_dummy == 0, by(party_id) saving(Data/03_temp/`x'1.dta, replace):  ci means feel_`x'_voters, level(90)
statsby if AP_index_dummy == 1, by(party_id) saving(Data/03_temp/`x'2.dta, replace):  ci means feel_`x'_voters, level(90)

use Data/03_temp/`x'2, clear
append using Data/03_temp/`x'1, gen(ap)

twoway rcap lb ub party_id, horiz msiz(*0.8) xlabel(,labs(small)) legend(label (1 "90% confidence intervals") label (2 "More polarized than the average") label(3 "Less polarized than the average") size(small)) || scatter party_id  mean if ap == 0, mcolor(red)|| sc party_id mean if ap == 1, name("feel_`x'_dif_by_party", replace)  yti("") yla( 2 "PP" 4 "PSOE" 5 "UP + IU" 3 "Ciudadanos" 1 "VOX", labsize(small)  tlc(none)) title(`=strupper("`x'")', size(medsmall))

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

hist AP_index, by(partid, note("")) yti("")

graph export Paper/Figures/AP_index_by_partisanship.png, replace

hist AP_index, by(party_id, note("")) yti("")

graph export Paper/Figures/AP_index_by_party_id.png, replace

egen AP_wave = mean(AP_index), by(wave)

line 