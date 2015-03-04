# asm.x86

This repository stores some of my (Alexey Kolyanov aka ba1dr) old programs on x86 assembler for **MS-DOS**.

I am sharing them on the public access in order of providing some sort of portfolio.

They are some kind of nostalgy for me as it was too far ago and there was fun time..

I will not describe how to run these programs - I've just found them on the old harddrive and trying to describe by memory.

These files were created mostly in 2000-2002 years and may contain comments on Russian - I have replaced some of them, but not all.


## Licensing

You may use these sources without limitations. I will be pleased if you set the link to me in your code.


# Compilation

I have used TASM to compile these programs. Most of them should be compiled to COM-files.


# Files List

### softscroll

The project for reading plaintext books on the screen. The main feature - smooth scrolling (by pixels, not lines) of the text. I was using framebuffers, vertical synchronization and direct memory access.

See the file 'bookread.asm' - all other files are likely for testing some features. I decided to place'em all there.


### locks

Two programs to switch on/off '*locks' indicators (num/caps/scroll) - 'locks.asm' or check their state ('nslocks.asm') and returning it as errorcode.


### sumtst

There was a challenge in the group of my internet friends to create the smallest program to summarize two numbers of custom length (well, both not more than 65535 digits length). The program should display the result on the screen.

The winner had 13 bytes, I managed to solve it in about of 18 bytes as I remember (with some optimisations like throwing out correct return to OS, etc).

Unfortunately I cannot find that one specimen so I used to save here not last version - it is of 29 bytes length.


### recoder

In the times of MS-DOS there was a problem with encoding of files. It is still an issue but now we have UTF encoding, but in those times we had only ASCII.

This program was intended to simply convert the file from one encoding to another.


### hnewy

I am not sure.. But it should be some kind of scrolling "Happy New Year" text.


### mdminit

Some operations to initialize modem and tweak some parameters.


### - others -

No sense to describe - just small programs to do small job.


# Copyright

Created by Alexey Kolyanov, free for use by anyone. 

