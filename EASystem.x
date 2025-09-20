//xlang Source, Name:EASystem.x 
//Date: Sun Aug 02:09:49 2025 

class Symbol{
    JsonObject content;
    XTraderExecuter executer;
    EASystem system;
    
    public Symbol(EASystem sys, XTraderExecuter e, JsonObject sc){
        executer = e;
        content = sc;
        system = sys;
    }
    public String name(){
        synchronized (content) {
        	return content.getString("name");
        }
    }
    
    public Bar [] getBars(ENUM_TIMEFRAMES period, long startTime, long endTime){
        ExecuteResult er = new ExecuteResult();
        String periodstr = "" + (int)period + "," + (startTime / 1000) + "," + (endTime / 1000);
        executer.query(er, TradingData.CMD_BARS, name(), periodstr);
        JsonObject result  = er.getResult();
        Bar [] bs = nilptr;
        if (result != nilptr){
            JsonArray items = result.getArray("items");
            if (items != nilptr){
                bs = new Bar[items.length()];
                for (int i : items.length()){
                    JsonObject item = items.getObject(i);
                    if (item != nilptr){
                        bs[i] = new Bar(item.getDouble ("high"), item.getDouble ("low"), item.getDouble ("open"), item.getDouble ("close"), item.getDouble ("vol"), item.getLong ("time"));
                    }
                }
            }
        }
        return bs;
    }
    
    public int digits(){
        synchronized (content) {
            return content.getInt("name");
        }
    }
    public int stopsLevel(){
        synchronized (content) {
            return content.getInt("tsl");
        }
    }
    public double volumeMin(){
        synchronized (content) {
            return content.getDouble("minlots");
        }
    }
    public double volumeMax(){
        synchronized (content) {
            return content.getDouble("maxlots");
        }
    }
    public double pointValue(){
        synchronized (content) {
            return content.getDouble("pointValue");
        }
    }
    public double contractSize(){
        synchronized (content) {
            return content.getDouble("contractSize");
        }
    }
    public String currencyBase(){
        synchronized (content) {
            return content.getString("currencyBase");
        }
    }
    public String currencyProfit(){
        synchronized (content) {
            return content.getString("currencyProfit");
        }
        
    }
    
    public double ask(){
        synchronized (content) {
            JsonObject lastTick = content.getObject("lastTick");
            if (lastTick != nilptr){
                return lastTick.getDouble("ask");
            }
        }
        return 0;
    }
    
    public double bid(){
        synchronized (content) {
            JsonObject lastTick = content.getObject("lastTick");
            if (lastTick != nilptr){
                return lastTick.getDouble("bid");
            }
        }
        return 0;
    }
    
    public long time(){
        synchronized (content) {
            JsonObject lastTick = content.getObject("lastTick");
            if (lastTick != nilptr){
                return lastTick.getDouble("time");
            }
        }
        return 0;
    }
    
    public double volume(){
        synchronized (content) {
            JsonObject lastTick = content.getObject("lastTick");
            if (lastTick != nilptr){
                return lastTick.getDouble("volume_real");
            }
        }
        return 0;
    }
    
    public IPosition CreatePosition(PositionType type, double stoploss, double takeprofit, double volume){
        ExecuteResult result = new ExecuteResult();
        executer.createOrder(result, 0, name(), type, 0, stoploss, takeprofit, volume);
        return nilptr;
    }
    
    public IOrder CreateOrder(OrderType type, double price, double stoploss, double takeprofit, double volume){
        ExecuteResult result = new ExecuteResult();
        executer.createOrder(result, 0, name(), type, price, stoploss, takeprofit, volume);
        return nilptr;
    }
    
    public void addArraw(OBJECT_TYPE arrawType, long time, double price){
        TradingData data = system.getData(name());
        if (data != nilptr){
            XPoint [] params = new XPoint[]{
                new XPoint(time, price)
            };
            RequestdObject ro = new RequestdObject(arrawType, params);
            data.addRequestdObject(ro);
        }
    }
    
    public void addHLine(double price){
        TradingData data = system.getData(name());
        if (data != nilptr){
            XPoint [] params = new XPoint[]{
                new XPoint(0, price)
            };
            RequestdObject ro = new RequestdObject(OBJECT_TYPE.OBJECT_HLINE, params);
            data.addRequestdObject(ro);
        }
    }
};



const int TICK_UPDATED = 0, POSITION_CLOSED = 1, POSITION_CREATED = 2, ORDER_CREATED = 3, ORDER_CLOSED = 4,  EA_UNINIT = 5;

class EAEvent{
    public int eventId;
    public Object object = nilptr;
    
    public EAEvent(int id, Object obj){
        eventId = id;
        object = obj;
    }
};

class EAShell : public Thread{
    ExpertAdvisor eadv;
    EASystem easystem;
    bool bQuit = false;
    
