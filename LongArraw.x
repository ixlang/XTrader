//xlang Source, Name:LongArraw.x 
//Date: Sun Aug 17:51:57 2025 

class LongArraw: DrawObject {
    int step = -1;

    QPointF start = new QPointF (0, 0), end = new QPointF (0, 0);

    ControlPoint stpt = new ControlPoint(), edpt = new ControlPoint();
    QPointF ps = new QPointF (0, 0), pe = new QPointF (0, 0);
    CommonConfigure configure = new CommonConfigure();
    int over = -1;
    
    long xtrs = 0;
    float ytrs = 0;
    long start_time = 0, end_time = 0;
    float lineWidth = 2;
    int color = 0xff2962FF;


    static float arrowSize = 20, arrowAngleDeg = 30;
    public bool isNeedCross()override{
        return true;
    }
    public OBJECT_TYPE getType() override{
        return OBJECT_TYPE.OBJECT_LINTETO;
    }
    public void onRemove (TradingView tv)override{}
    public LongArraw() {
        configure.setConfig ("width", CFG_DATA_TYPE.FLOAT, "线宽", nilptr, lineWidth);
        configure.setConfig ("color", CFG_DATA_TYPE.COLOR, "颜色", nilptr, color);
        configure.setConfig ("arrowSize", CFG_DATA_TYPE.FLOAT, "箭翼大小", nilptr, arrowSize);
        configure.setConfig ("arrowAngleDeg", CFG_DATA_TYPE.FLOAT, "箭翼角度", nilptr, arrowAngleDeg);
        configure.setConfig ("savedef", CFG_DATA_TYPE.BOOL, "设为默认", nilptr, false);
        
        String szConf = Preference.getString("larraw");
        if (TextUtils.isEmpty(szConf) == false){
            try{
            	JsonObject conf = new JsonObject(szConf);
                configure.loadResult(conf);
                updateConfigure();
            }catch(Exception e){
            	
            }
        }
    }
    
    public void relocal(Vector<Bar> bars)override{}
    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
        canvas.setAntialiasing(true);
        canvas.setPen (color, PenStyle.SolidLine, lineWidth);
        float l = start.x * xzoom, t = h - start.y * yzoom, r = end.x  * xzoom, b = h - end.y * yzoom;
        canvas.drawLine (l, t,  r,  b);
        // 计算方向角
        double angle = Math.atan2(b - t, r - l);

        // 角度转弧度
        double rad = arrowAngleDeg * Math.PI / 180.0;

        // 箭头两翼点
        float p1x = r - Math.cos(angle - rad) * arrowSize, p1y = b - Math.sin(angle - rad) * arrowSize,
        p2x = r - Math.cos(angle + rad) * arrowSize, p2y = b - Math.sin(angle + rad) * arrowSize;
        
        // 用直线画箭头两翼
        canvas.drawLine(r, b, p1x , p1y);
        canvas.drawLine(r, b, p2x , p2y);
        
        stpt.drawAt(canvas, l, t, over == 0);
        edpt.drawAt(canvas, r, b, over == 1);
    }
    public CommonConfigure getConfigure()override{return configure;}
    public void updateConfigure()override{
        lineWidth = configure.getFloat("width");
        arrowSize = configure.getFloat("arrowSize");
        arrowAngleDeg = configure.getFloat("arrowAngleDeg");
        color = configure.getInt("color");
        bool savedef = configure.getBool("savedef");
        if (savedef){
            JsonObject result = configure.buildResult();
            if (result != nilptr){
                Preference.setSetting("larraw", result.toString(false));
            }
        }
    }
    public bool onMouseButtonRelease (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        bool res = false;

        if (step > 2) {
            step = 0;
            res = true;
        }

        if (over != -1) {
            over = -1;
            res = true;
            tv.setCursor (Constant.CrossCursor);
        }

        return res;
    }

    long prevx;
    float prevy;

    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();
        if (step == 5) {
            start.x = ps.x + (time - prevx);
            start.y = ps.y + (Price - prevy);
            end.x = pe.x + (time - prevx);
            end.y = pe.y + (Price - prevy);
            return true;
        } else if (step == 3) {
            start.x = time;
            start.y = Price;
            return true;
        } else if (step == 1 || step == 4) {
            end.x = time;
            end.y = Price;
            return true;
        }

        if (stpt.contains (x, y) ) {
            if (over != 0) {
                over = 0;
                return true;
            }
        } else if (edpt.contains (x, y) ) {
            if (over != 1) {
                over = 1;
                return true;
            }
        } else{
            int ls = 0, re = 0;
            int base = 0;
            float rts = 0;
            QRect st_rc = stpt.Rect(), ed_rc = edpt.Rect();
            if (st_rc.left < ed_rc.left){
                ls = st_rc.right;
                re = ed_rc.left;
                base = st_rc.top;
                rts = ed_rc.top - st_rc.top;
            }else{
                ls = ed_rc.right;
                re = st_rc.left;
                base = ed_rc.top;
                rts = st_rc.top - ed_rc.top;
            }

            if (x > ls && x < re){
                float stdy = base + rts * (x - ls) / (float)(re - ls);
                if (y >= stdy && y <= stdy + 16){
                    tv.setCursor (Constant.PointingHandCursor);
                    return true;
                }
            }
            if (over != -1) {
                over = -1;
                return true;
            }
        }

        return false;
    }
    
    void endDraw(TradingView tv){
        tv.endDraw();
    }
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        if (step != 0){
            return false;
        }
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();
        if (stpt.contains (x, y) || edpt.contains (x, y)) {
            PropertyListener pl = new PropertyListener () {
                @NotNilptr
                String getSetting (String [] options, @NotNilptr String key) override{
                    String val = configure.getSetting(key);
                    if (options != nilptr){
                        return "" + options.indexOf(val);
                    }
                    return val;
                }
                bool setSetting (@NotNilptr String key, String val) override{
                    return configure.setSetting(key, val);
                }
            };
            ComponentConfigure.showConfigure(tv, configure.buildJsonobject(), pl);
            updateConfigure();
            return true;
        }   
        return false;
    }
    public bool onMouseButtonPress (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();

        if (step == -1) {
            end.x = start.x = time;
            end.y = start.y = Price;
            step = 1;
            return true;
        } else if (step == 1) {
            if (start.x == time){
                return false;
            }
            end.x = time;
            end.y = Price;
            step = 2;
            endDraw(tv);
            return true;
        } else if (stpt.contains (x, y) ) {
            step = 3;
            return true;
        } else if (edpt.contains (x, y) ) {
            step = 4;
            return true;
        } else{
            int ls = 0, re = 0;
            
            int base = 0;
            float rts = 0;
            QRect st_rc = stpt.Rect(), ed_rc = edpt.Rect();
            
            if (st_rc.left < ed_rc.left){
                ls = st_rc.right;
                re = ed_rc.left;
                base = st_rc.top;
                rts = ed_rc.top - st_rc.top;
            }else{
                ls = ed_rc.right;
                re = st_rc.left;
                base = ed_rc.top;
                rts = st_rc.top - ed_rc.top;
            }

            if (x > ls && x < re){
                float stdy = base + rts * (x - ls) / (float)(re - ls);
                if (y >= stdy && y <= stdy + 16){
                    ps.x = start.x;
                    ps.y = start.y;
                    pe.x = end.x;
                    pe.y = end.y;
                    prevx = time;
                    prevy = Price;
                    step = 5;
                    return true;
                }
            }
        }
        return false;
    }
};