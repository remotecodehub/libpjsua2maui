#define PJ_CONFIG_IPHONE                        1
#define PJMEDIA_HAS_BCG729                      1
#define PJMEDIA_HAS_VIDEO                       1   
#define PJMEDIA_VIDEO_DEV_HAS_OPENGL            0
#define PJMEDIA_VIDEO_DEV_HAS_OPENGL_ES         0
#define PJMEDIA_HAS_AVFOUNDATION                1
#define PJMEDIA_HAS_METAL                       1
#define PJMEDIA_HAS_OPENH264_CODEC              1
#define PJMEDIA_HAS_OPUS_CODEC                  1
#define PJ_HAS_SSL_SOCK                         1
#define PJ_SSL_SOCK_IMP                         PJ_SSL_SOCK_IMP_OPENSSL
/* 
 * Performance adjusts for user apps (Client Side)
 */
#define PJ_MAX_SOUND_CARDS                      2 
#define PJSIP_MAX_TSX_COUNT                     255
#define PJSIP_MAX_DIALOG_COUNT                  255
#define PJMEDIA_SOUND_BUFFER_COUNT              4
/*
 * disable background VoIP socket, use PushKit
 */ 
#undef PJ_IPHONE_OS_HAS_MULTITASKING_SUPPORT
#define PJ_IPHONE_OS_HAS_MULTITASKING_SUPPORT   0
#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED
#define __IPHONE_OS_VERSION_MIN_REQUIRED        122000
#endif

// #define PJMEDIA_HAS_G729_CODEC 1
#include <pj/config_site_sample.h>