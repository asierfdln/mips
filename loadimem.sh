python3 mystuff/asmtoisa.py |& tee mystuff/asmtoisa.log
cat mystuff/asmtoisa.log > mystuff/src/imem.dat.verbose
cat mystuff/asmtoisa.log | awk '{ print $1 }' > mystuff/src/imem.dat

# python3 mystuff/asmtoisa.py |& tee mystuff/asmtoisa.log
# retval="$?"
# if [ $retval -ne 0 ]
# then
#     false
# else
#     cat mystuff/asmtoisa.log > mystuff/src/imem.dat.verbose
#     cat mystuff/asmtoisa.log | awk '{ print $1 }' > mystuff/src/imem.dat
# fi
