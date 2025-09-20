//xlang Source, Name:OrderObject.x
//Date: Sun Jul 22:02:20 2025

class OrderObject : public DrawObject {

    int bkClr, txtClr, StrokeClr;

    QPainter.Paint _paint = new QPainter.Paint();
    String label;

    public static QImage closeImg = new QImage (__xPackageResource ("./assets/res/toolbar/close_hover.png"), "png");
    public static QImage newOrd = new QImage (__xPackageResource ("./assets/res/toolbar/neworder.png"), "png");
    public static QImage newOrdh = new QImage (__xPackageResource ("./assets/res/toolbar/newordn.png"), "png");
    public static QImage de_location = new QImage (__xPackageResource ("./assets/res/toolbar/location_unselected.png"), "png");
    public static QImage se_location = new QImage (__xPackageResource ("./assets/res/toolbar/location_selected.png"), "png");


    public bool bBuy = false;
    public float open_price = -1;
    public float sl_price = -1;
    public float tp_price = -1;
    public float psl = 0;
    public float lots = 0.01;
    public float profit = 0;
    public ORDER_TYPE orderType ;
    String symbol;
    public String tickid = nilptr;
    int downId = -1;
    bool isPos = false;
    
    public static OrderObject __currentObject = nilptr;
    
    public CommonConfigure getConfigure()override{return nilptr;}
    public void updateConfigure()override{
        // 更新配置
    }
    public bool isNeedCross() override{
        return true;
    }
    QRect majorBtn, slBtn, tpBtn, clsBtn, slclsBtn, tpclsBtn, lotbtn, priceBtn;
    public OBJECT_TYPE getType() override{
        return OBJECT_TYPE.OBJECT_BUTTON;
    }

    public void onRemove (TradingView tv) override{}
    public bool isBuy() {
        return bBuy;
    }

    public float Profit() {
        return profit;
    }
    public void relocal (Vector<Bar> bars) override{}
    public OrderObject (String _symbol, bool buy, double minLots, bool _isPos, String descr, float openprice, String id, ORDER_TYPE _nType) {
        symbol = _symbol;
        bBuy = buy;
        tickid = id;
        String [] sOrderType = {"买单", "卖单", "限价买单(BUYLIMIT)", "限价卖单(SELLLIMIT)", "止损买单(BUYSTOP)", "止损卖单(SELLSTOP)", "止损限价买单(BUYSTOPLIMIT)", "止损限价卖单(SELLSTOPLIMIT)", "对冲"};
        open_price = openprice;
        lots = minLots;

        try {
            label = sOrderType[ (int) _nType];
        } catch (Exception e) {

        }
        
        txtClr = 0xffffffff;
        isPos = _isPos;
        bBuy = ( (_nType & 1) == 0);
        orderType = _nType;
        _paint.setStyle (QPainter.Paint.FILL_AND_STROKE);
        _paint.setStrokeWidth (1);
        
    }

    public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
        if (__currentObject != nilptr && __currentObject != this) {
            return;
        }

        canvas.setAntialiasing (true);
        if (bBuy) {
            StrokeClr = bkClr = tv.getRiseClr();
        } else {
            StrokeClr = bkClr = tv.getFallClr();
        }
        float py = tv.priceToY (open_price);
        canvas.setPen (0xff357C95, PenStyle.DashDotLine, 0.5);
        canvas.drawLine (0, py, w, py);
        TradingData data = tv.currentData();
        int nextR = w - 50;
        clsBtn = TradingView.drawImageOnCenter (canvas, closeImg, nextR, py, 16, 16);
        nextR -= (16 + 15);
        String priceFormat = data.getPriceFormater();

        if (tp_price == -1) {
            tpBtn = TradingView.drawTextButton (canvas, "TP", nextR, py, 35, 20, tv.backgroundColor(), 0xff2962FF, 0xff2962FF,  3, _paint);
            nextR -= (tpBtn.width() + 15);
        }

        if (sl_price == -1) {
            slBtn = TradingView.drawTextButton (canvas, "SL", nextR, py, 35, 20, tv.backgroundColor(), 0xffF23645, 0xffF23645,  3, _paint);
            nextR -= (slBtn.width() + 15);
        }

        lotbtn = TradingView.drawTextButton (canvas, String.format ("%g", lots), nextR, py, 50, 20, tv.backgroundColor(), bkClr, bkClr,  3, _paint);
        nextR -= (lotbtn.width() + 15);

        if (!isPos) {
            priceBtn = TradingView.drawTextButton (canvas, String.format (priceFormat, open_price), nextR, py, 50, 20, bkClr, txtClr, StrokeClr,  3, _paint);
            nextR -= (priceBtn.width() + 15);
        }

        double mpt = (1.0 / Math.pow (10, data.getDigits() ) );
        double pv = data.pointValue() / mpt;
        bool bdisplayPY = Setting.getPLDisplayMode() == 1;
        
        String szDisplay = "";
        
        if (bdisplayPY){
            szDisplay = String.format ("%d PT",  (int)((profit / (lots * (data.pointValue() / (mpt)))) / mpt));
        }else{
            szDisplay = String.format ("%.2f " + data.getCurrencyProfit(), profit);
        }
        
