//xlang Source, Name:TradingData.x
//Date: Tue Jun 15:18:45 2025


class Bar {
    public float high = 0;
    public float low = 0;
    public float open = 0;
    public float close = 0;
    public float vol = 0;
    public long timedate;

    public Bar (float v) {
        high = v;
        low = v;
        open = v;
        close = v;
    }

    public Bar (float h, float l, float o, float c, float v, long t) {
        high = h;
        low = l;
        open = o;
        close = c;
        vol = v;
        timedate = t;
    }
};

class AlarmObject {
    public AlarmObject (bool b, double p, Object o) {
        less = b;
        price = p;
        idob = o;
    }
    public Object idob = nilptr;
    public bool less = false;
    public double price;
};

class XPoint{
    public long time;
    public double price;
    public XPoint(long t, double p){
        time  = t;
        price = p;
    }
};

class RequestdObject{
    public OBJECT_TYPE objetType;
    public XPoint [] params;
    
    public RequestdObject(OBJECT_TYPE t, XPoint [] p){
        objetType = t;
        params = p;
    }
};

class BarGroup{
    public Vector<Bar> bars = nilptr;
    public Vector<Bar> getBars(){
        return bars;
    }
};

interface Indicator{
    // 更新指标
    void onUpdate(String symbol, BarGroup bars, double[][] indexBuffer, bool bnewBar); // 更新指标
    //获取指标名称
    String getName();// 获取指标名称
    // 初始化 ， 返回值为指标有几个buffer
    void onInit(IConfigure); // 初始化
    // 配置
    int configure(IConfigure);
    // 卸载指标
    void onUninit();
    // 周期更新
    void onPeriodChange(ENUM_TIMEFRAMES period);
    int [] getPenColors();
    float [] getPenWidths();
    bool hasView();
    void draw(TradingView tv, QPainter canvas,float xoffset,int start,int length,float w,float h,float fw);
    float height();
    void setHeight(float h);
    bool onChatMouseMove(TradingView tv,int x,int y, IndicatorShell is);
    bool onChatMouseDown(TradingView tv,int x,int y, IndicatorShell is);
    bool onChatMouseUp(TradingView tv,int x,int y, IndicatorShell is);
    bool onChatMouseWheel(TradingView tv,int x,int y,int delta, int shift, IndicatorShell is);
    bool needMouseEvent();
    
    JsonObject getViewConfigure();
    void setViewConfigure(JsonObject vc);
};


enum CFG_DATA_TYPE{
    INTEGER,
    STRING,
    FLOAT,
    LONG,
    COLOR,
    BOOL,
    OPTIONS,
    FONT
};
    
interface IConfigure{
    void setConfig(String key, CFG_DATA_TYPE type, String name, String [] options, Object defValue);
    int getInt(String key);
    bool getBool(String key);
    String getString(String key);
    float getFloat(String key);
    long getLong(String key);
};


class CommonConfigure: public IConfigure{
    JsonObject root =  new JsonObject();
    JsonObject result = new JsonObject();
    
    public String getSetting (@NotNilptr String key) {
        return result.getString(key);
    }
    public bool setSetting (@NotNilptr String key, String val) {
        while (result.has(key)){
            result.remove(key);
        }
        result.put(key, val);
        return true;
    }
    public JsonObject buildResult(){
        return result;
    }
    
    public JsonObject buildJsonobject(){
        return root;
    }
    
    public void loadResult(JsonObject _result){
        if (_result != nilptr){
            result = _result;
        }
    }
    
