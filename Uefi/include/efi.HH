/**

Adaption of the efi headers

*/

public class EfiSystemTable;

public class EfiTableHeader {
  I64 signature;
  I32 revision;
  I32 headerSize;
  I32 CRC32;
  I32 reserved;
};

public class EfiSimpleTextOutput {
  U64 (*reset)(EfiSystemTable * this, U8 extendedVerification);
  U64 (*outputString)(EfiSystemTable * this, U16 * string);
  U64 (*testString)(EfiSystemTable * this, U16 string);
  U64 (*queryMode)(EfiSystemTable * this, );
  U64 (*setMode)(EfiSystemTable * this,);
  U64 (*setAttribute)(EfiSystemTable * this,);
  U64 (*clearScreen)(EfiSystemTable * this,);
  U64 (*setCurserPosition)(EfiSystemTable * this,);
  U64 (*enableCursor)(EfiSystemTable * this,);
  U64 (*mode)(EfiSystemTable * this,);
};

public class EfiMemoryDescriptor {
  U32 type;
  U32 pad;
  U64 pysicalStart;
  U64 virtualStart;
  U64 numberOfPages;
  U64 attribute;
};

public class EfiInpuKey {
  U64 scanCode;
  U16 unicodeChar;
};




public class EfiSystemTable {
// EfiTableheader
  I64 signature;
  I32 revision;
  I32 headerSize;
  I32 CRC32;
  I32 reserved;
  (*firmwareVender)();
  (*firmwareRevision)();
  (*consoleInHandle)();
  EfiSimpleTextOutput * efiSimpleTextOutput;
  (*consoleOutHandle)();
  (*conOut)();
  (*standardErrorhandle)();
  (*stdErr)();
  (*runtimeServices)()
  


};