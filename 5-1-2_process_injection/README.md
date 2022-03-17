# ProcessInjection

## Internals
Win32 API used:
* OpenProcess 
* VirtualAllocEx
* WriteProcessMemory
* CreateRemoteThread


## How to use
Cross-compile from Linux: 
- `git clone https://github.com/Nariod/Chocolatine.git`
- `cd 5-1-2_process_injection`
- change the shellcode in "main.nim"
- `nim c -d:mingw -d:release --cpu:amd64 -d:danger -d:strip --opt:size -o:bin/process_injector.exe src/main.nim`


## Overview
Last test on 17/03/2022.
Works, but is detected by Windows Defender as "Exploit:Win32/DDEDownloader!ml". Binary final size is ~60Ko.