    public void setConfig(String key, CFG_DATA_TYPE type, String name, String [] options, Object defValue)override{
        switch (type) {
        	case CFG_DATA_TYPE.INTEGER:
            case CFG_DATA_TYPE.STRING:
            case CFG_DATA_TYPE.FLOAT:
            case CFG_DATA_TYPE.LONG:
            {
                JsonObject stype = new JsonObject();
                stype.put("type", "string");
                stype.put("value", defValue.toString());
                root.put(name + ":" + key, stype);
                result.put(key, defValue.toString());
            }
            break;
            case CFG_DATA_TYPE.COLOR:
            {
                JsonObject stype = new JsonObject();
                stype.put("type", "color");
                stype.put("value", defValue.toString());
                root.put(name + ":" + key, stype);
                try{
                	result.put(key, "" +  (int)defValue);
                }catch(Exception e){
                	
                }
            }
            break;
            case CFG_DATA_TYPE.BOOL:
            {
                JsonObject stype = new JsonObject();
                stype.put("type", "bool");
                stype.put("value", defValue.toString());
                root.put(name + ":" + key, stype);
                result.put(key, defValue.toString());
            }
            break;
            case CFG_DATA_TYPE.OPTIONS:
            {
                JsonObject stype = new JsonObject();
                stype.put("type", "stringlist");
                JsonArray array = new JsonArray();
                if (options != nilptr){
                    for (String s : options){
                        array.put(s);
                    }
                }
                stype.put("list", array);
                root.put(name + ":" + key, stype);
                result.put(key, defValue.toString());
            }
            break;
            case CFG_DATA_TYPE.FONT:
            {
                JsonObject stype = new JsonObject();
                stype.put("type", "font");
                root.put(name + ":" + key, stype);
                result.put(key, defValue.toString());
            }
            break;
        }
        
    }
    
    public int getInt(String key)override{
        return result.getInt(key);
    }
    
    public bool getBool(String key)override{
         return result.getBool(key);
    }
    
    public String getString(String key)override{
        return result.getString(key);
    }
    
    public float getFloat(String key)override{
        return result.getDouble(key);
    }
    
    public long getLong(String key)override{
         return result.getLong(key);
    }
    
    public void setValue(String key, Object value){
        result.put(key, value);
    }
};


class IndicatorShell{
    Indicator indicator = nilptr;
    double[][] indexBuffer = nilptr;
    BarGroup bg = new BarGroup();
    TradingData td = nilptr;
    public int dx = 0, dy = 0, oldHeight = 0;
    
    int indexCount = 0;
    String indicname = "";
    public CommonConfigure configure = new CommonConfigure();
    public QRect toprc = nilptr;
    public QRect rect = nilptr;
    
    public IndicatorShell(TradingData data, Indicator indic){
        indicator = indic;
        indicator.onInit(configure);
        indexCount = indicator.configure(configure);
        indicname = indicator.getName();
        indexBuffer = new double[indexCount][0];
        td = data;
    }
    
    public bool needMouseEvent(){
        return indicator.needMouseEvent();
    }
    
    public int height(){
        return indicator.height();
    }
    
    public bool hasView(){
        return indicator.hasView();
    }
    
    public Indicator getIndicator(){
        return indicator;
    }
    public JsonObject getSaveStruct(){
        JsonObject js = new JsonObject();
        js.put("name", indicname);
        js.put("configure", configure.buildResult());
        js.put("vc", indicator.getViewConfigure());
        return js;
    }
    
    public void refresh(){
        indexCount = indicator.configure(configure);
        indexBuffer = new double[indexCount][0];
        td.IndicatorChanged();
    }
    
    public void setConfigure(JsonObject res, JsonObject vc){
        configure.loadResult(res);
        indexCount = indicator.configure(configure);
        indexBuffer = new double[indexCount][0];
        indicator.setViewConfigure(vc);
    }
    
    public String getName(){
        return indicname;
    }
    
    public double[][] getIndexBuffer(){
        return indexBuffer;
    }
    
    public int [] getPenColors(){
        return indicator.getPenColors();
    }
    
    public float [] getPenWidths(){
        return indicator.getPenWidths();
    }
    
    public void update(String symbol, Vector<Bar> bars, bool newBar){
        bg.bars = bars;
        
        if (hasView() == false){
            if (indexCount < 1){
                return ;
            }
            int bc = bars.size();
            if (newBar || indexBuffer[0] == nilptr || indexBuffer[0].length != bc){
                for (int i = 0; i < indexBuffer.length; i++){
                    double [] idx = new double[bc];
                    _system_.arrayCopy(indexBuffer[i], 0, idx, 0, Math.min(idx.length, indexBuffer[i].length));
                    indexBuffer[i] = idx;
                }
            }
        }
        
        try{
            indicator.onUpdate(symbol, bg, indexBuffer, newBar);
        }catch(Exception e){
            Dialog.OutputLogcat("指标[" + indicname + "]存在错误: Exception:" + e.getMessage());
        }
    }
};


