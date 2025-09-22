
void _entry (int moduleId, int xvmVer) {
    IndicatorSystem.registry("MACD", MACD);
    return ;
}


using{
    Qt;
};

class MACD : Indicator {
    // 更新指标
    int shortPeriod = 12;
    int longPeriod = 26;
    int signalPeriod = 9;

    float multiplierShort = 2 / (shortPeriod + 1);
    float multiplierLong = 2 / (longPeriod + 1);
    float multiplierSignal = 2 / (signalPeriod + 1);

    // 状态缓存
    float emaShort = 0;
    float emaLong = 0;
    float dea = 0; // 信号线

    Vector<double> macdData = new Vector<double> ();
    Vector<double> difData = new Vector<double> ();
    Vector<double> deaData = new Vector<double> ();
    
    float _height = 200;


    int macdr_color = 0xff00cc29;
    int macdf_color = 0xffC2291E;
    int dif_color = 0xff5900ff;
    int dea_color = 0xff006eff;

    float dif_width = 2;
    float dea_width = 2;

    float ytranslate = -100;

    float yzoom = 1.0;
    bool syz = false;
    bool myz = false;
    int zyy = 0, zxx = 0;
    float pty = 0;
    float ptx = 0;

    float mx = 0;
    float my = 0;
    
    void update(float price) {
	    if (emaShort == 0) {
	      // 初始化
	      emaShort = price;
	      emaLong = price;
	      dea = 0;
	    } else {
	      emaShort = (price - emaShort) * multiplierShort + emaShort;
	      emaLong = (price - emaLong) * multiplierLong + emaLong;
	    }

	    float dif = emaShort - emaLong;
	    dea = (dif - dea) * multiplierSignal + dea;
	    float macd = (dif - dea) * 2; // 柱状图
        difData.add(dif);
        deaData.add(dea);
	    macdData.add(macd);
	}
    
    void onUpdate(String symbol, BarGroup bars, double[][] indexBuffer, bool bNewBar)override // 更新指标
    {
        Vector<Bar> _bars = bars.getBars();
        if (macdData.size() == 0){
    		for (Bar b : _bars){
    			update(b.close);
    		}
    	}else
    	if (bNewBar){
    		update(_bars[_bars.size() - 2].close);
    	}
    }
    //获取指标名称
    String getName()override// 获取指标名称
    {
        return "MACD";
    }
    
    int configure(IConfigure ic)override{
        
        shortPeriod = ic.getInt("shortPeriod");
        longPeriod = ic.getInt("longPeriod");
        signalPeriod = ic.getInt("signalPeriod");
        
        dif_width = ic.getFloat("dif_width");
        dea_width = ic.getFloat("dea_width");
        
        dif_color = ic.getInt("dif_color");
        dea_color = ic.getInt("dea_color");
        
        macdr_color = ic.getInt("macdr_color");
        macdf_color = ic.getInt("macdf_color");
        
        multiplierShort = 2.0 / (shortPeriod + 1);
        multiplierLong = 2.0 / (longPeriod + 1);
        multiplierSignal = 2.0 / (signalPeriod + 1);
        macdData.clear();
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
        ic.setConfig("shortPeriod", CFG_DATA_TYPE.INTEGER, "短周期", nilptr, shortPeriod);
        ic.setConfig("longPeriod", CFG_DATA_TYPE.INTEGER, "长周期", nilptr, longPeriod);
        ic.setConfig("signalPeriod", CFG_DATA_TYPE.INTEGER, "信号周期", nilptr, signalPeriod);
        
        ic.setConfig("dif_width", CFG_DATA_TYPE.FLOAT, "DIF线宽", nilptr,dif_width);
        ic.setConfig("dea_width", CFG_DATA_TYPE.FLOAT, "DEA线宽", nilptr,dea_width);
        
        ic.setConfig("dif_color", CFG_DATA_TYPE.COLOR, "DIF颜色", nilptr,dif_color);
        ic.setConfig("dea_color", CFG_DATA_TYPE.COLOR, "DEA颜色", nilptr, dea_color);
        
        ic.setConfig("macdr_color", CFG_DATA_TYPE.COLOR, "MACD上涨颜色", nilptr,macdr_color);
        ic.setConfig("macdf_color", CFG_DATA_TYPE.COLOR, "MACD下跌颜色", nilptr, macdf_color);
    }
    // 卸载指标
    void onUninit()override{
        
    }
    
    // 周期更新
    void onPeriodChange(ENUM_TIMEFRAMES period)override{
        macdData.clear();
    }
    
    String getDescrName(){
    	return "MACD:" + shortPeriod + "/" + longPeriod  + "/" + signalPeriod;
    }
    
    bool hasView()override{
        return true;
    }
    void draw(TradingView tv, QPainter canvas,float xoffset,int start,int length,float w,float h,float fw)override{
        canvas.setPen(tv.clrText);
        canvas.drawText(getDescrName(), 6, 12);

    	if (macdData.size() == 0 || length == 0){
    		return;
    	}
    	int count = Math.min(length, macdData.size());

        canvas.translate(xoffset, ytranslate);
        double sig = w / length;
        float sw = sig;
        if (sw < 1){
            sw = 1;
        }
        var rsclr = 0xff000000 | (macdr_color & 0x00ffffff),
        	rwclr = 0x7f000000 | (macdr_color & 0x00ffffff),
        	fsclr = 0xff000000 | (macdf_color & 0x00ffffff),
        	fwclr = 0x7f000000 | (macdf_color & 0x00ffffff);
        {
        	double lastMacd = 0;
        	if (start > 0){
        		lastMacd = macdData[start - 1];
        	}
	        for (int i = start; i < start + count; i++){
	        	double sh = macdData[i];
	        	double l = (i - start) * sig;
	        	int clr = 0;

	        	if (sh < 0){ // 上涨
	        		if (sh < lastMacd){
	        			clr = fsclr;
	        		}else{
	        			clr = fwclr;
	        		}
	        	}else{
	        		if (sh > lastMacd){
	        			clr = rsclr;
	        		}else{
	        			clr = rwclr;
	        		}
	        	}
	            canvas.fillRect(l , h, sw, -sh * yzoom,  clr, Qt.QBrush.Style.SolidPattern);
	            lastMacd = sh;
	        }
	    }
        canvas.setBrush(0, QBrush.Style.NoBrush);
        {
            canvas.setPen (dif_color, PenStyle.SolidLine, dif_width);
            canvas.strokePathf3i (difData.toArray(new double[0]), 0, sig, _height, yzoom, start, count);
	    }

        {
        	canvas.setPen (dea_color, PenStyle.SolidLine, dea_width);
            canvas.strokePathf3i (deaData.toArray(new double[0]), 0, sig, _height, yzoom, start, count);
	    }
        
        int borderColor = tv.getBorderColor();
        
	    canvas.translate(-xoffset, -ytranslate);

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