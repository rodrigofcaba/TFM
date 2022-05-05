********************************************************************************
* Name: Master
* Description: 
* Author: Rodrigo Fernández Caba
********************************************************************************

clear all
set more off
set scheme tufte, perm
set autotabgraphs on, perm  

global projectdir "C:/Users/Rodrigo/Desktop/TFM"
global model 1

cd $projectdir

do Data/02_dofiles/01_setup.do $model
do Data/02_dofiles/03_graphs.do 
do Data/02_dofiles/04_models.do

