# Changing the "caller" call stack in using HolyC 

## Overview
TempleOS's native call stack is method parameters are passed on the stack, so when calling a method written in HolyC parameters are pushed on the stack, prior to call then accessed within the method by the offset into the stack.

I am currently writing in HolyC the ability to call the Windows ABI stack frame, initialy as the "caller" but potentially later as the "callee". This is because I am writing a EFI bootstrapper for templeOS, wholely inside TempleOS, so fully self contained with no external dependancies.

The Windows ABI uses register based parameter passing to methods, then once the registers are full it will pass additional parameters on the stack fortunatly for the most part the return value will be in RAX, as far as I can tell this will only change if its a float.
See also (Windows x64 Calling Convention)[https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170]

Initially I will focus on up to four parameter cals when the parameters are placed in RCX, RDX, R8, R9, there are additional rules around the preservation of other registers, as far as I can tell the other registers we are interested in preseving are preserved like RBP.

## Implementation Overview
Fortunatly through the foresight of Terry HolyC is a very veristile language especially for "low level" system work. As far as I can tell it only requires one line of assembly.

Creating a generic Wrapper method so inside HolyC we call the Wrapper with a pointer to our destination method and it adjusted the Call stack and calls the destination.

## Implementation
One of the really good features about HolyC is you can nominate the CPU register you want a variable or parameter to be stored in.
declaring a varaibale to use a register `<TYPE> reg <Register> [variable name];` (also interestingly you don't require a name for varibales).

In our case we want the parameters to be bound to specific CPU registers so we can deplare the method as such. so the following code will bind parameter 1 to RCX, param 2 to RDX etc, then we use our single line of asm with is call (which pretty much does what it says on the tin and makes a call to another method).

In this case we the function pointer has been stored in RBX.
Also note - Assembler can just be used directly in line in HolyC so now the function pointer is in RBX I can simple use `CALL RBX` inline. 
Also notw - in HolyC you can give parameters a default value in the method signature, which means you don't need to provide them when calling
### Resulting method 

```
U64 EfiWrapper(U8 * reg RBX functionPointer, U64 reg RCX p1 = NULL, U64 reg RDX p2= NULL, U64 reg R8 p3 = NULL, U64 reg R9 = NULL) {
CALL RBX
}
```
You can see I have made the parameters optional by assigning them a default value so now I can call the method with the function point and any of 1, 2, 3 or 4 parameters

## Full sample 
Trace gives you the assembler dump of the compiled output.
```
Trace;

// Wrapper to change call stack to the Windows EFI ABI
U64 EfiWrapper(U64 reg RBX functionPonter, U64 reg RCX p1 = NULL, U64 reg RDX p2 = NULL, U64 reg R8 p3 = NULL, U64 reg R9 p4 = NULL) {
CALL RBX
}

U64 dummyFunction() {
  U64 reg RCX a, reg RDX b, reg R8 c, reg R9 d;
  "reg value RCX=0x%x, RDX=0x%x, R8=0x%x, R9=0x%x\n", a, b, c, d;
}


U64 sampleUse() {
  // no params
  EfiWrapper(&dummyFunction);

  // 1 param ....
  EfiWrapper(&dummyFunction, 1);
  EfiWrapper(&dummyFunction, 1, 2);
  EfiWrapper(&dummyFunction, 1, 2, 3);
  EfiWrapper(&dummyFunction, 1, 2, 3, 4);
}

sampleUse();
```
