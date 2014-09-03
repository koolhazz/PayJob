#ifndef _DEFS_H_
#define _DEFS_H_

#define HTTP_SVR_NS_BEGIN namespace __http_svr_ns__ {
#define HTTP_SVR_NS_END }
#define USING_HTTP_SVR_NS using namespace __http_svr_ns__;

#define MAX_WEB_RECV_LEN            102400
#define MAX_ACCEPT_COUNT            256
enum CConnState
{
    CONN_IDLE,
    CONN_FATAL_ERROR,
    CONN_DATA_ERROR,
    CONN_CONNECTING,
    CONN_DISCONNECT,
    CONN_CONNECTED,
    CONN_DATA_SENDING,
    CONN_DATA_RECVING,
    CONN_SEND_DONE,
    CONN_RECV_DONE,
    CONN_APPEND_SENDING,
    CONN_APPEND_DONE
};

enum TDecodeStatus
{
    DECODE_FATAL_ERROR,
    DECODE_DATA_ERROR,
    DECODE_WAIT_HEAD,
    DECODE_WAIT_CONTENT,
    DECODE_HEAD_DONE,
    DECODE_CONTENT_DONE,
    DECODE_DONE,
    DECODE_DISCONNECT_BY_USER
};

typedef struct tagRspList
{
    char*   _buffer;
    int     _len;
    int     _sent;
    int     _type;

    struct tagRspList* _next;

}TRspList;

enum
{
	CLIENT_CMD_SYC = 0x0002,
	SERVER_CMD_SYC = 0x0001
};

enum ConnType
{
	CONN_CLINET,
	CONN_OTHER
};

//server¼äÍ¨ĞÅĞ­Òé
#define CLIENT_PACKET  		 0x0001//ÓÃ»§·¢¹ıÀ´µÄÊı¾İ°ü»òÕßserver·¢¸øÓÃ»§µÄ°ü
#define CLIENT_PACKET2		 0x0004//ÓÃ»§·¢¹ıÀ´µÄÊı¾İ°ü»òÕßserver·¢¸øÓÃ»§µÄ°ü(ĞÂÃüÁî×Ö)

#define CLIENT_CLOSE_PACKET  0x0002//ÓÃ»§¶Ï¿ªÁ¬½Ó£¬hall¸øÂß¼­server·¢µÄ°ü
#define SERVER_CLOSE_PACKET  0x0003//Âß¼­serverÖ÷¶¯¶Ï¿ªÁ¬½ÓµÄ°ü
#define SYS_RELOAD_CONFIG    0x0010//ÖØĞÂ¼ÓÔØÅäÖÃ
const int SYS_RELOAD_IP_MAP = 0x0011;//ÖØĞÂ¼ÓÔØipÓ³Éä
const int SYS_RESET_CONNECT_TIMER = 0x0012;//ÖØĞÂÉèÖÃconnect³¬Ê±Ê±¼ä
const int SYS_OPEN_DEBUG = 0x000D;//ÉèÖÃdebugÈÕÖ¾¿ª¹Ø

const int CLIENT_CMD_CLIENT_LOGIN = 0x0101;//ÓÃ»§´óÌüµÇÂ¼°ü
const int CMD_GET_NEW_ROOM = 0x0117;//Ëæ»ú³¡µã»÷ÁË×¼±¸,ÖØĞÂÇëÇó·¿¼äºÅ
const int CLIENT_CMD_REQUEST_LIST_ROOM = 0x11D;//ÓÃ»§ÇëÇó·¿¼äÁĞ±í
const int CLIENT_CMD_ENTER_ROOM = 0x0125;//ÓÃ»§ÇëÇó½øÈë·¿¼ä

const int SERVER_CMD_LOGIN_SUCCESS = 0x0201;//ÓÃ»§µÇÂ¼´óÌü³É¹¦
const int SERVER_CMD_KICK_OUT = 0x0203;//ÌŞ³ıÓÃ»§
const int SERVER_CMD_ENTER_ROOM = 0x0212;//·µ»ØÓÃ»§½øÈë·¿¼ä

const int SERVER_CMD_SET_IP = 0x0301;
const int CMD_GET_ROOM_LEVER_NUM = 0x0311;//»ñÈ¡¸÷µÈ¼¶³¡ÈËÊı

const int CMD_REQUIRE_IP_PORT = 0x0604;//ÇëÇóserverµÄipºÍ¶Ë¿Ú

const int CMD_SEPARATE = 0x0800;//ÃüÁî·Ö¸ô  ·Ö¸îÓÎÏ··şÎñÆ÷ÃüÁî×Ö

const int UDP_SERVER_LOG    =0x0901;    //ÉÏ±¨ÃüÁî×ÖÈÕÖ¾server
const int UDP_SERVER_CLIENT_CLOSE_LOG = 0x0902;//ÉÏ±¨ÓÃ»§Àë¿ª´óÌü
const int UDP_SERVER_USER_COUNT      = 0x0903;//ÉÏ±¨µ±Ç°ÓÃ»§ÓĞ¶àÉÙÈË

const int CLIENT_COMMAND_LOGIN = 0x1001;//ÓÃ»§µÇÂ¼Ä³¸ö·¿¼ä
const int SERVER_COMMAND_LOGOUT_SUCCESS = 0x2013;//ÓÃ»§³É¹¦ÍË³ö·¿¼ä

const int CLIENT_COMMAND_BREAK_TIME = 0x1016;//ĞÄÌø°ü

const int SERVER_GET_PLAYER_COUNT   = 0x3018;  //»ñµ½½ø³ÌÓĞ¶àÉÙÍæ¼Ò

const int SERVER_COMMAND_BREAK_TIME = 0x2017;//·µ»ØĞÄÌø

const int SERVER_COMMAND_CHANGE_GAMESERVER = 0x7213;

const int SERVER_BROADCAST_INFO = 0x7050;  // broadcast system
const int SERVER_BROADCAST_INFO_NEW = 0x7054;//ĞÂµÄ¹ã²¥Ğ­Òé
const int CLINET_REQUEST_BROADCAST_INFO = 0x7055; //Çø·ÖÖÕ¶ËÀàĞÍµÄ¹ã²¥

#ifndef CONST_T
#define CONST_T(T, V, v) (const T V = v)
#define CMD(V, v) CONST_T(int, V, v)
#else
#undef CONST_T
#undef CMD
#define CONST_T(T, V, v) (const T V = v)   m 
#define CMD(V, v) CONST_T(int, V, v)
#endif

#ifndef UNUSED
#define UNUSED(v) (void)(v)
#endif

CMD(CLIENT_CMD_REQ, 0x0001);			/* æ”¯ä»˜è¯·æ±‚ */
CMD(SERVER_CMD_REP, 0x1001);			/* æ”¯ä»˜å“åº” */

CMD(INTER_CMD_REQ, 0x8001);				/* å†…éƒ¨æ”¯ä»˜è¯·æ±‚ */
CMD(INTER_CMD_RES, 0x9001);				/* å†…éƒ¨æ”¯ä»˜å“åº” */

CMD(INTER_CMD_QUEUE_STAT_REQ, 0x8002)   /* é˜Ÿåˆ—çŠ¶æ€è¯·æ±‚ */
CMD(INTER_CMD_QUEUE_STAT_RES, 0x9002)   /* é˜Ÿåˆ—çŠ¶æ€å“åº” */

enum {
	JobWorkerType = 1,
	NotifyWorkerType
};

#endif

