def r_instruction(list_of_arguments):

    # [R-type]    opcode_31-25    dst_24-20       src1_19-15      src2_14-10              zeroes_9-0
    #             0000000         00000           00000           00000                   0000000000
    #             00000000000000000000000000000000
    #             0000 0000 0000 0000 0000 0000 0000 0000
    #             0    0    0    0    0    0    0    0
    #             00000000

    # r_type = [
    #     "ADD",      # r1 <- r2 + r3
    #     "SUB",      # r1 <- r2 - r3
    #     "AND",      # r1 <- r2 AND r3
    #     "OR",       # r1 <- r2 OR r3
    #     "SLT",      # r1 <- "1" if r2 < r3, otherwise r1 <- "0"
    #     # "MUL",      # r1 <- r2 * r3
    # ]

    opcode_31_25    = '0000000'
    dst_24_20       = '00000'
    src1_19_15      = '00000'
    src2_14_10      = '00000'
    zeroes_9_0      = '0000000000'

    dst_24_20       = bin(int(list_of_arguments[1]) % (2 ** len(dst_24_20)))[2:].zfill(len(dst_24_20))
    src1_19_15      = bin(int(list_of_arguments[2]) % (2 ** len(src1_19_15)))[2:].zfill(len(src1_19_15))
    src2_14_10      = bin(int(list_of_arguments[3]) % (2 ** len(src2_14_10)))[2:].zfill(len(src2_14_10))

    # print(dst_24_20)
    # print(src1_19_15)
    # print(src2_14_10)
    # exit(0)

    if list_of_arguments[0] == "ADD":
        opcode_31_25 = '0000000'
    elif list_of_arguments[0] == "SUB":
        opcode_31_25 = '0000001'
    elif list_of_arguments[0] == "AND":
        opcode_31_25 = '0000010'
    elif list_of_arguments[0] == "OR":
        opcode_31_25 = '0000011'
    elif list_of_arguments[0] == "SLT":
        opcode_31_25 = '0000100'
    # elif list_of_arguments[0] == "MUL":
    #     opcode_31_25 = '0000101'
    else:
        print(f'Oops, "{list_of_arguments[0]}" is not in r_instruction()')
        exit(1)

    # print(opcode_31_25)
    # exit(0)

    concat = f'{opcode_31_25}{dst_24_20}{src1_19_15}{src2_14_10}{zeroes_9_0}'
    if len(concat) != 32:
        print(f'Oops, "{list_of_arguments}" crashed in r_instruction(), failed lengthcheck: {len(concat)} {concat}')
        exit(1)

    hexvalue = hex(int(concat, 2))[2:].zfill(8)
    # print(hexvalue)
    # exit(0)

    return hexvalue, concat


def m_instruction(list_of_arguments):

    # [M-type]    opcode_31-25    dst_24-20       src1_19-15      offset_14-0
    #             0000000         00000           00000           000000000000000
    #             00000000000000000000000000000000
    #             0000 0000 0000 0000 0000 0000 0000 0000
    #             0    0    0    0    0    0    0    0
    #             00000000

    # m_type = [
    #     "ADDI",     # r1 <- r2 + imm
    #     "LDB",      # r1 <- mem[r2 + imm]
    #     "LDW",      # r1 <- mem[r2 + imm]
    #     "STB",      # mem[r2 + imm] <- r1                       # s.t. r1 --> r3
    #     "STW",      # mem[r2 + imm] <- r1                       # s.t. r1 --> r3
    # ]

    opcode_31_25    = '0000000'
    dst_24_20       = '00000'
    src1_19_15      = '00000'
    offset_14_0     = '000000000000000'

    dst_24_20       = bin(int(list_of_arguments[1]) % (2 ** len(dst_24_20)))[2:].zfill(len(dst_24_20))
    src1_19_15      = bin(int(list_of_arguments[2]) % (2 ** len(src1_19_15)))[2:].zfill(len(src1_19_15))
    offset_14_0     = bin(int(list_of_arguments[3]) % (2 ** len(offset_14_0)))[2:].zfill(len(offset_14_0))

    # print(dst_24_20)
    # print(src1_19_15)
    # print(offset_14_0)
    # exit(0)

    if list_of_arguments[0] == "ADDI":
        opcode_31_25 = '0000111'
    elif list_of_arguments[0] == "LDB":
        opcode_31_25 = '0010000'
    elif list_of_arguments[0] == "LDW":
        opcode_31_25 = '0010001'
    elif list_of_arguments[0] == "STB":
        opcode_31_25 = '0010010'
    elif list_of_arguments[0] == "STW":
        opcode_31_25 = '0010011'
    else:
        print(f'Oops, "{list_of_arguments[0]}" is not in m_instruction()')
        exit(1)

    # print(opcode_31_25)
    # exit(0)

    concat = f'{opcode_31_25}{dst_24_20}{src1_19_15}{offset_14_0}'
    if len(concat) != 32:
        print(f'Oops, "{list_of_arguments}" crashed in m_instruction(), failed lengthcheck: {len(concat)} {concat}')
        exit(1)

    hexvalue = hex(int(concat, 2))[2:].zfill(8)
    # print(hexvalue)
    # exit(0)

    return hexvalue, concat


