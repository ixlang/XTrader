//xlang


void _entry (int moduleId, int xvmVer) {
    IndicatorSystem.registry("Moving Average", SMAIndicator);
    return ;
}


class SMAIndicator : Indicator {
    // 更新指标
    bool bOnce = true;
    
    
    int PERIOD = 20;
    float EMA_FACTOR = (2.f/(20.f + 1));
    int [] colors = {0xff1BD66C, 0xffff0000};
    float [] widths = {1.0, 1.0};
    
    void onUpdate(String symbol, BarGroup bars, double[][] indexBuffer, bool newBar)override // 更新指标
    {
        Vector<Bar> _bars = bars.getBars();
        int bc = _bars.size() - 1;
        if (bOnce){
            indexBuffer[0][0] = _bars[0].close;
            double avv = 0;
            int mc = Math.min(PERIOD, _bars.size());
            
            for (int i =0; i < PERIOD; i++){
                avv += _bars[i].close;
                indexBuffer[0][i] = avv /  (i + 1);
                if (i == 0){
                    indexBuffer[1][i] = indexBuffer[0][i];
                }else{
                    indexBuffer[1][i] = _bars[i].close * EMA_FACTOR + indexBuffer[1][i - 1] * (1 - EMA_FACTOR);
                }
            }
            
            for (int i = PERIOD; i <= bc; i++){
                avv = 0;
                for (int x = 0;x < PERIOD; x++){
                    avv += _bars[i - x].close;
                }
                
                indexBuffer[0][i] = avv / PERIOD;
                indexBuffer[1][i] = _bars[i].close * EMA_FACTOR + indexBuffer[1][i - 1] * (1 - EMA_FACTOR);
            }
            bOnce = false;
        }else
        if (bc > PERIOD){
            double avv = 0;
            for (int i = 0; i < PERIOD; i++){
                avv += _bars[bc - i].close;
            }
            indexBuffer[1][bc] = _bars[bc].close * EMA_FACTOR + indexBuffer[1][bc - 1] * (1 - EMA_FACTOR);
            indexBuffer[0][bc] = avv / PERIOD;
        }
    }
    //获取指标名称
    String getName()override// 获取指标名称
    {
        return "Moving Average";
    }
    
    int configure(IConfigure ic)override{
        bOnce = true;
        PERIOD = ic.getInt("smaperiod");
        colors[0] = ic.getInt("smacolor");
        colors[1] = ic.getInt("emacolor");
        widths[0] = ic.getFloat("smawidth");
        widths[1] = ic.getFloat("emawidth");
        EMA_FACTOR = (2.f/(PERIOD + 1));
        return 2;
    }
    
    int [] getPenColors()override{
        return colors;
    }
    
    float [] getPenWidths()override{
        return widths;
    }
    // 初始化 ， 返回值为指标有几个buffer
    void onInit(IConfigure ic)override // 初始化
    {
        ic.setConfig("smaperiod", CFG_DATA_TYPE.INTEGER, "均线周期", nilptr, PERIOD);
        ic.setConfig("smacolor", CFG_DATA_TYPE.COLOR, "SMA颜色", nilptr,colors[0]);
        ic.setConfig("emacolor", CFG_DATA_TYPE.COLOR, "EMA颜色", nilptr, colors[1]);
        ic.setConfig("smawidth", CFG_DATA_TYPE.FLOAT, "SMA线宽", nilptr,widths[0]);
        ic.setConfig("emawidth", CFG_DATA_TYPE.FLOAT, "EMA线宽", nilptr,widths[1]);
    }
    // 卸载指标
    void onUninit()override{
        
    }
    
    // 周期更新
    void onPeriodChange(ENUM_TIMEFRAMES period)override{
        bOnce = true;
    }
    
    bool hasView()override{
        return false;
    }
    void draw(TradingView tv, QPainter canvas,float xoffset,int start,int length,float w,float h,float fw)override{
        return ;
    }
    float height()override{
        return 0;
    }
    void setHeight(float h)override{

    }
    bool onChatMouseMove(TradingView tv,int x,int y, IndicatorShell is)override{
        return false;
    }
    bool onChatMouseDown(TradingView tv,int x,int y, IndicatorShell is)override{
        return false;
    }
    bool onChatMouseUp(TradingView tv,int x,int y, IndicatorShell is)override{
        return false;
    }
    bool onChatMouseWheel(TradingView tv,int x,int y,int delta, int modifiers, IndicatorShell is)override{
        return false;
    }
    bool needMouseEvent()override{
        return false;
    }
    JsonObject getViewConfigure()override{
        return new JsonObject();
    }
    
    void setViewConfigure(JsonObject vc)override{
    }
};