class IndicatorSystem{
    static Map<String, Class> indicatorList = new Map<String, Class>();
    public static void registry(String name, Class indicatorClass){
        indicatorList.put(name, indicatorClass);
    }
    
    public static String [] getList(){
        var iter = indicatorList.iterator();
        Vector<String> _names = new Vector<String>();
        while (iter.hasNext()){
            _names.add(iter.getKey());
            iter.next();
        }
        return _names.toArray(new String[0]);
    }
    
    public static Class getIndicatorClass(String name){
        return indicatorList.get(name);
    }
};

class TradingData {
    public long handler = 0;
    public long lastTime = 0;
    static const int tickLimit = 300;
    public static const  int CMD_TICK = 1, CMD_BARS = 11, CMD_POSITION = 3, CMD_ORDERS = 4, CMD_UPDATEORDER = 5, CMD_UPDATEPOSITION = 6, CMD_REPLY = 7, CMD_HISTORY = 8, CMD_SYMBOLS = 0x100, CMD_ACCOUNT = 0x101, CMD_LOGRESULT = 0x102, CMD_PING = 0x103;
    Vector<Bar> bars = new Vector<Bar>();
    Vector<IndicatorShell> indicators = new Vector<IndicatorShell>();
    
    double [] tickshist = new double[tickLimit];
    int tickcount = 0;
    bool bClosed = false;
    float ask = 1000, bid = 1100;
    String szSymbol = nilptr, underlyingSymbol = nilptr;
    int sencondPeriod = 60;
    JsonObject configure = nilptr;
    String priceFmt;
    double _pointValue, _contractSize, _minLots, _maxLots;
    String currencyBase, currencyProfit;
    int digits;
    double spread = 0;
    public float xtranslate = 0, ytranslate = 0;
    public float xzoom = 1.0, yzoom = 1.0;
    String timeName = "M5";
    Vector<DrawObject> objects = new Vector<DrawObject>();
    Map<String, OrderObject> positions = new Map<String, OrderObject>();
    Map<String, OrderObject> orders = new Map<String, OrderObject>();
    Vector<TradingView> bindViews = new Vector<TradingView>();
    long change_count = 0;
    long createTime = _system_.currentTimeMillis();
    double fRecommandHeight = 0;
    Vector<AlarmObject> alarms = new Vector<AlarmObject>();
    Vector<RequestdObject> ros = new Vector<RequestdObject>();
    static long lastAlarm = 0;
    XTraderExecuter executer = nilptr;
    bool needGenDraw = false;
    bool tradeallowed = true;
    public Vector<IndicatorShell> getIndicators(){
        return indicators;
    }
    
    public void addbind (TradingView tv) {
        bindViews.add (tv);
    }
    
    public bool tradeAllowed(){
        return tradeallowed;
    }
    
    public IndicatorShell addIndicator(String name, Class c, bool save){
        Indicator indic = (Indicator)c.newInstance();
        IndicatorShell is = new IndicatorShell(this, indic);
        indicators.add(is);
        is.update(getCurrentSymbol(), bars, false);
        if (save){
            IndicatorChanged();
        }
        return is;
    }
    
    public void IndicatorChanged(){
        JsonObject indicconf =  new JsonObject();
        indicconf.put("symbol", szSymbol);
        JsonArray indics = new JsonArray();
        for (IndicatorShell is : indicators){
            indics.put(is.getSaveStruct());
        }
        indicconf.put("indics", indics);
        Preference.setSetting("indic_" + szSymbol , indicconf.toString());
    }
    
    public void loadIndicator(){
        String szDic = Preference.getString("indic_" + szSymbol);
        if (TextUtils.isEmpty(szDic) == false){
            JsonObject indicconf =  new JsonObject(szDic);
            JsonArray indics = indicconf.getArray("indics");
            for (int i : indics.length()){
                JsonObject item = indics.getObject(i);
                String name = item.getString("name");
                try{
                	Class c = IndicatorSystem.getIndicatorClass (name);
                    if (c != nilptr){
                        IndicatorShell is = addIndicator (name, c, false);
                        if (is != nilptr){
                            is.setConfigure(item.getObject("configure"), item.getObject("vc"));
                        }
                    }
                }catch(Exception e){
                	
                }
            }
        }
    }
    
    public void addRequestdObject(RequestdObject r){
        needGenDraw = true;
        synchronized (ros) {
            ros.add(r);
        }
    }
    
