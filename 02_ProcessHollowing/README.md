# ProcessHollowing


## How to use
- `git clone https://github.com/Nariod/Chocolatine.git`
- `git clone https://github.com/ajpc500/NimlineWhispers2`
- `cd 02_ProcessHollowing`
- `nim c -d:release -d:danger -d:mingw --cpu=amd64 --app=console -d:strip --opt:size src/ProcessHollowing.nim`

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
Added the "etw_patch_bin.nim" content as a function.
Added the strenc module import for a bit more obfuscation.