//xlang Source, Name:MT5Plugins.x
//Date: Sun Jun 20:46:37 2025


class MT5PluginsListener {
    public void onData (JsonObject)  ;
    public void onNetworError(bool bpluginMode);
    public void onNetworReset(bool bpluginMode);
};

class ExecuteResult {
    JsonObject result;
    public void setResult (JsonObject l) {
        result = l;
    }
    public bool isSucceed() {
        return false;
    }
    public int getCode() {
        return 0;
    }
    public String getRason() {
        return nilptr;
    }
    public String getDescription() {
        return nilptr;
    }
    public JsonObject getResult() {
        return result;
    }
};

enum EXECUTE_MODE {
    EXEC_ASYNC,
    EXEC_SYNC
};

const int CMD_ORDER_NONE = 0,
          CMD_ORDER_MARKETS_BUY = 1,//市价买单
          CMD_ORDER_MARKETS_SELL = 2, //市价卖单
          CMD_ORDER_BUYSTOP = 3, //市价卖单
          CMD_ORDER_BUYLIMIT = 4, //市价卖单
          CMD_ORDER_SELLSTOP = 5, //市价卖单
          CMD_ORDER_SELLLIMIT = 6, //市价卖单
          CMD_ORDER_CLOSE = 7, //平仓
          CMD_ORDER_CANCEL = 8, //取消挂单
          CMD_MODIFY_ORDER = 9,
          CMD_MODIFY_POS = 10;

interface XTraderExecuter {
    bool modify (ExecuteResult er, int id, String tick, int type, float price, float sl, float tp, float vol);
    bool createOrder (ExecuteResult er, int id, String symbol, int type, float price, float sl, float tp, float vol);
    bool close (ExecuteResult er, int type, int id, String tickid);
    bool query (ExecuteResult er, int cmd, String symbol, String period);
};

class MT5Plugins : Thread {
    public static const int MEG_MAXLEN = 10485760;
    public static const int SERVER_VERSION = 3;
    public static const int SERVER_PORT = 7613;
    StreamSocket serverSocket = new StreamSocket(), client;
    MT5PluginsListener listener;
    bool pluginMode = true;
    bool bQuit = false;
    const String SRVHost = "1.94.142.44";
    const int SRVPort = 5369;

    public bool isPluginMode(){
        return pluginMode;
    }
    long __request_serial = 0;
    Map<String, ExecuteResult> __responses = new Map<String, ExecuteResult>();

    public void setQuit() {
        bQuit = true;
    }

    public void configureListener (MT5PluginsListener _listener) {
        listener = _listener;
    }

    public bool openPipe () {
        if ( serverSocket.listen ("127.0.0.1", SERVER_PORT, 2) ) {
            pluginMode = true;
            start();
            return true;
        }

        return false;
    }

    bool started = false;

    public void registry (String username, String pwd) {
        JsonObject object = new JsonObject();
        object.put ("cmd", "registry");
        object.put ("name", username);
        object.put ("pwd", pwd);
        object.put ("version", SERVER_VERSION);
        object.put ("balance", 1000000);
        object.put ("lever", 400);
        send (nilptr, object);
    }

    public void ping() {
        JsonObject object = new JsonObject();
        object.put ("cmd", TradingData.CMD_PING);
        object.put ("version", SERVER_VERSION);
        object.put ("timestamp", _system_.currentTimeMillis() );
        send (nilptr, object);
    }

    public void login (String username, String pwd) {
        JsonObject object = new JsonObject();
        object.put ("cmd", "login");
        object.put ("name", username);
        object.put ("pwd", pwd);
        object.put ("version", SERVER_VERSION);
        send (nilptr, object);
    }

    public bool connectServer() {
        if (started) {
            return true;
        }

        pluginMode = false;
        client = new StreamSocket();
        bool connect = false;

        try {
            connect = client.connect (SRVHost, SRVPort, 15000);
        } catch (Exception e) {

        }

        if (connect) {
            client.setTcpNoDelay(false);
            start();
            started = true;
            return true;
        }

        client.close();
        client = nilptr;
        return false;
    }