    public OrderObject getPosition(String tick){
        return positions.get(tick);
    }
    
    public OrderObject getOrder(String tick){
        return orders.get(tick);
    }
    
    public void processRequest(){
        synchronized (ros) {
            if (ros.size() == 0){
                return;
            }
            
            for (RequestdObject r : ros){
                processRequest(r);
            }
            ros.clear();
        }
        needGenDraw = false;
    }
    
    void processRequest(RequestdObject r){
        DrawObject _dobject = nilptr;
        switch (r.objetType) {
            case OBJECT_TYPE.OBJECT_ARRAWUP:
            case OBJECT_TYPE.OBJECT_ARRAWDOWN:
            case OBJECT_TYPE.OBJECT_ARRAWLEFT:
            case OBJECT_TYPE.OBJECT_ARRAWRIGHT:
            {
                Arraw _do = new Arraw(r.objetType);
                int id = getBarIndexForTime(r.params[0].time /1000);
                _do.setPosition(id * SINGLE_BAR_WIDTH, r.params[0].price);
                _dobject = _do;
            }
            break;
            
        	case OBJECT_TYPE.OBJECT_HLINE: /*TODO*/
            {
                HLine _do = new HLine();
                _do.setPrice(r.params[0].price);
                _dobject = _do;
            }
        	break;
        	default:
        	break;
        }
        if (_dobject != nilptr){
            objects.add(_dobject);
        }
    }
    
    public void setRecommandHeight (double h) {
        fRecommandHeight = h;
    }
    
    public void addAlarm (Object idob, double p) {
        alarms.add (new AlarmObject (bid > p, p, idob) );
        Dialog.OutputLogcat("已添加警报, 当价格 "+ (bid > p ? "低于" : "高于") + String.format(priceFmt, p) + " 时将触发");
    }

    public void removeAlarm (Object idob) {
        for (int i : alarms.size()) {
            if (alarms[i].idob == idob) {
                Dialog.OutputLogcat("已移除了价格 "+ (alarms[i].less ? "低于" : "高于") + String.format(priceFmt, alarms[i].price) + " 时的警报.");
                alarms.remove (i);
                break;
            }
        }
    }
    
    
    public void modifyAlarm (Object idob, double p) {
        for (int i : alarms.size()) {
            if (alarms[i].idob == idob) {
                alarms[i].less = bid > p;
                alarms[i].price = p;
                Dialog.OutputLogcat("已将警报更改为价格 "+ (alarms[i].less ? "低于" : "高于") + String.format(priceFmt, alarms[i].price) + " 时触发.");
                break;
            }
        }
    }

    public void locateToCurrent (bool resetZoom) {
        for (TradingView tv : bindViews) {
            tv.locateToCurrent (resetZoom);
        }
    }

    public double getRecommandHeight() {
        return fRecommandHeight;
    }

    public void unbind (TradingView tv) {
        bindViews.remove (tv);
    }

    public double mobility() {
        double base = ( (_system_.currentTimeMillis() - createTime) / 60000);

        if (base == 0) {
            return change_count;
        }

        return change_count / base;
    }

    public void refresh() {
        resetTimePeriod();
        for (DrawObject _od : objects){
            _od.relocal(bars);
        }
        refreshAllindicator();
    }
    
    /*public bool hasIndicator(String name){
        for (int i =0; i < indicators.size(); i++){
            IndicatorShell s = indicators[i];
            if (s.getName() == name){
                return true;
            }
        }
        return false;
    }*/
    
    public void removeIndicator(int n){
        if (n >=0 && n < indicators.size()){
            indicators.remove(n);
        }
    }
    
    public void refreshAllindicator(){
        for (IndicatorShell  s: indicators ){
            s.refresh();
            s.update(getCurrentSymbol(), bars, false);
        }
    }

    public void cleanAndReload() {
        positions.clear();
        orders.clear();
        bars.clear();
    }

    public void updateView() {
        for (TradingView tv : bindViews) {
            tv.postUpdate();
        }
    }


    public void resetTimePeriod() {
        for (TradingView tv : bindViews) {
            tv.resetTimePeriod();
            tv.showWait(false, "");
        }
    }
    
