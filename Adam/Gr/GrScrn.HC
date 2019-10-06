#help_index "Graphics/Scrn"

U0 GrUpdateTaskODEs(CTask *task)
{
  sys_task_being_scrn_updated=task;
  try
    ODEsUpdate(task);
  catch {
    LBts(&task->win_inhibit,WIf_SELF_ODE);
    "Exception in WinMgr: Update Task ODEs\n";
    PutExcept;
    Sleep(3000);
    VGAFlush;
  }
  sys_task_being_scrn_updated=NULL;
}

U0 GrUpdateTaskWin(CTask *task)
{ //Draw a win.  Only Core0 tasks have a win.
  CDC *dc;
  CD3I64 saved_scroll;
  sys_task_being_scrn_updated=task;
  try {

    // Brook Win frame
    if (!Bt(&task->display_flags,DISPLAYf_NO_BORDER)) {

      TextBorder(Fs,task->win_left,task->win_right,task->win_top,
	    task->win_bottom,task->border_attr,task==sys_focus_task);
    }


    TextRect(task->win_left,task->win_right,
	  task->win_top,task->win_bottom,task->text_attr<<8);
    

    if (task==sys_winmgr_task) {
      if (gr.fp_wall_paper)
	(*gr.fp_wall_paper)(task);
    } else if (!(task->win_inhibit&WIF_SELF_DOC))
      DocUpdateTaskDocs(task);
    if (TaskValidate(task)) {
      if (task->draw_it) {
	dc=DCAlias(gr.dc2,task);
	(*task->draw_it)(task,dc);
	DCDel(dc);
      }
      if (TaskValidate(task)) {
	WinScrollNull(task,&saved_scroll);
	DrawCtrls(task);
	WinScrollRestore(task,&saved_scroll);
      }
    }
  } catch {
    if (task!=Fs && TaskValidate(task)) {
      LBtr(&task->display_flags,DISPLAYf_SHOW);
      "Exception in WinMgr: Update Task Win\n";
      PutExcept;
      Sleep(3000);
      VGAFlush;
    }
  }
  sys_task_being_scrn_updated=NULL;
}

U0 GrUpdateTasks()
{//Only called by WinMgr
  I64 i;
  CTask *task,*task1;
  try {
    winmgr.ode_time=0;
    if (Bt(&sys_semas[SEMA_UPDATE_WIN_Z_BUF],0))
      WinZBufUpdate;
    task1=task=sys_winmgr_task;
    do { //Loop through Core0 tasks.
      if (!TaskValidate(task)) break;
      if (Bt(&task->display_flags,DISPLAYf_SHOW) &&
	    Bt(gr.win_uncovered_bitmap,task->win_z_num))
	GrUpdateTaskWin(task);
      if (!TaskValidate(task)) break;
      task=task->next_task;
    } while (task!=task1);

    for (i=0;i<mp_cnt;i++) { //Loop through all cores.
      task1=task=cpu_structs[i].seth_task;
      do {
	if (!TaskValidate(task)) break;
	GrUpdateTaskODEs(task);
	if (!TaskValidate(task)) break;
	task=task->next_task;
      } while (task!=task1);
    }
  } catch {
    PutExcept(FALSE);
    Dbg("Exception in WinMgr");
  }
  winmgr.last_ode_time=winmgr.ode_time;
  ode_alloced_factor=LowPass1(0.1,ode_alloced_factor,
	Clamp(Gs->idle_factor-0.1,0.2,0.8),1/winmgr.fps);
  sys_task_being_scrn_updated=NULL;
}

U0 GrFixZoomScale()
{
  gr.scrn_zoom=ClampI64(gr.scrn_zoom,1,GR_SCRN_ZOOM_MAX);
  if (gr.scrn_zoom==1) {
    gr.sx=0;
    gr.sy=0;
  } else {
    gr.sx=ClampI64(gr.sx,0,GR_WIDTH-GR_WIDTH/gr.scrn_zoom)&~7;
    gr.sy=ClampI64(gr.sy,0,GR_HEIGHT-GR_HEIGHT/gr.scrn_zoom);
  }
}

