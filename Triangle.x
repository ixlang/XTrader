//xlang Source, Name:Triangle.x 
//Date: Thu Jul 18:50:43 2025 

class Triangle: DrawObject {
    int step = 0;

    QPointF px = new QPointF (0, 0), pa = new QPointF (0, 0), pb = new QPointF (0, 0), pc = new QPointF (0, 0);

    QPainter.Paint paint = new QPainter.Paint(), PtPaint = new QPainter.Paint();
    ControlPoint ptx = new ControlPoint(), pta = new ControlPoint(), ptb = new ControlPoint(), ptc = new ControlPoint(), ptm = new ControlPoint();
    CommonConfigure configure = new CommonConfigure();
    int over = -1;
    float lineWidth = 2;
    int color = 0xff2962FF;
    
    long prevx, xof;
    float prevy, yof;

    public OBJECT_TYPE getType() override{
        return OBJECT_TYPE.OBJECT_TRIANGLE;
    }
    public void onRemove (TradingView tv) override{}
        
    public Triangle() {
        paint.setColor (0xff6C80F3);
        paint.setStyle (QPainter.Paint.FILL_AND_STROKE);
        PtPaint.setColor (0xff2962FF);
        PtPaint.setStyle (QPainter.Paint.FILL_AND_STROKE);
        
        configure.setConfig ("width", CFG_DATA_TYPE.FLOAT, "线宽", nilptr, lineWidth);
        configure.setConfig ("color", CFG_DATA_TYPE.COLOR, "颜色", nilptr, color);
        configure.setConfig ("savedef", CFG_DATA_TYPE.BOOL, "设为默认", nilptr, false);
        
        String szConf = Preference.getString("triangle");
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
                Preference.setSetting("triangle", result.toString(false));
            }
        }
    }
    public void relocal(Vector<Bar> bars)override{}
    QPointF calculateIntersection(QPointF p1, QPointF p2, QPointF p3, QPointF p4) {
        // 计算第一条直线的斜率和截距 (y = a1x + b1)
        double a1 = (p2.y - p1.y) / (p2.x - p1.x);
        double b1 = p1.y - a1 * p1.x;
        
        // 计算第二条直线的斜率和截距 (y = a2x + b2)
        double a2 = (p4.y - p3.y) / (p4.x - p3.x);
        double b2 = p3.y - a2 * p3.x;
        
        // 检查是否平行
        if (a1 == a2) {
            return nilptr;
        }
        
        // 计算交点坐标
        double x = (b2 - b1) / (a1 - a2);
        double y = a1 * x + b1;
        
        return new QPointF(x, y);
    }
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        if (step != -1){
            return false;
        }
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();
        if (ptx.contains (x, y) ||pta.contains (x, y) ||ptb.contains (x, y) ||ptc.contains (x, y) || ptm.contains (x, y) ) {
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
    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
        canvas.setAntialiasing (true);
        canvas.setPen (color, PenStyle.SolidLine, lineWidth);
        if (step == 8){
            canvas.translate(xof * xzoom, -yof * yzoom);
        }
        QPointF pz = calculateIntersection(px, pb, pa, pc);
        if (pz != nilptr){    
            canvas.drawLine (px.x * xzoom, h - px.y * yzoom,  pz.x * xzoom,  h - pz.y * yzoom);
            canvas.drawLine (pa.x * xzoom, h - pa.y * yzoom,  pz.x * xzoom,  h - pz.y * yzoom);
            canvas.drawLine (px.x * xzoom, h - px.y * yzoom,  pa.x * xzoom,  h - pa.y * yzoom);
            
            canvas.setPen (color, PenStyle.DotLine, 1);
            canvas.drawLine (pa.x * xzoom, h - pa.y * yzoom,  pb.x * xzoom,  h - pb.y * yzoom);
            canvas.drawLine (pb.x * xzoom, h - pb.y * yzoom,  pc.x * xzoom,  h - pc.y * yzoom);
            
            ptx.drawAt (canvas, px.x * xzoom, h - px.y * yzoom, over == 0);
            pta.drawAt (canvas, pa.x * xzoom, h - pa.y * yzoom, over == 1);
            ptb.drawAt (canvas, pb.x * xzoom, h - pb.y * yzoom, over == 2);
            ptc.drawAt (canvas, pc.x * xzoom, h - pc.y * yzoom, over == 3);
            ptm.drawAt (canvas, pz.x * xzoom,  h - pz.y * yzoom, over == 4);
        }
        if (step == 8){
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

        if (step > 3) {
            if (step == 8){
                px.x += xof;
                px.y += yof;
                
                pa.x += xof;
                pa.y += yof;
                
                pb.x += xof;
                pb.y += yof;
                
                pc.x += xof;
                pc.y += yof;
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

    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price)override {
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();

        switch (step) {
        case 0: /*TODO*/
            px.x = pa.x = pb.x = pc.x = time;
            px.y = pa.y = pb.y = pc.y = Price;
            return true;
            break;

        case 1: /*TODO*/
            pa.x = pb.x = pc.x = time;
            pa.y = pb.y = pc.y = Price;
            return true;
            break;

        case 2: /*TODO*/
            pb.x = pc.x = time;
            pb.y = pc.y = Price;
            return true;
            break;

        case 3: /*TODO*/
            pc.x = time;
            pc.y = Price;
            return true;
            break;

        case 4: /*TODO*/
            px.x = time;
            px.y = Price;
            return true;
            break;

        case 5: /*TODO*/
            pa.x = time;
            pa.y = Price;
            return true;
            break;

        case 6: /*TODO*/
            pb.x = time;
            pb.y = Price;
            return true;
            break;

        case 7: /*TODO*/
            pc.x = time;
            pc.y = Price;
            return true;
            break;
            
         case 8: /*TODO*/
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
        }  else if (ptc.contains (x, y) ) {
            if (over != 3) {
                over = 3;
                return true;
            }
        }  else if (ptm.contains (x, y) ) {
            if (over != 4) {
                over = 4;
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

    public bool onMouseButtonPress (TradingView tv, int button, int x, int  y,  long time, float Price)override {
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();

        if (step == 0) {
            px.x = pa.x = pb.x = pc.x = time;
            px.y = pa.y = pb.y = pc.y = Price;
            step = 1;
            return true;
        } else if (step == 1) {
            pa.x = pb.x = pc.x = time;
            pa.y = pb.y = pc.y = Price;
            step = 2;
            return true;
        } else if (step == 2) {
            pb.x = pc.x = time;
            pb.y = pc.y = Price;
            step = 3;
            return true;
        }  else if (step == 3) {
            pc.x = time;
            pc.y = Price;
            step = -1;
            tv.endDraw();
            return true;
        }  else if (ptx.contains (x, y) ) {
            step = 4;
            return true;
        } else if (pta.contains (x, y) ) {
            step = 5;
            return true;
        }  else if (ptb.contains (x, y) ) {
            step = 6;
            return true;
        }  else if (ptc.contains (x, y) ) {
            step = 7;
            return true;
        }    else if (ptm.contains (x, y) ) {
            prevx = time;
            prevy = Price;
            xof = 0;yof = 0;
            step = 8;
            return true;
        }  

        return false;
    }

};