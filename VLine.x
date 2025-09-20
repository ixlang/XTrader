//xlang Source, Name:VLine.x 
//Date: Tue Jul 20:39:38 2025 

class VLine : public DrawObject {
    float ytrs = 0;
    int color = 0xff2962FF;
    float lineWidth = 2;
    float linex = -1, mx = -1, dx, ox;
    bool done = false, down = false;
    CommonConfigure configure = new CommonConfigure();
    public OBJECT_TYPE getType() override{
        return OBJECT_TYPE.OBJECT_VLINE;
    }
    
    public VLine(){
        configure.setConfig ("width", CFG_DATA_TYPE.FLOAT, "线宽", nilptr, lineWidth);
        configure.setConfig ("color", CFG_DATA_TYPE.COLOR, "颜色", nilptr, color);
        configure.setConfig ("savedef", CFG_DATA_TYPE.BOOL, "设为默认", nilptr, false);
        
        String szConf = Preference.getString("vline");
        if (TextUtils.isEmpty(szConf) == false){
            try{
            	JsonObject conf = new JsonObject(szConf);
                configure.loadResult(conf);
                updateConfigure();
            }catch(Exception e){
            	
            }
        }
    }
    
    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
        canvas.setPen (color, PenStyle.SolidLine, lineWidth);
        mx =  linex * xzoom ;
        canvas.drawLine (mx , - tv.getYTranslate(),  mx ,  h- tv.getYTranslate());
    }
    public bool isNeedCross()override{
        return true;
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

    public void relocal(Vector<Bar> bars)override{}
    public void onRemove (TradingView tv)override{}
    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        if (down) {
            linex = ox + (time - dx);
            return true;
        } else {
            x = x - tv.getXTranslate();

            if (x < mx + 4 && x > mx - 4) {
                tv.setCursor (Constant.SizeHorCursor);
                return true;
            }
        }

        return false;
    }
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        if (!done){
            return false;
        }
        x = x - tv.getXTranslate();
        if (x < mx + 4 && x > mx - 4) {
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
    public bool onMouseButtonPress (TradingView tv, int button, int x, int  y,  long time, float Price)override {
        if (!done) {
            linex = time;
            tv.endDraw();
            done = true;
            return true;
        } else if (!down) {
            x = x - tv.getXTranslate();

            if (x < mx + 4 && x > mx - 4) {
                down = true;
                dx = time;
                ox = linex;
                tv.setHideCross (true);
                return true;
            }
        }

        return false;
    }
};