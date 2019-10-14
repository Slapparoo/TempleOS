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


// the resulting rectangle will be the combined
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

U0 CCanvas_setPixel32(CCanvas *this, I64 x, I64 y, U32 color) {
  if (!CRect_pxinside(this->clipRct, x, y)) {
    return;
  }

  this->buffer[this->width * y + x] = color;
  this->update(this, x, y, x+1, y+1);
}

U0 CCanvas_setPixel16(CCanvas *this, I64 x, I64 y, U32 color) {
  if (!CRect_pxinside(this->clipRct, x, y)) {
    return;
  }
  
  U16 * b = this->buffer;

  b[this->width * y + x] = color&0xFFFF;
  this->update(this, x, y, x+1, y+1);
}

U0 CCanvas_setPixel8(CCanvas *this, I64 x, I64 y, U32 color) {
  if (!CRect_pxinside(this->clipRct, x, y)) {
    return;
  }

  U8 * b = this->buffer;
  b[this->width * y + x] = color&0xFF;
  this->update(this, x, y, x+1, y+1);
}

U0 CCanvas_setPixel4(CCanvas *this, I64 x, I64 y, U32 color) {
  if (!CRect_pxinside(this->clipRct, x, y)) {
    return;
  }

  U8 * b = this->buffer;
  b[this->width * y + x] = color&0xF;
  this->update(this, x, y, x+1, y+1);
}



// which leaves 4bits for shading/blending
// an example would be SHade + light + 1 - would make the dest pixel 1 shade lighter
// shade + trasnperency ignore the pixel color
// blend mixes the 2 colors, how much source is blened into dest
// is controled by XF_SOURCE

// put the pixel at the location by appliting the transform
U0 _CCanvas_tranformPixel32(U32 *dst, U32 color) {
  // Brook no bounds pixel direct
  // brook this needs asm
  U32 xform = color&XF_TRANSP,
    value, dPixel, lighter, i, v, b;

  if (!xform) {
    // just draw
    *dst = color;
    return;
  } 


  if (xform == XF_TRANSP) {
    // no draw
  } else if (xform == XF_SHADE) {
    // shade the dest pixel by
    value = (color&XF_VALUE)>>21;          // reduce by 22bits (value *16)
    lighter = (color&XF_LIGHT);

    dPixel = *dst;
    if (lighter) {
      // apply to each color
      for (i = 0; i < 3; i++) {
        v = dPixel.u8[i];
        v+=value;
        if ((v&0xFF) < dPixel.u8[i]) {
          v = 0xFF;
        }
        dPixel.u8[i] = v;
      }
    } else {
      for (i = 0; i < 3; i++) {
        v = dPixel.u8[i];
        v-=value;
        if ((v&0xFF) > dPixel.u8[i]) {
          v = 0x00;
        }
        dPixel.u8[i] = v;
      }
    }
    *dst = dPixel;
    
  } else {
    // must be blend ()
    dPixel = *dst;
      // apply to each color
    for (i = 0; i < 3; i++) {
      b = (dPixel.u8[i] + color.u8[i])>>1;
      dPixel.u8[i] = b;
    }
    
    *dst = dPixel;
  }
}

