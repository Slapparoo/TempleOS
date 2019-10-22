/*
Old School Object orientation

canvas/screen object 32 bit, 16, 8, 4 (which is 8)

2D bitmap drawing surface

This is the same format as the display device
*/

#exe {
  Option(OPTf_WARN_PAREN,OFF);
  Option(OPTf_WARN_DUP_TYPES,OFF);
};


I64 SgnI64(I64 val) {
  return (0 < val) - (val < 0);
}

public I64 CSizeCreate(U32 w, U32 h) {
  return w + (h<<32);
}


public I64 CPointCreate(U32 x, U32 y) {
  return x + (y<<32);
}


public I64 CRect_normalise(I64 this) {
  CRect *ts = &this;
  U16 tmp;

  if (ts->x1 > ts->x2) {
    tmp = ts->x1;
    ts->x1 = ts->x2;
    ts->x2 = tmp;
  }

  if (ts->y1 > ts->y2) {
    tmp = ts->y1;
    ts->y1 = ts->y2;
    ts->y2 = tmp;
  }

  return this;
}


public I64 CRectCreate(U16 x1, U16 y1, U16 x2, U16 y2) {
  I64 r = x1 + (x2<<16) + (y1<<32) + (y2<<48);

  return CRect_normalise(r);
}

public I64 CRectRelocate(I64 crect, U16 x, U16 y) {
  CRect *res = &crect;
  res->x1 += x;
  res->x2 += x;
  res->y1 += y;
  res->y2 += y;
  return CRect_normalise(crect);
}

public I64 CRectSet(I64 crect, U16 x1, U16 y1, U16 x2, U16 y2) {
  CRect *res = &crect;

  res->x1 = x1;
  res->x2 = x2;
  res->y1 = y1;
  res->y2 = y2;
  return CRect_normalise(crect);
}

//public extern CCanvas *CCanvasCreate(I64 width, I64 height, U32 * buffer =0);

// returns true if any of this Rect is inside that rect
public I64 CRect_inside(I64 this, I64 that) {
  if (this == 0 || that == 0) {
    return FALSE;
  }

  this = CRect_normalise(this);
  that = CRect_normalise(that);

  CRect *ts = &this;
  CRect *tt = &that;

  if (ts->x1 > tt->x2 || ts->y1 > tt->y2) {
    return FALSE;
  }

  if (ts->x2 < tt->x1 || ts->y2 < tt->y1) {
    return FALSE;
  }

  return TRUE;
}



public I64 CRect_pxinside(I64 this, I64 x, I64 y) {
  if (this == 0) {
    return FALSE;
  }

  this = CRect_normalise(this);

  CRect *ts = &this;

  if (ts->x1 > x || ts->y1 > y) {
    return FALSE;
  }

  if (ts->x2 < x || ts->y2 < y) {
    return FALSE;
  }

  return TRUE;
}


// returns the area of this that is inside that
// CRect_inside should be called first to test
// as invalide CRects get returned
// a slight variant on intersect which returns an intersect if
// they are adjacent
public I64 CRect_intersect(I64 this, I64 that) {
  if (this == 0 || that == 0) {
    return 0;
  }
  this = CRect_normalise(this);
  that = CRect_normalise(that);

  CRect *ts = &this;
  CRect *tt = &that;

  I64 xL = Max(ts->x1, tt->x1);
  I64 xR = Min(ts->x2, tt->x2);

  if (xR < xL) {
    return 0;
  }

  I64 yT = Max(ts->y1, tt->y1);  
  I64 yB = Min(ts->y2, tt->y2);

  if (yB < yT) {
    return 0;
  }

  return CRectSet(this, xL, yT, xR, yB);
}


// the resulting rectangle will be the combined
// size of both rectangles

public I64 CRect_join(I64 this, I64 that) {
  this = CRect_normalise(this);
  that = CRect_normalise(that);

  CRect *ts = &this;
  CRect *tt = &that;

  I64 xL = Min(ts->x1, tt->x1);
  I64 xR = Max(ts->x2, tt->x2);

  if (xR <= xL) {
    return -1;
  }

  I64 yT = Min(ts->y1, tt->y1);  
  I64 yB = Max(ts->y2, tt->y2);

  if (yB <= yT) {
    return -1;
  }

  return CRectSet(this, xL, yT, xR, yB);
}



U0 CRect_print(I64 this) {
  CRect *ts = &this;

  "x1=%d, y1=%d, x2=%d, y2=%d\n", ts->x1, ts->y1, ts->x2, ts->y2;
}


