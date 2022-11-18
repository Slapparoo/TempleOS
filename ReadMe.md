# TempleOS Explorers Edition

TempleOS was developed by the late Terry Davis and is a true testament to what a person can achieve, he single handedly developed and built the OS using a compiler he also developed. The system is "alien" to all its contemparies in that no external code or binary's can be introduced into the system (easily) or exported and run outside the environment.

The system has two pre-built binary's the Kernel and Compiler, at bootup the runtime environment is Just In Time (JIT) compiled and executed. The System is fast, the compiler is fast, in VirtualBox system startup time for me is around 0.4 seconds and that includes the compilation time of the runtime environment.

The compiler HolyC is a variant of C and there is some crossover, but there are enough differences that they are not compatible, IMHO HolyC is a better implementation, much more forgiving, more capable as a low level language, more capable as a general language simplified in the engineering sense where is easier to get things done, and it is clearer what is going on so other peoples code is much easier to follow, clearer and simpler in the engineering sense with no unnecessary complexity being added to an already complex domain.

He didn't re-write the book he built on the lessons of C and created a language which builds on the strengths, removes several complexities and weaknesses. But not all, pointer implementation as far as I can tell is implemented in the same way that it is implemented in C.

Explorers Edition builds on top of the base TempleOS to add new hardware support and installation options. 

What I interpret as Terry's intention for the OS will be honoured what I interpret as Gods intention will not, with the Ultimate Goal being a light weight Hobby OS, that is a fun place to explore and develop new ideas. Something that stands apart from the main stream Commercial OS's and is developed independently and encourages users to get in and get their hands dirty and try new things.

Initial Goals
The initial Goals are to bring the core of the OS up so it can be installed and run on (as many as possible) x64 PC's

* 32 Bit VESA Graphics
* AHCI Support
* More installation options (Maybe something using LILI style Virtualbox on a USB stick, Grub USB stick with a RAM ISO Image)
* Focus on the core Kernel
* Ability to easily manage code changes in source control
* Add newer OP codes to the assembler and compiler 
* Develop hardware graphics driver

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

