---
layout: post
title:  "Add <ctrl>-space, autocomplete hotkey"
---

#Implementing a `<ctrl>-space` hotkey for auto complete

ctrl space complete word and ctrl shift space navigate into autocomplete. 

I tried adding the `<ctrl-space` Hotkey combination in `/home/05-HomeKeyPlugins.ZC` but it wasn't coming through so I
had to modify `/System/DolDoc/DocPutKey.ZC`

Around line 900 I added
```
case ' ':
    if (sc & SCF_CTRL)
    {
        if (sc & SCF_KEY_DESC)
        {
            if (sc & SCF_SHIFT)
                KeyDescSet("Cmd /Word Definition");
            else
                KeyDescSet("Edit/Autocomplete Word");
        }
        else
        {
            if (AutoComplete(ON))
            {
                DocUnlock(doc);
                if (sc & SCF_SHIFT)
                    ACMan(1, Fs);
                else
                    ACFillIn(1);
                DocLock(doc);
            }
        }
    }
    break;
```
now after a reboot `<ctrl>-space` autocompletes the top selection, and `<ctrl><shift>-space` navigates into the top selection of autocomplete (`<alt>-a`, `<alt><shift>-a`).