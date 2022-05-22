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

* Set working directory to the root of the folder:
cap global projectdir "C:\Users\Rodrigo\Documents\programming\TFM"

global model 1
cd $projectdir

do Data/02_dofiles/01_setup.do $model
// do Data/02_dofiles/03_graphs.do 
do Data/02_dofiles/04_models.do

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