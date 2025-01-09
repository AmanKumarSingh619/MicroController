# MicroController
Here i have implemented a simple microcontroller using Verilog. Before you implement this on your end, I would reccomend you to go through a bit of description.
So lets dive into things one by one.
# Instruction Set Architecture
![image](https://github.com/user-attachments/assets/58dd16a5-2cc3-4c95-9d06-c9cf9529a52c)
Each instruction is of 12 bits. There are 3 types of instructions by encoding, which are as follows,
-> M type: one operand is accumulator (sometimes ignored) and the other operand is from data memory; the result can be stored into accumulator or the data memory entry (same entry as the second operand).
-> I type: one operand is accumulator and the other operand is immediate number encoded in instruction; the result is stored into accumulator.
-> S type: special instruction, no operand required. (e.g. NOP)