public U0 GrScaleZoom(F64 scale)
{//Multiply zoom factor larger or smaller.
  F64 s=gr.scrn_zoom;
  gr.scrn_zoom=gr.scrn_zoom*scale;
  GrFixZoomScale;
  s/=gr.scrn_zoom;
  ms.scale.x*=s;
  ms.scale.y*=s;
  ms.scale.z*=s;
  ms.offset.x=ms.pos.x-(ms.pos.x-ms.offset.x)*s;
  ms.offset.y=ms.pos.y-(ms.pos.y-ms.offset.y)*s;
  ms.offset.z=ms.pos.z-(ms.pos.z-ms.offset.z)*s;
  gr.sx=ms.pos.x-gr.zoomed_dc->width >>1/gr.scrn_zoom;
  gr.sy=ms.pos.y-gr.zoomed_dc->height>>1/gr.scrn_zoom;
  GrFixZoomScale;
}

U0 GrZoomInScrn()
{
  GrFixZoomScale;
  I64 plane,row,col,k,l,
	d2=gr.zoomed_dc->width>>3/gr.scrn_zoom,
	d4=gr.zoomed_dc->width_internal>>3,
	d5=d4-d2*gr.scrn_zoom,
	d3=gr.zoomed_dc->height/gr.scrn_zoom,
	d6=(gr.zoomed_dc->height-d3)*gr.dc1->width_internal>>3,
	d7=gr.zoomed_dc->height%gr.scrn_zoom*d4;
  U8 *src,*src2,*dst,*src3,*map=gr.scrn_zoom_tables[gr.scrn_zoom];

  src=gr.dc1->body+gr.sx>>3+gr.sy*gr.dc1->width_internal>>3;
  dst=gr.zoomed_dc->body;
  for (plane=1;plane<0x10;plane<<=1) {
    row=d3;
    while (row--) {
      k=gr.scrn_zoom;
      while (k--) {
	src2=src;
	col=d2;
	while (col--) {
	  src3=&map[*src2++];
	  l=gr.scrn_zoom;
	  while (l--) {
	    *dst++=*src3;
	    src3+=256;
	  }
	}
	l=d5;
	while (l--)
	  *dst++=0;
      }
      src+=d4;
    }
    l=d7;
    while (l--)
      *dst++=0;
    src+=d6;
  }
}

U0 GrUpdateTextBG()
{
  // Brook Are these hints to use regs for the vars?
  I64 reg RSI *dst=gr.dc2->body,
      reg R13 c,row,col,
      num_rows=TEXT_ROWS,
      num_cols=TEXT_COLS,
      i,j,cur_ch,
      reg R12 w1=gr.dc2->width_internal,
      w2=-7*w1+8,
      w3=7*w1,
      w4=0;
  U32 *src=gr.text_base;
  Bool blink_flag=Blink;
  U8 *dst2=dst;

  if (gr.pan_text_x||gr.hide_col) {
    gr.pan_text_x=ClampI64(gr.pan_text_x,-7,7);
    j=AbsI64(gr.pan_text_x)/FONT_WIDTH+1;
    num_cols-=j;
    if (gr.pan_text_x<0) {
      src+=j;
      i=FONT_WIDTH*j+gr.pan_text_x;
    } else
      i=gr.pan_text_x;
    dst2=dst(U8 *)+i;
    w4=j;
    w3+=j*FONT_WIDTH;

    j*=FONT_WIDTH;
    dst(U8 *)=gr.dc2->body;
    for (row=num_rows*FONT_HEIGHT;row--;) {
      for (col=i;col--;)
	*dst(U8 *)++=0;
      dst(U8 *)+=w1-i-j;
      for (col=j;col--;)
	*dst(U8 *)++=0;
    }
  }
  dst=dst2;

  if (gr.pan_text_y||gr.hide_row) {
    gr.pan_text_y=ClampI64(gr.pan_text_y,-7,7);
    j=AbsI64(gr.pan_text_y)/FONT_HEIGHT+1;
    num_rows-=j;
    if (gr.pan_text_y<0) {
      src+=w1/FONT_WIDTH*j;
      i=w1*(FONT_HEIGHT*j+gr.pan_text_y);
    } else
      i=w1*gr.pan_text_y;
    dst2=dst(U8 *)+i;

    j*=w1*FONT_HEIGHT;
    dst(U8 *)=gr.dc2->body;
    for (row=i;row--;)
      *dst(U8 *)++=0;
    dst(U8 *)=gr.dc2->body+TEXT_ROWS*TEXT_COLS*FONT_HEIGHT*FONT_WIDTH-j;
    for (row=j;row--;)
      *dst(U8 *)++=0;
  }
  dst=dst2;

  for (row=num_rows;row--;) {
    for (col=num_cols;col--;) {
      cur_ch=*src++;
      if (cur_ch & (ATTRF_SEL|ATTRF_INVERT|ATTRF_BLINK)) {
	if (cur_ch & ATTRF_SEL)
	  cur_ch.u8[1]=cur_ch.u8[1]^0xFF;
	if (cur_ch & ATTRF_INVERT)
	  cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
	if (cur_ch & ATTRF_BLINK && blink_flag)
	  cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
      }
      c=gr.to_8_colors[cur_ch.u8[1]>>4];
      MOV	U64 [RSI],R13
      ADD	RSI,R12
      MOV	U64 [RSI],R13
      ADD	RSI,R12
      MOV	U64 [RSI],R13
      ADD	RSI,R12
      MOV	U64 [RSI],R13
      ADD	RSI,R12
      MOV	U64 [RSI],R13
      ADD	RSI,R12
      MOV	U64 [RSI],R13
      ADD	RSI,R12
      MOV	U64 [RSI],R13
      ADD	RSI,R12
      MOV	U64 [RSI],R13
      dst(U8 *)+=w2;
    }
    src+=w4;
    dst(U8 *)+=w3;
  }
}

