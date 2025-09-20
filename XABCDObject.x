//xlang Source, Name:XABCDObject.x
//Date: Sun Jul 00:25:11 2025

class XABCDObject : DrawObject {
    int step = 0;

    QPointF px = new QPointF (0, 0), pa = new QPointF (0, 0), pb = new QPointF (0, 0), pc = new QPointF (0, 0), pd = new QPointF (0, 0);

    QPainter.Paint paint = new QPainter.Paint(), PtPaint = new QPainter.Paint();
    ControlPoint ptx = new ControlPoint(), pta = new ControlPoint(), ptb = new ControlPoint(), ptc = new ControlPoint(), ptd = new ControlPoint();

    int over = -1;

    long xtrs = 0;
    float ytrs = 0;
    CommonConfigure configure = new CommonConfigure();
    int color = 0xff2962FF;
    float lineWidth = 2;

    public OBJECT_TYPE getType() override{
        return OBJECT_TYPE.OBJECT_XABCD;
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
                Preference.setSetting("xabcd", result.toString(false));
            }
        }
    }
    public void onRemove (TradingView tv) override{}
    public XABCDObject() {
        paint.setColor (0xff6C80F3);
        paint.setStyle (QPainter.Paint.FILL_AND_STROKE);
        PtPaint.setColor (0xff2962FF);
        PtPaint.setStyle (QPainter.Paint.FILL_AND_STROKE);
        
        configure.setConfig ("width", CFG_DATA_TYPE.FLOAT, "线宽", nilptr, lineWidth);
        configure.setConfig ("color", CFG_DATA_TYPE.COLOR, "颜色", nilptr, color);
        configure.setConfig ("savedef", CFG_DATA_TYPE.BOOL, "设为默认", nilptr, false);
        
        String szConf = Preference.getString("xabcd");
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
    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h)override{
        canvas.setAntialiasing (true);
        canvas.setPen (color, PenStyle.SolidLine, lineWidth);

        canvas.drawLine (px.x * xzoom, h - px.y * yzoom,  pa.x * xzoom,  h - pa.y * yzoom);
        canvas.drawLine (pa.x * xzoom, h - pa.y * yzoom,  pb.x * xzoom,  h - pb.y * yzoom);
        canvas.drawLine (pb.x * xzoom, h - pb.y * yzoom,  pc.x * xzoom,  h - pc.y * yzoom);
        canvas.drawLine (pc.x * xzoom, h - pc.y * yzoom,  pd.x * xzoom,  h - pd.y * yzoom);

        canvas.setPen (color, PenStyle.DotLine, 1);
        canvas.drawLine (pb.x * xzoom, h - pb.y * yzoom,  pd.x * xzoom,  h - pd.y * yzoom);
        canvas.drawLine (px.x * xzoom, h - px.y * yzoom,  pb.x * xzoom,  h - pb.y * yzoom);
        canvas.drawLine (px.x * xzoom, h - px.y * yzoom,  pd.x * xzoom,  h - pd.y * yzoom);
        canvas.drawLine (pa.x * xzoom, h - pa.y * yzoom,  pc.x * xzoom,  h - pc.y * yzoom);

        ptx.drawAt (canvas, px.x * xzoom, h - px.y * yzoom, over == 0);
        pta.drawAt (canvas, pa.x * xzoom, h - pa.y * yzoom, over == 1);
        ptb.drawAt (canvas, pb.x * xzoom, h - pb.y * yzoom, over == 2);
        ptc.drawAt (canvas, pc.x * xzoom, h - pc.y * yzoom, over == 3);
        ptd.drawAt (canvas, pd.x * xzoom, h - pd.y * yzoom, over == 4);
        QRect xr = new QRect (ptx.Rect() );

        if (ptx.Rect().top > pta.Rect().top) {
            xr.offset (0, 20);
        } else {
            xr.offset (0, -20);
        }

        xr.extend (2, 2);
        canvas.drawRoundedRect (xr, 3, 3, PtPaint);
        canvas.setPen (0xffffffff);
        canvas.drawText ("X", xr, Constant.AlignCenter);

        xr = new QRect (pta.Rect() );

        if (ptx.Rect().top > pta.Rect().top) {
            xr.offset (0, -20);
        } else {
            xr.offset (0, 20);
        }

        xr.extend (2, 2);
        canvas.drawRoundedRect (xr, 3, 3, PtPaint);
        canvas.setPen (0xffffffff);
        canvas.drawText ("A", xr, Constant.AlignCenter);

        xr = new QRect (ptb.Rect() );

        if (ptb.Rect().top > pta.Rect().top) {
            xr.offset (0, 20);
        } else {
            xr.offset (0, -20);
        }

        xr.extend (2, 2);
        canvas.drawRoundedRect (xr, 3, 3, PtPaint);
        canvas.setPen (0xffffffff);
        canvas.drawText ("B", xr, Constant.AlignCenter);

        xr = new QRect (ptc.Rect() );

        if (ptb.Rect().top > ptc.Rect().top) {
            xr.offset (0, -20);
        } else {
            xr.offset (0, 20);
        }

        xr.extend (2, 2);
        canvas.drawRoundedRect (xr, 3, 3, PtPaint);
        canvas.setPen (0xffffffff);
        canvas.drawText ("C", xr, Constant.AlignCenter);

        xr = new QRect (ptd.Rect() );

        if (ptd.Rect().top > ptc.Rect().top) {
            xr.offset (0, 20);
        } else {
            xr.offset (0, -20);
        }

        xr.extend (2, 2);
        canvas.drawRoundedRect (xr, 3, 3, PtPaint);
        canvas.setPen (0xffffffff);
        canvas.drawText ("D", xr, Constant.AlignCenter);

        String txt = "Inf";
        double fbaxa = 0;

        //fbaxa < 0.618 0.5或者0.382 为蝙蝠形态,C点回调在0.382-0.886之间，D点的延伸最少是BC的1.618，同时达到XA的0.886位置， D点将在1.27AB
        //fbaxa 必须为 0.618 为加特利, C点的回调在0.382-0.886之间, D点相对BC的延伸不超过1.618；D点相对XA的回调为0.786, AB≈CD
        //fbaxa 必须在0.786 蝴蝶形态， AB=CD通常是延长的，即CD>=AB，常见情形是CD=1.27AB， D点相对于CB的延伸在1.272至3.618之间，D点相对于XA的延伸在1.272至1.618之间，C点回调在0.382-0.886之间
        //fbaxa B点的回调在0.382-0.618之间, AB=CD通常是延长的，CD>=1.27AB或CD=1.618AB, D点相对于CB的延伸比较极端，通常是2.618、3.14或3.618, D点相对于XA的延伸是1.618，这是一个决定性的限制,C点回调在0.382-0.886之间

        if ( (ptx.Rect().top - pta.Rect().top) != 0) {
            fbaxa = Math.abs ( (double) (ptb.Rect().top - pta.Rect().top) / (double) (ptx.Rect().top - pta.Rect().top) );
            txt = String.format ("%0.3f", fbaxa);
        }

        drawTextOnPoint (canvas, txt, ptx.Rect().left + (ptb.Rect().right - ptx.Rect().left) / 2, ptx.Rect().top + (ptb.Rect().bottom - ptx.Rect().top) / 2);

        txt = "Inf";

        if ( (ptb.Rect().top - ptc.Rect().top) != 0) {
            txt = String.format ("%0.3f", Math.abs ( (double) (ptd.Rect().top - ptc.Rect().top) / (double) (ptb.Rect().top - ptc.Rect().top) ) );
        }

        drawTextOnPoint (canvas, txt, ptb.Rect().left + (ptd.Rect().right - ptb.Rect().left) / 2, ptb.Rect().top + (ptd.Rect().bottom - ptb.Rect().top) / 2);

        txt = "Inf";

        if ( (pta.Rect().top - ptb.Rect().top) != 0) {
            txt = String.format ("%0.3f", Math.abs ( (double) (ptc.Rect().top - ptb.Rect().top) / (double) (pta.Rect().top - ptb.Rect().top) ) );
        }

        drawTextOnPoint (canvas, txt, pta.Rect().left + (ptc.Rect().right - pta.Rect().left) / 2, pta.Rect().top + (ptc.Rect().bottom - pta.Rect().top) / 2);

        txt = "Inf";

        if ( (ptx.Rect().top - ptc.Rect().top) != 0) {
            txt = String.format ("%0.3f", Math.abs ( (double) (ptd.Rect().top - ptc.Rect().top) / (double) (ptx.Rect().top - ptc.Rect().top) ) );
        }

        drawTextOnPoint (canvas, txt, ptx.Rect().left + (ptd.Rect().right - ptx.Rect().left) / 2, ptx.Rect().top + (ptd.Rect().bottom - ptx.Rect().top) / 2);
    }

    public void drawTextOnPoint (QPainter canvas, String txt, int x, int y) {
        QRect rect = canvas.measureText (0, 0, txt);
        rect.extend (10, 4);
        rect.offset (x - (rect.width() / 2), y - (rect.height() / 2) );
        canvas.drawRoundedRect (rect, 3, 3, PtPaint);
        canvas.setPen (0xffffffff);
        canvas.drawText (txt, rect, Constant.AlignVCenter | Constant.AlignHCenter);
    }
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        if (step != -1){
            return false;
        }
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();
        if (ptx.contains (x, y) || pta.contains (x, y) || ptb.contains (x, y) || ptc.contains (x, y) || ptd.contains (x, y) ) {
            PropertyListener pl = new PropertyListener () {
                @NotNilptr
                String getSetting (String [] options, @NotNilptr String key)override {
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

        if (step > 4) {
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

    long prevx;
    float prevy;

    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        x = x - tv.getXTranslate();
        y = y - tv.getYTranslate();

        switch (step) {
        case 0: /*TODO*/
            px.x = pa.x = pb.x = pc.x = pd.x = time;
            px.y = pa.y = pb.y = pc.y = pd.y = Price;
            return true;
            break;

        case 1: /*TODO*/
            pa.x = pb.x = pc.x = pd.x = time;
            pa.y = pb.y = pc.y = pd.y = Price;
            return true;
            break;

        case 2: /*TODO*/
            pb.x = pc.x = pd.x = time;
            pb.y = pc.y = pd.y = Price;
            return true;
            break;

        case 3: /*TODO*/
            pc.x = pd.x = time;
            pc.y = pd.y = Price;
            return true;
            break;

        case 4: /*TODO*/
            pd.x = time;
            pd.y = Price;
            return true;
            break;

        case 5: /*TODO*/
            px.x = time;
            px.y = Price;
            return true;
            break;

        case 6: /*TODO*/
            pa.x = time;
            pa.y = Price;
            return true;
            break;

        case 7: /*TODO*/
            pb.x = time;
            pb.y = Price;
            return true;
            break;

        case 8: /*TODO*/
            pc.x = time;
            pc.y = Price;
            return true;
            break;

        case 9: /*TODO*/
            pd.x = time;
            pd.y = Price;
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
        }  else if (ptd.contains (x, y) ) {
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
            px.x = pa.x = pb.x = pc.x = pd.x = time;
            px.y = pa.y = pb.y = pc.y = pd.y = Price;
            step = 1;
            return true;
        } else if (step == 1) {
            pa.x = pb.x = pc.x = pd.x = time;
            pa.y = pb.y = pc.y = pd.y = Price;
            step = 2;
            return true;
        } else if (step == 2) {
            pb.x = pc.x = pd.x = time;
            pb.y = pc.y = pd.y = Price;
            step = 3;
            return true;
        }  else if (step == 3) {
            pc.x = pd.x = time;
            pc.y = pd.y = Price;
            step = 4;
            return true;
        }  else if (step == 4) {
            pd.x = time;
            pd.y = Price;
            step = -1;
            tv.endDraw();
            return true;
        }  else if (ptx.contains (x, y) ) {
            step = 5;
            return true;
        } else if (pta.contains (x, y) ) {
            step = 6;
            return true;
        }  else if (ptb.contains (x, y) ) {
            step = 7;
            return true;
        }  else if (ptc.contains (x, y) ) {
            step = 8;
            return true;
        }  else if (ptd.contains (x, y) ) {
            step = 9;
            return true;
        }

        return false;
    }

};