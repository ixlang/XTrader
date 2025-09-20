//xlang Source, Name:HLine.x 
//Date: Sun Jul 00:23:11 2025 

class HLine : public DrawObject {
    float ytrs = 0;
    int color = 0xff2962FF;
    float lineWidth = 2;
    float liney = -1, my = -1, dy, oy;
    bool done = false, down = false;
    CommonConfigure configure = new CommonConfigure();
    public OBJECT_TYPE getType() override{
        return OBJECT_TYPE.OBJECT_HLINE;
    }
    public void onRemove (TradingView tv)override{}
    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
        float tx = - tv.getXTranslate();
        canvas.setPen (color, PenStyle.SolidLine, lineWidth);
        my = h - liney * yzoom;
        canvas.drawLine (0 + tx, my,  w + tx,  my );
    }
    public HLine(){
        configure.setConfig ("width", CFG_DATA_TYPE.FLOAT, "线宽", nilptr, lineWidth);
        configure.setConfig ("color", CFG_DATA_TYPE.COLOR, "颜色", nilptr, color);
        configure.setConfig ("savedef", CFG_DATA_TYPE.BOOL, "设为默认", nilptr, false);
        
        String szConf = Preference.getString("hline");
        if (TextUtils.isEmpty(szConf) == false){
            try{
            	JsonObject conf = new JsonObject(szConf);
                configure.loadResult(conf);
                updateConfigure();
            }catch(Exception e){
            	
            }
        }
    }
    public bool isNeedCross()override{
        return true;
    }
    public void relocal(Vector<Bar> bars)override{
        
    }
    public bool onMouseButtonRelease (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        if (down) {
            down = false;
            tv.setHideCross (false);
            return true;
        }

        return false;
    }
    public CommonConfigure getConfigure()override{return configure;}
    
    public void updateConfigure()override{
        lineWidth = configure.getFloat("width");
        color = configure.getInt("color");
        bool savedef = configure.getBool("savedef");
        if (savedef){
            JsonObject result = configure.buildResult();
            if (result != nilptr){
                Preference.setSetting("hline", result.toString(false));
            }
        }
    }
    
    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        if (down) {
            liney = oy + (Price - dy);
            return true;
        } else {
            y = y - tv.getYTranslate();

            if (y < my + 4 && y > my - 4) {
                tv.setCursor (Constant.SizeVerCursor);
                return true;
            }
        }

        return false;
    }

    public void setPrice(double price){
        liney = price;
        done = true;
    }
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        if (!done){
            return false;
        }
        y = y - tv.getYTranslate();
        if (y < my + 4 && y > my - 4) {
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
        if (!done) {
            liney = Price;
            tv.endDraw();
            done = true;
            return true;
        } else if (!down) {
            y = y - tv.getYTranslate();

            if (y < my + 4 && y > my - 4) {
                down = true;
                dy = Price;
                oy = liney;
                tv.setHideCross (true);
                return true;
            }
        }

        return false;
    }
};