U0 GrUpdateTextFG()
{//See $LK,"TextBase Layer",A="HI:TextBase Layer"$.

  U32 *src=gr.text_base;
  I64 i,j,cur_ch,
    *dst=gr.dc2->body,
    w1=gr.dc2->width_internal,
    w2=7*w1,w4=0,
    num_rows=TEXT_ROWS,
    num_cols=TEXT_COLS,row,col;
  U8 *dst_start=gr.dc2->body,*dst_end=dst_start+w1*gr.dc2->height-7*w1-8;
  Bool blink_flag=Blink;

  if (gr.pan_text_x||gr.hide_col) {
    gr.pan_text_x=ClampI64(gr.pan_text_x,-7,7);
    j=AbsI64(gr.pan_text_x)/FONT_WIDTH+1;
    num_cols-=j;
    if (gr.pan_text_x<0) {
      src+=j;
      dst(U8 *)+=FONT_WIDTH*j;
    }
    w4=j;
    w2+=j*FONT_WIDTH;
  }

  if (gr.pan_text_y||gr.hide_row) {
    gr.pan_text_y=ClampI64(gr.pan_text_y,-7,7);
    j=AbsI64(gr.pan_text_y)/FONT_HEIGHT+1;
    num_rows-=j;
    if (gr.pan_text_y<0) {
      src+=w1/FONT_WIDTH*j;
      dst(U8 *)+=w1*FONT_HEIGHT*j;
    }
  }

  for (row=num_rows;row--;) {
    for (col=num_cols;col--;) {
      cur_ch=*src++;
      if (cur_ch & (ATTRF_UNDERLINE|ATTRF_SEL|ATTRF_INVERT|ATTRF_BLINK)) {
	if (cur_ch & ATTRF_SEL)
	  cur_ch.u8[1]=cur_ch.u8[1]^0xFF;
	if (cur_ch & ATTRF_INVERT)
	  cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
	if (cur_ch & ATTRF_BLINK && blink_flag)
	  cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
      }
      if (i=cur_ch.u16[1]&0x3FF+gr.pan_text_x+gr.pan_text_y<<5) {
	j=i&0x1F;
	if (j&0x10) j|=~0x1F;
	i>>=5;
	if (i&0x10) i|=~0x1F;
	i=w1*i+j;
	if (dst_start<=dst(U8 *)+i<dst_end)
// remove underline	  GrRopEquU8NoClipping(cur_ch&(ATTRF_UNDERLINE+0xFFF),dst(U8 *)+i,w1);
	  GrRopEquU8NoClipping(cur_ch&0xFFF,dst(U8 *)+i,w1);
      } else
	GrRopEquU8NoClipping(cur_ch&0xFFF,dst,w1);
// remove underline	GrRopEquU8NoClipping(cur_ch&(ATTRF_UNDERLINE+0xFFF),dst,w1);
      dst(U8 *)+=8;
    }
    src+=w4;
    dst(U8 *)+=w2;
  }
}

