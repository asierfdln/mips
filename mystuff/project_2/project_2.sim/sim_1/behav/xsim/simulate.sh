#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2022.1 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Wed Nov 16 03:09:19 CET 2022
# SW Build 3526262 on Mon Apr 18 15:47:01 MDT 2022
#
# IP Build 3524634 on Mon Apr 18 20:55:01 MDT 2022
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# simulate design
echo "xsim register_file_tb_behav -key {Behavioral:sim_1:Functional:register_file_tb} -tclbatch register_file_tb.tcl -view /home/asier/vivadoprojects/project_2/imem_tb_behav.wcfg -view /home/asier/vivadoprojects/project_2/dmem_tb_behav.wcfg -view /home/asier/vivadoprojects/project_2/flopenr_tb_behav.wcfg -view /home/asier/vivadoprojects/project_2/datapath_tb_behav.wcfg -view /home/asier/vivadoprojects/project_2/alu_tb_behav.wcfg -view /home/asier/vivadoprojects/project_2/register_file_tb_behav.wcfg -log simulate.log"
xsim register_file_tb_behav -key {Behavioral:sim_1:Functional:register_file_tb} -tclbatch register_file_tb.tcl -view /home/asier/vivadoprojects/project_2/imem_tb_behav.wcfg -view /home/asier/vivadoprojects/project_2/dmem_tb_behav.wcfg -view /home/asier/vivadoprojects/project_2/flopenr_tb_behav.wcfg -view /home/asier/vivadoprojects/project_2/datapath_tb_behav.wcfg -view /home/asier/vivadoprojects/project_2/alu_tb_behav.wcfg -view /home/asier/vivadoprojects/project_2/register_file_tb_behav.wcfg -log simulate.log

