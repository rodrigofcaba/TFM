program compute_parties_distributions

args var

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
	
	if (party_id != 5) {
	sum var if party_id == `x'
	local m=r(mean)
	hist var if party_id == `x', xlabel(0 0.2 `m' "`=string(`m',"%6.2f")'" 0.8 1) fc(none) lc(`color') note("") yti("") xti("") xline(`m', lp(dash) ) title(`name') name(G`x', replace)
	}
	else
	{
	sum var if party_id == `x' & wave ==4
	local m=r(mean)
	hist var if party_id == `x' & wave == 4, xlabel(0 0.2 `m' "`=string(`m',"%6.2f")'" 0.8 1) fc(none) lc(`color') note("") yti("") xti("") xline(`m', lp(dash) ) title(`name') name(G`x', replace)
	}
	
}
graph combine G1 G2 G3 G4 G5, name("AP_index_by_party_id", replace) rows(2)
end