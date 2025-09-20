//xlang Source, Name:HisIndic.x 
//Date: Thu Jul 06:40:54 2025 

class HisIndic : DrawObject {

    QPointF open = new QPointF (0, 0), close = new QPointF (0, 0);
    
    public static QImage ssl = new QImage (__xPackageResource ("./assets/res/toolbar/ssl.png"), "png");
    public static QImage ssr = new QImage (__xPackageResource ("./assets/res/toolbar/ssr.png"), "png");
    public static QImage sll = new QImage (__xPackageResource ("./assets/res/toolbar/sll.png"), "png");
    public static QImage slr = new QImage (__xPackageResource ("./assets/res/toolbar/slr.png"), "png");
    

    bool blong = false;
    double profit;
    public bool isNeedCross()override{
        return false;
    }
    
    public void relocal(Vector<Bar> bars)override{
        
    }
    public CommonConfigure getConfigure()override{return nilptr;}
    public void updateConfigure()override{}
    public void setup(long opentime, double openPrice, long closetime, double closeprice, bool _blong, double _profit){
        blong = _blong;
        open.x = opentime;
        open.y = openPrice;
        close.x = closetime;
        close.y = closeprice;
        profit = _profit;
    }
    
    public OBJECT_TYPE getType()override {
        return OBJECT_TYPE.OBJECT_HISTROY;
    }
    
    public void onRemove (TradingView tv)override{}
        
    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
        canvas.setAntialiasing(true);
        float lr = 12.0 / xzoom, tr = 12.0 / yzoom;
        canvas.setPen (blong ? 0xff2962FF : 0xffff0000, PenStyle.DashLine, 1);
        
        double hbw = tv.getBarWidth() / 2.0;
        
        float l = (open.x  + hbw) * xzoom, t = h - open.y * yzoom, r = (close.x  + hbw)  * xzoom, b = h - close.y * yzoom;
        canvas.drawLine (l, t,  r,  b);
        
        double lt = h + 6 - (open.y + tr) * yzoom, ll = (open.x + hbw - lr) * xzoom;
        double rt = h + 6 - (close.y + tr) * yzoom, rl = (close.x + hbw) * xzoom;
         
        if (blong){
            canvas.drawImage(sll, ll, lt);
            canvas.drawImage(ssr, rl, rt);
        }else{
            canvas.drawImage(ssl, ll, lt);
            canvas.drawImage(slr, rl, rt);
        }
    }
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        return false;
    }
    
    public bool onMouseButtonRelease (TradingView tv, int button, int x, int  y,  long time, float Price)override {
        return false;
    }

    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price)override {
        return false;
    }

    public bool onMouseButtonPress (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        return false;
    }
};