    public void showWait(bool bw, String text){
        for (TradingView tv : bindViews) {
            tv.showWait(bw, text);
        }
    }

    public Vector<DrawObject> getDrawableObjects() {
        return objects;
    }

    public void addDrawableObject (DrawObject d) {
        objects.add (d);
    }

    public Map<String, OrderObject> getPositionsMap() {
        return positions;
    }

    public Map<String, OrderObject> getOrdersMap() {
        return orders;
    }

    public void updatePosition (Position order) {
        var iter = positions.find (order.id);

        if (iter != nilptr) {
            var item = iter.getValue();

            if (item.isModifing() ) {
                return;
            }

            if (order.sl != 0) {
                item.sl_price = order.sl;
            }

            if (order.tp != 0) {
                item.tp_price = order.tp;
            }

            item.profit = order.profit;
            item.lots = order.vl;
        } else {
            OrderObject item = new OrderObject (order.symbol, false, minLots(), true, order.type, order.price, order.id, order.posType);

            if (order.sl != 0) {
                item.sl_price = order.sl;
            }

            if (order.tp != 0) {
                item.tp_price = order.tp;
            }

            item.profit = order.profit;
            item.lots = order.vl;
            positions.put (order.id, item);
        }

        updateView();
    }


    public void updateOrder (Order order) {
        var iter = orders.find (order.tick);

        if (iter != nilptr) {
            OrderObject item = iter.getValue();

            if (item.isModifing() ) {
                return;
            }

            if (order.sl != 0) {
                item.sl_price = order.sl;
            } else {
                item.sl_price = -1;
            }

            if (order.tp != 0) {
                item.tp_price = order.tp;
            } else {
                item.tp_price = -1;
            }

            item.open_price = order.price;
            item.psl = order.psl;
            item.lots = order.vl;
        } else {
            OrderObject item = new OrderObject (order.symbol, false, minLots(), false, order.type, order.price, order.tick, order.orderType);

            if (order.sl != 0) {
                item.sl_price = order.sl;
            } else {
                item.sl_price = -1;
            }

            if (order.tp != 0) {
                item.tp_price = order.tp;
            } else {
                item.tp_price = -1;
            }

            item.open_price = order.price;
            item.psl = order.psl;
            item.lots = order.vl;
            orders.put (order.tick, item);
        }

        updateView();
    }

    public void removeOrder (Order order) {
        orders.remove (order.tick);
        updateView();
    }

    public void removePosition (Position order) {
        positions.remove (order.id);
        updateView();
    }

    public void removePosition (String tick) {
        positions.remove (tick);
        updateView();
    }

    public void removeOrder (String id) {
        orders.remove (id);
        updateView();
    }
    public int size() {
        return bars.size();
    }

    public TradingData (XTraderExecuter _executer ,String _underlyingSymbol, String symbol, long item, JsonObject _configure) {
        szSymbol = symbol;
        underlyingSymbol = _underlyingSymbol;
        handler = item;
        configure = _configure;
        priceFmt = "%." + configure.getInt ("digits") + "f";
        _pointValue = configure.getDouble ("pointValue");
        _contractSize = configure.getDouble ("contractSize");
        _minLots = configure.getDouble ("minlots");
        _maxLots = configure.getDouble ("maxlots");
        digits = configure.getInt ("digits");
        if (configure.has("tradeallowed")){
            tradeallowed = configure.getBool("tradeallowed");
        }
        
        currencyBase = configure.getString ("currencyBase");
        currencyProfit = configure.getString ("currencyProfit");
        executer = _executer;
        loadIndicator();
    }
    
    public XTraderExecuter getExecuter(){
        return executer;
    }

    public String getPriceFormater() {
        if (configure == nilptr) {
            return "";
        }

        return priceFmt;
    }

    
    public String getCurrencyProfit() {
        return currencyProfit;
    }

    public String getCurrencyBase() {
        return currencyBase;
    }

    public int getDigits() {
        return digits;
    }

    public double minLots() {
        return _minLots;
    }

    public double maxLots() {
        return _maxLots;
    }

    public double pointValue() {
        return _pointValue;
    }

    public double contractSize() {
        return _contractSize;
    }
    
    public ENUM_TIMEFRAMES currentPeriod(){
        return GetPeriod(sencondPeriod);
    }

