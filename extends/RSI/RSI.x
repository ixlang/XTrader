
void _entry (int moduleId, int xvmVer) {
    IndicatorSystem.registry("RSI", RSIIndicator);
    return ;
}


using{
    Qt;
};

class RSIIndicator : Indicator {
    // 更新指标
    int period = 12;


    Vector<double> prices = new Vector<double> ();
    Vector<double> rsi = new Vector<double> ();
    
    float _height = 200;
    
    int RSI_color = 0xff00cc29;
    float RSI_width = 2.0;

    int RSICHANNEL_color = 0xff7f7f7f;
    float RSICHANNEL_width = 1.0;
     
    float ytranslate = 0;
    bool isInitialized = false;
    float yzoom = 1.0;
    bool syz = false;
    bool myz = false;
    int zyy = 0, zxx = 0;
    float pty = 0, ptx = 0;
    float avgGain = 0, avgLoss = 0;
    float mx = 0, my = 0;
    
    void update(float price) {
    
        int len = this.prices.size();

        if (len > 0) {
            float diff = price - prices[len - 1];
            float gain = diff > 0 ? diff : 0;
            float loss = diff < 0 ? -diff : 0;

            if (len < period) {
                // 初始化阶段：先存满 period 个数据
                avgGain += gain;
                avgLoss += loss;
            } else if (len == period) {
                // 刚好够一个周期：取均值，初始化完成
                avgGain = (avgGain + gain) / period;
                avgLoss = (avgLoss + loss) / period;
                isInitialized = true;
            } else {
                // 平滑更新
                avgGain = (avgGain * (period - 1) + gain) / period;
                avgLoss = (avgLoss * (period - 1) + loss) / period;
            }
        }

        prices.add(price);

        if (!isInitialized) {
        	rsi.add(50);
        	return ;
        }

        if (avgLoss == 0) {
        	rsi.add(100);
        	return ;
        }
        
        float rs = this.avgGain / this.avgLoss;
        rsi.add(100 - 100 / (1 + rs));
	}
    
    void onUpdate(String symbol, BarGroup bars, double[][] indexBuffer, bool bNewBar)override // 更新指标
    {
        Vector<Bar> _bars = bars.getBars();
        int count = _bars.size();
        if (rsi.size() == 0) {
            for (var i = 0; i < count - 1; i++) {
                this.update(_bars[i].close);
            }
        } else
        if (bNewBar) {
            this.update(_bars[count - 2].close);
        }
    }
    //获取指标名称
    String getName()override// 获取指标名称
    {
        return "RSI";
    }
    
    int configure(IConfigure ic)override{
        
        period = ic.getInt("period");
        RSI_width = ic.getFloat("RSI_width");
        RSI_color = ic.getInt("RSI_color");
        
        RSICHANNEL_width = ic.getFloat("RSICHANNEL_width");
        RSICHANNEL_color = ic.getFloat("RSICHANNEL_color");
        
        prices.clear();
        rsi.clear();
        
        return 0;
    }
    
    int [] getPenColors()override{
        return nilptr;
    }
    
    float [] getPenWidths()override{
        return nilptr;
    }
    // 初始化 ， 返回值为指标有几个buffer
    void onInit(IConfigure ic)override // 初始化
    {
        ic.setConfig("period", CFG_DATA_TYPE.INTEGER, "周期", nilptr, period);
        
        ic.setConfig("RSI_width", CFG_DATA_TYPE.FLOAT, "RSI线宽", nilptr,RSI_width);
        ic.setConfig("RSI_color", CFG_DATA_TYPE.COLOR, "RSI颜色", nilptr,RSI_color);
        
        ic.setConfig("RSICHANNEL_width", CFG_DATA_TYPE.FLOAT, "轨道线宽", nilptr,RSICHANNEL_width);
        ic.setConfig("RSICHANNEL_color", CFG_DATA_TYPE.COLOR, "轨道颜色", nilptr, RSICHANNEL_color);
    }
    // 卸载指标
    void onUninit()override{
        
    }
    
    // 周期更新
    void onPeriodChange(ENUM_TIMEFRAMES period)override{
        prices.clear();
        rsi.clear();
    }
    
    String getDescrName(){
    	return "RSI:" + period ;
    }
    