// dest, src
// Brook can this go (include in UpdateGraphics32)
U0 DCBlotColor8(CDC *dc,CDC *img)
{
  U8  *src=img->body,
      *b0=dc->body;
  I64 j,
      k,
     d0=img->width_internal*img->height;
  for (k = 0; k < d0; k++) {
    j = *src++;
    if (j != TRANSPARENT)
      *b0++ = j;
    else
      b0++;
  }
}

U0 GrUpdateTextModeText()
{
  U32 *src=gr.text_base;
  I64 cur_ch,i=TEXT_COLS*TEXT_ROWS;
  U16 *dst=text.vga_text_alias,*dst2=gr.vga_text_cache;
  Bool blink_flag=Blink;
  if (LBtr(&sys_semas[SEMA_FLUSH_VGA_IMAGE],0)) {
    while (i--) {
      cur_ch=*src++;
      if (cur_ch & ATTRF_SEL)
	cur_ch.u8[1]=cur_ch.u8[1]^0xFF;
      if (cur_ch & ATTRF_INVERT)
	cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
      if (cur_ch & ATTRF_BLINK)
	if (blink_flag)
	  cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
      *dst++=*dst2++=cur_ch&0x7FFF;
    }
  } else {
    while (i--) {
      cur_ch=*src++;
      if (cur_ch & ATTRF_SEL)
	cur_ch.u8[1]=cur_ch.u8[1]^0xFF;
      if (cur_ch & ATTRF_INVERT)
	cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
      if (cur_ch & ATTRF_BLINK)
	if (blink_flag)
	  cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
      cur_ch&=0x7FFF;
      if (*dst2!=cur_ch)
	*dst++=*dst2++=cur_ch;
      else {
	dst++;
	dst2++;
      }
    }
  }
}

//U8 *screenCache;


public U32 pal[16] = 
    {BLACK32, BLUE32,    GREEN32,  CYAN32,
     0x002288,PURPLE32,  BROWN32,  LTGREY32,
     DKGREY32,LTBLUE32,  LTGREEN32,LTCYAN32,
     LTRED32, LTPURPLE32,YELLOW32, WHITE32};


