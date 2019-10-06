#help_index "Graphics"

// Brook gr def change cdc's

public class CGrGlbls
{
  I64	*to_8_bits,*to_8_colors;
  CDC	*scrn_image,	//Read only.
	*dc,		//Persistent
	*dc1,
	*dc2,		//Updated every refresh
	*dc_cache,
	*zoomed_dc;
  U32	*text_base;	//See $LK,"TextBase Layer",A="HI:TextBase Layer"$. (Similar to 0xB8000 but 32 bits)
  U16	*win_z_buf;

  #define SPHT_ELEM_CODE	1
  CHashTable *sprite_hash;

  U16	*win_uncovered_bitmap;
  I64	highest_uncovered;
  U16	*vga_text_cache;
  I64	pan_text_x,pan_text_y;	//[-7,7]
  U0	(*fp_final_scrn_update)(CDC *dc);//Mouse cursor is handled here.
  U0	(*fp_wall_paper)(CTask *task);
  U0	(*fp_draw_ms)(CDC *dc,I64 x,I64 y);
  U0	(*fp_draw_grab_ms)(CDC *dc,I64 x,I64 y,Bool closed);
  U8	*empty_sprite; //Gets assigned $LK,"gr.empty_sprite",A="FF:::/Adam/AMouse.HC,empty_sprite"$

  #define GR_PEN_BRUSHES_NUM 64
  CDC	*pen_brushes[GR_PEN_BRUSHES_NUM],
	*collision_pen_brushes[GR_PEN_BRUSHES_NUM],
	*even_pen_brushes[GR_PEN_BRUSHES_NUM],
	*odd_pen_brushes[GR_PEN_BRUSHES_NUM];
  I8	circle_lo[GR_PEN_BRUSHES_NUM][GR_PEN_BRUSHES_NUM],
	circle_hi[GR_PEN_BRUSHES_NUM][GR_PEN_BRUSHES_NUM];

  #define GR_SCRN_ZOOM_MAX	8
  U8	*scrn_zoom_tables[GR_SCRN_ZOOM_MAX+1];
  I64	scrn_zoom,sx,sy;

  //When zoomed, this keeps the mouse centered.
  Bool	continuous_scroll,
	hide_row,hide_col;
  U64 *pxlsUpd, *lstPxlsUpd; // bits indicating which pixels have changed
} gr;


public U8 *screenCache = MAlloc(screen32->width * screen32->height);

public extern U0 GrCalcScrnUpdates();
public extern U0 GrUpdateChanged(U64 a);


//See $LK,"RLf_VGA",A="FF:::/Kernel/KStart16.HC,RLf_VGA"$
//See $LK,"SysGrInit",A="MN:SysGrInit"$()
//Allows consts to be used instead of vars.

U32 textcols,textrows;

if (vesa_info.return_code == 0x4F) {
  textcols = text.cols;
  textrows = text.rows;
} else {
  textcols = 80;
  textrows = 25;
}

DefinePrint("GR_WIDTH","%d",screen32->width);
HashPublic("GR_WIDTH",HTT_DEFINE_STR);
DefinePrint("GR_HEIGHT","%d",screen32->height);
HashPublic("GR_HEIGHT",HTT_DEFINE_STR);

#help_index "Char;TextBase Layer/Char"
//DefinePrint("TEXT_ROWS","%d",text.rows);;;
DefinePrint("TEXT_ROWS","%d",textrows);
HashPublic("TEXT_ROWS",HTT_DEFINE_STR);
//DefinePrint("TEXT_COLS","%d",text.cols);;;
DefinePrint("TEXT_COLS","%d",textcols);
HashPublic("TEXT_COLS",HTT_DEFINE_STR);
