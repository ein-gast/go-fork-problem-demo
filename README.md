Демонстрация интересного ограничения.

**Собираем**

Если Go установлен локально:

```bash
./build.sh
```

Если хотим использовать Go в docker:

```bash
./build_with_docker.sh
```

Должно получится как-то так:

```
$ ./build_with_docker.sh 
amd64
arm64
OK
$ ls -l *.bin
-rwxr-xr-x 1 user user 1892514 Jun  1 22:28 app.amd64.1.bin
-rwxr-xr-x 1 user user 1585314 Jun  1 22:28 app.amd64.2.bin
-rwxr-xr-x 1 user user 2097412 Jun  1 22:28 app.arm64.1.bin
-rwxr-xr-x 1 user user 1769732 Jun  1 22:28 app.arm64.2.bin
$ file app*.bin
app.amd64.1.bin: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped
app.amd64.2.bin: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped
app.arm64.1.bin: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /system/bin/linker64, stripped
app.arm64.2.bin: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /system/bin/linker64, stripped
```

Любопытный нюанс. Похоже, что сейчас нельзя собрать польностью статический бинарник https://github.com/golang/go/issues/59942

Исходники:

 - [app1/app1.go](./app1/app1.go)
 - [app2/app2.go](./app2/app2.go)

**Запускаем локально (на linux-хосте):**

```
$ ./app.amd64.1.bin
(!)APP 1
argv[0] : app.amd64.1.bin
EXEC    : [./app.amd64.2.bin]
  ... Okay
STDOUT  : (2)APP 2

STDERR  : 
```

С strace:

```
$ strace --trace=%process ./app.amd64.1.bin 
execve("./app.amd64.1.bin", ["./app.amd64.1.bin"], 0x7ffea179dd78 /* 89 vars */) = 0
clone(child_stack=0xa9b0786e000, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS, tls=0xa9b078ac090) = 66035
clone(child_stack=0xa9b078c8000, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS, tls=0xa9b078ac890) = 66036
--- SIGURG {si_signo=SIGURG, si_code=SI_TKILL, si_pid=66034, si_uid=1000} ---
clone(child_stack=0xa9b078c4000, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS, tls=0xa9b078ad090) = 66037
(!)APP 1
argv[0] : app.amd64.1.bin
EXEC    : [./app.amd64.2.bin]
waitid(P_PIDFD, 11, 0xa9b0792c900, WEXITED, NULL) = -1 ECHILD (Нет дочерних процессов)
pidfd_send_signal(11, 0, NULL, 0)       = 0
clone(child_stack=NULL, flags=CLONE_VM|CLONE_PIDFD|CLONE_VFORK, parent_tid=[12]) = 66039
waitid(P_PIDFD, 12, {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=66039, si_uid=1000, si_status=0, si_utime=0, si_stime=0}, WEXITED|__WCLONE, NULL) = 0
clone(child_stack=NULL, flags=CLONE_VM|CLONE_PIDFD|CLONE_VFORK|SIGCHLD, parent_tid=[13]) = 66040
waitid(P_PIDFD, 13, {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=66040, si_uid=1000, si_status=0, si_utime=0, si_stime=0}, WEXITED, {ru_utime={tv_sec=0, tv_usec=0}, ru_stime={tv_sec=0, tv_usec=1229}, ...}) = 0
--- SIGCHLD {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=66040, si_uid=1000, si_status=0, si_utime=0, si_stime=0} ---
  ... Okay
STDOUT  : (2)APP 2

STDERR  : 
exit_group(0)                           = ?
+++ exited with 0 +++
```

**Запускаем в termux на android-телефоне:**

Доступ к телефону через ssh внутри termux. termux поставлен из Google Play.
Телефон Redmi Note 10 Pro.

```
$ ./scp.sh
Log in to u0_a158@192.168.0.5:22222...
app.arm64.1.bin         100% 2048KB   1.4MB/s   00:01    
app.arm64.2.bin         100% 1728KB   5.6MB/s   00:00    
```

```
./ssh.sh
Log in to 192.168.0.5:22222...
Warning: Permanently added '[192.168.0.5]:22222' (ED25519) to the list of known hosts.
Welcome to Termux

Docs:       https://doc.termux.com
Community:  https://community.termux.com

Working with packages:
 - Search:  pkg search <query>
 - Install: pkg install <package>
 - Upgrade: pkg upgrade

Report issues at https://bugs.termux.com
~ $ uname -a
Linux localhost 4.14.190-perf-g6d6db67fd446 #1 SMP PREEMPT Thu Aug 3 14:44:29 UTC 2023 aarch64 Android
~ $ ls *.bin
app.arm64.1.bin  app.arm64.2.bin
~ $ ./app.arm64.2.bin 
(2)APP 2
~ $ ./app.arm64.1.bin 
(!)APP 1
argv[0] : app.arm64.1.bin
EXEC    : [./app.arm64.2.bin]
  xxx fork/exec ./app.arm64.2.bin: permission denied
STDOUT  : 
STDERR  : 
```

Интересно, почему так?

strace тоже не получается, вероятно потому что strace тоже не может сделать fork/exec :)
```
~ $ strace ./app.arm64.1.bin 
strace: Unexpected wait status 0x1f
```

Сам termux тоже там что-то химичит:

```
~ $ env | grep -P ^LD
LD_PRELOAD=/data/data/com.termux/files/usr/lib/libtermux-exec.so
```
