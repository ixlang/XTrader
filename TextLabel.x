//xlang Source, Name:TextLabel.x 
//Date: Sun Aug 16:34:29 2025 

class TextLabel: public DrawObject {
    int step = -1;
    QPointF start = new QPointF (0, 0), oldStart = new QPointF (0, 0);

    int over = -1;
    ControlPoint stpt = new ControlPoint();
    long xtrs = 0;
    float ytrs = 0;
    String  szText = "Text", szFont = nilptr;
    QFont fFont = nilptr;
    int color = 0xff2962FF;
    int basePt = 0;
    QImage cache = nilptr;
    float tw = 0, th = 0;
    CommonConfigure configure = new CommonConfigure();

    public OBJECT_TYPE getType() override{
        return OBJECT_TYPE.OBJECT_TEXT;
    }
    public bool isNeedCross()override {
        return true;
    }
    public TextLabel() {
        String[] szPos = new String[]{"左上","右上","左下","右下"};
        configure.setConfig ("text", CFG_DATA_TYPE.STRING, "文本内容", nilptr, szText);
        configure.setConfig ("basept", CFG_DATA_TYPE.OPTIONS, "基点", szPos, szPos[basePt]);
        configure.setConfig ("color", CFG_DATA_TYPE.COLOR, "颜色", nilptr, color);
        configure.setConfig ("font", CFG_DATA_TYPE.FONT, "字体", nilptr, szFont);
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
        szText = configure.getString("text");
        color = configure.getInt("color");
        szFont = configure.getString("font");
        basePt = new String[]{"左上","右上","左下","右下"}.indexOf(configure.getString("basept"));
        if (basePt < 0 || basePt > 3){
            basePt = 0;
        }
        fFont = QFont.loadFromString(szFont);
        
        bool savedef = configure.getBool("savedef");
        
        if (savedef){
            JsonObject result = configure.buildResult();
            if (result != nilptr){
                Preference.setSetting("fibonacci", result.toString(false));
            }
        }
        if (fFont == nilptr){
            fFont = getDefaultFont();
        }
        QRect rc = fFont.measure(szText);
        cache = new QImage(rc.width(), rc.height(), QImage.Format_ARGB32);
        QPainter canvas = new QPainter(cache);
        canvas.setFont(fFont);
    
        canvas.setPen(color);
        canvas.drawText(szText, rc, Constant.AlignCenter);
        canvas = nilptr;
        tw = rc.width();
        th = rc.height();
        
    }
    
    QFont getDefaultFont(){
        QImage tc = new QImage(3, 3, QImage.Format_ARGB32);
        QPainter _canvas = new QPainter(tc);
        QFont _tf = _canvas.getFont();
        _canvas = nilptr;
        return _tf;
    }
    
    public void onRemove (TradingView tv) override{}
    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
        float x = start.x * xzoom, y = h - start.y * yzoom;
        
        if (cache != nilptr){
            switch (basePt) {
                case 1: /*TODO*/
                x = (start.x + tw) * xzoom - tw;
                canvas.drawImage(cache, x, y);
                stpt.drawAt (canvas, x + tw, y, over == 0);
            	break;
                case 2: /*TODO*/
                y = h - (start.y + th) * yzoom - th;
                canvas.drawImage(cache, x, y);
                stpt.drawAt (canvas, x, y + th, over == 0);
            	break;
                case 3: /*TODO*/
                x = (start.x + tw) * xzoom - tw;
                y = h - (start.y + th) * yzoom - th;
                canvas.drawImage(cache, x, y);
                stpt.drawAt (canvas, x + tw, y + th, over == 0);
            	break;
            	default:
                canvas.drawImage(cache, x, y);
                stpt.drawAt (canvas, x, y, over == 0);
            	break;
            }
        }
    }
    
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        if (step != 0){
            return false;
        }
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();
        if (stpt.contains (x, y) ) {
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
    
    void showConfigure(TradingView tv){
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
    }
    
    public bool onMouseButtonRelease (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        bool res = false;

        if (step != 0) {
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

        if (step == 1) {
            start.x = oldStart.x + (time - xtrs);
            start.y = oldStart.y + (Price - ytrs);
            return true;
        }

        if (stpt.contains (x, y) ) {
            if (over != 0) {
                over = 0;
                //tv.setCursor (Constant.PointingHandCursor);
                return true;
            }
        }  else{
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
            start.x = time;
            start.y = Price;
            showConfigure(tv);
            step = 0;
            if (TextUtils.isEmpty(szText)){
                tv.cancelDraw();
            }else{
                tv.endDraw();
            }
            return true;
        } 
        if (stpt.contains(x, y)){
            step = 1;
            xtrs = time;
            ytrs = Price;
            oldStart.x = start.x;
            oldStart.y = start.y;
            return true;
        }

        return false;
    }
};