# TempleOS Explorers Edition

# RzOS Expansion (major evision of TempleOS)

## Overview
TempleOS was developed by the late Terry Davis and is a true testament to what a person can achieve, he single handedly developed and built the OS using a compiler he also developed. The system is "alien" to all its contemparies in that no external code or binary's can be introduced into the system (easily) or exported and run outside the environment.

The system has two pre-built binary's the Kernel and Compiler, at bootup the runtime environment is Just In Time (JIT) compiled and executed. The System is fast, the compiler is fast, in VirtualBox system startup time for me is around 0.4 seconds and that includes the compilation time of the runtime environment.

The compiler HolyC is a variant of C and there is some crossover, but there are enough differences that they are not compatible, IMHO HolyC is a better implementation, much more forgiving, more capable as a low level language, more capable as a general language simplified in the engineering sense where is easier to get things done, and it is clearer what is going on so other peoples code is much easier to follow, clearer and simpler in the engineering sense with no unnecessary complexity being added to an already complex domain.

He didn't re-write the book he built on the lessons of C and created a language which builds on the strengths, removes several complexities and weaknesses. But not all, pointer implementation as far as I can tell is implemented in the same way that it is implemented in C.

## RzOS
Ring Zero Operating System

Migrate from BIOS to UEFI

tasks Outline
* Adapt c ufi headers 
* Add compiler extensions for Linux AIB, and UEFI calling conventions
* switch to a 8x16 font and probably use an existing 8x16.psf font
* Rewrite the kernel to boot from UEFI
* Implement a posix compatable stdlib in the kernel (this should allow some interapability with linx etc..)


[Wiki](https://github.com/Slapparoo/TempleOS-EE/wiki)

[Boot TempleOS with Grub2](https://github.com/Slapparoo/TempleOS-EE/wiki/Boot-TempleOS-with-Grub2)

[Quick Customisation Tasks](https://github.com/Slapparoo/TempleOS-EE/wiki/Quick-Customisation-Tasks)

[Github project page](https://slapparoo.github.io/TempleOS-EE/)

[Github Source repository](https://github.com/Slapparoo/TempleOS-EE)

## Blog Posts
<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>

