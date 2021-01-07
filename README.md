# Android Shared Object Injector

Injecting **Shared Object** in Android native process using **[Frida](https://github.com/frida/frida)**

This code is taken from https://github.com/oleavr/android-inject-custom

I have removed `frida-gum` dependency as it's not required for injection and have provided build system to build it for different architecture supported by **Android NDK**.


# Prerequisites

- [Android NDK r22](https://dl.google.com/android/repository/android-ndk-r22-linux-x86_64.zip)
- Rooted Android device


# Building

```sh
$ PATH="$PATH:$HOME/Android/Sdk/ndk/22.0.7026061" make
```

This will build the injector, the agent, and an example program you can inject the agent into to easily observe the results.


# Deploying to Android device

```sh
$ PATH="$PATH:$HOME/Android/Sdk/ndk/22.0.7026061" make deploy
```


# Running

Open a terminal and get into `adb` shell and launch the `victim-x86_64` process.

```sh
$ adb shell
generic_x86_64:/ # cd /data/local/tmp/injection
generic_x86_64:/data/local/tmp/injection # 
generic_x86_64:/data/local/tmp/injection # ./victim-x86_64
Victim running with PID 7521
```

Then in another terminal change directory to where the `injector-x86_64` binary is and run it.

```sh
generic_x86_64:/data/local/tmp/injection # ./injector-x86_64 -l /data/local/tmp/injection/libagent-x86_64.so -e entrypoint -p 7521                                                
                                                                   
	 ██╗███╗   ██╗     ██╗███████╗ ██████╗████████╗ ██████╗ ██████╗  
	 ██║████╗  ██║     ██║██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗ 
	 ██║██╔██╗ ██║     ██║█████╗  ██║        ██║   ██║   ██║██████╔╝ 
	 ██║██║╚██╗██║██   ██║██╔══╝  ██║        ██║   ██║   ██║██╔══██╗ 
	 ██║██║ ╚████║╚█████╔╝███████╗╚██████╗   ██║   ╚██████╔╝██║  ██║ 
	 ╚═╝╚═╝  ╚═══╝ ╚════╝ ╚══════╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝ 
                                                                   
[+] Patching SeLinux policy
[+] Injecting library: /data/local/tmp/injection/libagent-x86_64.so in pid: 7521
[+] Injection completed
1|generic_x86_64:/data/local/tmp/injection #
```

> **Note:** If **entry point** is not provided the target process will crash after loading the **shared object**.


You should now see a message printed by the `victim-x86_64` process when the **entry point** is called.

```sh
generic_x86_64:/data/local/tmp/injection # ./victim-x86_64
Victim running with PID 7521
entrypoint() called
```