U0 GrUpdateGr32ModeText()
{
  Bool blink_flag=Blink;
// works as expected
// Brook update text only mode
  I64 cur_ch,
    yy=0,
    xx=0,
    x=0, 
    y=0;
  U32 *src=gr.text_base, fg2, bg2;
  U8 fg, bg;
  U16 *dst2=gr.vga_text_cache;
  U32 updCnt = 0;

  if (LBtr(&sys_semas[SEMA_FLUSH_VGA_IMAGE],0)) {
    for (y=0;y < TEXT_ROWS;y++) {
      yy = y<<3;
      for (x=0;x < TEXT_COLS;x++) {
        cur_ch=*src++;
        if (cur_ch & ATTRF_SEL)
          cur_ch.u8[1]=cur_ch.u8[1]^0xFF;
        if (cur_ch & ATTRF_INVERT)
	  cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
        if (cur_ch & ATTRF_BLINK)
	  if (blink_flag)
	    cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
        // Writen as U16 u8[0] = chr, u8[1] = color bg:fg

        fg=(cur_ch & 0x0F00)>>8;
        bg=(cur_ch & 0xF000)>>12; 

        fg2 = pal[fg];
        bg2 = pal[bg];

        screen32->printAsmFont(screen32, cur_ch&0xFF, x<<3, yy, fg2, bg2);
        *dst2++=cur_ch;
      }
    }
    MemCpyU32(screen32_->buffer, screen32->buffer, screen32->bufferSize>>2);

//    screen32->pushUpdates(screen32, screen32_, 0, 0);
  } else {
    for (y=0;y < TEXT_ROWS;y++) {
      yy = y<<3;
      for (x=0;x < TEXT_COLS;x++) {

        cur_ch=*src++;
        if (cur_ch & ATTRF_SEL)
          cur_ch.u8[1]=cur_ch.u8[1]^0xFF;
        if (cur_ch & ATTRF_INVERT)
	  cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
        if (cur_ch & ATTRF_BLINK)
	  if (blink_flag)
	    cur_ch.u8[1]=cur_ch.u8[1]<<4+cur_ch.u8[1]>>4;
        if (*dst2&0xFFFF !=cur_ch&0xFFFF) {
          fg=(cur_ch & 0x0F00)>>8;
          bg=(cur_ch & 0xF000)>>12; 

          fg2 = pal[fg];
          bg2 = pal[bg];

          xx=x<<3;
          screen32->printAsmFont(screen32, cur_ch&0xFF, xx, yy, fg2, bg2);
          screen32->pushUpdates(screen32, screen32_, 0, 0);

          *dst2++=cur_ch&0xFFFF;
          updCnt++;
        } else {
	  dst2++;
        }
      }
    }
/*    if (gr.dc2->updated) {
       screen32_->printAsmFont(screen32_, '2', 900, 50, 0x4444FF, 0xFF8888);
       CDC_cleaned(gr.dc2);
    }
    if (gr.dc->updated) {
       screen32_->printAsmFont(screen32_, 'U', 908, 50, 0x4444FF, 0xFF8888);
       CDC_cleaned(gr.dc);
    }
    if (gr.dc1->updated) {
       screen32_->printAsmFont(screen32_, '1', 916, 50, 0x4444FF, 0xFF8888);
       CDC_cleaned(gr.dc1);
    }
*/
  }

}

U0 GrClearDC() {
  CDC *dc=gr.dc2; // GrUpdateGraphics32
  U64 len = dc->height*dc->width_internal;
  U8 *src =dc->body;
  U64 size=src+len; 
  
  for (; src < size; src++) {
    *src=0;
  }
}

/*
U0 GrUpdateGraphics32(U64){
  //Copy the 4bit screen to the 32bit display screen
  // fudging it;

  U32 *dst = screen32_->buffer, *dst2 = screen32->buffer, c;
  CDC *dc=gr.dc2; // GrUpdateGraphics32
  U64 len = dc->height*dc->width_internal;
  U8 *src =dc->body, *cch = screenCache, j;
  
  U64 size=src+len; 

  for (src=dc->body; src < size; src++, dst++, cch++, dst2++) {
    j = *src;
    if (j != *cch) {
      c = pal[j&0xF];
      *dst = c;
      *dst2 = c;
      *cch = j;
    }
  }
}
*/

/*

public U64 GR_UP_CNT1 = 0;
public U64 GR_UP_CNT2 = 0; 
public U64 GR_UP_CNT3 = 0; 

public U0 GrPixelUpdatedByIdx(U64 xyOffset) {
// this is the Screen based index, not the updates bitmap based index
// this should just be a call to BEqu

  U64 qofs = (xyOffset)>>7;
  U64 bofs = (xyOffset)>>1&0b111111;


//  "x=%d, y=%d, qofs=%d bofs=%d bMap=%b\n", x, y, qofs, bofs, 1<<bofs;

//  U64 bMap = *gr.pxlsUpd[qofs];
//  bMap |= 1<<bofs;

  gr.pxlsUpd[qofs] |= 1<<bofs;
  GR_UP_CNT1++; 
}


public U0 GrPixelUpdatedRect(U64 crect) {
  CRect *r = &crect;  
  U64 x, y, yy;
  //  inefficient
  for (y = r->y1; y < r->y2; y++) {
    yy = y * screen32->width;
    for (x = r->x1; x < r->x2; x++) {
      GrPixelUpdatedByIdx(yy + x);
    }
  }
  GR_UP_CNT2++; 
}



public U0 GrPixelUpdated(U64 x, U64 y) {
  GrPixelUpdatedByIdx(y * screen32->width + x);
  GR_UP_CNT3++; 
}
*/
/*
Calculate the pixels which have changed
*/
public U0 GrCalcScrnUpdates(U64 a=0) {
  // compare the previous screen to the current screen
  U16 *scrn = gr.dc2->body, *lstScrn = screenCache;
  U64 difsSize = screen32->width*screen32->height>>1, i;
  U64 *src = screen32->buffer, *dst = screen32_->buffer;

  for (i = 0; i < difsSize; i++, dst++, src++) {
    if (*scrn++ != *lstScrn++) {
      *dst = *src;
    }
  }
  MemCpyU64(screenCache, gr.dc2->body, difsSize>>2);
}

