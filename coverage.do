#coverage exclude -code b -du gcd_ctrl
#coverage exclude -srcfile tb.sv
run -all
coverage save a.ucdb
coverage report -details -output post-coverage.rpt
coverage report -details -html
exit
