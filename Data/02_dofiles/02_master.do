********************************************************************************
* Name: Master
* Description: 
* Author: Rodrigo Fernández Caba
********************************************************************************

*************
* GIT PUSH: *
*************

cap do git_push.do ""

********************************************************************************
clear all
set more off
set scheme tufte, perm
set autotabgraphs on, perm  

* Set working directory to the root folder:
cap global projectdir "C:\Users\Rodrigo\Desktop\TFM"

cd $projectdir

do Data/02_dofiles/01_setup.do
do Data/02_dofiles/04_models.do
do Data/02_dofiles/03_graphs.do 


hist AP_index , name(G1,replace)
hist AP_index2, name(G2,replace)
hist final, name(G3,replace)
graph combine G1 G2 G3

// reg spanish_econ_assessment i.partid if AP_index_dummy
// help reg
// reg spanish_econ_assessment i.opposition_id##i.AP_index_dummy  i.government_id##i.AP_index_dummy i.no_id##i.AP_index_dummy
// coefplot, keep(opposition_id no_id government_id) drop(_cons)
//
// coefplot, xline(0)
// tab government_id
// tab opposition_id
// tab no_id
//
// sum AP_index if !AP_index_dummy 


tab partid, nol
tab groups if partid == 0
tab groups2

tab spanish_econ_assessment
hist AP_index, by(party_id) name(G1, replace)
hist AP_index2, by(opposition_id) name(G2, replace)