/**


Old 24bit Graphics methods for reference

*/

// Old 24 bit graphics version
U0 UpdateScrnRegion24(U64 x1, U64 y1, U64 x2, U64 y2)
{// 
  //Brook Add bounds checks
  U8 *scrn;
  U64 dRowAdd = screen.width - (x2 - x1),
   sRowAdd = dRowAdd *3,
   startLoc = (y1 * screen.width) + x1,
   xIndex =0, yIndex =0;
  U32 *sBuffer, *dAddress;

  scrn = vesa_info.framebuffer + (startLoc * 3);
  sBuffer = screen.buffer + startLoc;

  for (yIndex = y1; yIndex < y2; yIndex++) {
    for (xIndex = x1; xIndex < x2; xIndex++) {
      dAddress = scrn;
      *dAddress &= 0xFF000000;
      *dAddress |= *sBuffer;
      sBuffer++;
      scrn += 3;
    }
    sBuffer += dRowAdd;
    scrn += sRowAdd;
  }
}


// old 24 bit version
U0 UpdateScrn24() {
  U8 *scrn;
  scrn = vesa_info.framebuffer;

  U32 reg RSI *sBuffer, reg RDI *dAddress; 

  U64 mx = (screen.width*screen.height) + screen.buffer;
  for (sBuffer = screen.buffer; sBuffer < mx; sBuffer++) {
    dAddress = scrn;
    *dAddress = *sBuffer;
    scrn += 3;
  }  
}
