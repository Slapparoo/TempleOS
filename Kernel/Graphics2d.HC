
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

/*

U0 SetPixel32(CGr32Scrn *scrn, U64 x, U64 y, U32 color)
{
  U64 yLoc = scrn->width * y + x;
  scrn->buffer[yLoc] = color;
}
*/

/*
// Font
U0 PrintFont32(CGr32Scrn *scrn, U8 letter, U64 x, U64 y, U32 fg = 0xFFFFFF, U32 bg = 0) 
{
  // Brook add bounds check
//    (printFonts_[letter&0xFF])(&scrn->buffer[(scrn->width * y) + x], scrn->width<<2, fg, bg);
  

  U64 letterT = text.font[letter],
   count, rowInc = scrn->width - FONT_WIDTH; // FONT_WIDTH
  U32 *dst;
  dst = scrn->buffer + (scrn->width * y) + x;

  for (count = 0; count<64; count++) // FONT_WIDTH x FONT_HEIGHT
  {
    if (letterT & 0x1)
    {
      *dst = fg;
      dst++;

    }
    else 
    {
      *dst = bg;
      dst++;

    }
    if (count & 0x7 == 0x7)
    {
      dst += rowInc;
    }
    letterT = letterT>>1;
  }

}

*/
/*
U0 PrintLine32(CGr32Scrn *scrn, U8 *str, U64 x, U64 y, U32 fg = 0xFFFFFF, U32 bg = 0)
{
  while (str[0] != 0)
  {
    PrintFont32(scrn, str[0], x, y, fg, bg);
    x += 8;
    str++;
  }
}
*/

I64 SgnI64(I64 val) {
  return (0 < val) - (val < 0);
}

/*
U0 fillrect2D(CGr32Scrn *scrn, I64 x1, I64 y1, I64 x2, I64 y2, U32 color) {
   // Brook Add some bounds checking
  
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

  tOff=(y1 * scrn->width)+x1;
  bOff=(y2 * scrn->width)+x1;  
  width = x2 - x1 +1;
  
  for (i=tOff; i<bOff; i+= scrn->width) {
    MemSetU32(scrn->buffer+i, color, width);
  }
}
*/

/*
U0 Line2D(CGr32Scrn *scrn, I64 x1, I64 y1, I64 x2, I64 y2, U32 color) {
  
//Uses $LK,"fixed-point",A="FI:::/Demo/Lectures/FixedPoint.HC"$.
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
    
  Bool first=TRUE;
  U32 *dst;

  dst = scrn->buffer+ (scrn->width * yy) + xx;
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
      dst = scrn->buffer+ (scrn->width * yy) + xx;
      *dst = color;
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
      dst = scrn->buffer+ (scrn->width * yy) + xx;
      *dst = color;
    }
  }
}
*/

/**
-- Kernelb

#define WIN_BORDER      0x00FFFFFF 
#define WIN_PANEL       0x00222266
#define WIN_BACK        0x00111111
#define WIN_FG          0x00333333
#define WIN_TITLE_COLOR 0x00FFFFFF

class CWindow {
  CGr32Scrn canvas;
  CGr32Scrn *dst; // probably the screen
  I64 x, y;
  U64 w, h, canvasX, canvasY;  // the window is bigger than the canvas
  U8 *title;
};

*/
/*
U0 InitScrn(CGr32Scrn *scrn, U64 width, U64 height) {
  scrn->width = width;
  scrn->height = height;
  scrn->bufferSize = width*height*4;
  scrn->buffer=CAlloc(scrn->bufferSize);
  scrn->size = width*height;
}
*/

