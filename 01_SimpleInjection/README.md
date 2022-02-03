# SimpleInjection


## How to use

nim c -d:release -d:danger -d:mingw --cpu=amd64 -d:strip --opt:size src/SimpleInjection.nim -o bin/SimpleInjection.exe


## Internals
WIP

## Overview
WIP

## Evasion
Sandbox evasion mechanisms:
* Check the result of VirtualAlloxExNuma API call
* Sleep for an amount of time and check if the result is 
In case of a failure, the process exits to prevent sandbox execution

Added the "amsi_patch_bin.nim" content as a function.


# added the "amsi_patch_bin.nim" content as a func
# added the strenc module import for a bit more obfuscation
# added the "etw_patch_bin.nim" content as a func
# added sandbox checks from NimHollow