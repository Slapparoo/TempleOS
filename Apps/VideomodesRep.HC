

//U16 *modelist = dev.uncached_alias+vbe2_info.video_modes;
//U8 *vender = vbe2_info.vender;


//"Vender %s\n", vender;

U32 i;

"Available modes:\n";

for ( i = 0; i < 50; ++i) {
  if (vesa_modes[i].return_code != 0x004F) {
    break;
  }
  if (vesa_modes[i].bpp == 32) {
    "$$BLUE$$";
  }
  if (vesa_modes[i].bpp == 24) {
    "$$GREEN$$";
  }
  if (vesa_modes[i].bpp == 16) {
    "$$YELLOW$$";
  }
  if (vesa_modes[i].bpp < 16) {
    "$$LTGREEN$$";
  }
  if (vesa_modes[i].mode == vesa_info.mode) {
    "$$BG,LTGRAY$$ *";
  } else {
    "  ";
  }


  "Mode 0x%p", vesa_modes[i].mode;
  " w/h/bpp %4d, %4d, %2d %b\n",vesa_modes[i].width, vesa_modes[i].height, vesa_modes[i].bpp, vesa_modes[i].attributes;
  "$$FG$$$$BG$$";
  



}


"Current mode:\n";
  "  Mode 0x%p", vesa_info.mode;
  " w/h/bpp %4d, %4d, %2d\n",vesa_info.width, vesa_info.height, vesa_info.bpp;
  "$$FG$$";

/*
  U16 attributes;
  U8 window_a;
  U8 window_b;
  U16 granularity;
  U16 window_size;
  U16 segment_a;
  U16 segment_b;
  U32 win_func_ptr;
  U16 pitch;  // bytes per row
  U16 width;  
  U16 height;
  U8  w_char, ychar, planes, bpp, banks, memory_model, bank_size;
  U8  image_pages, reserved0, red_mask, red_position, green_mask;
  U8  green_position, blue_mask, blue_position, reserved_mask;
  U8  reserved_position, direct_color_atributes;
  U32 framebuffer; // physical address of the LFB
  U32 off_screen_mem_off;
  U16 off_screen_mem_size;
  U8 reserved1[206];
  // our additions
//  U64 offscreenbuffer;
  U16 return_code;
  U16 mode; 
  U64 bufferSize; // = vesa_info.width*vesa_info.height*(bpp>>3);
*/

"Requested mode:\n";

"attributes        %h\n",vesa_info.attributes;
"attributes        %b\n",vesa_info.attributes;
"window_a          %d\n",vesa_info.window_a;
"window_b          %d\n",vesa_info.window_b;
"granularity       %d\n",vesa_info.granularity;
"window_size       %d\n",vesa_info.window_size;
"segment_a         %d\n",vesa_info.segment_a;
"segment_b         %d\n",vesa_info.segment_b;
"win_func_ptr      0x%p\n",vesa_info.win_func_ptr;
"pitch             %d\n",vesa_info.pitch;  // bytes per row
"width             %d\n",vesa_info.width;  
"height            %d\n",vesa_info.height;
"w_char            %d\n",vesa_info.w_char;
"ychar             %d\n",vesa_info.ychar;
"planes            %d\n",vesa_info.planes;
"bpp               %d\n",vesa_info.bpp; 
"banks             %d\n",vesa_info.banks;
"memory_model      %d\n",vesa_info.memory_model;
"bank_size         %d\n",vesa_info.bank_size;
"image_pages       %d\n",vesa_info.image_pages;
"reserved0         %d\n",vesa_info.reserved0;
"red_mask          %d\n",vesa_info.red_mask;
"red_position      %d\n",vesa_info.red_position;
"green_mask        %d\n",vesa_info.green_mask;
"green_position    %d\n",vesa_info.green_position;
"blue_mask         %d\n",vesa_info.blue_mask;
"blue_position     %d\n",vesa_info.blue_position;
"reserved_mask     %d\n",vesa_info.reserved_mask;
"reserved_position %d\n",vesa_info.reserved_position;
"direct_color_atrb %d\n",vesa_info.direct_color_atributes;
"framebuffer       0x%p\n",vesa_info.framebuffer; // physical address of the LFB
"off_screen_mem_of %p\n",vesa_info.off_screen_mem_off;
"off_screen_mem_sz %d\n",vesa_info.off_screen_mem_size;
//  U8 reserved1[206];
  // our additions
//  U64 offscreenbuffer;
"return_code       0x%p\n",vesa_info.return_code;
"mode              0x%p\n",vesa_info.mode; 
"bufferSize 32bit  %d\n",vesa_info.bufferSize; // = vesa_info.width*vesa_info.height*(bpp>>3);






"VBE2 info:\n";
"version      : %d\noem          : %d\ncapabilities : 0x%p\n", vbe2_info.version, vbe2_info.oem, vbe2_info.capabilities;
"video modes  : 0x%p\nvideo memory : %dMB\nsoftware rev : 0x%p\n", vbe2_info.video_modes, (vbe2_info.video_memory * 65535) / 1048576, vbe2_info.software_rev;
"vender       : %d\nproduct name : %d\nproduct rev  : 0x%p\n", vbe2_info.vender, vbe2_info.product_name, vbe2_info.product_rev;