U0 CCanvas_free(CCanvas *this) {
  if (this->ownsBuffer) { 

    "Freeing buffer..%p\n", this->buffer; 
    Free(this->buffer);
  }
  Free(this);
  "free at last\n";
}

U0 CCanvas_printFont32(CCanvas *this, U8 letter, I64 x, I64 y, U32 fg, U32 bg) {
  // Brook change to dynamic font
  U64 letterT = text.font[letter&0xFF],
   count, rowInc = this->width - FONT_WIDTH; // FONT_WIDTH
  U32 *dst;
  dst = this->buffer + (this->width * y) + x;

  U64 fRect = CRectCreate(x, y, x+8, y+8);
  U64 intersect = CRect_intersect(fRect,this->clipRct);
  if (!intersect) {
    // completely outside the the area
    return;
  }

  for (count = 0; count < 64; count++) {
    if (letterT & 0x1) {
          *dst = fg;
      dst++;
    } else {
          *dst = bg;
      dst++;
    }
    if (count & 0x7 == 0x7) {
      dst += rowInc;
      y++;
      x-=8;
    }
    letterT = letterT>>1;
  }
}

U0 CCanvas_printFont16(CCanvas *this, U8 letter, I64 x, I64 y, U32 fg, U32 bg) {
  // Brook change to dynamic font
  U64 letterT = text.font[letter&0xFF],
   count, rowInc = this->width - FONT_WIDTH; // FONT_WIDTH
  U16 *dst;
  dst = this->buffer;
  dst += this->width * y + x;

  U16 bgc = bg&0xFFFF, fgc = fg&0xFFFF;

  U64 fRect = CRectCreate(x, y, x+8, y+8);
  U64 intersect = CRect_intersect(fRect,this->clipRct);
  if (!intersect) {
    // completely outside the the area
    return;
  }

  for (count = 0; count < 64; count++) {
  // FONT_WIDTH x FONT_HEIGHT
    if (letterT & 0x1) {
      *dst = fgc;
      dst++;
    } else {
      *dst = bgc;
      dst++;
    }

    if (count & 0x7 == 0x7) {
      dst += rowInc;
      y++;
      x-=8;
    }
    letterT = letterT>>1;
  }
}




U0 CCanvas_printFont8(CCanvas *this, U8 letter, I64 x, I64 y, U32 fg, U32 bg) {
  // Brook change to dynamic font
  U64 letterT = text.font[letter&0xFF],
   count, rowInc = this->width - FONT_WIDTH; // FONT_WIDTH
  U8 *dst;
  dst = this->buffer;
  dst += this->width * y + x;

  U8 bgc = bg&0xFF, fgc = fg&0xFF;

  U64 fRect = CRectCreate(x, y, x+8, y+8);
  U64 intersect = CRect_intersect(fRect,this->clipRct);
  if (!intersect) {
    // completely outside the the area
    return;
  }

  for (count = 0; count < 64; count++) {
    if (letterT & 0x1) {
      *dst = fgc;
      dst++;
    } else {
      *dst = bgc;
      dst++;
    }

    if (count & 0x7 == 0x7) {
      dst += rowInc;
      y++;
      x-=8;
    }
    letterT = letterT>>1;
  }
}


U0 CCanvas_printString(CCanvas *this, U8 *str, I64 x, I64 y, U32 fg, U32 bg) {
  U64 fRect = CRectCreate(x, y, x+StrLen(str), y+8);
  U64 intersect = CRect_intersect(fRect,this->clipRct);
  if (!intersect) {
    // completely outside the the area
    return;
  }

  while (str[0] != 0) {
    *this->printFont(this, str[0], x, y, fg, bg);
    x += 8;  // Brook dynamic font size
    str++;
  }
}

U0 CCanvas_ScrollScrnDown32(CCanvas *this, U64 xdist, U32 bgColor)
{// 
  //Brook Add bounds checks

  U64 sStartLoc = xdist * this->width;

  MemCpyU32(this->buffer, this->buffer + sStartLoc, this->size - sStartLoc);


  MemSetU32(this->buffer + this->size - (this->width * FONT_HEIGHT),
               bgColor, this->width * FONT_HEIGHT);
}

