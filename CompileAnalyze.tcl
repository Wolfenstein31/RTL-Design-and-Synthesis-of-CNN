#---------------------------------------------------------
# Now resynthesize the design to meet constraints,     
# and try to best achieve the goal, and using the      
# CMOSX parts.  In large designs, compile can take     
# a lllooonnnnggg time!                                
#
# -map_effort specifies how much optimization effort   
# there is, i.e. low, medium, or high.                 
#    Use high to squeeze out those last picoseconds. 
# -verify_effort specifies how much effort to spend    
# making sure that the input and output designs        
# are equivalent logically                             
#---------------------------------------------------------
##################################################
# Revision History: 01/18/2011, by Zhuo Yan
# replaced with ultra: 08/21/2020, by P. Franzon
##################################################

###########################
# old command - still works, is probably faster but less optimal
# compile -map_effort medium
###########################

  compile_ultra

#---------------------------------------------------------
# This is just a sanity check: Write out the design before 
# hold fixing
#---------------------------------------------------------
  write -hierarchy -f verilog -o ./gl/${modname}_init.v

#---------------------------------------------------------
# Now trace the critical (slowest) path and see if     
# the timing works.                                    
# If the slack is NOT met, you HAVE A PROBLEM and      
# need to redesign or try some other minimization      
# tricks that Synopsys can do                          
#---------------------------------------------------------

  report_timing  > ./reports/timing_max_slow.rpt

#---------------------------------------------------------
# This is your section to do different things to       
# improve timing or area - RTFM (Read The Manual) :)
#---------------------------------------------------------

#---------------------------------------------------------
# Now resynthesize the design for the fastest corner   
# making sure that hold time conditions are met        
#---------------------------------------------------------

#---------------------------------------------------------
# Specify the fastest process corner and lowest temp   
# and highest (fastest) Vcc                            
#---------------------------------------------------------

  set target_library NangateOpenCellLibrary_PDKv1_2_v2008_10_fast_nldm.db
  set link_library   NangateOpenCellLibrary_PDKv1_2_v2008_10_slow_nldm.db
  set link_library   [concat  $link_library dw_foundation.sldb] 
  translate

#---------------------------------------------------------
# Set the design rule to 'fix hold time violations'    
# Then compile the design again, telling Synopsys to   
# only change the design if there are hold time        
# violations.                                          
#---------------------------------------------------------

  set_fix_hold $clkname
  compile -only_design_rule -incremental
#compile -prioritize_min_paths -only_hold_time
# report_timing -delay min -nworst 30 > timing_report_${modname}_min_postfix.rpt 
# report_timing -delay min -nworst 30 > timing_report_${modname}_min_postfix.rpt 

#---------------------------------------------------------
# Report the fastest path.  Make sure the hold         
# is actually met.                                     
#---------------------------------------------------------
# report_timing  > timing_max_fast_${type}.rpt
  report_timing -delay min  > ./reports/timing_min_fast_holdcheck_${type}.rpt

#---------------------------------------------------------
# Write out the 'fastest' (minimum) timing file        
# in Standard Delay Format.  We might use this in      
# later verification.                                  
#---------------------------------------------------------

  write_sdf ./sdf/counter_min.sdf

#---------------------------------------------------------
# Since Synopsys has to insert logic to meet hold      
# violations, we might find that we have setup         
# violations now.  So lets recheck with the slowest    
# corner, etc.                                         
#  YOU have problems if the slack is NOT MET           
# 'translate' means 'translate to new library'         
#---------------------------------------------------------

  set target_library NangateOpenCellLibrary_PDKv1_2_v2008_10_slow_nldm.db
  set link_library   NangateOpenCellLibrary_PDKv1_2_v2008_10_slow_nldm.db
  set link_library   [concat  $link_library dw_foundation.sldb]
  translate
  report_timing  > ./reports/timing_max_slow_holdfixed_${type}.rpt
# report_timing -delay min  > timing_min_slow_holdfixed_${type}.rpt

#---------------------------------------------------------
# Sanity checks to see if the libraries are characterized 
# correctly    
#---------------------------------------------------------
# set target_library NangateOpenCellLibrary_PDKv1_2_v2008_10_fast_nldm.db
# set link_library   NangateOpenCellLibrary_PDKv1_2_v2008_10_fast_nldm.db
# set link_library   [concat  $link_library dw_foundation.sldb]
# translate
# report_timing  > timing_max_fast_holdfixed_${type}.rpt
# report_timing -delay min  > timing_min_fast_holdfixed_${type}.rpt

# set target_library NangateOpenCellLibrary_PDKv1_2_v2008_10_typical_nldm.db
# set link_library   NangateOpenCellLibrary_PDKv1_2_v2008_10_typical_nldm.db
# set link_library   [concat  $link_library dw_foundation.sldb]
# translate
# report_timing  > timing_max_typ_holdfixed_${type}.rpt
# report_timing -delay min  > timing_min_typ_holdfixed_${type}.rpt


#---------------------------------------------------------
# Write out area distribution for the final design    
#---------------------------------------------------------
  report_cell > ./reports/cell_report_final.rpt

#---------------------------------------------------------
# Write out the resulting netlist in Verliog format    
#---------------------------------------------------------
  change_names -rules verilog -hierarchy > ./logs/fixed_names_init
  write -hierarchy -f verilog -o ./gl/${modname}_final.v
# write -hierarchy -format verilog -output ${modname}_netlist_holdfixed_${type}.v #RAVI

#---------------------------------------------------------
# Write out the 'slowest' (maximum) timing file        
# in Standard Delay Format.  We might use this in      
# later verification.                                  
#---------------------------------------------------------

  write_sdf ./sdf/${modname}_max.sdf

