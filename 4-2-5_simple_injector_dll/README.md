# SimpleInjectorDLL

## Internals
Win32 API used:
* VirtualAlloc 
* CreateThread
* WaitForSingleObject


## How to use
Cross-compile from Linux: 
- `git clone https://github.com/Nariod/Chocolatine.git`
- `cd 4-2-4_simple_injector`
- change the shellcode in "main.nim"
- `nim c -d:mingw -d:release --cpu:amd64 -d:danger -d:strip --opt:size --app=lib --nomain -o:bin/simple_injector_dll.dll src/main.nim`
On target machine:
- `rundll32.exe simple_injector_dll.dll, main`


## Overview
WIP, executed but not getting anything.