********************************************************************************
* Name: Master
* Description: 
* Author: Rodrigo Fernández Caba
********************************************************************************

clear all
set more off

global projectdir "C:/Users/Rodrigo/Desktop/TFM"

cd $projectdir

do 02_dofiles/01_setup.do

set scheme tufte, perm
set autotabgraphs on, perm  



foreach x in pp psoe up cs vox{
egen feel_avg_`x' = mean(feel_`x'_voters), by(party_id AP_index)


egen feel_median1_`x' = mean(feel_avg_`x') if AP_index_dummy == 0, by(party_id)
egen feel_median2_`x' = mean(feel_avg_`x') if AP_index_dummy == 1, by(party_id)
egen mean_fell_median1_`x' = mean(feel_median1_`x'), by(party_id)
egen mean_fell_median2_`x' = mean(feel_median2_`x'), by(party_id)
gen dif_feel_`x' = mean_fell_median2_`x' - mean_fell_median1_`x'
*tw sc party_id dif_feel_pp 

*gr dot feel_avg_`x', over(party_id) by(AP_index_dummy, cols(1) title("Feelings towards `=strupper("`x'")' voters by party"))  name("feel_`x'_by_party", replace)

gr dot dif_feel_`x', over(party_id, sort(1)) yline(0, lpattern(dash) lcolor(red)) name("feel_`x'_dif_by_party", replace) title("Difference in feelings towards `=strupper("`x'")' voters between more and less polarized")
gr export 05_graphs/punctual_diff_feel_`x'.png, replace

statsby if AP_index_dummy == 0, by(party_id) saving(03_temp/`x'1.dta, replace):  ci means feel_`x'_voters, level(90)
statsby if AP_index_dummy == 1, by(party_id) saving(03_temp/`x'2.dta, replace):  ci means feel_`x'_voters,  level(90) 

use 03_temp/`x'2, clear
append using 03_temp/`x'1, gen(ap)

twoway rcap lb ub party_id, horiz || scatter party_id  mean if ap == 0 || sc party_id mean if ap == 1, yti("") yla( 1 "PP" 2 "PSOE" 3 "UP + IU" 4 "Ciudadanos" 5 "VOX", tlc(none)) legend(off) title("Difference in feelings towards `=strupper("`x'")' voters between more and less polarized", size(small))

graph export 05_graphs/diff_feel_`x'.png, replace

use 03_temp/data, replace
}

global attitudinal "unemployment_sit education_sit health_sit immigration_sit pensions_sit corruption_sit viol_wom_sit catalonia_sit"
global sociodemo "s0_ s1_ s2_ s3a_ s4a_ s8_"

* Logit model
logit vote_incumbent c.spanish_econ_assessment##c.AP_index  $attitudinal $sociodemo

* hist AP_index, by(wave)

* browse *_like *_affect *_pol average_party_affect AP_index
