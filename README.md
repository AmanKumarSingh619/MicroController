# MicroController
Here i have implemented a simple microcontroller using Verilog. Before you implement this on your end, I would reccomend you to go through a bit of description.
So lets dive into things one by one.
# Instruction Set Architecture
S.No.	Instruction (binary)	Instruction (assembly)	Instruction (meaning)
0.	0000_0000_0000	NOP	No Operation
1.	1011_0000_0001	MOVIA Acc, 1	Acc = 1
2.	0010_0010_0000	MOVAM DMem[0], Acc	DMem[0] = Acc = 1
3.	1011_0000_0000	MOVIA Acc, 0	Acc = 0
4.	0011_0011_0000	MOVMA Acc, DMem[0]	Acc = DMem[0] = 1
5.	0001_0000_0101	GOTO 5	Jump to itself, i.e. infinite loop