U0 CCanvas_ScrollScrnDown16(CCanvas *this, U64 xdist, U32 bgColor)
{// 
  //Brook Add bounds checks

  U64 sStartLoc = xdist * this->width;

  U16 *b = this->buffer;

  MemCpyU16(b, b + sStartLoc, this->size - sStartLoc);


  MemSetU16(b + this->size - (this->width * FONT_HEIGHT),
               bgColor&0xFFFF, this->width * FONT_HEIGHT);
}

U0 CCanvas_ScrollScrnDown8(CCanvas *this, U64 xdist, U32 bgColor)
{// 
  //Brook Add bounds checks

  U64 sStartLoc = xdist * this->width;

  U8 *b = this->buffer;

  MemCpyU8(b, b + sStartLoc, this->size - sStartLoc);


  MemSetU8(b + this->size - (this->width * FONT_HEIGHT),
               bgColor&0xFF, this->width * FONT_HEIGHT);
}



/*
Calculate the pixels which have changed
*/
public U0 CCanvas_CalcScrnUpdates32(CCanvas* this, CCanvas* dest, U8* grBody, U8* screenCache) {

  // TODO - this needs work - it is making tons of assumptions about the size 
  // of the canvases being equal
  // and that there is only one screencache


  // compare the previous screen to the current screen
  // this works on 2 pixels at a time
  
  // this works on the assuption that writing to
  // video memory is slower than regular memory

  U16 *scrn = grBody, *lstScrn = screenCache;
  U64 difsSize = this->size>>1;
  U64 *src = this->buffer, *dst = dest->buffer;

  I64 i = difsSize-1;

  for (; i >= 0; i--) {
    if (scrn[i] != lstScrn[i]) {
      dst[i] = src[i];
    }
  }

  MemCpyU64(screenCache, grBody, dest->size>>3);

  if (LBtr(&sys_semas[SEMA_FLUSH_VGA_IMAGE],0)) {
    MemCpyU64(dest->buffer, this->buffer, this->size>>1);
  }
}


/*
Calculate the pixels which have changed
*/
public U0 CCanvas_CalcScrnUpdates16(CCanvas* this, CCanvas* dest, U8* grBody, U8* screenCache) {

  // TODO - this needs work - it is making tons of assumptions about the size 
  // of the canvases being equal
  // and that there is only one screencache


  // compare the previous screen to the current screen
  // this works on 2 pixels at a time
  
  // this works on the assuption that writing to
  // video memory is slower than regular memory

  U16 *scrn = grBody, *lstScrn = screenCache;
  U64 difsSize = this->size>>1;
  U32 *src = this->buffer, *dst = dest->buffer;

  I64 i = difsSize-1;

  for (; i >= 0; i--) {
    if (scrn[i] != lstScrn[i]) {
      dst[i] = src[i];
    }
  }

  MemCpyU64(screenCache, grBody, dest->size>>3);

  if (LBtr(&sys_semas[SEMA_FLUSH_VGA_IMAGE],0)) {
    MemCpyU64(dest->buffer, this->buffer, this->size>>2);
  }
}



// neeeds to be extern now there are multiple declrarions
U32 pal32[16] = 
    {BLACK32, BLUE32,    GREEN32,  CYAN32,
     0x002288,PURPLE32,  BROWN32,  LTGREY32,
     DKGREY32,LTBLUE32,  LTGREEN32,LTCYAN32,
     LTRED32, LTPURPLE32,YELLOW32, WHITE32};


U0 CCanvas_FullScrnDraw32(CCanvas* this, CCanvas *dest, U8* grBody, U8 * screenCache) {
  //Copy the 4bit screen to the 32bit display screen
  // fudging it;

  U32 *dst = this->buffer;
  U8 *src = grBody;
  
  I32 i;


  for (i = this->size -1; i > 0; i--, src++, dst++) {
      *dst = pal32[*src];
  }

  CCanvas_CalcScrnUpdates32(this, dest, grBody, screenCache);
}

// neeeds to be extern now there are multiple declrarions
U16 pal16[16] = 
    {0x0000, 0x1111, 0x2222, 0x3333, 0x4444, 0x5555, 0x6666, 0x7777, 
     0x8888, 0x9999, 0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD, 0xEEEE, 0xFFFF};


U0 CCanvas_FullScrnDraw16(CCanvas* this, CCanvas *dest, U8* grBody, U8 * screenCache) {
  //Copy the 4bit screen to the 32bit display screen
  // fudging it;


  U16 *dst = this->buffer;
  U8 *src = grBody, j;
  
  U64 size = src + this->size; 
  I32 i;


  for (i = this->size -1; i > 0; i--, src++, dst++) {
      *dst = pal16[*src];
  }

  CCanvas_CalcScrnUpdates16(this, dest, grBody, screenCache);
}


