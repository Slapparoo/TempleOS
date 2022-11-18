---
layout: post
title:  "New data type definitions"
---

#New types

Added the new type aliases  to reflect primative data types in byte size instead of bit size.

the types are 
* B for Unsigned byte
* N for Integer byte (I was already taken)

so there are now
* B1 = U8
* N1 - I8
* B2 = U16
* N2 = I16
* B4 = U32
* N4 = I32
* B8 = U64
* N8 = I64

The usual indexing optionas are also available with
B2 a; a.b1[0], a.b1[1] 
