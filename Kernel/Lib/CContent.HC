/*

Drawable content inside a window


Push drawing (called from a pull)

*/

#exe {Option(OPTf_WARN_PAREN,OFF);};


U0 CContentText_redraw(CContentText *this, I64 x, I64 y) {
  CContentText *t = this;
  CCanvas *c = t->parent->canvas;
  
  c->printString(c, t->string, x, y, t->fg, t->bg);

  t->x =x;
  t->y =y;

  updated = FALSE;
}

U0 CContentText_draw(CContentText *this, I64 x, I64 y) {
  if (x != this->x || y != this->y) {
    redraw(this, x, y);
  }


  if (this->updated) ) {
    redraw(this, x, y);
  }
}

#exe {Option(OPTf_WARN_PAREN,ON);};
