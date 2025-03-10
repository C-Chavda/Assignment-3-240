#!/bin/bash
# Program name: "Triangle Area"
# Author: Chandresh Chavda
# Author Email: chav349@csu.fullerton.edu
# CWID: 885158899
# Class: 240-11 Section 11
# This file is the script file that accompanies the "Triangles" program.
# Prepare for execution in normal mode (not gdb mode).

# Delete unneeded files
rm -f *.o
rm -f *.out

echo "Assembling the source file manager.asm"
nasm -f elf64 -l manager.lis -o manager.o manager.asm -gdwarf

echo "Assembling the Isfloat"
nasm -f elf64 -l isfloat.lis -o isfloat.o isfloat.asm -gdwarf

echo "Assembling the source file istriangle.asm"
nasm -f elf64 -l istriangle.lis -o istriangle.o istriangle.asm -gdwarf

echo "Assembling the source file huron.asm"
nasm -f elf64 -l huron.lis -o huron.o huron.asm -gdwarf

echo "Compiling the source file triangle.c"
gcc -m64 -Wall -no-pie -std=c2x -o triangle.o -c triangle.c -gdwarf

echo "Linking the object modules to create an executable file"
gcc -m64 -no-pie -o triangle.out manager.o istriangle.o isfloat.o huron.o triangle.o -z noexecstack -lm
echo "Executing the program"
chmod +x triangle.out
./triangle.out

echo "This bash script has completed execution."