U0 _CCanvas_update(CCanvas *this, I64 crect) {
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


U0 CCanvas_update(CCanvas *this, I64 x1, I64 y1, I64 x2, I64 y2) {
  _CCanvas_update(this, CRectCreate(x1, y1, x2, y2));
}


U0 CCanvas_cleaned(CCanvas *this) {
  // update the dirty region on the screen to clear
  // Does it need multple dirty regions
  
  this->updated = FALSE;
  this->dirtyRct = 0;
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

  // x,y are tracked for cliprect

  for (count = 0; count < 64; count++) {
  // FONT_WIDTH x FONT_HEIGHT
    if (letterT & 0x1) {
//      if (CRect_pxinside(this->clipRct, x, y)) {
//        _CCanvas_tranformPixel(dst, fg);
          *dst = fg;
//      }
      dst++;
    } else {
//      if (CRect_pxinside(this->clipRct, x, y)) {
//        _CCanvas_tranformPixel(dst, bg);
          *dst = bg;
//      }
      dst++;
    }
    if (count & 0x7 == 0x7) {
      dst += rowInc;
      y++;
      x-=8;
    }
    letterT = letterT>>1;
  }
  // Brook dynamic font
  _CCanvas_update(this, intersect);
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

  // x,y are tracked for cliprect

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
  // Brook dynamic font
  _CCanvas_update(this, intersect);
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

  // x,y are tracked for cliprect

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
  // Brook dynamic font
  _CCanvas_update(this, intersect);
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

U0 CCanvas_fillrect(CCanvas *this, I64 x1, I64 y1, I64 x2, I64 y2, U32 color) {
  
  U64 fRect = CRectCreate(x1, y1, x2, y2);
  U64 intersect = CRect_intersect(fRect,this->clipRct);
  if (!intersect) {
    // completely outside the the area
    return;
  }

  CRect *cr = &intersect;
  x1 = cr->x1;
  x2 = cr->x2;
  y1 = cr->y1;
  y2 = cr->y2;


  I64 tOff, bOff, i, tmp, width;

  if (y1>y2) {
    // switchery do
    tmp=y1;
    y1=y2;
    y2=tmp;
  }

  if (x1>x2) {
    // switchery do
    tmp=x1;
    x1=x2;
    x2=tmp;
  }

  tOff=(y1 * this->width)+x1;
  bOff=(y2 * this->width)+x1;  
  width = x2 - x1 +1;
  
  for (i=tOff; i<bOff; i+= this->width) {
    MemSetU32(this->buffer+i, color, width);
  }
//  this->update(this, x1, y1, x2, y2);
  _CCanvas_update(this, intersect);
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



U0 CCanvas_line(CCanvas *this, I64 x1, I64 y1, I64 x2, I64 y2, U32 color) {

  U64 fRect = CRectCreate(x1, y1, x2, y2);
  U64 intersect = CRect_intersect(fRect,this->clipRct);
  if (!intersect) {
    // completely outside the the area
    return;
  }

  I64 i,
    dx=x2-x1,
    dy=y2-y1,
    sdx=SgnI64(dx),
    sdy=SgnI64(dy),
    adx=AbsI64(dx),
    ady=AbsI64(dy),
    x=adx>>1,
    y=ady>>1,
    xx=x1,
    yy=y1;
    
  U32 *dst;

  dst = this->buffer+ (this->width * yy) + xx;
  *dst = color;

  // on one of the axis the next pixel will be no more than
  // 1 away
  if (adx>=ady) { // line is more horizonal
    for (i=0;i<adx;i++) {
      y+=ady;
      if (y>=adx) {
        y-=adx;
        yy+=sdy;
      }
      xx+= sdx;
      // pixel
      if (CRect_pxinside(this->clipRct, xx, yy)) {
        dst = this->buffer+ (this->width * yy) + xx;
        *dst = color;
      }
    }
  } else {
    for (i=0;i<ady;i++) {
      x+=adx;
      if (x>=ady) {
        x-=ady;
        xx+=sdx;
      }
      yy+= sdy;
      // pixel
      if (CRect_pxinside(this->clipRct, xx, yy)) {
        dst = this->buffer+ (this->width * yy) + xx;
        *dst = color;
      }
    }
  }
  // this is overkill for a line - this clip rect is way to big
  this->update(this, x1, y1, x2, y2);
}

/*
Copies the src canvas to this canvas's x, y
*/
U0 CCanvas_copyFrom(CCanvas *this, I64 x, I64 y, CCanvas *src) {
  CRect *cr = &this->clipRct;
  CRect *sc = CRectRelocate(src->clipRct, x, y);

  I64 c = CRectCreate(x, y, cr->x2, cr->y2);
  c = CRect_intersect(c, *sc);

  cr = &c;
  
  U64 
    xMax = cr->x2-cr->x1,
    yMax = cr->y2-cr->y1,

    sAddRow = src->width, 
    dAddRow = this->width,
    dOffset = (this->width*y) + x;
   
  U32 *sBuffer, *dBuffer;
  sBuffer = src->buffer;
  dBuffer = dOffset + this->buffer;

  // Brook asm copy loop?
  for (y=0 ; y<yMax;y++ ) {
    MemCpyU32(dBuffer, sBuffer, xMax);
    sBuffer += sAddRow;
    dBuffer += dAddRow;
  }
  _CCanvas_update(this, c);

  // Brook mark the src as clean?
  src->cleaned(src);
}
/*

Copies a rectangle(x1, y1, x2, y2) location from the src to this and puts it at x, y

*/
U0 CCanvas_copyRegion(CCanvas *this, I64 x, I64 y, CCanvas *src, 
        I64 x1, I64 y1, I64 x2, I64 y2) {
// Brook Add bounds check
  U64 xMax = x2 -x1, // Min(src->width, dst->width-x),
//    yMax = Min(src->height, dst->height-y),
    sAddRow = src->width, 
    dAddRow = this->width,
    yy = y2 - y1;
   
  U32 *sBuffer, *dBuffer;
  sBuffer = src->buffer + (src->width * y1) + x1;
  dBuffer = this->buffer + (this->width * (y1 + y)) + (x1 + x);

  for (y=0 ; y<yy;y++ ) {
    MemCpyU32(dBuffer, sBuffer, xMax);
    sBuffer += sAddRow;
    dBuffer += dAddRow;
  }

  this->update(this, x, y, x+x2-x1, y+y2-y1);
}


U0 CCanvas_copyRegion1(CCanvas *this, I64 x, I64 y, CCanvas *src, I64 crect) {
// Brook Add bounds check
  // x1, y1, x2, y2 non-aligned copy

// brook complete 

  // intersect 

  CRect *c = &crect;
  U64 xMax = c->x2 - c->x1, 
    sAddRow = src->width, 
    dAddRow = this->width,
    yy = c->y2 - c->y1;
   
  U32 *sBuffer, *dBuffer;
  sBuffer = src->buffer + (src->width * c->y1) + c->x1;
  dBuffer = this->buffer + (this->width * (c->y1 + y)) + (c->x1 + x);

  for (y=0 ; y<yy;y++ ) {
    MemCpyU32(dBuffer, sBuffer, xMax);
    sBuffer += sAddRow;
    dBuffer += dAddRow;
  }

  this->update(this, x, y, x+c->x2-c->x1, y+c->y2-c->y1);
}


/*

  Copy the dirty region to the dest (x, y)

*/
U0 CCanvas_pushUpdates(CCanvas *this, CCanvas *dst, I64 x, I64 y) { 
  if (!this->updated) {
    return;
  }

//  CRect *r = &this->dirtyRct;

//  dst->copyRegion(dst, x, y, this, r->x1, r->y1, r->x2, r->y2);  
  CCanvas_copyRegion1(dst, x, y, this, this->dirtyRct);  
  

  // mark the src as clean - verify this one
  this->cleaned(this);
}

// Utility method used to push changes onto the display screen
public U0 _CCanvas_UpdateScrnRegion(U64 crect)
{// 
  // x1, y1, x2, y2 aligned copy
  U64 intersect = CRect_intersect(crect, screenCanvas->clipRct);
  CRect * cr = &intersect;
//  CRect * cr = &crect;

  U64 row = (cr->x2 - cr->x1),
   rowAdd = screenCanvas->width,
   startLoc = ((cr->y1 * screenCanvas->width) + cr->x1),
   yy;
  U32 *sBuffer, *dAddress;

  dAddress = &screenCanvas_->buffer[startLoc];
  sBuffer = &screenCanvas->buffer[startLoc];

  for (yy = cr->y1; yy < cr->y2; yy++) {
    MemCpyU32(dAddress,sBuffer,row);
    sBuffer += rowAdd;
    dAddress += rowAdd;
  }
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
  
//  U64 size = src + this->size; 
  I32 i;


  for (i = this->size -1; i > 0; i--, src++, dst++) {
      *dst = pal32[*src];
  }

  this->calcScrnUpdates(this, dest, grBody, screenCache);
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

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
//    "Owns buffer=false %p\n", buffer;
    this->buffer=buffer;
    this->ownsBuffer=FALSE;
  } else {
    this->buffer=MAlloc(this->bufferSize);
//    "Allocate buffer %p\n", this->buffer;
    this->ownsBuffer=TRUE;
  }
  this->size = width*height;

  this->updated = FALSE;
  this->dirtyRct = 0;
  this->clipRct = CRectCreate(0, 0, width, height);
  

  this->setPixel = &CCanvas_setPixel32;  
  this->printFont = &CCanvas_printFont32;  
  this->printString = &CCanvas_printString;  
  this->fillrect = &CCanvas_fillrect;  
  this->line = &CCanvas_line;
  this->copyFrom = &CCanvas_copyFrom;
  this->copyRegion = &CCanvas_copyRegion;
  this->update = &CCanvas_update;
  this->cleaned = &CCanvas_cleaned;
  this->pushUpdates = &CCanvas_pushUpdates;
  this->free = &CCanvas_free;
  this->UpdateScrnRegion = &_CCanvas_UpdateScrnRegion;
  this->scrollScrnDown = &CCanvas_ScrollScrnDown32;
  this->calcScrnUpdates = &CCanvas_CalcScrnUpdates32;
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
//    "Owns buffer=false %p\n", buffer;
    this->buffer=buffer;
    this->ownsBuffer=FALSE;
  } else {
    this->buffer=MAlloc(this->bufferSize);
//    "Allocate buffer %p\n", this->buffer;
    this->ownsBuffer=TRUE;
  }
  this->size = width*height;

  this->updated = FALSE;
  this->dirtyRct = 0;
  this->clipRct = CRectCreate(0, 0, width, height);
  

  this->setPixel = &CCanvas_setPixel16;  
  this->printFont = &CCanvas_printFont16;  
  this->printString = &CCanvas_printString;  
  this->fillrect = &CCanvas_fillrect;  
  this->line = &CCanvas_line;
  this->copyFrom = &CCanvas_copyFrom;
  this->copyRegion = &CCanvas_copyRegion;
  this->update = &CCanvas_update;
  this->cleaned = &CCanvas_cleaned;
  this->pushUpdates = &CCanvas_pushUpdates;
  this->free = &CCanvas_free;
  this->UpdateScrnRegion = &_CCanvas_UpdateScrnRegion;
  this->scrollScrnDown = &CCanvas_ScrollScrnDown16;
//  this->calcScrnUpdates = &CCanvas_CalcScrnUpdates16;
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
//    "Owns buffer=false %p\n", buffer;
    this->buffer=buffer;
    this->ownsBuffer=FALSE;
  } else {
    this->buffer=MAlloc(this->bufferSize);
//    "Allocate buffer %p\n", this->buffer;
    this->ownsBuffer=TRUE;
  }
  this->size = width*height;

  this->updated = FALSE;
  this->dirtyRct = 0;
  this->clipRct = CRectCreate(0, 0, width, height);
  

  this->setPixel = &CCanvas_setPixel8;  
  this->printFont = &CCanvas_printFont8;  
  this->printString = &CCanvas_printString;  
  this->fillrect = &CCanvas_fillrect;  
  this->line = &CCanvas_line;
  this->copyFrom = &CCanvas_copyFrom;
  this->copyRegion = &CCanvas_copyRegion;
  this->update = &CCanvas_update;
  this->cleaned = &CCanvas_cleaned;
  this->pushUpdates = &CCanvas_pushUpdates;
  this->free = &CCanvas_free;
  this->UpdateScrnRegion = &_CCanvas_UpdateScrnRegion;
  this->scrollScrnDown = &CCanvas_ScrollScrnDown8;
//  this->calcScrnUpdates = &CCanvas_CalcScrnUpdates8;
  this->fullScrnDraw = &CCanvas_FullScrnDraw8;


  return this;
}