    public static ENUM_TIMEFRAMES GetPeriod (int tf) {
        switch (tf) {
        case 60:
            return ENUM_TIMEFRAMES.PERIOD_M1;

        case 120:
            return ENUM_TIMEFRAMES.PERIOD_M2;

        case 180:
            return ENUM_TIMEFRAMES.PERIOD_M3;

        case 240:
            return ENUM_TIMEFRAMES.PERIOD_M4;

        case 300:
            return ENUM_TIMEFRAMES.PERIOD_M5;

        case 360:
            return ENUM_TIMEFRAMES.PERIOD_M6;

        case 600:
            return ENUM_TIMEFRAMES.PERIOD_M10;

        case 720:
            return ENUM_TIMEFRAMES.PERIOD_M12;

        case 900:
            return ENUM_TIMEFRAMES.PERIOD_M15;

        case 1200:
            return ENUM_TIMEFRAMES.PERIOD_M20;

        case 1800:
            return ENUM_TIMEFRAMES.PERIOD_M30;

        case 3600:
            return ENUM_TIMEFRAMES.PERIOD_H1;

        case 7200:
            return ENUM_TIMEFRAMES.PERIOD_H2;

        case 10800:
            return ENUM_TIMEFRAMES.PERIOD_H3;

        case 14400:
            return ENUM_TIMEFRAMES.PERIOD_H4;

        case 21600:
            return ENUM_TIMEFRAMES.PERIOD_H6;

        case 28800:
            return ENUM_TIMEFRAMES.PERIOD_H8;

        case 43200:
            return ENUM_TIMEFRAMES.PERIOD_H12;

        case 86400:
            return ENUM_TIMEFRAMES.PERIOD_D1;

        case 604800:
            return ENUM_TIMEFRAMES.PERIOD_W1;

        case 2592000:
            return ENUM_TIMEFRAMES.PERIOD_MN1;
        }

        return ENUM_TIMEFRAMES.PERIOD_M5;
    }

    public static int getTimeFrame (ENUM_TIMEFRAMES tf) {
        switch (tf) {
        case ENUM_TIMEFRAMES.PERIOD_M1:
            return 60;

        case ENUM_TIMEFRAMES.PERIOD_M2:
            return 120;

        case ENUM_TIMEFRAMES.PERIOD_M3:
            return 180;

        case ENUM_TIMEFRAMES.PERIOD_M4:
            return 240;

        case ENUM_TIMEFRAMES.PERIOD_M5:
            return 300;

        case ENUM_TIMEFRAMES.PERIOD_M6:
            return 360;

        case ENUM_TIMEFRAMES.PERIOD_M10:
            return 600;

        case ENUM_TIMEFRAMES.PERIOD_M12:
            return 720;

        case ENUM_TIMEFRAMES.PERIOD_M15:
            return 900;

        case ENUM_TIMEFRAMES.PERIOD_M20:
            return 1200;

        case ENUM_TIMEFRAMES.PERIOD_M30:
            return 1800;

        case ENUM_TIMEFRAMES.PERIOD_H1:
            return 3600;

        case ENUM_TIMEFRAMES.PERIOD_H2:
            return 7200;

        case ENUM_TIMEFRAMES.PERIOD_H3:
            return 10800;

        case ENUM_TIMEFRAMES.PERIOD_H4:
            return 14400;

        case ENUM_TIMEFRAMES.PERIOD_H6:
            return 21600;

        case ENUM_TIMEFRAMES.PERIOD_H8:
            return 28800;

        case ENUM_TIMEFRAMES.PERIOD_H12:
            return 43200;

        case ENUM_TIMEFRAMES.PERIOD_D1:
            return 86400;

        case ENUM_TIMEFRAMES.PERIOD_W1:
            return 604800;

        case ENUM_TIMEFRAMES.PERIOD_MN1:
            return 2592000;
        }

        return 60;
    }