#exe {
  Option(OPTf_WARN_UNUSED_VAR,OFF);
};


U0 CCanvas_FullScrnDraw8(CCanvas* this, CCanvas *dest, U8* grBody, U8 * screenCache) {
  if (this);
  if (screenCache);

  MemCpyU64(dest->buffer, grBody, dest->size>>3); 
}

#exe {
  Option(OPTf_WARN_UNUSED_VAR,ON);
};


public CCanvas *CCanvasCreate32(I64 width, I64 height, U32 *buffer =0) {

  CCanvas *this = MAlloc(sizeof(CCanvas));

  // Brook set max for the canvas don't need to be bigger than the screen

  this->width = width;
  this->height = height;
  this->bufferSize = (width*height)<<2;
  if (buffer) {
    this->buffer=buffer;
    this->ownsBuffer=FALSE;
  } else {
    this->buffer=MAlloc(this->bufferSize);
    this->ownsBuffer=TRUE;
  }
  this->size = width*height;

  this->updated = FALSE;
  this->dirtyRct = 0;
  this->clipRct = CRectCreate(0, 0, width, height);
  

  this->printFont = &CCanvas_printFont32;  
  this->printString = &CCanvas_printString;  
  this->free = &CCanvas_free;
  this->scrollScrnDown = &CCanvas_ScrollScrnDown32;
  this->fullScrnDraw = &CCanvas_FullScrnDraw32;


  return this;
}


public CCanvas *CCanvasCreate16(I64 width, I64 height, U32 *buffer =0) {

  CCanvas *this = MAlloc(sizeof(CCanvas));

  // Brook set max for the canvas don't need to be bigger than the screen

  this->width = width;
  this->height = height;
  this->bufferSize = (width*height)<<1;
  if (buffer) {
    this->buffer=buffer;
    this->ownsBuffer=FALSE;
  } else {
    this->buffer=MAlloc(this->bufferSize);
    this->ownsBuffer=TRUE;
  }
  this->size = width*height;

  this->updated = FALSE;
  this->dirtyRct = 0;
  this->clipRct = CRectCreate(0, 0, width, height);
  

  this->printFont = &CCanvas_printFont16;  
  this->printString = &CCanvas_printString;  
  this->free = &CCanvas_free;
  this->scrollScrnDown = &CCanvas_ScrollScrnDown16;
  this->fullScrnDraw = &CCanvas_FullScrnDraw16;


  return this;
}

public CCanvas *CCanvasCreate8(I64 width, I64 height, U32 *buffer =0) {

  CCanvas *this = MAlloc(sizeof(CCanvas));

  // Brook set max for the canvas don't need to be bigger than the screen

  this->width = width;
  this->height = height;
  this->bufferSize = (width*height);
  if (buffer) {
    this->buffer=buffer;
    this->ownsBuffer=FALSE;
  } else {
    this->buffer=MAlloc(this->bufferSize);
    this->ownsBuffer=TRUE;
  }
  this->size = width*height;

  this->updated = FALSE;
  this->dirtyRct = 0;
  this->clipRct = CRectCreate(0, 0, width, height);
  

  this->printFont = &CCanvas_printFont8;  
  this->printString = &CCanvas_printString;  
  this->free = &CCanvas_free;
  this->scrollScrnDown = &CCanvas_ScrollScrnDown8;
  this->fullScrnDraw = &CCanvas_FullScrnDraw8;

  return this;
}

//public U64 CDC_UPD_CNT1 = 0;

U0 CDC_update(CDC *this, I64 crect) {
  CDC_UPD_CNT1++; 
  // update the dirty region on the screen
  // Does it need multple dirty regions
  // expects x1 <= x2
  
  // First time though
  if (!this->updated) {
    this->updated = TRUE;
    this->dirtyRct = crect;

    return;    
  }

  I64 newRct = crect;

  this->updated = TRUE;
  this->dirtyRct = CRect_join(this->dirtyRct, newRct);
}


U0 CDC_cleaned(CDC *this) {
  // update the dirty region on the screen to clear
  // Does it need multple dirty regions
  
  this->updated = FALSE;
  this->dirtyRct = 0;
}





#exe {
  Option(OPTf_WARN_PAREN,ON);
  Option(OPTf_WARN_DUP_TYPES,ON);
};

