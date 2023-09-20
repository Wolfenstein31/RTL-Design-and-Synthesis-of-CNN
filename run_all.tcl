redirect -tee ./logs/setup.log {source -echo setup.tcl} 
redirect -tee ./logs/read.log {source -echo read.tcl} 
redirect -tee ./logs/Constraints.log {source -echo Constraints.tcl} 
redirect -tee ./logs/CompileAnalyze.log {source -echo CompileAnalyze.tcl}
exit