    public static String getPeriodName (ENUM_TIMEFRAMES tf) {

        switch (tf) {
        case ENUM_TIMEFRAMES.PERIOD_M1:
            return "M1";

        case ENUM_TIMEFRAMES.PERIOD_M2:
            return "M2";

        case ENUM_TIMEFRAMES.PERIOD_M3:
            return "M3";

        case ENUM_TIMEFRAMES.PERIOD_M4:
            return "M4";

        case ENUM_TIMEFRAMES.PERIOD_M5:
            return "M5";

        case ENUM_TIMEFRAMES.PERIOD_M6:
            return "M6";

        case ENUM_TIMEFRAMES.PERIOD_M10:
            return "M10";

        case ENUM_TIMEFRAMES.PERIOD_M12:
            return "M12";

        case ENUM_TIMEFRAMES.PERIOD_M15:
            return "M15";

        case ENUM_TIMEFRAMES.PERIOD_M20:
            return "M20";

        case ENUM_TIMEFRAMES.PERIOD_M30:
            return "M30";

        case ENUM_TIMEFRAMES.PERIOD_H1:
            return "H1";

        case ENUM_TIMEFRAMES.PERIOD_H2:
            return "H2";

        case ENUM_TIMEFRAMES.PERIOD_H3:
            return "H3";

        case ENUM_TIMEFRAMES.PERIOD_H4:
            return "H4";

        case ENUM_TIMEFRAMES.PERIOD_H6:
            return "H6";

        case ENUM_TIMEFRAMES.PERIOD_H8:
            return "H8";

        case ENUM_TIMEFRAMES.PERIOD_H12:
            return "H12";

        case ENUM_TIMEFRAMES.PERIOD_D1:
            return "D1";

        case ENUM_TIMEFRAMES.PERIOD_W1:
            return "W1";

        case ENUM_TIMEFRAMES.PERIOD_MN1:
            return "MN1";
        }

        return "UNKNOW";
    }

    public static ENUM_TIMEFRAMES getPeriod(String tf) {

        switch (tf) {
        case "M1":
            return ENUM_TIMEFRAMES.PERIOD_M1;

        case "M2":
            return ENUM_TIMEFRAMES.PERIOD_M2;

        case "M3":
            return ENUM_TIMEFRAMES.PERIOD_M3;

        case "M4":
            return ENUM_TIMEFRAMES.PERIOD_M4;

        case "M5":
            return ENUM_TIMEFRAMES.PERIOD_M5;

        case "M6":
            return ENUM_TIMEFRAMES.PERIOD_M6;

        case "M10":
            return ENUM_TIMEFRAMES.PERIOD_M10;

        case "M12":
            return ENUM_TIMEFRAMES.PERIOD_M12;

        case "M15":
            return ENUM_TIMEFRAMES.PERIOD_M15;

        case "M20":
            return ENUM_TIMEFRAMES.PERIOD_M20;

        case "M30":
            return ENUM_TIMEFRAMES.PERIOD_M30;

        case "H1":
            return ENUM_TIMEFRAMES.PERIOD_H1;

        case "H2":
            return ENUM_TIMEFRAMES.PERIOD_H2;

        case "H3":
            return ENUM_TIMEFRAMES.PERIOD_H3;

        case "H4":
            return ENUM_TIMEFRAMES.PERIOD_H4;

        case "H6":
            return ENUM_TIMEFRAMES.PERIOD_H6;

        case "H8":
            return ENUM_TIMEFRAMES.PERIOD_H8;

        case "H12":
            return ENUM_TIMEFRAMES.PERIOD_H12;

        case "D1":
            return ENUM_TIMEFRAMES.PERIOD_D1;

        case "W1":
            return ENUM_TIMEFRAMES.PERIOD_W1;

        case "MN1":
            return ENUM_TIMEFRAMES.PERIOD_MN1;
        }

        return ENUM_TIMEFRAMES.PERIOD_M5;
    }

    public static String getTimeFrameName (int tf) {
        switch (tf) {
        case 60:
            return "M1";

        case 120:
            return "M2";

        case 180:
            return "M3";

        case 240:
            return "M4";

        case 300:
            return "M5";

        case 360:
            return "M6";

        case 600:
            return "M10";

        case 720:
            return "M12";

        case 900:
            return "M15";

        case 1200:
            return "M20";

        case 1800:
            return "M30";

        case 3600:
            return "H1";

        case 7200:
            return "H2";

        case 10800:
            return "H3";

        case 14400:
            return "H4";

        case 21600:
            return "H6";

        case 28800:
            return "H8";

        case 43200:
            return "H12";

        case 86400:
            return "D1";

        case 604800:
            return "W1";

        case 2592000:
            return "MN1";
        }

        return "UNKNOW";
    }