U0 CCanvas_test1(CCanvas *c) {
   c->line(c, 900, 50, 1000, 100, 0x888888);
   c->printString(c, "text", 900, 50, XF_TRANSP, XF_SHADE|XF_VALUE|XF_LIGHT);
   c->printString(c, "text", 900, 60, 0xFFFFFF, XF_TRANSP);
   c->printString(c, "text", 900, 60, 0xFFFFFF, XF_TRANSP);

   I64 i = 0;
   for (i = 70; i < 600; i+=10) {
     c->printString(c, "text3", 600, i, 0xFFFFFF, XF_TRANSP);
   }

   CRect_print(c->dirtyRct);


   c->pushUpdates(c, screenCanvas_, 0, 0);


   for (i = 70; i < 600; i+=10) {
     c->printString(c, "text5", 950, i, 0xFFFFFF, XF_TRANSP);
   }
   CRect_print(c->dirtyRct);

   c->pushUpdates(c, screenCanvas_, 0, 0);

   CRect_print(c->dirtyRct);

//   I64 dr = CRectCreate(900, 50, 1000,600);   
//   _CCanvas_UpdateScrnRegion(dr);
}



U0 CCanvas_Test8BitFont(CCanvas *c) {
   c->printString(c, "text line", 900, 60, 0xFF, 0);
}



U0 CRect_test1() {

  I64 r =CRectCreate(200, 75, 100, 150);


  "r ";
  CRect_print(r);

  I64 c = CRect_normalise(r);
  "r normalise";
  CRect_print(c);

  I64 r1 = CRectCreate(120, 10, 20, 80);

  CRect_print(r1);

  "%d\n", CRect_inside(r1, r);
  " intersect "; CRect_print(CRect_intersect(r1, r));
  " intersect "; CRect_print(CRect_intersect(r, r1));
  " join "; CRect_print(CRect_join(r, r1));
  " join "; CRect_print(CRect_join(r1, r));

  c = CRectSet(r1, 50, 10, 20, 80);

  "%d\n", CRect_inside(c, r);
  " intersect "; CRect_print(CRect_intersect(c, r));
  " join "; CRect_print(CRect_join(c, r));

  "Check if adjoining areas get an interset\n";
  I64 rr1 =CRectCreate(100, 75, 200, 150);
  I64 rr2 =CRectCreate(200, 75, 300, 150);

  " intersect "; CRect_print(CRect_intersect(rr1, rr2));


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