/*

Transfer just the changes to the Video Buffer (LFB)
*/
/*
public U0 GrUpdateChanged(U64 a=0) {
  U64 difsSize = screen32->width*screen32->height>>7;
  U64 i = 0, ix, bt;
  U64 *src = screen32->buffer, *dst = screen32_->buffer;

  for (;i < difsSize; i++) {
    U64 changes = gr.pxlsUpd[i] | gr.lstPxlsUpd[i];

    if (changes) {
      for (ix = 0; ix < 64; ix++, dst++, src++) {
        bt = 1<<ix;
        if (changes&bt) {
          *dst = *src;
        }
      }

    } else {
      src += 64;
      dst += 64;
    }
  }

  src = gr.lstPxlsUpd;
  gr.lstPxlsUpd = gr.pxlsUpd;
  gr.pxlsUpd = src;
  MemSetI64(src, 0, difsSize);
}
*/

U0 GrCopyScreenBuffer(U64 a = 0) {
//  MemCpyU64(screen32_->buffer, screen32->buffer, screen32->bufferSize>>3);
/*   U64 reg RDI *dst = screen32_->buffer;
   U64 reg RSI *src = screen32->buffer;
   U64 reg RCX *cnt = screen32->bufferSize>>6;
   asm {
     @@05:
        MOV R8,[RSI] 
        MOV R9,[RSI+8] 
        MOV R10,[RSI+16] 
        MOV R11,[RSI+24] 
        MOV R12,[RSI+32] 
        MOV R13,[RSI+40] 
        MOV R14,[RSI+48] 
        MOV R15,[RSI+56]

        MOV [RDI], R8 
        MOV [RDI+8], R9 
        MOV [RDI+16], R10 
        MOV [RDI+24], R11 
        MOV [RDI+32], R12 
        MOV [RDI+40], R13 
        MOV [RDI+48], R14 
        MOV [RDI+56], R15

        ADD RSI, 64
        ADD RDI, 64
        DEC RCX
        JNZ @@05
   }
*/
//   GrCalcScrnUpdates;
//   GrUpdateChanged; 
}



U0 GrFullScreenDraw32(U64 x=0){
  //Copy the 4bit screen to the 32bit display screen
  // fudging it;

  U32 *dst = screen32->buffer;
  CDC *dc=gr.dc2; // GrUpdateGraphics32
  U64 len = dc->height*dc->width_internal;
  U8 *src =dc->body, j;
  
  U64 size=src+len; 

  for (src=dc->body; src < size; src++, dst++) {
    *dst = pal[*src&0xF];
  }
//  Spawn(&GrCopyScreenBuffer,,,mp_cnt-1);
//  GrCopyScreenBuffer;
//  LOCK 
  GrCalcScrnUpdates;
//  Spawn(&GrCalcScrnUpdates,,,mp_cnt-1);

}


U0 GrUpdateVGAGraphics()
{//Update Graphic Card

  I64 row,plane,d=gr.zoomed_dc->width_internal>>6;
  U32 *src,*vga,*dst;
  if (gr.scrn_zoom==1)
    src=gr.dc1->body;
  else {
    GrZoomInScrn;
    src=gr.zoomed_dc->body;
  }
  dst=gr.scrn_image->body;
  if (LBtr(&sys_semas[SEMA_FLUSH_VGA_IMAGE],0)) {
    for (plane=1;plane<0x10;plane<<=1) {
      OutU8(VGAP_IDX,VGAR_MAP_MASK);
      OutU8(VGAP_DATA,plane);
      vga=text.vga_alias;
      row=gr.zoomed_dc->height;
      while (row--)
	GrUpdateLine64FlushCache(&vga,&src,d,&dst);
    }
  } else {
    for (plane=1;plane<0x10;plane<<=1) {
      OutU8(VGAP_IDX,VGAR_MAP_MASK);
      OutU8(VGAP_DATA,plane);
      vga=text.vga_alias;
      row=gr.zoomed_dc->height;
      while (row--)
	GrUpdateLine64(&vga,&src,d,&dst);
    }
  }
}

