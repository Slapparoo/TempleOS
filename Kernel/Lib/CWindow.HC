#exe {
  Option(OPTf_WARN_PAREN,OFF);
  Option(OPTf_WARN_DUP_TYPES,OFF);
};

/*

Old school OO, the Object is the first parameter

CWindow 

Currently based on a push model

*/



//public extern U8 CCanvas_UpdateScrnRegion(U64 crect);


U0 CWindow_show(CWindow *this) {
  this->visible = TRUE;
  this->push(this);
}

U0 CWindow_free(CWindow *this) {
  this->canvas->free(this->canvas);
  this->contents->free(this->contents);
  Free(this);
}



U0 CWindow_hide(CWindow *this) {
  this->visible = TRUE;

  // Brook fire an event to let some something know
}

U0 CWindow_redraw(CWindow *this) {
  // loop through the contents and draw them to the canvas

}


U0 CWindow_pullContent(CWindow *this) {
  // loop through the contents and draw changes
  
  // content need a dirty flag
  CList *c = this->contents;
  I64 i;
  I64 drawItem;

  for (i = 0; i < c->length; i++) {
    drawItem = c->items[i];

    // is updated -> draw;
  }

  this->pushChanges(this);
}


U0 CWindow_move(CWindow *this, I64 x, I64 y) {
  
  this->x = x;
  this->y = y;

  
  // Brook fire a redraw
  // its no good drawing unless the dst canvas has been prepared
  this->push(this);
}


U0 CWindow_pushChanges(CWindow *this) {

  if (!this->visible) return;
// brook include the frame

  CCanvas *c = this->canvas;
//  CRect *cr = &c->clipRct;

  U64 x = this->x+this->canvasX, 
    y = this->y+this->canvasY,
    dstRegion;

  if (c->updated) {

    c->pushUpdates(c, this->dst, x, y);

    // crect_reloacte x, y
    dstRegion = CRectRelocate(c->clipRct, x, y);

    // Brook fire an event to let them know
    _CCanvas_UpdateScrnRegion(dstRegion);
  }
}

/*
// Deprecated
U0 CWindow_pushCanvasRegion_(CWindow *this, U64 x1, U64 y1, U64 x2, U64 y2) {

  if (!this->visible) return;

  U64 x = this->x+this->canvasX, y = this->y+this->canvasY;
  this->dst->copyRegion(this->dst, x, y, this->canvas, x1, y1, x2, y2);

//  UpdateScrnRegion(x+x1, y+y1, x+x2, y+y2);
***    CCanvas_UpdateScrnRegion(dstRegion);

}
*/


U0 CWindow_pushCanvas(CWindow *this) {
  if (!this->visible) return;
  this->dst->copyFrom(this->dst,this->x+this->canvasX, this->y+this->canvasY, this->canvas); 
  // Brook canvas needs events
}

U0 CWindow_push(CWindow *this) {
  if (!this->visible) return;

  // hasFrame
  CWindow *t = this; // shorthand
  if (t->hasFrame) {
    CCanvas *d = t->dst; // more shorthand

    // the frame gets drawn to dst not the windows canvas
    d->fillrect(d, t->x, t->y, t->x+t->w, t->y+13, WIN_PANEL); //t

    d->line(d, t->x,      t->y,      t->x+t->w, t->y,       WIN_BORDER); //t
    d->line(d, t->x,      t->y+12,   t->x+t->w, t->y+12,    WIN_BORDER); // t2
    d->line(d, t->x,      t->y,      t->x,      t->y+t->h,  WIN_BORDER); // l
    d->line(d, t->x,      t->y+t->h, t->x+t->w, t->y+t->h,  WIN_BORDER); // b
    d->line(d, t->x+t->w, t->y,      t->x+t->w, t->y+t->h,  WIN_BORDER); //r 

    d->printString(d, t->title, t->x+3, t->y+2, WIN_TITLE_COLOR, WIN_PANEL);
  }
  t->pushCanvas(t);
}

U0 CWindow_resize() {
  // resize canvas
  // redraw
  // push
}

CWindow *CWindowCreate(CCanvas *dst, U8 * title, I64 w, I64 h) {
  CWindow *this = MAlloc(sizeof(CWindow));

  this->canvas = CCanvasCreate(w, h);
  this->contents = CListCreate();
  this->dst = dst;
  this->title = title; // does this need a copy?
  this->w = w;
  this->h = h;

  this->visible = FALSE;
  this->hasFrame = FALSE;

  this->x = 10;
  this->y = 10;
  this->canvasX = 0;
  this->canvasY = 0;
  
  this->redraw=&CWindow_redraw;
  this->show=&CWindow_show;
  this->hide=&CWindow_hide;
  this->free=&CWindow_free;
  this->move=&CWindow_move;
  this->pushChanges=&CWindow_pushChanges;
  this->pushCanvas=&CWindow_pushCanvas;
  this->push=&CWindow_push;
//  this->pushCanvasRegion_=&CWindow_pushCanvasRegion_;
  return this;
}

/*

A frameless window
*/
CWindow *CPanelCreate(CCanvas *dst, U8 * title, I64 w, I64 h) {
  CWindow *this = MAlloc(sizeof(CWindow));

  this->canvas = CCanvasCreate(w, h);
  this->contents = CListCreate();
  this->dst = dst;
  this->title = title; // does this need a copy?
  this->w = w;
  this->h = h;

  this->visible = FALSE;
  this->hasFrame = FALSE;

  this->x = 10;
  this->y = 10;
  this->canvasX = 0;
  this->canvasY = 0;
  
  this->redraw=&CWindow_redraw;
  this->show=&CWindow_show;
  this->hide=&CWindow_hide;
  this->free=&CWindow_free;
  this->move=&CWindow_move;
  this->pushChanges=&CWindow_pushChanges;
  this->pushCanvas=&CWindow_pushCanvas;
  this->push=&CWindow_pushCanvas;
//  this->pushCanvasRegion_=&CWindow_pushCanvasRegion_;
  return this;
}

#exe {
  Option(OPTf_WARN_PAREN,ON);
  Option(OPTf_WARN_DUP_TYPES,ON);
};


