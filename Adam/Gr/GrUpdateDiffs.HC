/**

Utility functions for differential graphics updates.

Copying a full screen buffer was slow, so only the pixels which are changed are copyed,
A "bitmap" of pixels changed (not set to the background color) is maintained for each screen
refresh. The bitmap has 1 bit per 2 pixels or every 64bits (as it is just as expensive to copy)
64bits as it is to copy 32bits. So what gets copied out to the Linier Framer Buffer (LFB) each
refresh is the pixels from the previous refesh and the pixels from this refresh.

So each bit represents 2 pixels and every 64bits in the bitmap, represents 128 pixels. 

*/
// some metrics
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

/*
Calculate the pixels which have changed
*/
public U0 GrCalcScrnUpdates() {
  // compare the previous screen to the current screen
  U16 *scrn = gr.dc2->body, *lstScrn = screenCache;
  U64 difsSize = screen32->width*screen32->height>>1, i;

  for (i = 0; i < difsSize; i++) {
    if (*scrn != *lstScrn) {
      GrPixelUpdatedByIdx(i);
    }
  }
  MemCpyU64(screenCache, gr.dc2->body, difsSize>>2);
}

/*

Transfer just the changes to the Video Buffer (LFB)
*/
public U0 GrUpdateChanged(U64 a=0) {
  U64 difsSize = screen32->width*screen32->height>>7;
  U64 i = 0, ix, bt;
  U64 *src = screenBuffer->buffer, *dst = screen32_->buffer;

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


/*
GrPixelUpdated(63, 0);
GrPixelUpdated(127, 0);
GrPixelUpdated(128, 0);
GrPixelUpdated(129, 0);
GrPixelUpdated(130, 0);
GrPixelUpdated(131, 0);

GrPixelUpdated(10, 10);
*/