/*
U0 InitWindow(CGr32Scrn *dst, CWindow24 *win, U64 w, U64 h) 
{
  win->w = w;
  win->h = h;

  InitScrn(&win->canvas, w-1, h-13);

  win->canvasX = 1;
  win->canvasY = 13;
  win->dst = dst; 
  win->title = "Window";

  // self aware or win manager  
  win->x = 20;
  win->y = 20;

  win->visible = TRUE;

  MemSetU32(win->canvas.buffer,WIN_BACK,win->canvas.size);
}
*/
/*
U0 CpyScrn(CGr32Scrn *dst, I64 x, I64 y, CGr32Scrn *src) {
// Brook Add bounds check -x, -y
  U64 xMax = Min(src->width, dst->width-x),
    yMax = Min(src->height, dst->height-y),
    sAddRow = src->width, // would be zero if inside
    dAddRow = dst->width,
    dOffset = (dst->width*y) + x;
   
  U32 *sBuffer, *dBuffer;
  sBuffer = src->buffer;
  dBuffer = dOffset + dst->buffer;

  for (y=0 ; y<yMax;y++ ) {
    MemCpyU32(dBuffer, sBuffer, xMax);
    sBuffer += sAddRow;
    dBuffer += dAddRow;
  }
}
*/
/*
U0 CpyScrnRegion(CGr32Scrn *dst, I64 x, I64 y, CGr32Scrn *src, 
        I64 x1, I64 y1, I64 x2, I64 y2) {
// Brook Add bounds check
  U64 xMax = x2 -x1, // Min(src->width, dst->width-x),
//    yMax = Min(src->height, dst->height-y),
    sAddRow = src->width, 
    dAddRow = dst->width,
    yy = y2 - y1;
   
  U32 *sBuffer, *dBuffer;
  sBuffer = src->buffer + (src->width * y1) + x1;
  dBuffer = dst->buffer + (dst->width * (y1 + y)) + (x1 + x);

  for (y=0 ; y<yy;y++ ) {
    MemCpyU32(dBuffer, sBuffer, xMax);
    sBuffer += sAddRow;
    dBuffer += dAddRow;
  }
}
*/
/**

Copy the screen buffer to the display screen

*/
/*
U0 UpdateScrnRegion(U64 x1, U64 y1, U64 x2, U64 y2)
{// 
  //Brook Add bounds checks
  U64 row = (x2 - x1),
   rowAdd = screen.width,
   startLoc = ((y1 * screen.width) + x1),
   yy;
  U32 *sBuffer, *dAddress;

  dAddress = vesa_info.framebuffer + (startLoc<<2);
  sBuffer = screen.buffer + startLoc;

  for (yy = y1; yy < y2; yy++) {
    MemCpyU32(dAddress,sBuffer,row);
    sBuffer += rowAdd;
    dAddress += rowAdd;
  }
}
*/
/**

Push a canvas region to the display screen

*/
/*
U0 pushCanvasRegion(CWindow24 *win, U64 x1, U64 y1, U64 x2, U64 y2) {

  if (!win->visible) return;

  U64 x = win->x+win->canvasX, y = win->y+win->canvasY;
  CpyScrnRegion(win->dst, x, y, &win->canvas, x1, y1, x2, y2);

  UpdateScrnRegion(x+x1, y+y1, x+x2, y+y2);
}
*/

/*
U0 pushCanvas(CWindow24 *win) {
  if (!win->visible) return;
  CpyScrn(win->dst, win->x+win->canvasX, win->y+win->canvasY, &win->canvas);
}
*/
/*
U0 pushWindow(CWindow24 *win) {
  if (!win->visible) return;
  // the frame gets drawn to dst not the windows canvas
  fillrect2D(win->dst, win->x, win->y, win->x+win->w, win->y+13, WIN_PANEL); //t

  Line2D(win->dst, win->x,       win->y,       win->x+win->w,win->y,       WIN_BORDER); //t
  Line2D(win->dst, win->x,       win->y+12,    win->x+win->w,win->y+12,    WIN_BORDER); // t2
  Line2D(win->dst, win->x,       win->y,       win->x,       win->y+win->h,WIN_BORDER); // l
  Line2D(win->dst, win->x,       win->y+win->h,win->x+win->w,win->y+win->h,WIN_BORDER); // b
  Line2D(win->dst, win->x+win->w,win->y,       win->x+win->w,win->y+win->h,WIN_BORDER); //r 

  PrintLine32(win->dst, win->title, win->x+3, win->y+2, WIN_TITLE_COLOR, WIN_PANEL);
  pushCanvas(win);
}
*/
/*
Copy the buffer to the display screen
-- full screen update
*/
U0 UpdateScrn() {
  // 32bit buffer 32 bit pysical screen
//  MemCpyU32(vesa_info.framebuffer,screen.buffer,screen.bufferSize>>2);
  MemCpyU32(screen32_->buffer,screen32->buffer,screen32->bufferSize>>2);
}



/*

Brook not great redraw the "known" windows
*/
U0 redraw32() {
//  MemSetU32(screen.buffer,SYS_BACK,screen.size);
//  pushWindow(&dbgWindow);
//  pushWindow(&adamWindow);
//  pushWindow(&adamLGWindow);
//  UpdateScrn();
}


#exe {Option(OPTf_WARN_PAREN,ON);};

