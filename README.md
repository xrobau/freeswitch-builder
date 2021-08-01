# This does not work!

This was my attempt at compiling all the prerequisites for libstirshaken
on CentOS7. But it doesn't work. Everything wants to keep using openssl
1.0, and I just couldn't be bothered spending the time yak shaving all
the individual packages.

```
(gdb) where
#0  0x00007fdba1addbc0 in ?? () from /usr/lib64/libssl.so.1.1
#1  0x00007fdba042fa9d in SSL_CTX_new () from /usr/lib64/libssl.so.10
#2  0x00007fdb9a92f3b9 in sofia_profile_thread_run (thread=0x1ff8b08, obj=0x1ff1ba0) at sofia.c:3209
#3  0x00007fdba427ba60 in dummy_worker () from /usr/lib64/libfreeswitch.so.1
#4  0x00007fdba115bea5 in start_thread () from /usr/lib64/libpthread.so.0
#5  0x00007fdba0e849fd in clone () from /usr/lib64/libc.so.6
```

`sofia_profile_thread_run` always wants to use openssl10, and this is where
I have given up.  If someone wants to fix this, feel free to do a PR and
tag me on social media or email me or something if I don't see it.


