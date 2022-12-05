---
layout: post
title:  "Efi application startup"
---

#Efi application startup

After some tething issues around the creation of EFI files from within TempleOS, and some other issues I had 
around parameter passing for the EFI ABI, things are now back on track and for now it looks like the applicaiton has
stablised and I can call ProtocalHandle successfully (which was causing me grief, some of it my own making), and draw to the screen successfully using the GOP.

The main area now is receiving events like key board or timer events.

The focus will now be on 
* implement all the UEFI method stubs
* Keyboard
* Mouse
* Disk
* Memory 

Once complete Preparing a second Kernel for EFI boot, so leave the existing for BIOS boot, and create a second for EFI boot.

Secondary will be
* CPU
* Threading
* Other IO like Network / Serial
* Other devices  

[Graphics Sample](Screenshot from 2022-12-05 19-36-35.png)
