#ifndef _DEFS_H_
#define _DEFS_H_

#define HTTP_SVR_NS_BEGIN namespace __http_svr_ns__ {
#define HTTP_SVR_NS_END }
#define USING_HTTP_SVR_NS using namespace __http_svr_ns__;

#define MAX_WEB_RECV_LEN            102400
#define MAX_ACCEPT_COUNT            256
enum CConnState {
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

enum TDecodeStatus {
    DECODE_FATAL_ERROR,
    DECODE_DATA_ERROR,
    DECODE_WAIT_HEAD,
    DECODE_WAIT_CONTENT,
    DECODE_HEAD_DONE,
    DECODE_CONTENT_DONE,
    DECODE_DONE,
    DECODE_DISCONNECT_BY_USER
};

typedef struct tagRspList {
    char*   _buffer;
    int     _len;
    int     _sent;
    int     _type;

    struct tagRspList* _next;

} TRspList;

enum {
	CLIENT_CMD_SYC = 0x0002,
	SERVER_CMD_SYC = 0x0001
};

enum ConnType {
	CONN_CLINET,
	CONN_OTHER
};

//server��ͨ��Э��
#define CLIENT_PACKET  		 0x0001//�û������������ݰ�����server�����û��İ�
#define CLIENT_PACKET2		 0x0004//�û������������ݰ�����server�����û��İ�(��������)

#define CLIENT_CLOSE_PACKET  0x0002//�û��Ͽ����ӣ�hall���߼�server���İ�
#define SERVER_CLOSE_PACKET  0x0003//�߼�server�����Ͽ����ӵİ�
#define SYS_RELOAD_CONFIG    0x0010//���¼�������
const int SYS_RELOAD_IP_MAP = 0x0011;//���¼���ipӳ��
const int SYS_RESET_CONNECT_TIMER = 0x0012;//��������connect��ʱʱ��
const int SYS_OPEN_DEBUG = 0x000D;//����debug��־����

const int CLIENT_CMD_CLIENT_LOGIN = 0x0101;//�û�������¼��
const int CMD_GET_NEW_ROOM = 0x0117;//����������׼��,�������󷿼��
const int CLIENT_CMD_REQUEST_LIST_ROOM = 0x11D;//�û����󷿼��б�
const int CLIENT_CMD_ENTER_ROOM = 0x0125;//�û�������뷿��

const int SERVER_CMD_LOGIN_SUCCESS = 0x0201;//�û���¼�����ɹ�
const int SERVER_CMD_KICK_OUT = 0x0203;//�޳��û�
const int SERVER_CMD_ENTER_ROOM = 0x0212;//�����û����뷿��

const int SERVER_CMD_SET_IP = 0x0301;
const int CMD_GET_ROOM_LEVER_NUM = 0x0311;//��ȡ���ȼ�������

const int CMD_REQUIRE_IP_PORT = 0x0604;//����server��ip�Ͷ˿�

const int CMD_SEPARATE = 0x0800;//����ָ�  �ָ���Ϸ������������

const int UDP_SERVER_LOG    =0x0901;    //�ϱ���������־server
const int UDP_SERVER_CLIENT_CLOSE_LOG = 0x0902;//�ϱ��û��뿪����
const int UDP_SERVER_USER_COUNT      = 0x0903;//�ϱ���ǰ�û��ж�����

const int CLIENT_COMMAND_LOGIN = 0x1001;//�û���¼ĳ������
const int SERVER_COMMAND_LOGOUT_SUCCESS = 0x2013;//�û��ɹ��˳�����

const int CLIENT_COMMAND_BREAK_TIME = 0x1016;//������

const int SERVER_GET_PLAYER_COUNT   = 0x3018;  //�񵽽����ж������

const int SERVER_COMMAND_BREAK_TIME = 0x2017;//��������

const int SERVER_COMMAND_CHANGE_GAMESERVER = 0x7213;

const int SERVER_BROADCAST_INFO = 0x7050;  // broadcast system
const int SERVER_BROADCAST_INFO_NEW = 0x7054;//�µĹ㲥Э��
const int CLINET_REQUEST_BROADCAST_INFO = 0x7055; //�����ն����͵Ĺ㲥

#ifndef CONST_T
#define CONST_T(T, V, v, b) (const T V = v + b)
#define CMD(V, v, b) CONST_T(int, V, v, b)
#else
#undef CONST_T
#undef CMD
#define CONST_T(T, V, v, b) (const T V = v + b)
#define CMD(V, v, b) CONST_T(int, V, v, b)
#endif

#ifndef UNUSED
#define UNUSED(v) (void)(v)
#endif

#define CLIENT_BASE 	0x0
#define SERVER_BASE 	0x1000
#define INTER_REQ_BASE	0x8000
#define INTER_RES_BASE	0x9000

CMD(CLIENT_CMD_REQ, 0x1, CLIENT_BASE);					/* 支付请求 */
CMD(SERVER_CMD_REP, 0x1, SERVER_BASE);					/* 支付响应 */

CMD(INTER_CMD_REQ, 0x1, INTER_REQ_BASE);				/* 内部支付请求 */
CMD(INTER_CMD_RES, 0x1, INTER_RES_BASE);				/* 内部支付响应 */

CMD(INTER_CMD_WAITER_STAT_REQ, 0x2, INTER_REQ_BASE);   	/* Waiter队列状态请求 */
CMD(INTER_CMD_WAITER_STAT_RES, 0x2, INTER_RES_BASE);  	/* Waiter队列状态响应 */

CMD(INTER_CMD_NOTIFY_STAT_REQ, 0x3, INTER_REQ_BASE);	/* Notify队列状态请求 */	
CMD(INTER_CMD_NOTIFY_STAT_RES, 0x3, INTER_RES_BASE);	/* Notify队列状态响应 */

enum {
	JobWorkerType = 1,
	NotifyWorkerType
};

typedef struct server_stat_s server_stat_t;
struct server_stat_s {
	unsigned int _w_qlen; /* length of waiter's queue */
	unsigned int _n_qlen; /* length of notify's queue */
	unsigned int _w_ctime;
	unsigned int _n_ctime;
};

typedef struct server_switch_s server_switch_t;
struct server_switch_s {
	bool _w_is_busyed;
	bool _n_is_busyed;
};

CONST_T(int, SVR_MAX_W_QLEN, 1024, 0);
CONST_T(int, SRV_MAX_N_QLEN, 1024, 0);


#endif

