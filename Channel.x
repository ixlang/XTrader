//xlang Source, Name:Channel.x 
//Date: Thu Jul 20:21:36 2025 

class Channel: DrawObject {
    int step = 0;

    QPointF px = new QPointF (0, 0), pa = new QPointF (0, 0), pb = new QPointF (0, 0);

    QPainter.Paint paint = new QPainter.Paint(), PtPaint = new QPainter.Paint();
    ControlPoint ptx = new ControlPoint(), pta = new ControlPoint(), ptb = new ControlPoint(), ptm = new ControlPoint();
    long prevx, xof;
    float prevy, yof;
    
    int over = -1;

    long xtrs = 0;
    float ytrs = 0;
    float lineWidth = 2;

    float [] seciont = {0.33, 0.5, 0.67};
    int [] color = {
        0xff2962FF,
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
    
    CommonConfigure configure = new CommonConfigure();
    public CommonConfigure getConfigure()override{return configure;}
    public void updateConfigure()override{
        lineWidth = configure.getFloat("fibwidth");
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
                Preference.setSetting("channel", result.toString(false));
            }
        }
    }
    public OBJECT_TYPE getType() override{
        return OBJECT_TYPE.OBJECT_CHANNEL;
    }
    public void onRemove (TradingView tv) override{}
    public bool isNeedCross()override{
        return false;
    }
    public void relocal(Vector<Bar> bars)override{}
    public Channel() {
        paint.setColor (0xff6C80F3);
        paint.setStyle (QPainter.Paint.FILL_AND_STROKE);
        PtPaint.setColor (0xff2962FF);
        PtPaint.setStyle (QPainter.Paint.FILL_AND_STROKE);
        ptm.setColor(0xff65400A);
        
        configure.setConfig ("fibwidth", CFG_DATA_TYPE.FLOAT, "线宽", nilptr, lineWidth);

        for (int i = 0; i < 12 ; i++) {
            float fv = 0;

            if (i < seciont.length) {
                fv = seciont[i];
            }

            configure.setConfig ("fb" + i, CFG_DATA_TYPE.FLOAT, "回撤点" + (i + 1), nilptr, fv);
        }
        configure.setConfig ("savedef", CFG_DATA_TYPE.BOOL, "设为默认", nilptr, false);
        
        String szConf = Preference.getString("channel");
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
        canvas.setAntialiasing (true);
        canvas.setPen (color[0], PenStyle.SolidLine, lineWidth);
        if (step == 6){
            canvas.translate(xof * xzoom, -yof * yzoom);
        }
        double zx = ((pa.x - px.x) + pb.x)  * xzoom, zy = h - ((pa.y - px.y) + pb.y) * yzoom;
        
        canvas.drawLine (px.x * xzoom, h - px.y * yzoom,  pa.x * xzoom,  h - pa.y * yzoom);
        canvas.drawLine (pb.x * xzoom, h - pb.y * yzoom,  zx,  zy);
        int i = 0 ;
        for (i = 0; i < seciont.length; i++){
            double xhd = (pb.x - px.x) * seciont[i], yhd = (pb.y - px.y) * seciont[i];
            double mx = (xhd + px.x)  * xzoom, my = h - (yhd + px.y) * yzoom;
            canvas.setPen (color[i + 1], PenStyle.DashDotDotLine, lineWidth);
            canvas.drawLine (mx , my,  (pa.x + xhd) * xzoom,  h - (yhd + pa.y) * yzoom);
            drawTextOnPoint(canvas, "" + seciont[i], mx - 20, my);
        }
        i++;
        canvas.setPen (color[i + 1], PenStyle.DotLine, lineWidth);
        canvas.drawLine (px.x * xzoom, h - px.y * yzoom,  pb.x * xzoom,  h - pb.y * yzoom);
        canvas.drawLine (pa.x * xzoom, h - pa.y * yzoom,  zx,  zy);
        
        
        ptx.drawAt (canvas, px.x * xzoom, h - px.y * yzoom, over == 0);
        pta.drawAt (canvas, pa.x * xzoom, h - pa.y * yzoom, over == 1);
        ptb.drawAt (canvas, pb.x * xzoom, h - pb.y * yzoom, over == 2);
        ptm.drawAt (canvas, zx,  zy, over == 3);
        if (step == 6){
            canvas.translate(-xof * xzoom, yof * yzoom);
        }
        canvas.setAntialiasing (false);
    }
    
    public void drawTextOnPoint (QPainter canvas, String txt, int x, int y) {
        QRect rect = canvas.measureText (0, 0, txt);
        rect.extend (10, 4);
        rect.offset (x - (rect.width() / 2), y - (rect.height() / 2) );
        canvas.drawRoundedRect (rect, 3, 3, PtPaint);
        canvas.setPen (0xffffffff);
        canvas.drawText (txt, rect, Constant.AlignVCenter | Constant.AlignHCenter);
    }

    public bool onMouseButtonRelease (TradingView tv, int button, int x, int  y,  long time, float Price)override {
        bool res = false;

        if (step > 2) {
            if (step == 6){
                px.x += xof;
                px.y += yof;
                
                pa.x += xof;
                pa.y += yof;
                
                pb.x += xof;
                pb.y += yof;
            }
            step = -1;
            res = true;
        }

        if (over != -1) {
            over = -1;
            res = true;
            tv.setCursor (Constant.CrossCursor);
        }

        return res;
    }



    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();

        switch (step) {
        case 0: /*TODO*/
            px.x = pa.x = pb.x = time;
            px.y = pa.y = pb.y = Price;
            return true;
            break;

        case 1: /*TODO*/
            pa.x = pb.x = time;
            pa.y = pb.y = Price;
            return true;
            break;

        case 2: /*TODO*/
            pb.x = time;
            pb.y = Price;
            return true;
            break;

        case 3: /*TODO*/
            px.x = time;
            px.y = Price;
            return true;
            break;

        case 4: /*TODO*/
            pa.x = time;
            pa.y = Price;
            return true;
            break;

        case 5: /*TODO*/
            pb.x = time;
            pb.y = Price;
            return true;
            break;
         case 6: /*TODO*/
            xof = time - prevx;
            yof = Price - prevy;
            return true;
            break;
        }

        if (ptx.contains (x, y) ) {
            if (over != 0) {
                over = 0;
                return true;
            }
        } else if (pta.contains (x, y) ) {
            if (over != 1) {
                over = 1;
                return true;
            }
        }  else if (ptb.contains (x, y) ) {
            if (over != 2) {
                over = 2;
                return true;
            }
        }  else if (ptm.contains (x, y) ) {
            if (over != 3) {
                over = 3;
                return true;
            }
        }  else {
            if (over != -1) {
                over = -1;
                return true;
            }
        }

        return false;
    }

    public bool onMouseButtonPress (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();

        if (step == 0) {
            px.x = pa.x = pb.x = time;
            px.y = pa.y = pb.y = Price;
            step = 1;
            return true;
        } else if (step == 1) {
            pa.x = pb.x = time;
            pa.y = pb.y = Price;
            step = 2;
            return true;
        } else if (step == 2) {
            pb.x = time;
            pb.y = Price;
            step = -1;
            tv.endDraw();
            return true;
        }  else if (ptx.contains (x, y) ) {
            step = 3;
            return true;
        } else if (pta.contains (x, y) ) {
            step = 4;
            return true;
        }  else if (ptb.contains (x, y) ) {
            step = 5;
            return true;
        } else if (ptm.contains (x, y) ) {
            prevx = time;
            prevy = Price;
            xof = 0;yof = 0;
            step = 6;
            return true;
        }   
        return false;
    }
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        if (step != -1){
            return false;
        }
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();
        if (ptx.contains (x, y) || pta.contains (x, y) || ptb.contains (x, y) || ptm.contains (x, y) ) {
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
};