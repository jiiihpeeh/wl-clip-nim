#pragma once
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char* ptr;
    size_t len;
    char* error;
} WlClipString;

typedef struct {
    uint8_t* ptr;
    size_t len;
    char* error;
} WlClipBytes;

typedef struct {
    int32_t value;
    char* error;
} WlClipInt;

void wlclip_set_foreground(char val);
WlClipString wlclip_get_text();
WlClipInt wlclip_set_text(char* text);
WlClipBytes wlclip_get_image();
WlClipInt wlclip_set_image_type(uint8_t* image_data, size_t len, char* mime_type);
WlClipString wlclip_get_files();
WlClipInt wlclip_set_files(char* json);
void wlclip_free_string(char* ptr);
void wlclip_free_bytes(uint8_t* ptr, size_t len);
