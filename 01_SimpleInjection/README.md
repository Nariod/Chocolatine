# SimpleInjection


## How to use
git clone https://github.com/Nariod/Chocolatine.git
cd 01_SimpleInjection
nim c src/SimpleInjection.nim -o bin/SimpleInjection.exe

## Internals
WIP

## Overview
WIP

## Evasion
### Sandbox
Sandbox evasion mechanisms:
* Check the result of VirtualAlloxExNuma API call
* Sleep for an amount of time and check if the result is 
In case of a failure, the process exits to prevent sandbox execution

### AV/EDR
Added the "amsi_patch_bin.nim" content as a function.
Added the "etw_patch_bin.nim" content as a funcction.
Added the strenc module import for a bit more obfuscation