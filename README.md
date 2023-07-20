#What's this?


Small in-order, single-issue pipelined processor made for the Processor Architecture subject (MIRI-HPC master's at UPC), custom small ISA.



##What source materials were used to make this?

Subject's slides were used in part for this, which were heavily inspired, in turn, by the Hennessy-Patterson and Patterson-Hennessy diagrams and figures. However, in my personal view, the David Money Harris book provides a much simpler, step-by-step design process



#What to take a look at to understand stuff?
===========================================

the .drawio file provided with the project files lays out a step-by-step extension-process of how to go from the single-cycle version of the processor to the fully functional pipelined version. Each tab of the .drawio file is aptly named to refer to the motivation and purpose behind the extension (note: Ctrl+Shift+H to centre the design in the window and thus see each transition from a sort fo “framed” fixed position). The single-cycle version corresponds to the datapath.vhd file (simulated with the datapath_tb.vhd file) and the pipelined version resides in the datapath_PP{,_tb}.vhd files.



##On the final report "report.pdf" file
=====================================

DISCLAIMER #1: the report was written with the subject's professor being the sole audience in mind as a compilation of the deviations and

DISCLAIMER #2: it can be a little tedious and convoluted if read before having checked the "step.by.step.proc.pdf" presentation or if not familiar with ISA encoding.

The "report.pdf" file containts the final report handed-in to the professor. Not much in the way of explaining how the processor works or is implemented. Instead, it details the specific modifications made to the proposed ISA and/or hardware blocks according to personal preferences/idiosincrasies. It is, essentially, a compilation of notes and

HOWEVER, the report does contain the ISA encoding and definitions of instructions, as well as explanations of all the sanity-check programs and benchmarks used to confirm the correct functioning of the processor. They include a simple a instruction-checker, a Fibonacci-number program, a buffer-sum, a mem-copy and a matrix-multiply. All programs are shown in C, in their assembly implementation format, as well as the expected contents of imem for the sanity-checkers (see "loadimem.sh" script for further details on how imem is loaded).
