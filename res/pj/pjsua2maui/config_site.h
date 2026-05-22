/* 
 * Endianness Auto-detection and arch for Mac Catalyst (Apple Silicon vs Intel)
 * Resolves the compilation mismatch from SWIG at ARM64 runner from GitHub Actions
 */
#if defined(__arm64__) || defined(__aarch64__)
#  ifndef PJ_IS_LITTLE_ENDIAN
#    define PJ_IS_LITTLE_ENDIAN 1
#  endif
#  ifndef PJ_IS_BIG_ENDIAN
#    define PJ_IS_BIG_ENDIAN    0
#  endif
#  // Ensures that the config.h from PJSIP validates the 64-bits Apple ecosysistem 
#  ifndef __aarch64__
#    define __aarch64__         1
#  endif
#elif defined(__x86_64__) || defined(__i386__)
#  ifndef PJ_IS_LITTLE_ENDIAN
#    define PJ_IS_LITTLE_ENDIAN 1
#  endif
#  ifndef PJ_IS_BIG_ENDIAN
#    define PJ_IS_BIG_ENDIAN    0
#  endif
#endif

#define PJ_CONFIG_IPHONE 1

/* 
 * 1. OS e Arch adjstuments 
 * Forces PJSIP understand that the native threads POSIX support is available 
 * with suitable I/O seletocrs for Darwin (Apple) ecosystem.
 */
#define PJ_HAS_FLOATING_POINT           1
#define PJ_ACTIVESOCK_MAX_LOOP          1
#define PJ_IOQUEUE_MAX_HANDLES          1024

/* 
 * 2. Security and Crypto (OpenSSL) 
 */
#define PJ_HAS_SSL_SOCK                 1
#define PJ_SSL_SOCK_IMP                 PJ_SSL_SOCK_IMP_OPENSSL

/* 
 * 3. Video support and  H264 Codec (OpenH264)
 */
#define PJMEDIA_HAS_VIDEO               1
#define PJMEDIA_HAS_OPENH264_CODEC      1
#define PJMEDIA_HAS_LIBAVCODEC          0  /* avoid forced FFmpeg dependencies  */
#define PJMEDIA_HAS_VID_TOOLBOX_CODEC   1

/* 
 * Important: Mac Catalyst doens't have OpenGLES. 
 * Deactivated for not allow PJSIP link the missing framework.
 */
#define PJMEDIA_HAS_OPENGLES            0
#define PJMEDIA_VIDEO_DEV_HAS_OPENGL    0

/* 
 * Activate macOS/Catalyst compatible native capture and renders 
 * (AVFoundation for camera and Metal/CoreVideo for viewing)
 */
#define PJMEDIA_HAS_AVFOUNDATION        1
#define PJMEDIA_HAS_METAL               1

/* 
 * 4. Audio Codecs (Opus & BCG729)
 */
#define PJMEDIA_HAS_OPUS_CODEC          1
#define PJMEDIA_HAS_BCG729_CODEC        1
 
/* 
 * 5. Performance adjusts for user apps (Client Side)
 *
#define PJ_MAX_SOUND_CARDS              2 */
#define PJSIP_MAX_TSX_COUNT             255
#define PJSIP_MAX_DIALOG_COUNT          255
#define PJMEDIA_SOUND_BUFFER_COUNT      4

/* Includes default sampling settings and base ecosystem */
#include <pj/config_site_sample.h>