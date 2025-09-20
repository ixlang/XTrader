//xlang Source, Name:DrawObject.x 
//Date: Sun Jul 00:24:16 2025 

enum OBJECT_TYPE {
    OBJECT_NONE,
    OBJECT_FB,
    OBJECT_HLINE,
    OBJECT_VLINE,
    OBJECT_XABCD,
    OBJECT_ABCD,
    OBJECT_ANDREW,
    OBJECT_BUTTON,
    OBJECT_TRENDLINE,
    OBJECT_ALARM,
    OBJECT_ARRAWUP,
    OBJECT_ARRAWDOWN,
    OBJECT_ARRAWLEFT,
    OBJECT_ARRAWRIGHT,
    OBJECT_TRIANGLE,
    OBJECT_CHANNEL,
    OBJECT_HISTROY,
    OBJECT_TEXT,
    OBJECT_LINTETO,
    OBJECT_SETTING
};

class DrawObject {
    public OBJECT_TYPE getType();
    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h);
    public bool onMouseButtonRelease (TradingView tv, int button, int x, int  y,  long time, float Price);
    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price) ;
    public bool onMouseButtonPress (TradingView tv, int button, int x, int  y,  long time, float Price);
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price);
    public void onRemove (TradingView tv);
    public bool isNeedCross();
    public void relocal(Vector<Bar> bars);
    public CommonConfigure getConfigure();
    public void updateConfigure();
};