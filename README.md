# XTERM
Xmodem Terminal for the Commodore VIC-20

This is a simple terminal program for the unexpanded Commodore VIC-20. It is written in machine langauge and is hard coded for 1200 baud and 8,N,1.  

The ultimate goal is for this terminal program to support Xmodem uploads and downloads. Currently, those features are still in development, but I expect to have them finished soon.

To use the program, download either the .D64 image or the .PRG file and get it onto your VIC-20 (how you do that is up to you). Then, type:

```
LOAD "XTERM",8
```

to load the program into memory, and then type:

```
RUN
```

You should see a screen that looks like this:

![XTERM](https://github.com/user-attachments/assets/266a90e4-464b-4e62-8830-6b43f0e81ee3)

You can use Hayes AT commands to dial out to a BBS, such as:

```
ATDT VIC-BBS.COM:6502
```

Once connected and logged into a bulletin board system, you can use the ` F1 ` key to start an upload, and the ` F3 ` key to start a download. ` F7 ` will exit the program.
