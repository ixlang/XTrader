//xlang Source, Name:FIX4X.x
//Date: Fri Jun 17:31:31 2025

class FIX4X {
    public interface TraderListener{
        void onLogin(FIX4X f, int code);
        void onLoginOut(FIX4X f, String msg);
        void onSymbolsListUpdate(FIX4X f, JsonArray );
        void onError(FIX4X f,String errmsg);
        void onUpdate(FIX4X f, String symbol, long time, double ask , double bid, double vol);
        void onOrderStateChange(FIX4X f, JsonObject obj);
    };

    public bool configure(TraderListener listenr, String
                              sDataDictionary,
                              String SenderCompID, String TargetCompID, String SenderSubID, String TargetSubID, String SocketConnectHost, int SocketConnectPort,
                              String Username,
                              String Password, bool useSSL)
    {
        _listener = listenr;
        Method m = onCommand;
        handle = create(this.hash(), m.toNative(), sDataDictionary, SenderCompID, TargetCompID, SenderSubID, TargetSubID, SocketConnectHost, SocketConnectPort,Username,Password, useSSL);
        if (handle == 0l){
            return false;
        }
        
        return true;
    }
    
    public bool startServer(){
        if (handle == 0l){
            return false;
        }
        return start(handle);
    }
    
    public bool stopServer(){
        if (handle == 0l){
            return false;
        }
        return stop(handle);
    }
    
    private void finalize(){
        if (handle != 0l){
            close(handle);
            handle = 0l;
        }
    }
    
    public bool subScribe(String symbol, bool add){
        return subscribe(handle, "SCRIBE_" + symbol, symbol, add);
    }
    
    public bool getList(){
        return updateList(handle,  "" + Math.random());
    }

    private Pointer handle = 0l;
    private TraderListener _listener = nilptr;
    private import "fix4x" {
        Pointer cdecl create (long tag,
                              Pointer callback,
                              String
                              sDataDictionary,
                              String SenderCompID, String TargetCompID, String SenderSubID, String TargetSubID, String SocketConnectHost, int SocketConnectPort,
                              String Username,
                              String Password, bool useSSL);

        bool cdecl start (Pointer fh);
        bool cdecl stop (Pointer fh);
        bool cdecl close (Pointer fh);
        bool cdecl subscribe (Pointer fh, String reqid, String symbol, bool add);
        bool cdecl updateList (Pointer fh, String reqid);
        bool cdecl ModifyOrder(Pointer fh, String symbol, String neworderid, String orderid, double quantity, double price);
        bool cdecl CancelOrder(Pointer fh, String symbol, String orderid, bool buy);
        bool cdecl RequestMessageSeq(Pointer fh, int lastProcessedSeqNo);
        bool cdecl SendOrder(Pointer fh, String symbol, String orderid, bool buy, int type, double quantity, double price, double sl, double tp);
    };
    
    public bool modifyOrder(String symbol, String neworderid, String orderid, double quantity, double price){
        return ModifyOrder(handle, symbol, neworderid,  orderid, quantity, price);
    }
    
    public bool cancelOrder(String symbol, String orderid, bool buy){
        return CancelOrder(handle, symbol, orderid, buy);
    }
    
    public bool requestMessageSeq(int lastProcessedSeqNo){
        return RequestMessageSeq(handle, lastProcessedSeqNo);
    }
    
    public bool sendOrder(String symbol, String orderid, bool buy, int type, double quantity, double price, double sl, double tp){
        return SendOrder(handle, symbol, orderid, buy, type, quantity, price, sl, tp);
    }
    
    private void doCmd(String msg){
        JsonObject json = new JsonObject(msg);
        int cmd = json.getInt("cmd");
        switch (cmd) {
        	case -1: /*TODO*/ // 发生错误
            if (_listener != nilptr){
                _listener.onError(this, json.getString("msg"));
            }
        	break;
            case 0: /*TODO*/ // 更新价格
            if (_listener != nilptr){
                _listener.onUpdate(this, json.getString("symbol"), json.getLong("timestamp"), json.getDouble("ask"), json.getDouble("bid"), json.getDouble("vol"));
            }
        	break;
            case 1: /*TODO*/ // 登陆成功
            if (_listener != nilptr){
                _listener.onLogin(this, json.getInt("code"));
            }
        	break;
            case 2: /*TODO*/ // 登出
            if (_listener != nilptr){
                _listener.onLoginOut(this, json.getString("msg"));
            }
        	break;
            case 3: /*TODO*/ // 更新列表
            if (_listener != nilptr){
                _listener.onSymbolsListUpdate(this, json.getArray("items"));
            }
        	break;
            
            case 4:
            if (_listener != nilptr){
                _listener.onOrderStateChange(this, json);
            }
            break;
        	default:
        	break;
        }
    }
    
    @Native(Conversion = "stdcall")
    static void onCommand(long tag, String msg){
        FIX4X fh = FIX4X.fromHash(tag);
        fh.doCmd(msg);
    }
};