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

* Logit model
logit vote_incumbent c.spanish_econ_assessment##c.AP_index 
logit vote_incumbent spanish_econ_assessment##c.AP_index if wave ==4

hist AP_index, by(wave)

browse *_like *_affect *_pol average_party_affect AP_index

help xtset

describe g1a_0
xtset g1a_0 wave

xtreg p37a_ AP_index

tab p38a_ wave
tab p37a_ wave

browse g1a_0 p38a_ p37a_ AP_index wave

* vote for the incumbent:
reg pa_ p37a_##c.AP_index if wave != 1