    public void setListener (MT5PluginsListener _listener) {
        listener = _listener;
    }

    XTraderExecuter xte = new XTraderExecuter() {
        bool modify (ExecuteResult er, int id, String tick, int type, float open, float sl, float tp, float vol) override {
            JsonObject object = new JsonObject();
            object.put ("cmd", type);
            object.put ("id", id);
            object.put ("tick", tick);
            object.put ("open", open);
            object.put ("sl", sl);
            object.put ("tp", tp);
            object.put ("vl", vol);
            return send (er, object);
        }
        bool createOrder (ExecuteResult er, int id, String symbol, int type, float open, float sl, float tp, float vol) override {
            JsonObject object = new JsonObject();
            object.put ("cmd", type);
            object.put ("id", id);
            object.put ("open", open);
            object.put ("sl", sl);
            object.put ("tp", tp);
            object.put ("vl", vol);
            object.put ("symbol", symbol);
            return send (er, object);
        }

        bool close (ExecuteResult er, int type, int id, String tick) override {
            JsonObject object = new JsonObject();
            object.put ("cmd", type);
            object.put ("id", id);
            object.put ("tick", tick);
            return send (er, object);
        }

        bool query (ExecuteResult er, int cmd, String symbol, String period) override{
            JsonObject object = new JsonObject();
            object.put ("cmd", cmd);
            object.put ("symbol", symbol);
            object.put ("param", period);
            return send (er, object);
        }
    };

    public XTraderExecuter getExecuter() {
        return xte;
    }

    public bool send (ExecuteResult er, JsonObject json) {
        String reqId = nilptr;


        if (client != nilptr) {
            if (er != nilptr) {
                reqId = "r" +  (++__request_serial);
                json.put ("reqId", reqId);
                synchronized (__responses) {
                    __responses.put (reqId, er);
                }
            }

            String content = json.toString (false);
            byte [] data  = ("\nlength:" +  content.length() + "\n" + content).getBytes();

            try {
                bool Succeed = false;

                if (reqId != nilptr) {
                    synchronized (er) {
                        synchronized (this) {
                            Succeed = (client.write (data, 0, data.length) != 0);
                        }

                        if (Succeed) {
                            er.wait();
                        }
                        synchronized (__responses) {
                            __responses.remove (reqId);
                        }
                    }
                } else {
                    synchronized (this) {
                        Succeed = (client.write (data, 0, data.length) != 0);
                    }
                }

                return Succeed;
            } catch (Exception e) {

            }

        }

        return false;
    }

    public static String AsGZip (String content) {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        GZipOutputStream gz = nilptr;

        try {
            gz = new GZipOutputStream (bos);
            byte [] data = content.getBytes();
            gz.write (data, 0, data.length);
            gz.finish();
        } catch (Exception e) {

        } finally {
            if (gz != nilptr) {
                gz.flush();
                gz.close();
            }
        }

        return Base64.encodeToString (bos.toByteArray(), false);
    }

    public static String unGZip (String content) {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        GZipInputStream gz = nilptr;

        try {
            byte [] data = Base64.decodeString (content);
            gz = new GZipInputStream (data, 0, data.length);
            data = new byte[32768];

            while (gz.available (true) > 0) {
                int len = gz.read (data, 0, 32768);

                if (len > 0) {
                    bos.write (data, 0, len);
                }
            }
        } catch (Exception e) {

        } finally {
            if (gz != nilptr) {
                gz.flush();
                gz.close();
            }
        }

        return new String (bos.toByteArray() );
    }

    public void onData (JsonObject json) {
        String reqId = json.getString ("reqId");

        if (TextUtils.isEmpty (reqId) == false) {
            synchronized (__responses) {
                ExecuteResult er = __responses.get (reqId);

                if (er != nilptr) {
                    synchronized (er) {
                        er.setResult (json);
                        er.notify();
                        return;
                    }
                }
            }
        }

        if (listener != nilptr) {
            listener.onData (json);
        }
    }