        majorBtn = TradingView.drawTextButton (canvas, isPos ? (szDisplay )  : label, nextR, py, 50, 20, bBuy ? TradingView.buyColor : TradingView.sellColor, txtClr, bBuy ? TradingView.buyColor : TradingView.sellColor,  3, _paint);
        nextR -= (majorBtn.width() + 15);

        
        String sPriceFormat = data.getPriceFormater();
        int TextAreaWid = tv.getTextAreaWid(), TextAreaHei = tv.getTextAreaHeight();
        
        
        if (sl_price != -1) {
            py = tv.priceToY (sl_price);
            canvas.setPen (tv.getFallClr(), PenStyle.DashDotDotLine, 0.5);
            canvas.drawLine (0, py, w, py);
            nextR = w - 50;
            slclsBtn = TradingView.drawImageOnCenter (canvas, closeImg, nextR, py, 16, 16);
            nextR -= (16 + 15);
            
            
            if (bdisplayPY){
                szDisplay = String.format ("%d PT", (int)((bBuy ? (sl_price - open_price) : (open_price - sl_price) ) / mpt));
            }else{
                szDisplay = String.format ("%.2f " + data.getCurrencyProfit(), lots * pv * (bBuy ? (sl_price - open_price) : (open_price - sl_price) ) );
            }
            
            slBtn = TradingView.drawTextButton (canvas, "SL:" + szDisplay, nextR, py, 50, 20, tv.backgroundColor(), 0xffF23645, 0xffF23645,  3, _paint);
            tv.drawTextOnRect (canvas, String.format (sPriceFormat, sl_price), tv.getChatWidth() - TextAreaWid, py, TextAreaWid + 8, TextAreaHei,  0xff47181C, 0xffffffff, 0);
        }

        if (tp_price != -1) {
            py = tv.priceToY (tp_price);
            canvas.setPen (tv.getRiseClr(), PenStyle.DashDotDotLine, 0.5);
            canvas.drawLine (0, py, w, py);
            nextR = w - 50;


            tpclsBtn = TradingView.drawImageOnCenter (canvas, closeImg, nextR, py, 16, 16);
            nextR -= (16 + 15);
            
            if (bdisplayPY){
                szDisplay = String.format ("%d PT", (int)((bBuy ? (tp_price - open_price) : (open_price - tp_price) ) / mpt));
            }else{
                szDisplay = String.format ("%.2f " + data.getCurrencyProfit(), lots * pv * ( (bBuy ? (tp_price - open_price) : (open_price - tp_price) ) ) );
            }
            
            tpBtn = TradingView.drawTextButton (canvas, "TP:" + szDisplay, nextR, py, 50, 20, tv.backgroundColor(), 0xff2962FF, 0xff2962FF,  3, _paint);
            tv.drawTextOnRect (canvas, String.format (sPriceFormat, tp_price), tv.getChatWidth() - TextAreaWid, py, TextAreaWid + 8, TextAreaHei,  0xff15234A, 0xffffffff, 0);
        }