def b_instruction(list_of_arguments):

    # [LIES : start]
    # [B-type]    opcode_31-25    offsethi_24-20  src1_19-15      src2/offsetmid_14-10    offsetlo_9-0
    #             0000000         00000           00000           00000                   0000000000
    #             00000000000000000000000000000000
    #             0000 0000 0000 0000 0000 0000 0000 0000
    #             0    0    0    0    0    0    0    0
    #             00000000
    # [LIES :   end]

    # [BEQ-type]  opcode_31-25    dst_24-20       src1_19-15      offset_14-0
    #             0000000         00000           00000           000000000000000
    #             00000000000000000000000000000000
    #             0000 0000 0000 0000 0000 0000 0000 0000
    #             0    0    0    0    0    0    0    0
    #             00000000
    # [JMP-type]  opcode_31-25    offset_24-0
    #             0000000         0000000000000000000000000
    #             00000000000000000000000000000000
    #             0000 0000 0000 0000 0000 0000 0000 0000
    #             0    0    0    0    0    0    0    0
    #             00000000

    # b_type = [
    #     "BEQ",      # if r1 == r2, PC = PC_plus4 + imm          # s.t. r1 --> r3
    #     "JMP",      # PC = concat(PC(31 downto 27, imm, "00")   # imm is instr(24 downto 0)
    # ]

    if list_of_arguments[0] == "BEQ":

        opcode_31_25    = '0110000'
        dst_24_20       = '00000'
        src1_19_15      = '00000'
        offset_14_0     = '000000000000000'

        dst_24_20       = bin(int(list_of_arguments[1]) % (2 ** len(dst_24_20)))[2:].zfill(len(dst_24_20))
        src1_19_15      = bin(int(list_of_arguments[2]) % (2 ** len(src1_19_15)))[2:].zfill(len(src1_19_15))
        offset_14_0     = bin(int(list_of_arguments[3]) % (2 ** len(offset_14_0)))[2:].zfill(len(offset_14_0))

        # print(dst_24_20)
        # print(src1_19_15)
        # print(offset_14_0)
        # exit(0)

        concat = f'{opcode_31_25}{dst_24_20}{src1_19_15}{offset_14_0}'
        if len(concat) != 32:
            print(f'Oops, "{list_of_arguments}" crashed in BEQ, in b_instruction(), failed lengthcheck: {len(concat)} {concat}')
            exit(1)

        hexvalue = hex(int(concat, 2))[2:].zfill(8)
        # print(hexvalue)
        # exit(0)

        return hexvalue, concat

    elif list_of_arguments[0] == "JMP":

        opcode_31_25    = '0110001'
        offset_24_0     = '0000000000000000000000000'

        offset_24_0     = bin(int(list_of_arguments[1]) % (2 ** len(offset_24_0)))[2:].zfill(len(offset_24_0))

        # print(offset_24_0)
        # exit(0)

        concat = f'{opcode_31_25}{offset_24_0}'
        if len(concat) != 32:
            print(f'Oops, "{list_of_arguments}" crashed in JMP, in b_instruction(), failed lengthcheck: {len(concat)} {concat}')
            exit(1)

        hexvalue = hex(int(concat, 2))[2:].zfill(8)
        # print(hexvalue)
        # exit(0)

        return hexvalue, concat

    else:
        print(f'Oops, "{list_of_arguments[0]}" is not in b_instruction()')
        exit(1)


r_type = [
    "ADD",      # r1 <- r2 + r3
    "SUB",      # r1 <- r2 - r3
    "AND",      # r1 <- r2 AND r3
    "OR",       # r1 <- r2 OR r3
    "SLT",      # r1 <- "1" if r2 < r3, otherwise r1 <- "0"
    # "MUL",      # r1 <- r2 * r3
]

m_type = [
    "ADDI",     # r1 <- r2 + imm
    "LDB",      # r1 <- mem[r2 + imm]
    "LDW",      # r1 <- mem[r2 + imm]
    "STB",      # mem[r2 + imm] <- r1                       # s.t. r1 --> r3
    "STW",      # mem[r2 + imm] <- r1                       # s.t. r1 --> r3
]

b_type = [
    "BEQ",      # if r1 == r2, PC = PC_plus4 + imm          # s.t. r1 --> r3
    "JMP",      # PC = concat(PC(31 downto 27, imm, "00")   # imm is instr(24 downto 0)
]

asm_src = [
    "LDB 2 0 32768",
    "LDB 2 0 32767",
    "LDB 2 0 68",
    "LDW 2 0 68",
    "BEQ 2 0 68",
    "JMP 15",
    "ADD 2 0 30",
    "ADD 2 0 31",
    "ADD 2 0 32",
    "ADD 2 0 31",
    "SUB 2 0 31",
    "AND 2 0 31",
    "OR 2 0 31",
    "SLT 2 0 31",
    "ADDI 2 0 31",
    "ADDI 2 2 68",
]

isa_instrs = []

bin_instrs = []

for asm_instr in asm_src:
    spacesplit = asm_instr.split(" ")
    if spacesplit[0] in r_type:
        instruction_hex, instruction_bin = r_instruction(spacesplit)
        instruction_bin = ' '.join([instruction_bin[i:i + 4] for i in range(0, len(instruction_bin), 4)])
        isa_instrs.append(instruction_hex)
        bin_instrs.append(instruction_bin)
    elif spacesplit[0] in m_type:
        instruction_hex, instruction_bin = m_instruction(spacesplit)
        instruction_bin = ' '.join([instruction_bin[i:i + 4] for i in range(0, len(instruction_bin), 4)])
        isa_instrs.append(instruction_hex)
        bin_instrs.append(instruction_bin)
    elif spacesplit[0] in b_type:
        instruction_hex, instruction_bin = b_instruction(spacesplit)
        instruction_bin = ' '.join([instruction_bin[i:i + 4] for i in range(0, len(instruction_bin), 4)])
        isa_instrs.append(instruction_hex)
        bin_instrs.append(instruction_bin)
    else:
        print(f'Oops, "{asm_instr}" crashed, instruction not known')
        exit(1)

for final_instr, bin_versh, asm_instr in zip(isa_instrs, bin_instrs, asm_src):
    print(f'{final_instr:<12}{asm_instr:<20}{bin_versh}')
