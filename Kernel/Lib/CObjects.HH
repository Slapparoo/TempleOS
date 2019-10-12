
/*

The Definition of some Gr32 obects

*/

/*
extern class CCanvas;
extern class CRect;
extern class CSize;
extern class CPoint;
*/

class CSize {
// Basic description of a screen item size width + height
// U32 means it all fits nicely into an I64
  U32 w, h;
};


public class CRect {
// Basic description of a screen rectangle
// U16 means it all fits nicely into an I64
  U16 x1, x2, y1, y2;
};


public class CPoint {
// Basic description of a screen location
// U32 means it all fits nicely into an I64
  U32 x, y;
};


// Brook CCanvas needs a cliprect
public class CCanvas {
// Describes a logical screen
  I16 width, height;
  U32 *buffer;
  I64 size; // width*height;
  I64 bufferSize; // = width*height*4;

  I64 rct;  // canvas bounds

  // Updated bounds
  Bool updated; // Dirty flag
  I64 dirtyRct;  // Maybe a list
  // Clip area - currently unused
  Bool clipped; // has a clip rect

  // Brook rename
  I64 clipRct;
  
  Bool ownsBuffer;

  U0 (*setPixel)(CCanvas *this, I64 x, I64 y, U32 color);
  U0 (*printFont)(CCanvas *this, U8 letter, I64 x, I64 y, U32 fg, U32 bg);
  U0 (*printString)(CCanvas *this, U8 *str, I64 x, I64 y, U32 fg, U32 bg);
  U0 (*fillrect)(CCanvas *this, I64 x1, I64 y1, I64 x2, I64 y2, U32 color);
  U0 (*line)(CCanvas *this, I64 x1, I64 y1, I64 x2, I64 y2, U32 color);
  U0 (*copyFrom)(CCanvas *this, I64 x, I64 y, CCanvas *src);
  U0 (*copyRegion)(CCanvas *this, I64 x, I64 y, CCanvas *src, I64 x1, I64 y1, I64 x2, I64 y2);
  U0 (*update)(CCanvas *this, I64 x1, I64 y1, I64 x2, I64 y2);
  U0 (*cleaned)(CCanvas *this);
  U0 (*pushUpdates)(CCanvas *this, CCanvas *dst, I64 x, I64 y); 
  U0 (*free)(CCanvas *this);
  U0 (*scrollScrnDown)(CCanvas *this, U64 xdist, U32 bgColor);
};


public class CList {
  I64 length; // number of items
  I64 size_; // allocated memory size;
  I64 *items; // list contents
  
  I64 growBy_;

  U0 (*add)(CList *this, I64 entry);
  U0 (*removeItem)(CList *this, I64 entry);
  U0 (*remove)(CList *this, I64 index);
  I64 (*get)(CList *this, I64 index);
  Bool (*contains)(CList *this, I64 entry);
  U0 (*grow)(CList *this, I64 growBy);  // increase the size by x
  U0 (*shrink)(CList *this); // compact if you suspect the allocated space is bigger than required
  U0 (*clear)(CList *this);
  U0 (*free)(CList *this);
  U0 (*foreach)(CList *this, I64 (*callback)(I64 index, I64 entry)); // foreach with call back per item
};


#define LIST_INITIAL_SIZE 16
#define LIST_GROWBY_SIZE 16    // not a perfect science




public class CWindow 
{
  CCanvas *canvas;
  CCanvas *dst; // where this ends up going
  // Brook parent win manager (dialogs?, sub windows)
  I64 x, y;
  U64 w, h, canvasX, canvasY;  // the window is bigger than the canvas
  U8 *title;
  Bool visible;
  Bool hasFrame;

  CList *contents;

  I64 parent; // place holder for parent - or message que

  // manage content
  // add, remove....

  // actions
  U0 (*redraw)(CWindow this);
  U0 (*show)(CWindow this);
  U0 (*hide)(CWindow this);
  U0 (*move)(CWindow this, I64 x, I64 y);
  U0 (*pushChanges)(CWindow this);
  U0 (*pushCanvas)(CWindow this);
  U0 (*push)(CWindow this);
//  U0 (*pushCanvasRegion_)(CWindow *this, U64 x1, U64 y1, U64 x2, U64 y2);
  U0 (*free)(CWindow this);
  U0 (*pullContent)(CWindow this);
  // Events  
  // selected, close, move, redraw, keyevents, mouse, timer, callbacks, sync....
  // Brook build a message que
};


// Brook this class is nowhere near complete

public class CContent {
  Bool visible;
  Bool updated; // managed cleared after draw

  I64 x, y;
  I64 w, h;

  I64 type; // good for introspection
  CWindow *parent;

  // Brook does this need a clip rect?
  
//  U0 (*draw)(CContent *this); // 
  U0 (*update)(CContent *this);
  U0 (*cleared)(CContent *this);
  U0 (*free)(CContent *this); // 
  U0 (*draw)(CContent *this, I64 x, I64 y); // 
  U0 (*redraw)(CContent *this, I64 x, I64 y); // 

};

public class CContentText:CContent {
  U8 *string;  // rudimentary
  U32 bg, fg;
};

