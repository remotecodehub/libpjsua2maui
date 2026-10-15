#include <pj/config_site_sample.h>
#define PJ_HAS_IPV6 1
#define PJ_HAS_SSL_SOCK 1
#define PJ_SSL_SOCK_IMP PJ_SSL_SOCK_IMP_OPENSSL
#define PJSIP_HAS_TLS_TRANSPORT 1
#define PJMEDIA_AUDIO_DEV_HAS_PORTAUDIO 0
#define PJMEDIA_HAS_VIDEO 1
#define PJMEDIA_HAS_OPENH264_CODEC 1
#define PJMEDIA_HAS_OPUS_CODEC 1
#define PJMEDIA_HAS_BCG729 1
#define PJ_DLL 1
#define PJ_EXPORTING 1
#define PJ_EXPORT_SPECIFIER __declspec(dllexport)
#define PJ_IMPORT_SPECIFIER __declspec(dllimport)
