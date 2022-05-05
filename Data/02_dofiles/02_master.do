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
cap global projectdir "your/path/to/TFM"

global model 1
cd $projectdir

do Data/02_dofiles/01_setup.do $model
do Data/02_dofiles/03_graphs.do 
do Data/02_dofiles/04_models.do

