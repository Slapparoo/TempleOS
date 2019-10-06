/*

Basic growable list

Some old school Object Orientation <===3

*/

#exe {Option(OPTf_WARN_PAREN,OFF);};



U0 CList_add(CList *this, I64 entry) {
  if (this->length == this->size_) {
    (this->grow)(this, this->growBy_);
  }

  this->items[this->length++] = entry;
}


U0 CList_removeItem(CList *this, I64 entry) {
  I64 i = 0;

  for (i = 0; i< this->length; i++) {
    if (this->items[i] == entry) {
      if (i+1 < this->length) {
        MemCpyU64(&this->items[i], &this->items[i+1], this->length - i);
      }

      this->length--;
    }
  } 
}


U0 CList_remove(CList *this, I64 index) {
  if (index > this->length) {
    // doesn't exist
    "Doesn't exist\n";
    return;
  }

  if (index+1 < this->length) {
    
    MemCpyU64(&this->items[index], &this->items[index+1], this->length - index);
  }

  this->length--;
}


I64 CList_get(CList *this, I64 index) {
  if (index > this->length) {
    // doesn't exist
    return -1;
  }
  
  return this->items[index];

}


Bool CList_contains(CList *this, I64 entry) {
  I64 i = 0;

  for (i = 0; i< this->length; i++) {
    if (this->items[i] == entry) {
      return TRUE;
    }
  } 
  return FALSE;
}


U0 CList_grow(CList *this, I64 growBy) {
  I64 newSize = this->size_ + growBy;
  I64 *newItems = MAlloc(newSize * sizeof(I64));

  MemCpyU64(newItems, this->items, this->length);
  Free(this->items);

  this->items = newItems;
  this->size_ = newSize;
}

U0 CList_shrink(CList *this) {
  // perform a major size reduction
  // Brook TODO

}

U0 CList_clear(CList *this) {
  // clear the full size
  MemSetI64(this->items, 0, this->size_);
  this->length =0;
}



U0 CList_free(CList *this) {
  Free(this->items);
  Free(this);
}


U0 CList_foreach(CList *this, I64 (*callback)(I64 index, I64 entry)) {

  I64 i = 0;

  for (i = 0; i < this->length; i++) {
    (*callback)(i, this->items[i]);
  }
}


public CList *CListCreate() {
  CList *list = MAlloc(sizeof(CList));

  list->length = 0;
  list->size_ = LIST_INITIAL_SIZE;
  list->items = MAlloc(sizeof(I64) * LIST_INITIAL_SIZE);

  list->growBy_ = LIST_GROWBY_SIZE;
  
  list->add=&CList_add;
  list->remove=&CList_remove;
  list->contains=&CList_contains;
  list->grow=&CList_grow;
  list->shrink=&CList_shrink;
  list->free=&CList_free;

  list->clear=&CList_clear;
  list->get=&CList_get;
  list->removeItem=&CList_removeItem;
  list->foreach=&CList_foreach;

  return list;
} 


U0 myCallback(I64 index, I64 entry) {
  "%d=%d\n", index, entry;
}


U0 CList_test() {
  CList *l = CListCreate();
  l->add(l, 10);
  l->add(l, 20);
  l->add(l, 30);
  l->add(l, 40);
  "%d \n", l->get(l,0);
  "%d \n", l->get(l,1);
  "%d \n", l->get(l,2);
  "%d \n", l->get(l,3);

  l->remove(l, 0);
  l->remove(l, 1);

  "%d i0\n", l->get(l,0);
  "%d i1\n", l->get(l,1);
  "%d i2\n", l->get(l,2);

  l->clear(l);

  "%d size\n", l->size_;
  "%d length\n", l->length;
  "%d growBy\n", l->growBy_;


  l->add(l, 10);
  l->add(l, 20);

  I64 i = 0;

  for (i = 0; i < 100; i++) {
    l->add(l, 40+i);

  }

  l->add(l, 10);
  l->add(l, 20);

  "%d i63\n", l->get(l,63);

  "%d size\n", l->size_;
  "%d length\n", l->length;
  "%d growBy\n", l->growBy_;

  l->foreach(l, &myCallback);

}

//CList_test;

#exe {Option(OPTf_WARN_PAREN,ON);};