        canvas.setAntialiasing (false);
    }

    public bool isModifing() {
        return downId != -1;
    }

    public bool onMouseButtonRelease (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        if (__currentObject != nilptr && __currentObject != this) {
            return false;
        }

        if (downId != -1) {
            downId = -1;

            if (tickid != nilptr) {
                tv.getExecuter().modify (nilptr, 0, tickid, isPos ? CMD_MODIFY_POS : CMD_MODIFY_ORDER, open_price, sl_price, tp_price, lots);
            }

            return true;
        }

        return false;
    }

    public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price)override {
        if (__currentObject != nilptr && __currentObject != this) {
            return false;
        }

        if (downId == 0) {
            double dist = Price - open_price;
            open_price = Price;

            if (tp_price != -1) {
                tp_price += dist;
            }

            if (sl_price != -1) {
                sl_price += dist;
            }

            return true;
        }

        if (downId == 2) {
            tp_price = Price;
            return true;
        }

        if (downId == 3) {
            sl_price = Price;
            return true;
        }

        if (clsBtn != nilptr && clsBtn.contains (x, y) ) {
            tv.setCursor (Constant.PointingHandCursor);
            QPoint pt = tv.mapToGlobal (x, y);
            tv.ShowToolTips (pt.x, pt.y, isPos ? "平仓(Ctrl 反向建仓)" : "取消挂单", 5000);
            return true;
        } else /*if ( (!isPos && lotbtn != nilptr &&  lotbtn.contains (x, y) ) ) {
                setCursor (Constant.PointingHandCursor);
                QPoint pt = mapToGlobal (x, y);
                ShowToolTips (pt.x, pt.y, "单击修改仓位数量", 5000);
                return true;
            } else */if (slclsBtn != nilptr && slclsBtn.contains (x, y) ) {
                tv.setCursor (Constant.PointingHandCursor);
                QPoint pt = tv.mapToGlobal (x, y);
                tv.ShowToolTips (pt.x, pt.y, "取消止损", 5000);
                return true;
            } else if (tpclsBtn != nilptr && tpclsBtn.contains (x, y) ) {
                tv.setCursor (Constant.PointingHandCursor);
                QPoint pt = tv.mapToGlobal (x, y);
                tv.ShowToolTips (pt.x, pt.y, "取消止盈", 5000);
                return true;
            } else if ( (slBtn != nilptr && slBtn.contains (x, y) ) || (tpBtn != nilptr && tpBtn.contains (x, y) ) ) {
                tv.setCursor (Constant.SizeVerCursor);
                return true;
            } else if ( !isPos &&  (priceBtn != nilptr && priceBtn.contains (x, y) ) ) {
                tv.setCursor (Constant.SizeVerCursor);
                return true;
            } else if (majorBtn != nilptr && majorBtn.contains (x, y) ) {
                tv.setCursor (Constant.PointingHandCursor);
                QPoint pt = tv.mapToGlobal (x, y);
                tv.ShowToolTips (pt.x, pt.y, "点击仅显示该订单", 5000);
                tv.setCursor (Constant.PointingHandCursor);
                return true;
            }

        return false;
    }

    public bool onMouseButtonPress (TradingView tv, int button, int x, int  y,  long time, float Price) override{
        if (__currentObject != nilptr && __currentObject != this) {
            return false;
        }

        XTraderExecuter executer = tv.getExecuter();

        if (slclsBtn != nilptr && slclsBtn.contains (x, y) ) {
            sl_price = -1;
            executer.modify (nilptr, 0, tickid, isPos ? CMD_MODIFY_POS : CMD_MODIFY_ORDER, open_price, sl_price, tp_price, lots);
            return true;
        } else if (tpclsBtn != nilptr && tpclsBtn.contains (x, y) ) {
            tp_price = -1;
            executer.modify (nilptr, 0, tickid, isPos ? CMD_MODIFY_POS : CMD_MODIFY_ORDER, open_price, sl_price, tp_price, lots);
            return true;
        } else if (clsBtn != nilptr && clsBtn.contains (x, y) ) {
            if (isPos) {
                // 平仓
                if (Setting.isCloseConfirm() == false) {
                    close (executer);
                } else {
                    TradingData data = tv.currentData();
                    if (data != nilptr && XTMessageBox.MessageBoxYesNo (tv,
                                                      "注意",
                                                      "是否对订单 [" + tickid + "] 进行平仓, 将获利 " + String.format ("%.2f " + data.getCurrencyProfit(), profit) + "?",
                                                      "平仓",
                                                      nilptr,
                                                      "取消",
                                                      nilptr,
                                                      0,
                                                      false) == QMessageBox.Yes)
                    {
                        close (executer);
                    }
                }
        
            } else {
                // 取消挂单
                executer.close (nilptr, CMD_ORDER_CANCEL, 0,  tickid);
            }
            OrderObject.__currentObject = nilptr;
            return true;
        } else if (tpBtn != nilptr && tpBtn.contains (x, y) ) {
            downId = 2;
            return true;
        } else if (slBtn != nilptr && slBtn.contains (x, y) ) {
            downId = 3;
            return true;
        } else if (!isPos && priceBtn != nilptr && priceBtn.contains (x, y) ) {
            downId = 0;
            return true;
        } else if (majorBtn != nilptr && majorBtn.contains (x, y) ) {
            if (__currentObject == nilptr) {
                __currentObject = this;
            }

            return true;
        } else if (__currentObject != nilptr) {
            __currentObject = nilptr;
        }

        return false;
    }
    public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price)override{
        return false;
    }
    public void close (XTraderExecuter executer) {
        executer.close (nilptr, CMD_ORDER_CLOSE, 0, tickid);
        int modifiers = QApplication.keyboardModifiers();

        if ( (modifiers & Constant.ControlModifier) == Constant.ControlModifier) {
            executer.createOrder (nilptr, 0, symbol, bBuy ? CMD_ORDER_MARKETS_SELL : CMD_ORDER_MARKETS_BUY, 0, 0, 0, lots);
        }
    }
    /*QRect drawTextButton (QPainter canvas, String text, int x, int y, int w, int h, int bc, int tc, int sc, int r) {
        QRect txtRect = new QRect();

        _paint.setColor (bc);
        canvas.setPaint (_paint);
        QFont nf = canvas.getFont();
        nf.setBold (true);
        canvas.setFont (nf);
        txtRect = canvas.measureText (0, 0, text);

        if (w < txtRect.width() + 8) {
            w = txtRect.width() + 8;
        }

        if (h < txtRect.height() + 4) {
            h = txtRect.height() + 4;
        }

        canvas.drawRoundedRect (x, y - h / 2, w, h, r, r, _paint);
        QRect ButtonRect = new QRect (x, y - h / 2, x + w, (y - h / 2) +  h);
        canvas.setPen (sc, PenStyle.SolidLine, 1);
        canvas.drawRect (x, y - h / 2, w, h);

        _paint.setColor (tc);
        canvas.setPaint (_paint);

        canvas.drawText (text, x + (w - txtRect.width() ) / 2.f, (y + h / 2) - (h  - (txtRect.height() - canvas.descent() ) )  / 2.f);
        return ButtonRect;
    }*/
};