    List<EAEvent> eventList = new List<EAEvent>();
    
    public EAShell(EASystem es, ExpertAdvisor ea){
        eadv = ea;
        easystem = es;
    }
    
    public void sendEvent(EAEvent eae){
        synchronized (eventList) {
        	eventList.add(eae);
            eventList.notifyAll();
        }
    }
    
    public void run()override{
        bQuit = false;
        eadv.onInit(easystem);
        
        while (!bQuit){
            EAEvent eav = nilptr;
            synchronized (eventList) {
                while (!bQuit && eventList.size() == 0){
                    eventList.wait();
                }
                if (!bQuit){
                    eav = eventList.pollHead();
                }
            }
            
            switch(eav.eventId){
                case TICK_UPDATED:
                eadv.onTickUpdated();
                break;
                case POSITION_CLOSED:
                eadv.onPositionClose((IPosition)eav.object);
                break;
                case POSITION_CREATED:
                eadv.onPositionCreate((IPosition)eav.object);
                break;
                case ORDER_CLOSED:
                eadv.onOrderClose((IOrder)eav.object);
                break;
                case ORDER_CREATED:
                eadv.onOrderCreate((IOrder)eav.object);
                break;
                case EA_UNINIT:
                eadv.onUninit();
                break;
            }
            
        }
    }
};

class EASystem : EAController{
    static Map<String, EAShell> eaMap = new Map<String, EAShell>();
    
    static EASystem __instalce = nilptr;
    XTraderExecuter executer = nilptr;
    Map<String, Position> positions = nilptr;
    Map<String, Order> orders = nilptr;
    Map<String, JsonObject> symbolsList = nilptr;
    Map<String, Position> hislist = nilptr;
    Map<String, TradingData> subscribelist = nilptr;
    
    public EASystem(XTraderExecuter _executer, Map<String, Position> _positions, Map<String, Order> _orders,  Map<String, TradingData> _subscribelist, Map<String, JsonObject> _symbolsList, Map<String, Position> _hislist){
        __instalce = this;
        positions = _positions;
        orders = _orders;
        symbolsList = _symbolsList;
        hislist = _hislist;
        executer = _executer;
        subscribelist = _subscribelist;
    }
    
    public TradingData getData(String symbol){
        synchronized (subscribelist) {
        	return subscribelist.get(symbol);
        }
    }
    
    public static bool registry(ExpertAdvisor ea){
        EAShell eas = nilptr;
        String eaid = ea.getEAID();
        
        synchronized (eaMap) {
            if (eaMap.containsKey(eaid) == false){
                eas = new EAShell(__instalce, ea);
                eaMap.put(ea.getEAID(), eas);
            }else{
                return false;
            }
        }
        
        eas.start();
        return true;
    }
    
    public void sendEvent(int event, Object object){
        synchronized (eaMap) {
            var iter = eaMap.iterator();
            EAEvent eae = new EAEvent(event, object);
            while (iter.hasNext()){
                iter.getValue().sendEvent(eae);
                iter.next();
            }
        }
    }
        
    public Symbol [] ListSymbols()override{
        synchronized (symbolsList) {
            Symbol [] sa = new Symbol[symbolsList.size()];
            int n = 0;
            var iter = symbolsList.iterator();
            while (iter.hasNext()){
                sa[n++] = new Symbol(this, executer, iter.getValue());
                iter.next();
            }
            return sa;
        }
    }
    
    public Symbol getSymbol(String symbol)override{
        synchronized (symbolsList) {
            JsonObject obj = symbolsList.get(symbol);
            if (obj != nilptr){
                return new Symbol(this, executer, obj);
            }
        }
        return nilptr;
    }
    
    public IPosition [] ListHistories()override{
        IPosition [] sa = new IPosition[hislist.size()];
        int n = 0;
        synchronized (hislist) {
            var iter = hislist.iterator();
            while (iter.hasNext()){
                sa[n++] = new IPosition(iter.getValue(), executer);
                iter.next();
            }
        }
        return sa;
    }
    
    public IPosition getHistory(String tick)override{
        Position p = nilptr;
        synchronized (positions) {
            p = hislist.get(tick);
        }
        if (p != nilptr){
            return new IPosition(p, executer);
        }
        return nilptr;
    }
    
    public IPosition getPosition(String tick)override{
        Position p = nilptr;
        synchronized (positions) {
            p = positions.get(tick);
        }
        if (p != nilptr){
            return new IPosition(p, executer);
        }
        return nilptr;
    }
        
    public IOrder getOrder(String id)override{
        Order p = nilptr;
        synchronized (orders) {
            p = orders.get(id);
        }
        if (p != nilptr){
            return new IOrder(p, executer);
        }
        return nilptr;
    }
    
    public void Log(String text)override{
        Dialog.OutputLogcat(text);
    }
};