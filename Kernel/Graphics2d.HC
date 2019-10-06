
#exe {Option(OPTf_WARN_PAREN,OFF);};
  

/*

Added to Compliment the 24bit graphics changes

Brook

*/


public U32 pal4bit[16] = 
    {BLACK32, BLUE32,    GREEN32,  CYAN32,
     0x002288,PURPLE32,  BROWN32,  LTGREY32,
     DKGREY32,LTBLUE32,  LTGREEN32,LTCYAN32,
     LTRED32, LTPURPLE32,YELLOW32, WHITE32};



U0 Copy4BitToScreen(CDC *dc)
{//Copy the 4bit screen to the 32bit display screen

//  CDC *dc = gr.dc2; 
  U8 *src = dc->body;
  U32 *dst = screen32_->buffer;

  U64 size = (dc->height * dc->width_internal) + src; 

  for (; src < size; src++) {
    *dst++ = pal4bit[*src&0xF];
  }
}


I64 SgnI64(I64 val) {
  return (0 < val) - (val < 0);
}


U0 UpdateScrn() {
  // 32bit buffer 32 bit pysical screen
  MemCpyU32(screen32_->buffer,screen32->buffer,screen32->bufferSize>>2);
}



/*

Brook not great redraw the "known" windows
*/
U0 redraw32() {
}


#exe {Option(OPTf_WARN_PAREN,ON);};

