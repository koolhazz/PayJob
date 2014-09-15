#ifndef __CLIENT_SYNC_H__
#define __CLIENT_SYNC_H__

#include <poller.h>
#include <timerlist.h>
#include <global.h>
#include <noncopyable.h>
#include <cache.h>
#include <memcheck.h>
#include "ICHAT_PacketBase.h"
#include "EncryptDecrypt.h"

using namespace comm::sockcommu;

HTTP_SVR_NS_BEGIN
#pragma pack(1)
struct TPkgHeader {	
	 short 			length;
	 char  			flag[2];	 	
	 char  			cVersion;	
	 char  			cSubVersion;
	 short 			cmd;
	 unsigned char  code;
};

typedef struct pkg_header_s pkg_header_t;
struct pkg_header_s {
	 short 			length;
	 char  			flag[2];	 	
	 char  			cVersion;	
	 char  			cSubVersion;
	 short 			cmd;
	 unsigned char  code;
};

#pragma pack()



class CDecoderUnit;
class CHelperUnit;
class CIncoming;
class CGameUnit;

// 支付信息
typedef struct payer_s payer_t;
struct payer_s {
	unsigned int id;  /* 商品ID */
	unsigned int mid; /* 游戏玩家ID */
};

class CClientUnit : public CPollerObject, 
					private CTimerObject, 
					private noncopyable {
public:
	CClientUnit (CDecoderUnit*, int, unsigned long);
	virtual ~CClientUnit ();

    int Attach (void);

    inline void set_state (CConnState stage) 
	{ 
		_stage = stage;
	}
	inline CConnState get_state (void) 
	{ 
		return _stage;
	}

    inline void set_netfd (int fd)
	{ 
		netfd = fd;
	}
	
	inline int get_netfd (void) 
	{ 
		return netfd; 
	}

	inline void set_uid(int id)
	{
		_uid = id;
	}

	inline int get_uid()
	{
		return _uid;
	}

	inline void set_login_flag(int flag)
	{
		_login_flag = flag;
	}

	inline int get_login_flag()
	{
		return _login_flag;
	}
	
	int ResetIpMap();
	int ResetHelperUnit();
	int recv (void);
	int send (void);
	void add_rsp_buf(const char* data, unsigned int len);
	int HandleInput(const char* data,  int len);
	int HandleInputBuf(const char* data, int len);
	bool CheckCmd(int cmd);

	unsigned long 
	get_flow() { return _flow; }
	
	void
	set_flow(unsigned long flow) { _flow = flow; }
	
	payer_t
	get_payer() { return _payer; }
	
	void
	set_payer(payer_t* p) { _payer.id = p->id; _payer.mid = p->mid; }
	
private:
	virtual int InputNotify (void);
	virtual int OutputNotify (void);
    virtual int HangupNotify (void);
    virtual void TimerNotify(void);
    void update_timer(void);
	TDecodeStatus proc_pkg();

	int ProcessGetLevelCount(NETInputPacket *pPacket);

	int ProcUserGetNewRoom(NETInputPacket *pPacket);
	int ProcUserGetNewRoom1(CGameUnit *pGameUnit);
	int ProcUserGetNewRoom2(NETInputPacket *pPacket);
	int ProcGetUserCount(NETInputPacket* pPacket);

	CHelperUnit* GetRandomHelper(short level);

	int SendPacketToHelperUnit(CHelperUnit *pHelperUnit, char *pData, int nSize);

	void SendIPSetPacket(CGameUnit* pGameUnit, NETInputPacket &reqPacket, int cmd);	
	int ProcessOpenDebug(NETInputPacket *pPacket);

	int client_cmd_req_handler(NETInputPacket* pack);

private:
	CHelperUnit* _get_job_worker();
public:
	short           _api;
	short           _send_error_times;
private:
    CConnState      _stage;
	TDecodeStatus   _decodeStatus;
    CDecoderUnit*   _decoderunit;
	int			    _uid;
	int             _login_flag;
	CRawCache       _r;
	CRawCache       _w;
	unsigned long 	_flow; // 数字标示
	payer_t			_payer; // 支付用户信息
};
HTTP_SVR_NS_END
#endif