    bool hasView()override{
        return true;
    }
    void draw(TradingView tv, QPainter canvas,float xoffset,int start,int length,float w,float h,float fw)override{
        canvas.setPen(tv.clrText);
        canvas.drawText(getDescrName(), 6, 12);

    	if (rsi.size() == 0){
    		return;
    	}
    	int count = Math.min(length, rsi.size());
        if (count == 0){
            return;
        }
        canvas.translate(xoffset, ytranslate);
        double sig = w / length;
        
        {
            canvas.setBrush(0, QBrush.Style.NoBrush);
            canvas.setPen (RSI_color, PenStyle.SolidLine, RSI_width);
            canvas.strokePathf3i (rsi.toArray(new double[0]), 0, sig, _height, yzoom, start, count - 1);
	    }
        canvas.setPen(RSICHANNEL_color, PenStyle.DotLine, this.RSICHANNEL_width);
        canvas.drawLine(0, h - 70* this.yzoom, fw, h - 70* this.yzoom);
        canvas.drawLine(0, h - 30* this.yzoom, fw, h - 30* this.yzoom);
        
         
	    canvas.translate(-xoffset, -ytranslate);
        
        int borderColor = tv.getBorderColor();
	    canvas.fillRect(fw - tv.getTextAreaWid() - 8, 0, tv.getTextAreaWid() + 8, h, borderColor, Qt.QBrush.Style.SolidPattern);

	    var c = _height / 30;
        canvas.setPen(tv.clrText);

        for (var i = 0; i < c; i++) {
            canvas.drawText(String.format("%.3f", -(0 - i * 30 - ytranslate) / yzoom), fw - tv.getTextAreaWid() + 5, h - (i * 30) + 8);
        }

        canvas.setPen(0xff000000 | (~tv.getBackgroundColor() & 0x00ffffff),  PenStyle.DashLine, 0.5);
        var mmy = (h - my + ytranslate) / yzoom;
        //canvas.drawLine(mx, 0, mx, h);
        canvas.drawLine(0, my, fw, my);
        tv.drawTextOnRect(canvas, String.format("%.3f", mmy), fw - tv.getTextAreaWid(), my, tv.getTextAreaWid() + 8, tv.getTextAreaHeight(), 0xff000000 | (~borderColor & 0x00ffffff), borderColor, 0);
    }
    float height()override{
        return _height;
    }
    void setHeight(float h)override{
        _height = h;
    }
    bool onChatMouseMove(TradingView tv,int x,int y, IndicatorShell is)override{
        mx = x;
        my = y;

    	if (syz) {
            var oldp = (height() - pty + ytranslate) / yzoom;

            if (y > zyy) {
                yzoom = yzoom * 0.943;
            } else {
                yzoom = yzoom * 1.06;
            }

            if (yzoom < 0) {
                yzoom = 0.01;
            }

            ytranslate = (oldp * yzoom) - (height() - pty);
            zyy = y;
            return true;
        }else
        if (myz) {
        	ytranslate = zyy + (y - pty);
        	tv.setXTranslate(zxx + (x - ptx));
            return true;
        }
        
        return false;
    }
    bool onChatMouseDown(TradingView tv,int x,int y, IndicatorShell is)override{
        if (x > tv.getChatWidth() - tv.getTextAreaWid() && x < tv.getChatWidth()){
    		syz = true;
            zyy = y;
            pty = y;
            ptx = x;
            tv.captureIndicator(is);
            return true;
    	}else{
    		myz = true;
            zyy = ytranslate;
            pty = y;
            ptx = x;
            zxx = tv.getXTranslate();
            tv.captureIndicator(is);
            return true;
    	}
        return false;
    }
    bool onChatMouseUp(TradingView tv,int x,int y, IndicatorShell is)override{
        if (syz) {
            syz = false;
            tv.releaseCaptureIndicator(is);
            return true;
        }else
        if (myz) {
            myz = false;
            tv.releaseCaptureIndicator(is);
            return true;
        }
        return false;
    }
    bool onChatMouseWheel(TradingView tv,int x,int y,int delta, int modifiers, IndicatorShell is)override{
        if ( (modifiers & Constant.ControlModifier) != Constant.ControlModifier) {
            if (delta > 0) {
                yzoom = yzoom * 1.1;
            } else {
                yzoom = yzoom / 1.1;

                if (yzoom < 0) {
                    yzoom = 0.01;
                }
            }
            return true;
        }else{
        	tv.onChatMouseWheel(x, y, delta, modifiers);
        }
        return false;
    }
    bool needMouseEvent()override{
        return true;
    }
    JsonObject getViewConfigure()override{
        JsonObject vc = new JsonObject();
        vc.put("height", _height);
        vc.put("yzoom", yzoom);
        vc.put("ytranslate", ytranslate);
        return vc;
    }
    
    void setViewConfigure(JsonObject vc)override{
        if (vc == nilptr){
            return;
        }
        _height = vc.getDouble("height");
        yzoom = vc.getDouble("yzoom");
        ytranslate = vc.getDouble("ytranslate");
    }
};