# mipstest.asm
# 9/16/03 David Harris David_Harris@hmc.edu
#
# Test MIPS instructions. Assumes little-endian memory was
# initialized as:
# word 16: 3
# word 17: 5
# word 18: 12


0x0     R   ADD     r1, r2, r3
0x1     R   SUB     r1, r2, r3
0x2     R   AND     r1, r2, r3
0x3     R   OR      r1, r2, r3
0x4     R   SLT     r1, r2, r3
0x5     R   MUL     r1, r2, r3
    TODO diff block and such, buff...
0x6     R   MOV     r1, r2, REG0_to_do_a_sum...
    but this would make it an M-type instruction whose offset must always be zeroes...
    TODO this is a bit of a chapuza, must have some block to set all r3 bits to zero governed by a control signal... like just a bunch of and_gates with all the remaining bits of r3andbeyond and ALUctrl set to add stuff... or just a mux2 with aluresult and move result... this is much better
(Rñeh) ADDI??... this would allow us to do fibonacci
    TODO should be as simple as playing around with control signals i think...
0x10    M   LDB     imm(r1), r0
    // load byte: $1 <- mem[$2 + imm]
0x11    M   LDW     imm(r1), r0
    // load byte: $1 <- mem[$2 + imm]
0x12    M   STB     r0, imm(r1)
    // store byte: mem[$2 + imm] <- $1
0x13    M   STW     r0, imm(r1)
    // store byte: mem[$2 + imm] <- $1
0x30    B   BEQ     r1, r2, offset
    // if r1==r2, PC = PC + offset
0x31    B   JUMP    r1, offset
    // PC = r1 + offset
// others...
0x15    B   TLBWR   ...
0x16    B   IRET    ...


[R-type]    opcode_31-25    dst_24-20       src1_19-15      src2_14-10              zeroes_9-0
            0000000         00000           00000           00000                   0000000000
            00000000000000000000000000000000
            0000 0000 0000 0000 0000 0000 0000 0000
            0    0    0    0    0    0    0    0
            00000000
[M-type]    opcode_31-25    dst_24-20       src1_19-15      offset_14-0
            0000000         00000           00000           000000000000000
            00000000000000000000000000000000
            0000 0000 0000 0000 0000 0000 0000 0000
            0    0    0    0    0    0    0    0
            00000000
[B-type]    opcode_31-25    offsethi_24-20  src1_19-15      src2/offsetmid_14-10    offsetlo_9-0
            0000000         00000           00000           00000                   0000000000
            00000000000000000000000000000000
            0000 0000 0000 0000 0000 0000 0000 0000
            0    0    0    0    0    0    0    0
            00000000


main:       #Assembly Code          effect                      Machine Code
            lb $2, 68($0)           # initialize $2 = 5         20200044        [M-type]    opcode_31-25    dst_24-20       src1_19-15      offset_14-0
                                                                                            0000000         00000           00000           000000000000000
                                                                                        --> 0010000         00010           00000           000000001000100
                                                                                            00000000000000000000000000000000
                                                                                        --> 00100000001000000000000001000100
                                                                                            0000 0000 0000 0000 0000 0000 0000 0000
                                                                                        --> 0010 0000 0010 0000 0000 0000 0100 0100
                                                                                            0    0    0    0    0    0    0    0
                                                                                        --> 2    0    2    0    0    0    4    4
                                                                                            00000000
                                                                                        !!! 20200044
            lb $7, 64($0)           # initialize $7 = 3         80070040
            lb $3, 69($7)           # initialize $3 = 12        80e30045
            or $4, $7, $2           # $4 <= 3 or 5 = 7          00e22025
            and $5, $3, $4          # $5 <= 12 and 7 = 4        00642824
            add $5, $5, $4          # $5 <= 4 + 7 = 11          00a42820
            beq $5, $7, end         # shouldn’t be taken        10a70008
            slt $6, $3, $4          # $6 <= 12 < 7 = 0          0064302a
            beq $6, $0, around      # should be taken           10c00001
            lb $5, 0($0)            # shouldn’t happen          80050000
around:     slt $6, $7, $2          # $6 <= 3 < 5 = 1           00e2302a
            add $7, $6, $5          # $7 <= 1 + 11 = 12         00c53820
            sub $7, $7, $2          # $7 <= 12 - 5 = 7          00e23822
            j end                   # should be taken           0800000f
            lb $7, 0($0)            # shouldn’t happen          80070000
end:        sb $7, 71($2)           # write adr 76 <= 7         a0470047
            .dw 3                                               00000003
            .dw 5                                               00000005
            .dw 12                                              0000000c

memfile.dat
80020044
80070040
80e30045
00e22025
00642824
00a42820
10a70008
0064302a
10c00001
80050000
00e2302a
00c53820
00e23822
0800000f
80070000
a0470047
00000003
00000005
0000000c