    public void reset (int _secondPeriod) {
        bars.clear();

        for (int i = objects.size() - 1; i >= 0 ; i--) {
            if (objects[i].getType() != OBJECT_TYPE.OBJECT_ALARM) {
                objects.remove (i);
            }
        }

        timeName = getTimeFrameName (_secondPeriod);
        sencondPeriod = _secondPeriod;
        resetTimePeriod();
        lastTime = 0;
        bClosed = false;
    }

    public String getTimePeriodName() {
        return timeName;
    }

    public void clear() {
        xtranslate = ytranslate = 0;
        xzoom = yzoom = 1.0;
        bars.clear();
        objects.clear();
        alarms.clear();
        positions.clear();
        orders.clear();
        timeName = "M5";
        sencondPeriod = 0;
        lastTime = 0;
        bClosed = false;

        for (TradingView t : bindViews) {
            t.reset();
        }

        bindViews.clear();
    }

    public Vector<Bar> getBars() {
        return bars;
    }

    public Bar operator [] (int n) {
        return bars[n];
    }

    public void addBar (Bar b) {
        bars.add (b);
    }

    public String getCurrentSymbol() {
        return szSymbol;
    }

    public String getUnderlyingSymbol() {
        return underlyingSymbol;
    }

    public void addBar (float high, float low, float open, float close, float vol,  long time) {
        Bar  b = new Bar (high, low, open, close, vol, time);
        lastTime = time;
        bars.add (b);
    }

    public long getLastTime() {
        return lastTime;
    }

    public int getSecondPeriod() {
        return sencondPeriod;
    }

    public double [] getTickData() {
        return tickshist;
    }

    public int getTickCount() {
        return tickcount;
    }

    public void addTick (float _ask, float _bid, float vol,  long time) {
        change_count++;

        if (tickcount == tickLimit) {
            _system_.arrayCopy (tickshist, 1, tickshist, 0, tickLimit - 1);
            tickcount--;
        }

        tickshist[tickcount++] = _bid;
        int n = tickcount;

        while (n < tickLimit) {
            tickshist[n++] = _bid;
        }

        bool close = ( (lastTime / sencondPeriod) != (time / sencondPeriod) );
        lastTime = time;
        Bar b = nilptr;
        bool bNewBar = false;
        if (bClosed || bars.size() == 0) {
            bClosed = false;
            b = new Bar (_bid);
            b.timedate = time;
            bars.add (b);
            bNewBar = true;
        } else {
            b = bars[bars.size() - 1];
        }

        if (_bid > b.high) {
            b.high = _bid;
        }

        if (_bid < b.low) {
            b.low = _bid;
        }

        b.vol += vol;
        b.close = _bid;
        bClosed = close;
        ask = _ask;
        bid = _bid;
        spread = ask - bid;
        updateView();

        if (_system_.currentTimeMillis()  - lastAlarm > 3000) {
            for (AlarmObject a : alarms) {
                if (a.less == (bid < a.price) ) {
                    Dialog.OutputLogcat ("Caution: 品种" + szSymbol + " 添加的警报 [卖出价" + (a.less ? "低于" : "高于 ") + String.format (priceFmt, a.price) + "] 已达成!");
                    lastAlarm = _system_.currentTimeMillis();
                    SoundMgr.playAlarm();
                    break;
                }
            }
        }
        if (needGenDraw){
            processRequest();
        }
        
        if (bindViews.size() > 0){
            for (IndicatorShell inc : indicators){
                inc.update(szSymbol, bars, bNewBar);
            }
        }
    }

    public float getAsk() {
        return ask;
    }

    public float getBid() {
        return bid;
    }

    public float getSpread() {
        return spread;
    }
    
    int binarySearch(int left, int right, long target) {
        while (left <= right) {
            int mid = left + (right - left) / 2;
            
            // 检查目标是否在中间
            if (bars[mid].timedate <= target && target < bars[mid].timedate + sencondPeriod)
                return mid;
                
            // 如果目标更大，忽略左半部分
            if (bars[mid].timedate < target)
                left = mid + 1;
            // 否则忽略右半部分
            else
                right = mid - 1;
        }
        return -1;
    }

    public int getBarIndexForTime(long time){
        return binarySearch(0, bars.size() - 1, time);
    }
        
};