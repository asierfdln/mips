python3 mystuff/asmtoisa.py > mystuff/src/imem.dat.verbose
cat mystuff/src/imem.dat.verbose
cat mystuff/src/imem.dat.verbose | awk '{ print $1 }' > mystuff/src/imem.dat
