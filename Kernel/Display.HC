
U0 ScrollScrnDown(CCanvas *canvas, U64 xdist)
{// 
  //Brook Add bounds checks

  U64 sStartLoc = xdist * canvas->width;

  MemCpyU32(canvas->buffer, canvas->buffer + sStartLoc, canvas->size - sStartLoc);
}

U0 RawPutChar(I64 ch)
{/*For RAW output during boot and in debugger.

See $LK,"GrUpdateTextFG",A="MN:GrUpdateTextFG"$ for
the normal scrn text output routine.

See also $LK,"GrUpdateScrn",A="MN:GrUpdateScrn"$().
*/
  I64 /*i,*/row,col;
  U8 *ptr,/* *ptr1,*ptr2 */;

  if (!(text.raw_flags&RWF_SHOW_DOLLAR)) {
    if (ch=='$$') {
      if (text.raw_flags&RWF_IN_DOLLAR) {
	text.raw_flags&=~RWF_IN_DOLLAR;
	if (!(text.raw_flags & RWF_LAST_DOLLAR)) {
	  text.raw_flags&=~RWF_LAST_DOLLAR;
	  return;
	}
      } else {
	text.raw_flags|=RWF_IN_DOLLAR|RWF_LAST_DOLLAR;
	return;
      }
    }
    text.raw_flags&=~RWF_LAST_DOLLAR;
    if (text.raw_flags&RWF_IN_DOLLAR)
      return;
  }
  if (ch=='\t') {
    RawPutChar(CH_SPACE);
    while (text.raw_col & 7)
      RawPutChar(CH_SPACE);
  } else if (ch==CH_BACKSPACE) {
    text.raw_col--;
    RawPutChar(CH_SPACE);
    text.raw_col--;
  } else if (ch=='\n') {
    RawPutChar(CH_SPACE);
    while (text.raw_col % text.cols)
      RawPutChar(CH_SPACE);

  } else if (Bt(char_bmp_displayable,ch)) {
    row=text.raw_col/text.cols%text.rows;
    col=text.raw_col%text.cols;
    // Brook rlf vga no set
    if (!Bt(&sys_run_level,RLf_24BIT_GRP)) { //if text mode
      if (text.raw_flags&RWF_SCROLL && text.raw_col && !row && !col) {
	MemCpy(text.vga_text_alias,text.vga_text_alias+text.cols*2,
	      text.cols*(text.rows-1)*2);
	MemSet(text.vga_text_alias+text.cols*(text.rows-1)*2,0,text.cols*2);
	text.raw_col-=text.cols;
	row=text.rows-1;
      }
      ptr=text.vga_text_alias+(row*text.cols+col)*2;
      ptr[0]=ch;
      ptr[1]=BLACK<<4+WHITE;
    } else {
      if (text.raw_flags & RWF_SCROLL && text.raw_col && !row && !col) {
        //Scroll cached image
        ScrollScrnDown(screen32_, FONT_HEIGHT);
        MemSetU32(screen32_->buffer+screen32_->size -(screen32_->width*FONT_HEIGHT),
               WIN_BACK,screen32_->width*FONT_HEIGHT);

	text.raw_col -= text.cols;
	row = text.rows - 1;
      }

      PUSHFD
      CLI
      screen32_->printFont(screen32_, ch&255, col*8, row*8, WIN_FG, WIN_BACK);
      POPFD

    }
    text.raw_col++;
  }
}

U0 VGAFlush()
{//Flush winmgr vga cache, so updates whole scrn.
  // Brook need to hook into this

  LBts(&sys_semas[SEMA_FLUSH_VGA_IMAGE],0);
}

U0 WinDerivedValsUpdate(CTask *task)
{//Those things calculated from other variables.
  if (!task) task=Fs;
  //Assert: This is called with TASKf_TASK_LOCK set
  PUSHFD
  CLI
  task->win_width =task->win_right-task->win_left+1;
  task->win_height=task->win_bottom-task->win_top+1;
  task->pix_left	=FONT_WIDTH*task->win_left;
  task->pix_right	=FONT_WIDTH*(task->win_right+1)-1;
  task->pix_width	=task->pix_right-task->pix_left+1;
  task->pix_top		=FONT_HEIGHT*task->win_top;
  task->pix_bottom	=FONT_HEIGHT*(task->win_bottom+1)-1;
  task->pix_height	=task->pix_bottom-task->pix_top+1;
  POPFD
}

Bool WinInside(I64 x,I64 y,CTask *task=NULL,I64 border=0)
{//Is pixel (x,y) inside task's win? Border to FONT_WIDTH.
  if (!task) task=Fs;
  if (TaskValidate(task) && Bt(&task->display_flags,DISPLAYf_SHOW)) {
    if (Bt(&task->display_flags,DISPLAYf_NO_BORDER))
      border=0;
    if (task->pix_left-border<=x<=task->pix_right+border &&
	  task->pix_top-border<=y<=task->pix_bottom+border)
      return TRUE;
  }
  return FALSE;
}
