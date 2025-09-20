//xlang Source, Name:EAInterface.x 
//Date: Tue Jun 16:58:51 2025 


interface EAController{
    void Log(String text);
    Symbol [] ListSymbols();
    IPosition [] ListHistories();
    IPosition getHistory(String tick);
    IPosition getPosition(String tick);
    IOrder getOrder(String id);
    Symbol getSymbol(String symbol);
};


enum PositionType{
    PositionBuy = 0,
    PositionSell = 1
};

enum OrderType{
    MarketOrderBuy = CMD_ORDER_MARKETS_BUY,
    MarketOrderSell = CMD_ORDER_MARKETS_SELL, //
    BuyStopOrder = CMD_ORDER_BUYSTOP, //
    BuyLimitOrder = CMD_ORDER_BUYLIMIT, //
    SellStopOrder = CMD_ORDER_SELLSTOP, //
    SellLimitOrder = CMD_ORDER_SELLLIMIT //
};

class IPosition{
    private Position pos;
    private XTraderExecuter executer;
     
    public IPosition(Position p, XTraderExecuter e){
        pos = p;
        executer = e;
    }
        
    public bool setStoploss(double stoploss){
        ExecuteResult result = new ExecuteResult();
        executer.modify(result, 0, pos.id, CMD_MODIFY_POS, pos.price, stoploss, pos.tp, pos.vl);
        return result.isSucceed();
    }
    
    public bool setTakeProfit(double takeprofit){
        ExecuteResult result = new ExecuteResult();
        executer.modify(result, 0, pos.id, CMD_MODIFY_POS, pos.price, pos.sl, takeprofit, pos.vl);
        return result.isSucceed();
    }
    
    public String id(){
        return pos.id;
    }
    
    public double stoploss(){
        return pos.sl;
    }
    
    public double taskProfit(){
        return pos.tp;
    }
    
    public double profit(){
        return pos.profit;
    }
    
    public double openPrice(){
        return pos.price;
    }
    
    public long openTime(){
        return pos.time;
    }
    
    public bool close(){
        ExecuteResult result = new ExecuteResult();
        if (executer.close(result, CMD_ORDER_CLOSE, 0, pos.id)){
            return result.isSucceed();
        }
        return false;
    }
};

class IOrder{
    private Order ord;
    private XTraderExecuter executer;
    
    public IOrder(Order p, XTraderExecuter e){
        ord = p;
        executer = e;
    }
    
    public static IPosition Create(PositionType type, double stoploss, double takeprofit){
        return nilptr;
    }
    
    public static IOrder [] ListOrder(){
        return nilptr;
    }
    
    public bool setStoploss(double stoploss){
        ExecuteResult result = new ExecuteResult();
        executer.modify(result, 0, ord.tick, CMD_MODIFY_ORDER, ord.price, stoploss, ord.tp, ord.vl);
        return result.isSucceed();
    }
    
    public bool setTakeProfit(double takeprofit){
        ExecuteResult result = new ExecuteResult();
        executer.modify(result, 0, ord.tick, CMD_MODIFY_ORDER, ord.price, ord.sl, takeprofit, ord.vl);
        return result.isSucceed();
    }
    
    public bool setPrice(double price){
        ExecuteResult result = new ExecuteResult();
        executer.modify(result, 0, ord.tick, CMD_MODIFY_ORDER, price, ord.sl, ord.tp, ord.vl);
        return result.isSucceed();
    }
    
    public String id(){
        return ord.tick;
    }
    
    public double stoploss(){
        return ord.sl;
    }
    
    public double taskProfit(){
        return ord.tp;
    }
    
    public double openPrice(){
        return ord.price;
    }
    
    public long openTime(){
        return ord.time;
    }
};

interface ExpertAdvisor{
    String getEAID();// 获取EAID
    // TICK 事件
    void onTickUpdated();
    //初始化事件
    bool onInit(EAController controller);
    // 挂单关闭事件
    void onOrderClose(IOrder);
    //挂单创建事件
    void onOrderCreate(IOrder);
    //仓位关闭事件
    void onPositionClose(IPosition);
    //仓位创建事件
    void onPositionCreate(IPosition);
    // 响应事件通知
    void onResponse(int id);
    // 卸载事件
    void onUninit();
};