I64 lastMouse = -1;

U0 GrUpdateGr32Mouse() {

  I64 x,y, thisMouse;
  PUSHFD
  CLI
  x=ms.pos.x;
  y=ms.pos.y + 8;  // ms.pos is being clipped
  POPFD
  if (ms.show && ms_hard.installed) {

/*    if (ms.lb) {
      dc->color=ROP_XOR+LTPURPLE^TRANSPARENT;
    } else if (ms.rb) {
      dc->color=ROP_XOR+LTCYAN^TRANSPARENT;
    } else {
      dc->color=ROP_XOR+BLACK^TRANSPARENT;
    } 
  
*/
    // pushLast area to pref mouse position
       CRect *tm = &thisMouse; 


       tm->x1 = x;
       tm->y1 = y;
       tm->x2 = x+8;
       tm->y2 = y+8;

       PUSHFD
       CLI
       if (lastMouse != -1) {
         screen32_->UpdateScrnRegion(lastMouse);
//         UpdateScrnRegion(lastMouse.u16[0], lastMouse.u16[1], lastMouse.u16[2], lastMouse.u16[3]);
       }
      
       screen32_->printAsmFont(screen32_, 'þ', x, y, 0xFFFFFF, 0);
 

//       PrintFont32(&screen_, 'þ', x, y, 0xFFFFFF, 0);
       POPFD
       
       lastMouse = thisMouse;
  }
}

U0 GrUpdateThread(U64 x = 0) {
  DCBlotColor4(gr.dc1->body,gr.dc2->body,gr.dc_cache->body,
    gr.dc2->height*gr.dc2->width_internal>>3);
//  GrUpdateGraphics32(0);
  GrFullScreenDraw32;
  
//  GrUpdateGr32ModeText;
//  GrUpdateGr32Mouse;
}



U0 GrUpdateScrn(U64 a=0)
{//Called by the Window Manager $LK,"HERE",A="FF:::/Adam/WinMgr.HC,GrUpdateScrn"$, 30 times a second.
  CDC *dc;
//  "GrUpdateScrn\n";

  if (vesa_info.return_code == 0x4F) {
    GrUpdateTextBG;
    GrUpdateTextFG;
//    GrClearDC;
    GrUpdateTasks;
    // dest, src
    DCBlotColor8(gr.dc2,gr.dc);
  } else if (!Bt(&sys_run_level,RLf_VGA)) { //if text mode
    GrUpdateTasks;
  } else {
    GrUpdateTextBG;
    GrUpdateTextFG;
    GrUpdateTasks;
    // dest, src
    DCBlotColor8(gr.dc2,gr.dc);
  }

  // Brook update to 32bit draw mouse etc
  dc=DCAlias(gr.dc2,Fs);
  dc->flags|=DCF_ON_TOP;
  if (gr.fp_final_scrn_update)
    (*gr.fp_final_scrn_update)(dc);
  DCDel(dc);

  if (vesa_info.return_code == 0x4F) {
    
    DCBlotColor4(gr.dc1->body,gr.dc2->body,gr.dc_cache->body,
	  gr.dc2->height*gr.dc2->width_internal>>3);

    /*
    GrUpdateGraphics32(0);

    GrUpdateGr32ModeText;
    GrUpdateGr32Mouse;
    */
//    Spawn(&GrUpdateThread,,,1);
    GrUpdateThread;

  } else if (!Bt(&sys_run_level,RLf_VGA)) { //if text mode {
    GrUpdateTextModeText;
  } else {
    // dc2.body contains an 8bit image  
    // which I'm guesing gets converted to 4bit
    DCBlotColor4(gr.dc1->body,gr.dc2->body,gr.dc_cache->body,
	  gr.dc2->height*gr.dc2->width_internal>>3);
    GrUpdateVGAGraphics;
  }
  
}
