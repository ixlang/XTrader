//xlang Source, Name:Alarm.x 
//Date: Wed Jul 02:43:00 2025 

class Alarm : public DrawObject {
    float ytrs = 0;
    int color = 0xff808080;
    float liney = -1, my = -1, dy, oy;
    bool done = false, down = false;
    String sPriceFormat = nilptr;
    public static QImage ico_alarm = new QImage(__xPackageResource("assets/res/alarm.png"), "png");
    bool bless = false;
    public OBJECT_TYPE getType() override{
        return OBJECT_TYPE.OBJECT_ALARM;
    }

    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
        float tx = - tv.getXTranslate();
        //canvas.setPen (color, PenStyle.SolidLine, 1);
        canvas.setPen (0xff2962FF, PenStyle.SolidLine, 2);
        my = h - liney * yzoom;
        canvas.drawImage(ico_alarm, tx + w - 57, my - 22);
        /*if (sPriceFormat == nilptr){
            sPriceFormat = tv.currentData().getPriceFormater();
        }*/
        //tv.drawTextOnRect (canvas, String.format (sPriceFormat, liney), tx + tv.getChatWidth() - tv.getTextAreaWid(), my, tv.getTextAreaWid() + 8, tv.getTextAreaHeight(),  0xffef3f3f, 0xffffffff, 0);
    }
    public bool isNeedCross()override{
        return true;
    }
    public void onRemove (TradingView tv)override{
        tv.currentData().removeAlarm(this);
    }
    public CommonConfigure getConfigure()override{return nilptr;}
    public void updateConfigure()override{
        // 更新配置
    }
    public void relocal(Vector<Bar> bars)override{}
    public bool onMouseButtonRelease (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        if (down) {
            down = false;
            tv.currentData().modifyAlarm(this, liney);
            /*tv.currentData().removeAlarm(this);
            tv.currentData().addAlarm(this, liney);*/
            bless = tv.currentData().getBid() < liney;
            tv.setHideCross (false);
            return true;
        }

        return false;
    }
    
    public void setPrice(TradingView tv, double Price){
        liney = Price;
        tv.currentData().addAlarm(this, liney);
        bless = tv.currentData().getBid() < liney;
        done = true;
    }
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        return false;
    }
    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        float tx = - tv.getXTranslate();
        var td = tv.currentData();
        
        QPoint gpt = tv.mapToGlobal(x, y);
        String sPriceFormat = tv.currentData().getPriceFormater();
        
        
        if (down) {
            liney = oy + (Price - dy);
            if (td.getBid() < liney){
                tv.ShowToolTips(gpt.x, gpt.y, "卖出价格高于 " + String.format(sPriceFormat, liney) + " 时报警", 10000);
            }else{
                tv.ShowToolTips(gpt.x, gpt.y, "卖出价格低于 " + String.format(sPriceFormat, liney) + " 时报警", 10000);
            }
            return true;
        } else {
            y = y - tv.getYTranslate();
            
            if (y < my + 4 && y > my -22 && x - tv.getXTranslate() > tx + (tv.getChatWidth() - tv.getTextAreaWid()) - 57) {
                tv.setCursor (Constant.SizeVerCursor);
                if (bless){
                    tv.ShowToolTips(gpt.x, gpt.y, "卖出价格大于等于 " + String.format(sPriceFormat, liney) + " 时报警", 10000);
                }else{
                    tv.ShowToolTips(gpt.x, gpt.y, "卖出价格小于等于 " + String.format(sPriceFormat, liney) + " 时报警", 10000);
                }
                return true;
            }
        }

        return false;
    }

    public bool onMouseButtonPress (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        float tx = - tv.getXTranslate();
        if (!done) {
            liney = Price;
            tv.currentData().addAlarm(this, liney);
            bless = tv.currentData().getBid() < liney;
            tv.endDraw();
            done = true;
            return true;
        } else if (!down) {
            y = y - tv.getYTranslate();

            if (y < my + 4 && y > my -22 && x - tv.getXTranslate() > tx + (tv.getChatWidth() - tv.getTextAreaWid()) - 57) {
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