    public bool processClient() {
        String content = "";
        byte [] data = new byte[1024];
        int lengt = -1;

        while (!bQuit && client != nilptr && (lengt = client.read (data, 0, 1024) ) > 0) {
            content = content + new String (data, 0, lengt);

            bool bgzd = false;
            int n = content.indexOf ("\nlength:");
            int gzn = content.indexOf ("\ngzdlen:");

            if (gzn != -1 && gzn < n) {
                bgzd = true;
                n = gzn;
            }

            while (n >= 0) {
                int crlf = content.indexOf ("\n", n + 8);

                if (crlf > 0) {
                    int startPos = crlf + 1;
                    int length = content.substring (n + 8, crlf).parseInt();

                    if (length > 0 && length < MT5Plugins.MEG_MAXLEN)  {
                        int msgLen = content.length();

                        if (msgLen >= length + startPos) {
                            String json = content.substring (startPos, startPos + length);

                            try {
                                if (bgzd) {
                                    json = unGZip (json);
                                }

                                onData (new JsonObject (json) );
                            } catch (Exception e) {

                            }
                        } else {
                            break;
                        }
                    } else {
                        //获取到的数据长度小于0 , 说明数据错误
                        length = 0;
                    }

                    if (length + startPos == content.length() ) {
                        content = "";
                        break;
                    } else {
                        content = content.substring (length + startPos, content.length() );
                    }
                } else {
                    break;
                }

                n = content.indexOf ("\nlength:");
                gzn = content.indexOf ("\ngzdlen:");

                if (gzn != -1 && gzn < n) {
                    bgzd = true;
                    n = gzn;
                } else {
                    bgzd = false;
                }
            }
        }

        return false;
    }

    public void run() override {
        while (!bQuit) {
            if (pluginMode) {
                try {
                    if (false == processClient() && !bQuit) {
                        if (listener != nilptr) {
                            listener.onNetworError(pluginMode);
                        }
                        if (client != nilptr) {
                            client.close();
                            client = nilptr;
                            _system_.output ("已断开");
                        }

                        client = serverSocket.accept();

                        if (client != nilptr) {
                            client.setTcpNoDelay(false);
                            _system_.output ("已连接");
                            if (listener != nilptr) {
                                listener.onNetworReset(pluginMode);
                            }
                        }
                    }
                } catch (Exception e) {
                    if (listener != nilptr) {
                        listener.onNetworError(pluginMode);
                    }
                    if (client != nilptr) {
                        client.close();
                        client = nilptr;
                    }

                    client = serverSocket.accept();

                    if (client != nilptr) {
                        client.setTcpNoDelay(false);
                        _system_.output ("已连接");
                        if (listener != nilptr) {
                            listener.onNetworReset(pluginMode);
                        }
                    }
                }
            } else {
                try {
                    if (false == processClient() && !bQuit) {
                        bool success = false;

                        if (listener != nilptr) {
                            listener.onNetworError(pluginMode);
                        }

                        do {
                            if (client != nilptr) {
                                client.close();
                                client = nilptr;
                            }

                            client = new StreamSocket();

                            try {
                                success = client.connect (SRVHost, SRVPort, 15000);
                                if (success){
                                    client.setTcpNoDelay(false);
                                }
                            } catch (Exception e) {

                            }

                        } while (false ==  success && !bQuit);

                        if (listener != nilptr) {
                            listener.onNetworReset(pluginMode);
                        }
                    }
                } catch (Exception e) {

                    bool success = false;

                    if (listener != nilptr) {
                        listener.onNetworError(pluginMode);
                    }

                    do {
                        if (client != nilptr) {
                            client.close();
                            client = nilptr;
                        }

                        client = new StreamSocket();

                        try {
                            success = client.connect (SRVHost, SRVPort, 15000);
                            if (success){
                                client.setTcpNoDelay(false);
                            }
                        } catch (Exception e) {

                        }

                    } while (false ==  success && !bQuit);

                    if (listener != nilptr) {
                        listener.onNetworReset(pluginMode);
                    }
                }
            }
        }
    }
};