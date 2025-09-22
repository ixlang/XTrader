//xlang Source, Name:Fibonacci.x
//Date: Sun Jul 00:22:51 2025

class Fibonacci : public DrawObject {
    int step = -1;
    QPointF start = new QPointF (0, 0), end = new QPointF (0, 0);
    QRect topbarrc = new QRect();
    QPointF ps = new QPointF (0, 0), pe = new QPointF (0, 0);
    bool bFill = false;
    
    float lineWidth = 2;
    
    int over = -1;
    ControlPoint stpt = new ControlPoint(), edpt = new ControlPoint();
    long xtrs = 0;
    float ytrs = 0;
    CommonConfigure configure = new CommonConfigure();
    static QImage topbar = new QImage (__xPackageResource ("./assets/res/toolbar/barrage_top.png"), "png");

    float [] seciont = {0.33, 0.5, 0.67};
    int [] color = {
        0xff00BCD4,
        0xff4CAF50,
        0xffF23645,
        0xffff8c00,
        0xffe81123,
        0xffd13438,
        0xffc30052,
        0xffbf0077,
        0xff9a0089,
        0xff881798,
        0xff744da9,
        0xff10893e,
        0xff107c10,
        0xff018574,
        0xff2d7d9a,
        0xff0063b1,
        0xff6b69d6,
        0xff8e8cd8,
        0xff8764b8,
        0xff038387,
        0xff486860,
        0xff525e54
    };

    public OBJECT_TYPE getType() override{
        return OBJECT_TYPE.OBJECT_FB;
    }
    public bool isNeedCross() override{
        return true;
    }
    public Fibonacci() {
        configure.setConfig ("fibwidth", CFG_DATA_TYPE.FLOAT, "线宽", nilptr, lineWidth);
        configure.setConfig ("isfill", CFG_DATA_TYPE.BOOL, "填充", nilptr, bFill);

        for (int i = 0; i < 12 ; i++) {
            float fv = 0;

            if (i < seciont.length) {
                fv = seciont[i];
            }

            configure.setConfig ("fb" + i, CFG_DATA_TYPE.FLOAT, "回撤点" + (i + 1), nilptr, fv);
        }
        configure.setConfig ("savedef", CFG_DATA_TYPE.BOOL, "设为默认", nilptr, false);
        
        String szConf = Preference.getString("fibonacci");
        if (TextUtils.isEmpty(szConf) == false){
            try{
            	JsonObject conf = new JsonObject(szConf);
                configure.loadResult(conf);
                updateConfigure();
            }catch(Exception e){
            	
            }
        }
    }
    public void relocal (Vector<Bar> bars) override{
        
    }
    public CommonConfigure getConfigure() override{
        return configure;
    }
    public void updateConfigure() override{
        lineWidth = configure.getFloat("fibwidth");
        bFill = configure.getBool("isfill");
        bool savedef = configure.getBool("savedef");
        
        Vector<float> lfis = new Vector<float>();
        
        for (int i = 0; i < 12 ; i++) {
            float fv = configure.getFloat("fb" + i);
            if (fv > 0) {
                lfis.add(fv);
            }
        }
        
        seciont = lfis.toArray(new float[0]);
        if (savedef){
            JsonObject result = configure.buildResult();
            if (result != nilptr){
                Preference.setSetting("fibonacci", result.toString(false));
            }
        }
    }
    public void onRemove (TradingView tv) override{}
    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
        float lw = lineWidth;
        canvas.setPen (0xff808080, PenStyle.SolidLine, lw);
        float height = end.y - start.y;

        float x = start.x * xzoom, y = h - start.y * yzoom, r = end.x  * xzoom;

        canvas.drawText ("0.0", x, y - 2);
        canvas.drawLine (x, y,  r,  y );
        float sy = y, ny;

        for (int i = 0; i < seciont.length; i++) {
            ny = h - (start.y + height * seciont[i]) * yzoom;

            if (bFill) {
                canvas.fillRect (x, sy, r - x, ny - sy, 0x1f000000 | (color[i] & 0xffffff), QBrush.Style.SolidPattern);
            }

            sy = ny;
            canvas.setPen (color[i], PenStyle.SolidLine, lw);
            canvas.drawText ("" + seciont[i], x, sy - 2);
            canvas.drawLine (x, sy,  r,  sy);
        }

        ny = h - (start.y + height) * yzoom;

        if (bFill) {
            canvas.fillRect (x, sy, r - x, ny - sy, 0x1f000000 | (0xff808080 & 0xffffff), QBrush.Style.SolidPattern);
        }

        canvas.setPen (0xff808080, PenStyle.SolidLine, lw);
        canvas.drawText ("1.0", x, (h - end.y * yzoom ) - 2);
        canvas.drawLine (x, h - end.y * yzoom,  r,  h - end.y * yzoom);

        stpt.drawAt (canvas, start.x * xzoom, (h - start.y * yzoom), over == 0);
        edpt.drawAt (canvas, end.x * xzoom, (h - end.y * yzoom), over == 1);

        topbarrc = TradingView.drawImageOnCenter (canvas, topbar, (x + r) / 2 + 16, y, 32, 14);
    }
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        if (step != 0){
            return false;
        }
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();
        if (stpt.contains (x, y) || edpt.contains (x, y) ) {
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
        } else if (topbarrc.contains (x, y) ) {
            tv.setCursor (Constant.PointingHandCursor);
            return true;
        }

        if (stpt.contains (x, y) ) {
            if (over != 0) {
                over = 0;
                //tv.setCursor (Constant.PointingHandCursor);
                return true;
            }
        } else if (edpt.contains (x, y) ) {
            if (over != 1) {
                over = 1;
                //tv.setCursor (Constant.PointingHandCursor);
                return true;
            }
        } else {
            if (over != -1) {
                over = -1;
                //tv.setCursor (Constant.CrossCursor);
                return true;
            }
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
            end.x = time;
            end.y = Price;
            step = 2;
            tv.endDraw();
            return true;
        } else if (stpt.contains (x, y) ) {
            step = 3;
            return true;
        } else if (edpt.contains (x, y) ) {
            step = 4;
            return true;
        } else if (topbarrc.contains (x, y) ) {
            step = 5;

            ps.x = start.x;
            ps.y = start.y;

            pe.x = end.x;
            pe.y = end.y;

            prevx = time;
            prevy = Price;
            return true;
        }

        return false;
    }
};