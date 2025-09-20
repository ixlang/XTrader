//xlang Source, Name:Arraw.x 
//Date: Wed Jul 21:27:05 2025 

class Arraw: DrawObject {

    QPointF start = new QPointF (0, 0);
    ControlPoint stpt = new ControlPoint();
    OBJECT_TYPE __type;
    QImage currentImage;
    QRect rect = new QRect(0, 0, 0, 0);
    int step = 1;
    public bool isNeedCross()override{
        return true;
    }
    public Arraw(OBJECT_TYPE dt){
        __type = dt;
        switch (__type) {
        	case OBJECT_TYPE.OBJECT_ARRAWUP: /*TODO*/
            currentImage = up;
        	break;
            case OBJECT_TYPE.OBJECT_ARRAWDOWN: /*TODO*/
            currentImage = down;
        	break;
            case OBJECT_TYPE.OBJECT_ARRAWLEFT: /*TODO*/
            currentImage = left;
        	break;
            default:
            currentImage = right;
        	break;
        }
    }
    public CommonConfigure getConfigure()override{return nilptr;}
    public void updateConfigure()override{
        // 更新配置
    }
    public void relocal(Vector<Bar> bars)override{}
    public static QImage up = new QImage (__xPackageResource ("./assets/res/toolbar/aup.png"), "png");
    public static QImage down = new QImage (__xPackageResource ("./assets/res/toolbar/adown.png"), "png");
    public static QImage left = new QImage (__xPackageResource ("./assets/res/toolbar/aleft.png"), "png");
    public static QImage right = new QImage (__xPackageResource ("./assets/res/toolbar/aright.png"), "png");
    
    bool bDown = false;
    
    public OBJECT_TYPE getType() override{
        return __type;
    }
    
    public void onRemove (TradingView tv)override{}
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        return false;
    }
    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
        canvas.setAntialiasing(true);
        float lr = 10.0 / xzoom, tr = 10.0 / yzoom, l , t ;
        
        switch (__type) {
        	case OBJECT_TYPE.OBJECT_ARRAWUP: 
                l = (start.x - lr) * xzoom;
                t = h - start.y * yzoom;
        	break;
            case OBJECT_TYPE.OBJECT_ARRAWDOWN:  
                l = (start.x - lr) * xzoom;
                t = h - (start.y + tr * 2) * yzoom;
        	break;
            case OBJECT_TYPE.OBJECT_ARRAWLEFT: 
                t = h - (start.y + tr)* yzoom;
                l = start.x * xzoom;
        	break;
            case OBJECT_TYPE.OBJECT_ARRAWRIGHT: 
                t = h - (start.y + tr)* yzoom;
                l = (start.x - lr * 2) * xzoom;
        	break;
        }
        
        rect.left = l;
        rect.top = t;
        rect.right = l + 20;
        rect.bottom = t + 20;
        
        canvas.drawImage(currentImage, l, t);
    }

    public bool onMouseButtonRelease (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        if (bDown) {
            bDown = false;
            tv.setCursor (Constant.CrossCursor);
            return true;
        }
        return false;
    }

    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        if (bDown){
            start.x = time;
            start.y = Price;
            return true;
        }
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();
        if (rect.contains (x, y) ) {
            tv.setCursor (Constant.PointingHandCursor);
            return true;
        } 
        return false;
    }
    
    public void setPosition(long time, float price){
        start.x = time;
        start.y = price;
        step = 0;
    }

    public bool onMouseButtonPress (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();

        if (step == 1) {
            start.x = time;
            start.y = Price;
            step = 0;
            tv.endDraw();
            return true;
        } else if (rect.contains (x, y) ) {
            bDown = true;
            return true;
        } 
        return false;
    }
};