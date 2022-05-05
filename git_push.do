* RUN TO PUSH CHANGES TO GITHUB:
args text
file close _all
file open git using mygit.bat, write replace
file write git "git add --all" _n
file write git "git commit -m "
file write git `"""' "`text'" `"""' _n
file write git "git push" _n
file close git
! mygit.bat
