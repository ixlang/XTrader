//xlang Source, Name:TradingView.x
//Date: Sun Jun 22:33:51 2025



enum DrawMode {
    NORMAL_K, // 正常K
    TREND_K,  // 折线
    USA_K   // 美国线
};

static const int SINGLE_BAR_WIDTH =  14;

class TradingView
    : QWidget {

    DrawMode KMode = DrawMode.NORMAL_K;
    public static int buyColor = 0xff2962FF, sellColor = 0xffF23645;
    public int  clrText = 0xffcecece;
    public QImage location = OrderObject.de_location;
    public static byte [] logicodata = __xPackageResource ("assets/res/logo.png");
    public static QImage ico_logo = new QImage (logicodata, "png");
    public static byte [] logodata = __xPackageResource ("assets/res/ic_launcher.png");

    public static byte [] darktheme = __xPackageResource ("configure/dark.cfg");
    public static byte [] lighttheme = __xPackageResource ("configure/light.cfg");
    static const float MAXZOOMWIDTH = 50, MINZOOMWIDTH = 0.4, VIEW_SPLITER = 5;
    public static QIcon win_logo = nilptr;
    bool drawMode = false;
    DrawObject currentObject = nilptr;
    DrawObject currentSelected = nilptr;
    Vector<ViewButton> orderobject = new Vector<ViewButton>();
    ContextMenu chatMenus = new ContextMenu();
    QRect chatRect = new QRect();
    TVToolBar toolbar = new TVToolBar();
    
    XTickChat tickView = new XTickChat();
    HisIndic currentHistory = nilptr;
    Position currentHistoryPosition = nilptr;
    bool bDrawDaySplit = true;
    String sPriceFormat = "%.2f";
    String sTimeFormat = "%Y-%m-%d %H:%M";
    XTraderExecuter executer = nilptr;
    IndicatorShell catchedIndic = nilptr;
    IndicatorShell capturedIndicator = nilptr;
    
    bool bAllowAlone = true;
    int VolumeHeight = 100;
    
    int _chatHeight = 0;
    
    public int getChatWidth() {
        return fullWid;
    }

    bool showAsk = true, showTimeremain = true, showGrid = true, isDrawVol = true, showkNum = true, showSymbol = true, showTickView = true, showToolbars = true;

    public int getRiseClr() {
        return riseClr;
    }

    public void setTheme (bool bdark) {
        if (bdark) {
            loadConfigure (new JsonObject (new String (darktheme) ) );
        } else {
            loadConfigure (new JsonObject (new String (lighttheme) ) );
        }

        String fstr = Preference.getString ("chat_font");

        if (TextUtils.isEmpty (fstr) == false) {
            yaheiHy = QFont.loadFromString (fstr);
        }

        sTimeFormat = Preference.getString ("timeformat");
        showAsk = Preference.getBool ("askshow");
        showTimeremain = Preference.getBool ("timeremain");
        isDrawVol = Preference.getBool ("showvol");
        showkNum = Preference.getBool ("showknum");
        showSymbol = Preference.getBool ("showwm");
        showTickView = Preference.getBool ("tickview");
        showToolbars = Preference.getBool ("toolbar");
        showGrid = Preference.getBool ("grid");

        if (TextUtils.isEmpty (sTimeFormat) ) {
            sTimeFormat = "%Y-%m-%d %H:%M";
        }

        // 默认配置
        if (Setting.isCustomChatStyle() ) {
            backgroundClr = Setting.getChatBackColor();
            clrText = Setting.getChatForeColor();
            riseClr = Setting.getChatRiseColor();
            fallClr = Setting.getChatFallColor();
            lineColor = Setting.getChatGridColor();
            borderClr = Setting.getChatBorderColor();
            KMode = (DrawMode) Setting.getKMode();
        }
    }

    public void setAllowAlone (bool b) {
        chatMenus.setEnable (72, b);
        chatMenus.setEnable (73, !b);
        bAllowAlone = b;

        if (!b ) {
            if (win_logo == nilptr) {
                win_logo = new QIcon (logodata, 0, logodata.length);
            }

            if (win_logo != nilptr) {
                setWindowIcon (win_logo);
            }
        }
    }

    public int backgroundColor() {
        return backgroundClr;
    }

    public int getFallClr() {
        return fallClr;
    }

    public void onResize (int w, int h, int ow, int oh) override {
        toolbar.relocal (this);
        tickView.relocal (this);

        if (data != nilptr) {
            float pointx = (BarWidth + sp) * data.xzoom;
            float leftest = pointx  + (data.xtranslate + _t_xtranslate);

            if (leftest > 50) {
                _t_xtranslate = 50  - (pointx + data.xtranslate);
            }

            int dcount = data.size();
            pointx = (BarWidth + sp) * dcount * data.xzoom;

            float rightest = pointx  + (data.xtranslate + _t_xtranslate);

            if (rightest <  fullWid / 2) {
                _t_xtranslate = (fullWid / 2)  - (pointx + data.xtranslate);
            }
        }
    }

    public double getBarWidth() {
        return BarWidth;
    }

    public double getSingleBarWidth() {
        return BarWidth + sp;
    }

    public void allPositionSL (bool buy, bool hasTp, double price) {
        if (data == nilptr) {
            return;
        }

        Map<String, OrderObject>  positions = data.getPositionsMap();

        if (positions.size() != 0) {
            var iter = positions.iterator();

            while (iter.hasNext() ) {
                OrderObject p = iter.getValue();

                if (p.isBuy() == buy) {
                    if ( (hasTp && hasTp == (p.Profit() > 0) ) || !hasTp) {
                        executer.modify (nilptr, 0, p.tickid, CMD_MODIFY_POS, p.open_price, price, p.tp_price, p.lots);
                    }
                }

                iter.next();
            }
        }
    }

    public void allPositionTP (bool buy, bool hasTp, double price) {
        if (data == nilptr) {
            return;
        }

        Map<String, OrderObject>  positions = data.getPositionsMap();

        if (positions.size() != 0) {
            var iter = positions.iterator();

            while (iter.hasNext() ) {
                OrderObject p = iter.getValue();

                if (p.isBuy() == buy) {
                    if ( (hasTp && hasTp == (p.Profit() > 0) ) || !hasTp) {
                        executer.modify (nilptr, 0, p.tickid, CMD_MODIFY_POS, p.open_price, p.sl_price, price, p.lots);
                    }
                }

                iter.next();
            }
        }
    }

    class ChatListener : public onEventListener {
        double price;
        public void setPrice (double p) {
            price = p;
        }
        public void onTrigger (QObject obj) override {
            if (data == nilptr) {
                return;
            }
            QColor qc = nilptr;
            int id = chatMenus.actions.indexOf ( (QAction) obj);

            switch (id) {
            case 0: /*TODO*/
                createPlacehold (price, true);
                break;

            case 1: /*TODO*/
                createPlacehold (price, false);
                break;

            case 3: /*TODO*/
                createMarketPrice (true);
                break;

            case 4: /*TODO*/
                createMarketPrice (false);
                break;

            case 7: //全部多单到此止损
                allPositionSL (true, false, price);
                break;

            case 8: //全部已盈利多单到此止损
                allPositionSL (true, true, price);
                break;

            case 9: //全部空单到此止损
                allPositionSL (false, false, price);
                break;

            case 10: //全部已盈利空单到此止损
                allPositionSL (false, true, price);
                break;

            case 13: //全部多单到此止盈
                allPositionTP (true, false, price);
                break;

            case 14: //全部已盈利多单到此止盈
                allPositionTP (true, true, price);
                break;

            case 15: //全部空单到此止盈
                allPositionTP (false, false, price);
                break;

            case 16: //全部已盈利空单到此止盈
                allPositionTP (false, true, price);
                break;

            case 18: /*TODO*/
                KMode = DrawMode.NORMAL_K;
                break;

            case 19: /*TODO*/
                KMode = DrawMode.TREND_K;
                break;

            case 20: /*TODO*/
                KMode = DrawMode.USA_K;
                break;

            case 22: /*TODO*/
                ComponentList.showComponent (TradingView.this, currentData(), false);
                postUpdate();
                break;

            case 23: /*TODO*/
                IndicatorManager.showComponent (TradingView.this, currentData() );
                postUpdate();
                break;

            case 26: // 买价线
                showAsk = !showAsk;
                postUpdate();
                break;

            case 27: // 倒计时
                showTimeremain = !showTimeremain;
                postUpdate();
                break;

            case 28: // 网格
                showGrid = !showGrid;
                postUpdate();
                break;

            case 29: // 成交量
                isDrawVol = !isDrawVol;
                postUpdate();
                break;

            case 30: // K序号
                showkNum = !showkNum;
                postUpdate();
                break;

            case 31: // 品种名称
                showSymbol = !showSymbol;
                postUpdate();
                break;

            case 33: // 背景色
                qc = QColorDialog.getColor ("选择背景色", TradingView.this, backgroundClr);
                if (qc.isValid()){
                    backgroundClr = qc.value();
                    toolbar.refresh (TradingView.this);
                    postUpdate();
                }
                break;

            case 34: // 前景色
                qc = QColorDialog.getColor ("选择前景色", TradingView.this, clrText);
                if (qc.isValid()){
                    clrText = qc.value();
                    postUpdate();
                }
                break;

            case 35: // 上涨K
                qc = QColorDialog.getColor ("选择上涨色", TradingView.this, riseClr);
                if (qc.isValid()){
                    riseClr = qc.value();
                    postUpdate();
                }
                break;

            case 36: // 下跌K
                qc =QColorDialog.getColor ("选择下跌色", TradingView.this, fallClr);
                if (qc.isValid()){
                    fallClr = qc.value();
                    postUpdate();
                }
                break;

            case 37: // 网格色
                qc =QColorDialog.getColor ("选择网格线颜色", TradingView.this, lineColor);
                if (qc.isValid()){
                    lineColor = qc.value();
                    postUpdate();
                }
                break;

            case 38: // 网格色
                qc =QColorDialog.getColor ("选择边栏背景颜色", TradingView.this, borderClr);
                if (qc.isValid()){
                    borderClr = qc.value();
                    postUpdate();
                }
                break;

            case 39: // 网格色
                String fstr = QFontDialog.getFontDialog ("选择字体", yaheiHy.toString(), TradingView.this);

                if (fstr != nilptr) {
                    Preference.setSetting ("chat_font", fstr);
                    yaheiHy = QFont.loadFromString (fstr);
                    symbolImage = nilptr;
                }

                postUpdate();
                break;

            case 40: // 品种名称
                showTickView = !showTickView;
                tickView.relocal (TradingView.this);
                postUpdate();
                break;

            case 41: // 交易日分割线
                bDrawDaySplit = !bDrawDaySplit;
                postUpdate();
                break;

            case 43: { // 保存图片
                String szfile = QFileDialog.getSaveFileName ("保存图片", "", "PNG图像 (*.png)", TradingView.this);
                if (TextUtils.isEmpty (szfile) == false) {
                    QImage _dbuffer = new QImage (width(), height(), QImage.Format_ARGB32);
                    QPainter __canvas = new QPainter (_dbuffer);
                    setHideCross(true);
                    drawTrading (__canvas, width(), height());
                    setHideCross(false);
                    _dbuffer.saveToFile (szfile, "png", 9);
                }
            }
            break;

            case 44: { // 加载方案
                String filepath = QFileDialog.getOpenFileName ("保存方案", AssetsManager.getDataDir().appendPath ("chatcfg"), "*.cfg", TradingView.this);

                if (TextUtils.isEmpty (filepath) == false) {
                    FileInputStream fos = nilptr;

                    try {
                        fos = new FileInputStream (filepath);
                        JsonObject conf = new JsonObject (new String (fos.readAllBytes() ) );
                        fos.close();
                        fos = nilptr;
                        loadConfigure (conf);
                    } catch (Exception e) {

                    } finally {
                        if (fos != nilptr) {
                            fos.close();
                        }
                    }

                }
            }
            break;

            case 45: { // 保存方案
                JsonObject conf = new JsonObject();
                conf.put ("showask", showAsk);
                conf.put ("countdown", showTimeremain);
                conf.put ("showgrid", showGrid);
                conf.put ("showvolume", isDrawVol);
                conf.put ("barindex", showkNum);
                conf.put ("symbolwm", showSymbol);
                conf.put ("background", backgroundClr);
                conf.put ("foreground", clrText);
                conf.put ("riseclr", riseClr);
                conf.put ("fallclr", fallClr);
                conf.put ("gridclr", lineColor);
                conf.put ("borderclr", borderClr);
                conf.put ("font", yaheiHy.toString() );
                conf.put ("kmode", KMode.value() );

                String filepath = QFileDialog.getSaveFileName ("保存方案", AssetsManager.getDataDir().appendPath ("chatcfg"), "*.cfg", TradingView.this);

                if (TextUtils.isEmpty (filepath) == false) {
                    try {
                        FileOutputStream fos = new FileOutputStream (filepath);
                        fos.write (conf.toString().getBytes() );
                        fos.close();
                    } catch (Exception e) {

                    }

                }
            }
            break;

            case 48://1M
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "1");
                }

                break;

            case 49:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "2");
                }

                break;

            case 50:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "3");
                }

                break;

            case 51:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "4");
                }

                break;

            case 52:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "5");
                }

                break;

            case 53:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "6");
                }

                break;

            case 54:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "10");
                }

                break;

            case 55:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "12");
                }

                break;

            case 56:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "15");
                }

                break;

            case 57:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "20");
                }

                break;

            case 58:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "30");
                }

                break;

            case 59:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "16385");
                }

                break;

            case 60:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "16386");
                }

                break;

            case 61:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "16387");
                }

                break;

            case 62:
                if (executer != nilptr) {
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "16388");
                }

                break;

            case 63:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "16390");
                }

                break;

            case 64:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "16392");
                }

                break;

            case 65:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "16396");
                }

                break;

            case 66:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "16408");
                }

                break;

            case 67:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "32769");
                }

                break;

            case 68:
                if (executer != nilptr) {
                    showWait(true, "加载中...");
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "49153");
                }

                break;

            case 71:
                showToolbars = !showToolbars;
                postUpdate();
                break;

            case 72:
                TradingView tv = new TradingView();

                if (tv.create() ) {
                    tv.onInit();
                    tv.setup (data);
                    tv.setAllowAlone (false);
                    tv.show();
                }

                reset();
                break;

            case 73:
                if ( (WindowFlags() & (int) WindowType.WindowStaysOnTopHint) != 0) {
                    setWindowFlags (WindowFlags() & ~ (int) WindowType.WindowStaysOnTopHint);
                } else {
                    setWindowFlags (WindowFlags() | (int) WindowType.WindowStaysOnTopHint);
                }

                show();
                break;

            case 74:
                TradingData data = currentData();

                if (data != nilptr) {
                    data.cleanAndReload();
                    executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "" + (int) data.currentPeriod() );
                    symbolImage = nilptr;
                    _system_.gc();
                }

                break;

            default:
                break;
            }
        }
    };

    public void loadConfigure (JsonObject conf) {
        showAsk = conf.getBool ("showask");
        showTimeremain = conf.getBool ("countdown");
        showGrid = conf.getBool ("showgrid");
        isDrawVol = conf.getBool ("showvolume");
        showkNum = conf.getBool ("barindex");
        showSymbol = conf.getBool ("symbolwm");
        backgroundClr = conf.getInt ("background");
        clrText = conf.getInt ("foreground");
        riseClr = conf.getInt ("riseclr");
        fallClr = conf.getInt ("fallclr");
        lineColor = conf.getInt ("gridclr");
        borderClr = conf.getInt ("borderclr");
        KMode = (DrawMode) conf.getInt ("kmode");
        String sfont = conf.getString ("font");


        if (TextUtils.isEmpty (sfont) != false) {
            yaheiHy = QFont.loadFromString (sfont);
        }

        toolbar.refresh (this);
        postUpdate();
    }

    ChatListener chatListener = new ChatListener();


    public void onAttach() override {
        onInit();
    }

    ToolbarListener toolevent = new ToolbarListener() {
        public void onItemClick (OBJECT_TYPE t) override {
            beginDraw (t);
        }
        public void onSettingClick() override {

        }
    };

    void initToolBars() {
        toolbar.create (toolevent);
        toolbar.addTool (OBJECT_TYPE.OBJECT_HLINE);
        toolbar.addTool (OBJECT_TYPE.OBJECT_VLINE);
        toolbar.addTool (OBJECT_TYPE.OBJECT_FB);
        toolbar.addTool (OBJECT_TYPE.OBJECT_TRENDLINE);
        toolbar.addTool (OBJECT_TYPE.OBJECT_XABCD);
        toolbar.addTool (OBJECT_TYPE.OBJECT_ALARM);
        toolbar.addTool (OBJECT_TYPE.OBJECT_ARRAWLEFT);
        toolbar.addTool (OBJECT_TYPE.OBJECT_ARRAWRIGHT);
        toolbar.addTool (OBJECT_TYPE.OBJECT_ARRAWUP);
        toolbar.addTool (OBJECT_TYPE.OBJECT_ARRAWDOWN);
        toolbar.addTool (OBJECT_TYPE.OBJECT_TRIANGLE);
        toolbar.addTool (OBJECT_TYPE.OBJECT_CHANNEL);
        toolbar.addTool (OBJECT_TYPE.OBJECT_ANDREW);
        toolbar.addTool (OBJECT_TYPE.OBJECT_TEXT);
        toolbar.addTool (OBJECT_TYPE.OBJECT_LINTETO);
    }

    public void onInit() {
        createContextMenu (this);
        paint.setStyle (QPainter.Paint.FILL_AND_STROKE);
        setCursor (Constant.CrossCursor);
        paint.setStrokeWidth (1);
        initToolBars();
        trendpaint.setStyle (QPainter.Paint.FILL_AND_STROKE);
        trendpaint.setStrokeWidth (2);

        setTheme (Setting.isDarkTheme() );
        chatMenus.setEnable (73, false);
        String fstr = Preference.getString ("chat_font");

        if (TextUtils.isEmpty (fstr) == false) {
            yaheiHy = QFont.loadFromString (fstr);
        }

        if (yaheiHy == nilptr) {
            yaheiHy = getFont();
        }


    }

    public bool beginDraw (OBJECT_TYPE type) {
        if (data == nilptr) {
            return false;
        }

        if (type == OBJECT_TYPE.OBJECT_FB) {
            currentObject = new Fibonacci();
        } else if (type == OBJECT_TYPE.OBJECT_HLINE) {
            currentObject = new HLine();
        } else if (type == OBJECT_TYPE.OBJECT_TRENDLINE) {
            currentObject = new TrendLine();
        } else if (type == OBJECT_TYPE.OBJECT_XABCD) {
            currentObject = new XABCDObject();
        } else if (type == OBJECT_TYPE.OBJECT_VLINE) {
            currentObject = new VLine();
        } else if (type == OBJECT_TYPE.OBJECT_ALARM) {
            currentObject = new Alarm();
        } else if (type == OBJECT_TYPE.OBJECT_ARRAWLEFT) {
            currentObject = new Arraw (type);
        } else if (type == OBJECT_TYPE.OBJECT_ARRAWRIGHT) {
            currentObject = new Arraw (type);
        } else if (type == OBJECT_TYPE.OBJECT_ARRAWUP) {
            currentObject = new Arraw (type);
        } else if (type == OBJECT_TYPE.OBJECT_ARRAWDOWN) {
            currentObject = new Arraw (type);
        } else if (type == OBJECT_TYPE.OBJECT_TRIANGLE) {
            currentObject = new Triangle();
        } else if (type == OBJECT_TYPE.OBJECT_CHANNEL) {
            currentObject = new Channel();
        } else if (type == OBJECT_TYPE.OBJECT_ANDREW) {
            currentObject = new Andrew();
        } else if (type == OBJECT_TYPE.OBJECT_TEXT) {
            currentObject = new TextLabel();
        } else if (type == OBJECT_TYPE.OBJECT_LINTETO) {
            currentObject = new LongArraw();
        } else {
            return false;
        }

        setCursor (Constant.CrossCursor);
        setHideCross (!currentObject.isNeedCross() );
        drawMode = true;
        setFocus();
        return true;
    }


    class ViewButton : public DrawObject {
        int bkClr, txtClr, StrokeClr;

        QPainter.Paint _paint = new QPainter.Paint();
        String label;
        bool marketPrice = false;
        bool bBuy = false;
        public float open_price = -1;
        public float sl_price = -1;
        public float tp_price = -1;
        public float lots = 0;
        public int createCount = 0;
        public void relocal (Vector<Bar> bars)override {}
        int downId = -1;
        QRect majorBtn, priceBtn, slBtn, tpBtn, clsBtn, slclsBtn, tpclsBtn, lotbtn;
        public OBJECT_TYPE getType() override{
            return OBJECT_TYPE.OBJECT_BUTTON;
        }

        public CommonConfigure getConfigure() override{
            return nilptr;
        }
        public void updateConfigure() override{
            // 更新配置
        }
        public bool isMarketPrice() {
            return marketPrice;
        }
        public bool isBuy() {
            return bBuy;
        }
        public bool isNeedCross() override{
            return true;
        }
        public void onRemove (TradingView tv) override{}
        public ViewButton (bool buy, float openprice) {
            bBuy = buy;
            open_price = openprice;

            if (data != nilptr) {
                lots = Preference.getDouble (Dialog.UserIdent() + "_lot_" + data.getCurrentSymbol() );

                if (lots <= 0) {
                    lots = data.minLots();
                }
            } else {
                lots = 0.01;
            }

            if (Setting.isSavePosCount()){
                createCount = Preference.getInt (Dialog.UserIdent() + "_count_" + data.getCurrentSymbol() );

                if (createCount <= 0 ) {
                    createCount = 1;
                }
            }else{
                createCount = 1;
            }

            if (openprice == -1) {
                marketPrice = true;
            }

            label = bBuy ? "买入" : "卖出";
            txtClr = 0xffffffff;

            if (buy) {
                StrokeClr = bkClr = riseClr;
            } else {
                StrokeClr = bkClr = fallClr;
            }

            _paint.setStyle (QPainter.Paint.FILL_AND_STROKE);
            _paint.setStrokeWidth (1);
        }

        public bool onMouseButtonDblClick (TradingView tv, int button, int x, int  y,  long time, float Price) override{
            return false;
        }
        public void drawTrading (TradingView tv, QPainter canvas, float xzoom, float yzoom, int w, int h) override{
            canvas.setAntialiasing (true);
            float py = priceToY (open_price);
            canvas.setPen (0xff357C95, PenStyle.DashDotLine, 0.5);
            canvas.drawLine (0, py, w, py);

            int nextR = w - 50;
            clsBtn = TradingView.drawImageOnCenter (canvas, OrderObject.closeImg, nextR, py, 16, 16);
            nextR -= (16 + 15);

            if (tp_price == -1) {
                tpBtn = drawTextButton (canvas, "TP", nextR, py, 35, 20, backgroundClr, 0xff2962FF, 0xff2962FF,  3, _paint);
                nextR -= (tpBtn.width() + 15);
            }

            if (sl_price == -1) {
                slBtn = drawTextButton (canvas, "SL", nextR, py, 35, 20, backgroundClr, 0xffF23645, 0xffF23645,  3, _paint);
                nextR -= (slBtn.width() + 15);
            }

            String priceFormat = data.getPriceFormater();

            lotbtn = drawTextButton (canvas, String.format ("%g 手 ×️ %d", lots, createCount), nextR, py, 50, 20, backgroundClr, bkClr, bkClr,  3, _paint);
            nextR -= (lotbtn.width() + 15);

            if (!marketPrice) { // 如果是市价单的话
                priceBtn = drawTextButton (canvas, String.format (priceFormat, open_price), nextR, py, 50, 20, bkClr, txtClr, StrokeClr,  3, _paint);
                nextR -= (priceBtn.width() + 15);

                majorBtn = drawTextButton (canvas, label, nextR, py, 50, 20, bBuy ? buyColor : sellColor, txtClr, bBuy ? buyColor : sellColor,  3, _paint);
                nextR -= (majorBtn.width() + 15);
            } else {
                majorBtn = drawTextButton (canvas, String.format ("以 " + priceFormat + " ", open_price) + label, nextR, py, 50, 20, bBuy ? buyColor : sellColor, txtClr, StrokeClr,  3, _paint);
                nextR -= (majorBtn.width() + 15);
            }

            bool bdisplayPY = Setting.getPLDisplayMode() == 1;
            double mpt = (1.0 / Math.pow (10, data.getDigits() ) );
            double pv = data.pointValue() / (mpt);
            String szDisplay = "";

            if (sl_price != -1) {
                py = priceToY (sl_price);
                canvas.setPen (fallClr, PenStyle.DashDotDotLine, 0.5);
                canvas.drawLine (0, py, w, py);
                nextR = w - 50;
                slclsBtn = drawImageOnCenter (canvas, OrderObject.closeImg, nextR, py, 16, 16);
                nextR -= (16 + 15);

                if (bdisplayPY) {
                    szDisplay = String.format ("%d PT", (int) ( (bBuy ? (sl_price - open_price) : (open_price - sl_price) ) / mpt ) );
                } else {
                    szDisplay = String.format ("%.2f " + data.getCurrencyProfit(), lots * pv * ( (bBuy ? (sl_price - open_price) : (open_price - sl_price) ) ) );
                }

                slBtn = drawTextButton (canvas, "SL:" + szDisplay, nextR, py, 50, 20, backgroundClr, 0xffF23645, 0xffF23645,  3, _paint);
                tv.drawTextOnRect (canvas, String.format (sPriceFormat, sl_price), fullWid - TextAreaWid, py, TextAreaWid + 8, TextAreaHei,  0xff47181C, 0xffffffff, 0);
            }

            if (tp_price != -1) {
                py = priceToY (tp_price);
                canvas.setPen (riseClr, PenStyle.DashDotDotLine, 0.5);
                canvas.drawLine (0, py, w, py);
                nextR = w - 50;

                tpclsBtn = drawImageOnCenter (canvas, OrderObject.closeImg, nextR, py, 16, 16);
                nextR -= (16 + 15);

                if (bdisplayPY) {
                    szDisplay = String.format ("%d PT", (int) ( (bBuy ? (tp_price - open_price) : (open_price - tp_price) ) / mpt ) );
                } else {
                    szDisplay = String.format ("%.2f " + data.getCurrencyProfit(), lots * pv * ( (bBuy ? (tp_price - open_price) : (open_price - tp_price) ) ) );
                }

                tpBtn = drawTextButton (canvas, "TP:" + szDisplay, nextR, py, 50, 20, backgroundClr, 0xff2962FF, 0xff2962FF,  3, _paint);
                tv.drawTextOnRect (canvas, String.format (sPriceFormat, tp_price), fullWid - TextAreaWid, py, TextAreaWid + 8, TextAreaHei,  0xff15234A, 0xffffffff, 0);
            }

            canvas.setAntialiasing (false);
        }

        public bool onMouseButtonRelease (TradingView tv, int button, int x, int  y,  long time, float Price) override{
            if (downId != -1) {
                downId = -1;
                setHideCross (false);
                return true;
            }

            return false;
        }

        public bool onMouseMove (TradingView tv, int button, int x, int  y,  long time, float Price) override{
            if (!marketPrice && downId == 0) {
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
                setCursor (Constant.PointingHandCursor);
                QPoint pt = mapToGlobal (x, y);
                ShowToolTips (pt.x, pt.y, "取消", 5000);
                return true;
            } else if (lotbtn != nilptr &&  lotbtn.contains (x, y) ) {
                setCursor (Constant.PointingHandCursor);
                QPoint pt = mapToGlobal (x, y);
                ShowToolTips (pt.x, pt.y, "单击修改交易数量", 5000);
                return true;
            } else if (slclsBtn != nilptr && slclsBtn.contains (x, y) ) {
                setCursor (Constant.PointingHandCursor);
                QPoint pt = mapToGlobal (x, y);
                ShowToolTips (pt.x, pt.y, "取消止损", 5000);
                return true;
            } else if (tpclsBtn != nilptr && tpclsBtn.contains (x, y) ) {
                setCursor (Constant.PointingHandCursor);
                QPoint pt = mapToGlobal (x, y);
                ShowToolTips (pt.x, pt.y, "取消止盈", 5000);
                return true;
            } else if ( (majorBtn != nilptr && majorBtn.contains (x, y) ) ) {
                setCursor (Constant.PointingHandCursor);
                QPoint pt = mapToGlobal (x, y);
                ShowToolTips (pt.x, pt.y, "提交订单", 5000);
                return true;
            } else if (!marketPrice && priceBtn != nilptr && priceBtn.contains (x, y) ) {
                setCursor (Constant.SizeVerCursor);
                QPoint pt = mapToGlobal (x, y);
                ShowToolTips (pt.x, pt.y, "拖动修改价格", 5000);
                return true;
            } else if ( (slBtn != nilptr && slBtn.contains (x, y) ) || (tpBtn != nilptr && tpBtn.contains (x, y) ) ) {
                setCursor (Constant.SizeVerCursor);
                return true;
            }

            return false;
        }

        public bool onMouseButtonPress (TradingView tv, int button, int x, int  y,  long time, float Price) override{

            if (slclsBtn != nilptr && slclsBtn.contains (x, y) ) {
                sl_price = -1;
                return true;
            } else if (tpclsBtn != nilptr && tpclsBtn.contains (x, y) ) {
                tp_price = -1;
                return true;
            } else if (clsBtn != nilptr && clsBtn.contains (x, y) ) {
                cancelPlaceHold (this);
                return true;
            } else if (lotbtn != nilptr && lotbtn.contains (x, y) ) {
                DigiInput.requestInput (TradingView.this, new DigiInput.onInputListener() {
                    public bool onInputOk (DigiInput dlg, String text, String sCount) override {
                        double value = text.parseDouble();
                        int _count = sCount.parseInt();

                        if (_count < 1) {
                            dlg.setError ("不正确的仓位数量!");
                            return false;
                        }


                        if (value < data.minLots() || value > data.maxLots() ) {
                            dlg.setError ("不正确的交易量!");
                            return false;
                        }


                        Preference.setSetting (Dialog.UserIdent() + "_lot_" + data.getCurrentSymbol(), value);
                        if (Setting.isSavePosCount()){
                            Preference.setSetting (Dialog.UserIdent() + "_count_" + data.getCurrentSymbol(), createCount);
                        }
                        lots = value ;
                        createCount = _count;

                        return true;
                    }
                    public bool onInputCancel (DigiInput) override {
                        return true;
                    }
                    public void onChange (DigiInput dlg, String text, String minlots) override {

                    }
                    public String getTitle() override {
                        return "确认交易量";
                    }
                    public String getDefault() override {
                        return String.format ("%.2f", lots);
                    }
                    public String getDefaultCount() override {
                        return String.format ("%d", createCount);
                    }
                    public String getDescription() override {
                        return "请输入交易量("  + data.minLots()  + " ~ " + data.maxLots() + ")";
                    }
                    public void onInit (DigiInput dlg) override {
                    }
                });
                return true;
            } else if (!marketPrice && priceBtn != nilptr && priceBtn.contains (x, y) ) {
                downId = 0;
                setHideCross (true);
                return true;
            } else if (tpBtn != nilptr && tpBtn.contains (x, y) ) {
                downId = 2;
                setHideCross (true);
                return true;
            } else if (slBtn != nilptr && slBtn.contains (x, y) ) {
                downId = 3;
                setHideCross (true);
                return true;
            } else if ( (majorBtn != nilptr && majorBtn.contains (x, y) ) ) {
                if (data.tradeAllowed() == false) {
                    XTMessageBox.MessageBoxYesNo (tv,
                                                  "注意",
                                                  "该品种不在交易时段!",
                                                  "好",
                                                  nilptr,
                                                  nilptr,
                                                  nilptr,
                                                  0,
                                                  false);
                    return true;
                }

                if (isMarketPrice() ) { // 假如是市价单
                    for (int i = 0; i < createCount; i++) {
                        executer.createOrder (nilptr, 0, getCurrentSymbol(), bBuy ? CMD_ORDER_MARKETS_BUY : CMD_ORDER_MARKETS_SELL, open_price, sl_price, tp_price, lots);
                    }
                } else if (data != nilptr) {
                    for (int i = 0; i < createCount; i++) {
                        if (bBuy) {
                            if (open_price > data.getAsk() ) { //开仓价大于买价
                                executer.createOrder (nilptr, 0, getCurrentSymbol(), CMD_ORDER_BUYSTOP, open_price, sl_price, tp_price, lots);
                            } else {
                                executer.createOrder (nilptr, 0, getCurrentSymbol(), CMD_ORDER_BUYLIMIT, open_price, sl_price, tp_price, lots);
                            }
                        } else {
                            if (open_price > data.getBid() ) { //开仓价大于买价
                                executer.createOrder (nilptr, 0, getCurrentSymbol(), CMD_ORDER_SELLLIMIT, open_price, sl_price, tp_price, lots);
                            } else {
                                executer.createOrder (nilptr, 0, getCurrentSymbol(), CMD_ORDER_SELLSTOP, open_price, sl_price, tp_price, lots);
                            }
                        }
                    }
                }

                cancelPlaceHold (this);
                return true;
            }

            return false;
        }

    };

    public static QRect drawImageOnCenter (QPainter canvas, QImage img, int x, int y, int w, int h) {
        QRect dst = new QRect (x - w,  y - h / 2, x, y + h / 2);
        canvas.drawImage (img, dst, new QRect (0, 0, img.width(), img.height() ), 0);
        return dst;
    }

    public static QRect drawTextButton (QPainter canvas, String text, int r, int y, int w, int h, int bc, int tc, int sc, int rr, QPainter.Paint _paint) {
        QRect txtRect = new QRect();

        _paint.setColor (bc);
        canvas.setPaint (_paint);
        canvas.setBold (true);
        txtRect = canvas.measureText (0, 0, text);

        if (w < txtRect.width() + 8) {
            w = txtRect.width() + 8;
        }

        if (h < txtRect.height() + 4) {
            h = txtRect.height() + 4;
        }

        int x = r - w;

        QRect ButtonRect = new QRect (x, y - h / 2, x + w, y + h / 2);

        canvas.drawRoundedRect (ButtonRect, rr, rr, _paint);
        canvas.setPen (sc, PenStyle.SolidLine, 1);
        canvas.drawRect (ButtonRect);

        _paint.setColor (tc);
        canvas.setPaint (_paint);

        canvas.drawText (text, ButtonRect, Constant.AlignHCenter | Constant.AlignVCenter);
        return ButtonRect;
    }

    void setActionText (int n, String text) {
        mainMenu.actions[n].setText (text);
    }

    class TREvent : public onEventListener {
        float price = 0;
        public void setPrice (float p) {
            price = p;
        }
        void onTrigger (QObject obj) override {
            if (obj == mainMenu.actions[0]) {
                createAlaramOnPrice (price);
                return;
            }

            if (obj == mainMenu.actions[2]) {
                createPlacehold (price, true);
                return;
            }

            if (obj == mainMenu.actions[3]) {
                createPlacehold (price, false);
                return ;
            }

            if (obj == mainMenu.actions[5]) {
                createMarketPrice (true);
                return ;
            }

            if (obj == mainMenu.actions[6]) {
                createMarketPrice (false);
                return ;
            }

            if (obj == mainMenu.actions[8]) {
                createHLineOnPrice (price);
                return ;
            }
        }
    };

    TREvent _mevent = new TREvent();

    void createContextMenu (QWidget window) {
        mainMenu.createPopup (this, new String [] {"添加警报",  "-", "建立买入挂单", "建立卖出挂单", "-", "建立市价买单", "建立市价卖单", "-", "添加水平线"}, _mevent);
        mainMenu.enableAll (true);

        mainMenu.actions[0].setIcon (AssetsManager.getResource ("res/toolbar/alarm.png") );
        mainMenu.actions[2].setIcon (AssetsManager.getResource ("res/toolbar/buy_hold.png") );
        mainMenu.actions[3].setIcon (AssetsManager.getResource ("res/toolbar/sell_hold.png") );
        mainMenu.actions[5].setIcon (AssetsManager.getResource ("res/toolbar/buy.png") );
        mainMenu.actions[6].setIcon (AssetsManager.getResource ("res/toolbar/sell.png") );
        mainMenu.actions[8].setIcon (AssetsManager.getResource ("res/toolbar/HLINE.png") );

        chatMenus.create (this,
                          new String [] {"挂单买入", "挂单卖出",  "-", "市价买入", "市价卖出", "-", ">>止损",
                                         "全部多单到此止损", "全部已盈利多单到此止损", "全部空单到此止损", "全部已盈利空单到此止损", "<<",
                                         ">>止盈",
                                         "全部多单到此止盈", "全部已盈利多单到此止盈", "全部空单到此止盈", "全部已盈利空单到此止盈", "<<",
                                         "阴阳烛", "折线", "美国线",  "-", "对象列表", "指标列表", "-",
                                         ">>设置", "买价线",  "倒计时",  "网格", "成交量", "K线序号", "品种名称", "-", "背景色", "前景色", "上涨K颜色",
                                         "下跌K颜色", "网格颜色", "边栏背景色", "字体", "Tick视图", "交易日分割线",  "<<", "保存为图片", "加载方案", "保存方案", "-", ">>时间周期", "1 Min",
                                         "2 Min", "3 Min", "4 Min", "5 Min", "6 Min", "10 Min", "12 Min", "15 Min", "20 Min", "30 Min", "1 Hour", "2 Hours",
                                         "3 Hours", "4 Hours", "6 Hours", "8 Hours", "12 Hours", "1 Day", "1 Week", "1 Month", "<<",
                                         "-", "工具栏", "独立视图", "保持置顶", "刷新"
                                        }, chatListener, nilptr, 0);

        chatMenus.actions[0].setIcon (AssetsManager.getResource ("res/toolbar/buy_hold.png") );
        chatMenus.actions[1].setIcon (AssetsManager.getResource ("res/toolbar/sell_hold.png") );
        chatMenus.actions[3].setIcon (AssetsManager.getResource ("res/toolbar/buy.png") );
        chatMenus.actions[4].setIcon (AssetsManager.getResource ("res/toolbar/sell.png") );

        chatMenus.actions[18].setIcon (AssetsManager.getResource ("res/toolbar/kbar.png") );
        chatMenus.actions[19].setIcon (AssetsManager.getResource ("res/toolbar/line.png") );
        chatMenus.actions[20].setIcon (AssetsManager.getResource ("res/toolbar/usak.png") );
        /*String [] periodIcons = {
            AssetsManager.getResource("res/toolbar/m1.png"),
            AssetsManager.getResource("res/toolbar/M2.png"),
            AssetsManager.getResource("res/toolbar/M3.png"),
            AssetsManager.getResource("res/toolbar/M4.png"),
            AssetsManager.getResource("res/toolbar/M5.png"),
            AssetsManager.getResource("res/toolbar/M6.png"),
            AssetsManager.getResource("res/toolbar/M10.png"),
            AssetsManager.getResource("res/toolbar/M12.png"),
            AssetsManager.getResource("res/toolbar/M15.png"),
            AssetsManager.getResource("res/toolbar/M20.png"),
            AssetsManager.getResource("res/toolbar/M30.png"),
            AssetsManager.getResource("res/toolbar/H1.png"),
            AssetsManager.getResource("res/toolbar/H2.png"),
            AssetsManager.getResource("res/toolbar/H3.png"),
            AssetsManager.getResource("res/toolbar/H4.png"),
            AssetsManager.getResource("res/toolbar/H6.png"),
            AssetsManager.getResource("res/toolbar/H8.png"),
            AssetsManager.getResource("res/toolbar/H12.png"),
            AssetsManager.getResource("res/toolbar/D1.png"),
            AssetsManager.getResource("res/toolbar/W1.png"),
            AssetsManager.getResource("res/toolbar/MN.png")
        };*/

        chatMenus.actions[18].setCheckable (true);
        chatMenus.actions[19].setCheckable (true);
        chatMenus.actions[20].setCheckable (true);
        chatMenus.actions[26].setCheckable (true);
        chatMenus.actions[27].setCheckable (true);
        chatMenus.actions[28].setCheckable (true);
        chatMenus.actions[29].setCheckable (true);
        chatMenus.actions[30].setCheckable (true);
        chatMenus.actions[31].setCheckable (true);
        chatMenus.actions[40].setCheckable (true);
        chatMenus.actions[41].setCheckable (true);
        chatMenus.actions[71].setCheckable (true);
        chatMenus.actions[73].setCheckable (true);

        for (int i = 48; i < 69; i++) {
            chatMenus.actions[i].setCheckable (true);
            //chatMenus.actions[i].setIcon (periodIcons[i - 48]);
        }

        chatMenus.enableAll (true);
    }

    public int getTextAreaHeight() {
        return TextAreaHei;
    }

    ContextMenu mainMenu = new ContextMenu();
    private TradingData data;
    int TextAreaWid = 0, TextAreaHei = 15;


    float _t_xtranslate = 0, _t_ytranslate = 0;

    int lineColor = 0xff1C1C1C;

    float BarWidth = 11, sp = 3, fullWid = 0;
    int riseClr = 0xff089981, fallClr = 0xffF23645, backgroundClr = 0xff0F0F0F, foreColor = 0xffffffff, borderClr = 0xff0f0f0f;
    QPainter.Paint paint = new QPainter.Paint();
    QPainter.Paint trendpaint = new QPainter.Paint();
    int sellClr = 0x6fF23645, buyClr = 0x6f2962D7;
    float mx = 0, my = 0;
    int btl,  btr;
    int trading_time = 0;
    int currentime = 0;
    int hoverIndex = -1;
    QFont smallFont = nilptr;
    QFont yaheiHy = nilptr;
    QRect locarc = new QRect();
    int timeZoneOffset = Calendar.getInstance().getTimeZoneOffset();
    QRect btnBuy = new QRect(), btnSell = new QRect();
    bool bHideCross = false;

    String currentSymbol = "XTrader";
    QImage symbolImage = nilptr;

    public void setHideCross (bool bh) {
        bHideCross = bh;
    }
    
    public int getBorderColor(){
        return borderClr;
    }
    
    public int getBackgroundColor(){
        return backgroundClr;
    }

    public XTraderExecuter getExecuter() {
        return executer;
    }

    public void resetTimePeriod() {
        symbolImage = nilptr;
        currentHistory = nilptr;

        if (bAllowAlone) {
            Dialog.UpdateActions();
        }
    }

    public void setup (TradingData _data) {
        reset();
        data = _data;

        if (data != nilptr) {
            _data.addbind (this);
            currentSymbol = data.getCurrentSymbol();
            symbolImage = nilptr;
            sPriceFormat = data.getPriceFormater();

            if (data.getSecondPeriod() > 3600) {
                bDrawDaySplit = false;
            }

            executer = _data.getExecuter();
            toolbar.refresh (this);
        }

        postUpdate();
    }

    public void reset() {
        drawMode = false;
        currentSelected = currentObject = nilptr;
        currentHistoryPosition = nilptr;
        currentHistory = nilptr;
        orderobject.clear();
        bdrawOrder = false;

        if (data != nilptr) {
            data.unbind (this);
            data = nilptr;
            currentSymbol = "";
        }

        postUpdate();
    }


    public void updateTime (long s) {
        if (data == nilptr) {
            return;
        }

        trading_time = s % data.getSecondPeriod();
        currentime = currentLocalTime();
        postUpdate();
    }

    long currentLocalTime() {
        if (data == nilptr) {
            return 0;
        }

        return (_system_.currentTimeMillis() / 1000) % data.getSecondPeriod();
    }

    public int getRemainSecond() {
        if (data == nilptr) {
            return 0;
        }

        return data.getSecondPeriod() - ( (currentLocalTime() - currentime) + trading_time);
    }

    public String getSymbol() {
        if (data != nilptr) {
            return data.getCurrentSymbol();
        }

        return nilptr;
    }

    public bool onClose() override {
        reset();
        return true;
    }

    public void onPaint (int l, int t, int r, int b, long hpaint) override{
        QPainter painter = new QPainter (hpaint);
        painter.setAntialiasing (true);
        QImage _dbuffer = new QImage (r - l, b - t, QImage.Format_ARGB32);
        QPainter __canvas = new QPainter (_dbuffer);
        //__canvas.setAntialiasing(true);
        drawTrading (__canvas, r - l, b - t);
        if (isWaiting){
            drawWaiting(__canvas, r - l, b - t);
        }
        painter.drawImage (_dbuffer, 0, 0);
        __canvas = nilptr;
        _dbuffer = nilptr;
        painter = nilptr;
    }
    
    bool isWaiting = false;
    String szWaitText = "加载中...";
    
    public void showWait(bool bw, String text){
        szWaitText = text;
        this.setContextMenuPolicy(bw ? Constant.NoContextMenu: Constant.ActionsContextMenu);
        isWaiting = bw;
        postUpdate();
    }
    
    
    public void drawWaiting(QPainter canvas, int w, int h){
        canvas.save();
        canvas.fillRect(0, 0, w, h, 0x99000000, QBrush.Style.SolidPattern);
        canvas.setAntialiasing(true);
        int dd = 48;
        int arc_width = 6;
        int cx = w / 2, cy = h / 2;
        canvas.setPen(0x4CFFFFFF, PenStyle.SolidLine, arc_width);
        canvas.setBrush(0, QBrush.Style.NoBrush);
        int x = cx - dd / 2, y = cy - dd / 2;
        canvas.drawArc(x, y, dd, dd, 0, 5760);
        int startAr = _system_.currentTimeMillis() % 1000 * 5760 / 1000;
        canvas.setPen(0xFFFFFFFF, PenStyle.SolidLine, arc_width);
        canvas.drawArc(x, y, dd, dd, -startAr, 1392);
        //QFont oldFont = canvas.getFont();
        canvas.setFontPointSize(18);
        canvas.drawText(szWaitText, new QRect(0, y + dd + 30, w, y + dd + 30 + 42), Constant.AlignCenter);
        canvas.setAntialiasing(false);
        canvas.restore();
        //canvas.setFont(oldFont);
        postUpdate();
    }

    public float getTextAreaWid() {
        return TextAreaWid;
    }

    public int getIndicatorsViewHeight(){
        Vector<IndicatorShell> ids = data.getIndicators();
        int total = 0;
        for (IndicatorShell s : ids) {
            if (s.hasView()){
                total += (VIEW_SPLITER + s.height());
            }
        }
        return total;
    }
    //maindraw
    public void drawTrading (QPainter canvas, int w, int h) {
        canvas.fillRect (0, 0, w, h, backgroundClr, QBrush.Style.SolidPattern);

        if (data == nilptr) {
            w -= 20;
            h -= 20;

            if (w < h) {
                float zrate = 1136.f / w;
                float t = (h - (939.f / zrate) ) / 2.0;
                canvas.drawImage (ico_logo, new QRect (10, t + 10, w - 10, h - t - 10), new QRect (0, 0, 1136, 939), 0);
            } else {
                float zrate = 939.f / h;
                float l = (w - (1136.f / zrate) ) / 2.0;
                canvas.drawImage (ico_logo, new QRect (l + 10, 10, w - l - 10, h - 10), new QRect (0, 0, 1136, 939), 0);
            }

            return;
        }

        float xt = (data.xtranslate + _t_xtranslate), yt = (data.ytranslate + _t_ytranslate);
        fullWid = w;


        if (showGrid) {
            canvas.setPen (lineColor, PenStyle.SolidLine, 2);
            int xls = ( (int) (xt  ) % 60), yls = ( (int) (yt ) % 60);

            for (int a = 0; a <= h / 60; a++) {
                canvas.drawLine (0, a * 60 + yls, w, a * 60 + yls);
            }

            for (int i = 0; i <= w / 60; i++) {
                canvas.drawLine (i * 60 + xls, 0,   i * 60 + xls, h);
            }
        }
        
        var ivHeight = getIndicatorsViewHeight();
        _chatHeight = h - ivHeight;
        h = _chatHeight;
        canvas.setClipRect(0, 0, w, h, ClipOperation.ReplaceClip);
        canvas.setFont (yaheiHy);

        if (showSymbol) {
            if (symbolImage == nilptr) {
                String symbolPeriod = currentSymbol + " - " + data.getTimePeriodName();
                QFont oldFont = canvas.getFont();
                canvas.setFontPointSize (32);

                QRect rc = canvas.measureText (0, 0, symbolPeriod);
                symbolImage = new QImage (rc.width(), rc.height(), QImage.Format_ARGB32_Premultiplied);
                QPainter __qpa = new QPainter (symbolImage);

                __qpa.setPen (0x9f000000 | (clrText & 0x00ffffff) );
                __qpa.setFont (oldFont);
                __qpa.setFontPointSize (32);
                __qpa.drawText (symbolPeriod, 0, rc.height() );
                __qpa = nilptr;
                canvas.setFont (oldFont);
                setWindowTitle ("XTrader Chat " + symbolPeriod);
            }

            canvas.drawImage (symbolImage, 35, h - (isDrawVol ? (VolumeHeight + 55) : 55) - symbolImage.height() );
        }

        if (data == nilptr) {
            return;
        }

        float singleWidth = (BarWidth + sp) ;
        bool showNo = showkNum && bDrawDaySplit;

        if (showNo && singleWidth * data.xzoom < 20) {
            showNo = false;
        }


        int start = Math.max (0, (int) (0 - xt / (singleWidth * data.xzoom) ) );

        //float high = -2147483647, low = 2147483647;

        canvas.translate (xt, yt);

        if (TextAreaWid == 0 && data.size() > 0) {
            QRect rct = canvas.measureText (0, 0, "0" + String.format (sPriceFormat, data[0].open) + "0");
            TextAreaWid = rct.width() + 30;
        }

        float viewWidth = w - TextAreaWid;
        int numOfPage = viewWidth / (singleWidth * data.xzoom) + 1;
        int count = Math.min (numOfPage, data.size() - start) ;
        int lastday = 0;
        int secondPeriod = data.getSecondPeriod();

        float maxvol = 0;
        float vrate = 0;
        bool bDrawVolume = isDrawVol;
        if (bDrawVolume) {
            for (int i = 0; i < count; i++) {
                int bn = i + start;
                Bar b = data[bn];

                if (b == nilptr) {
                    return;
                }

                if (maxvol < b.vol) {
                    maxvol = b.vol;
                }
            }

            if (maxvol == 0) {
                bDrawVolume = false;
            } else {
                vrate = - VolumeHeight / maxvol;
            }
        }

        int vrclr = 0x5f000000 | (riseClr & 0xffffff), vfclr = 0x5f000000 | (fallClr & 0xffffff);
        int vbegin = - (yt - h + 24);
        long mouseTime = 0;

        double xzoom = data.xzoom;
        double yzoom = data.yzoom;

        Vector<IndicatorShell> ids = data.getIndicators();

        for (IndicatorShell s : ids) {
            if (s.hasView()){
                continue;
            }
            
            double [][] indexBuffer = s.getIndexBuffer();
            int []colros = s.getPenColors();
            float [] widths = s.getPenWidths();

            for (int x = 0; x < indexBuffer.length; x++) {
                double [] cur = indexBuffer[x];

                if (start < 0 || cur.length < start + count) {
                    break;
                }

                canvas.setPen (colros[x], PenStyle.SolidLine, widths[x]);
                canvas.strokePathf3i (cur, (singleWidth * start + singleWidth / 2) * xzoom, singleWidth * xzoom, h, yzoom, start, count);
                /*float prev_x = (singleWidth * start) * xzoom;
                int  prev_y = (h - cur[start]  * yzoom);

                for (int i = 1; i < count; i++) {
                    int bn = i + start;
                    float cur_x = (singleWidth * bn) * xzoom;
                    int  cur_y = (h - cur[bn]  * yzoom);
                    canvas.drawLine(prev_x, prev_y, cur_x, cur_y);
                    prev_x = cur_x;
                    prev_y = cur_y;
                }*/
            }
        }

        bool hideAtt = (BarWidth  * xzoom) < 2;

        // 可显示的价格范围
        float maxPrice = (h + yt) / yzoom, minPrice  = yt / yzoom;

        if (KMode == DrawMode.TREND_K) {
            // 折线
            trendpaint.setColor (riseClr);
            canvas.setPaint (trendpaint);
            float lastx = 0;
            int lastY = 0;

            for (int i : count) {
                int bn = i + start;
                Bar b = data[bn];

                if (b == nilptr) {
                    return;
                }

                int _b = (h - b.close  * yzoom);

                float barbegin = (singleWidth * bn) * xzoom;

                if (lastx != 0 && b.low < maxPrice && b.high > minPrice) {
                    canvas.drawLine (lastx, lastY, barbegin, _b);
                }

                lastx = barbegin;
                lastY = _b;
            }
        } else if (KMode == DrawMode.NORMAL_K) {
            int bw = Math.max (1, (int) (BarWidth * xzoom) );

            for (int i : count) {
                int bn = i + start;
                Bar b = data[bn];

                if (b == nilptr) {
                    return;
                }

                float xoffset = singleWidth * (bn);
                float barbegin = xoffset * xzoom;
                int _t = (h - b.open  * yzoom), _b = (h - b.close  * yzoom);
                bool bInDisplay = (b.low < maxPrice && b.high > minPrice);

                if (b.close > b.open) {
                    if (bDrawVolume) {
                        canvas.fillRect (barbegin, vbegin, bw, b.vol * vrate, vrclr, QBrush.Style.SolidPattern);
                    }

                    if (bInDisplay) {
                        paint.setColor (riseClr);
                        canvas.setPaint (paint);

                        if (_b == _t) {
                            _b = _t + 1;
                        }

                        canvas.drawLine ( (xoffset + (BarWidth) / 2) * xzoom, (h - b.high * yzoom), (xoffset + (BarWidth  / 2) ) * xzoom,  (h - b.low * yzoom) );

                        if (!hideAtt) {
                            canvas.fillRect (barbegin, _t, bw, _b - _t, riseClr, QBrush.Style.SolidPattern);
                        }
                    }
                } else {
                    if (bDrawVolume) {
                        canvas.fillRect (barbegin, vbegin, bw, b.vol * vrate, vfclr, QBrush.Style.SolidPattern);
                    }

                    if (bInDisplay) {
                        paint.setColor (fallClr);
                        canvas.setPaint (paint);

                        if (_b == _t) {
                            _b = _t - 1;
                        }

                        canvas.drawLine ( (xoffset + (BarWidth) / 2) * xzoom, (h - b.high * yzoom), (xoffset + (BarWidth  / 2) ) * xzoom, (h - b.low * yzoom) );

                        if (!hideAtt) {
                            canvas.fillRect (barbegin, _b, bw, _t - _b, fallClr, QBrush.Style.SolidPattern);
                        }
                    }
                }

                long seconds = (b.timedate + (timeZoneOffset * 3600) );

                if (showNo) {
                    canvas.drawText ("" + (1 + (seconds % 86400) / secondPeriod), barbegin, (h - b.low  * yzoom) + 20);
                }

                int curday = (seconds + secondPeriod) / 86400;

                if (bDrawDaySplit &&  lastday != 0 && lastday != curday) {
                    canvas.setPen (0x6f000011 | (~backgroundClr & 0x00ffff00), PenStyle.DashDotLine, 2);
                    float mdl = barbegin + ( (singleWidth - (sp / 2.f) ) * xzoom);
                    canvas.drawLine (mdl, -yt, mdl, h - yt );
                }

                lastday = curday;

                if (hoverIndex == bn) {
                    mouseTime = b.timedate * 1000;
                    String info = String.format ("高:" + sPriceFormat + ", 低:" + sPriceFormat + ", 开:" + sPriceFormat + ", 收:" + sPriceFormat + "" + ", 量:%d", b.high, b.low, b.open, b.close, (int)(b.vol));
                    QRect rct = canvas.measureText (0, 0, info);
                    canvas.fillRect (-xt + 3, -yt + 3, rct.width() + 10, 36, 0x1fefefef, QBrush.Style.SolidPattern);
                    canvas.drawText (String.formatDate (sTimeFormat, mouseTime), -xt + 7, -yt + 14);
                    canvas.drawText (info, -xt + 7, -yt + 32);
                }

            }
        } else if (KMode == DrawMode.USA_K) {
            int bw = Math.max (1, (int) (BarWidth * xzoom) );
            paint.setStrokeWidth (2);

            for (int i : count) {
                int bn = i + start;
                Bar b = data[bn];

                if (b == nilptr) {
                    return;
                }

                float xoffset = singleWidth * (bn);
                float barbegin = xoffset * xzoom;

                int _t = (h - b.open  * yzoom), _b = (h - b.close  * yzoom);
                bool bInDisplay = (b.low < maxPrice && b.high > minPrice);

                if (b.close > b.open) {
                    if (bDrawVolume) {
                        canvas.fillRect (barbegin, vbegin, bw, b.vol * vrate, vrclr, QBrush.Style.SolidPattern);
                    }

                    if (bInDisplay) {
                        paint.setColor (riseClr);
                        canvas.setPaint (paint);

                        if (_b == _t) {
                            _b = _t + 1;
                        }

                        canvas.drawLine ( (xoffset + (BarWidth) / 2) * xzoom, (h - b.high * yzoom), (xoffset + (BarWidth  / 2) ) * xzoom,  (h - b.low * yzoom) );

                        if (!hideAtt) {
                            canvas.drawLine (barbegin, _t, (xoffset + (BarWidth) / 2) * xzoom,  _t);
                            canvas.drawLine ( (xoffset + (BarWidth) / 2) * xzoom, _b, barbegin + bw, _b);
                        }
                    }
                } else {
                    if (bDrawVolume) {
                        canvas.fillRect (barbegin, vbegin, bw, b.vol * vrate, vfclr, QBrush.Style.SolidPattern);
                    }

                    if (bInDisplay) {
                        paint.setColor (fallClr);
                        canvas.setPaint (paint);

                        if (_b == _t) {
                            _b = _t - 1;
                        }

                        canvas.drawLine ( (xoffset + (BarWidth) / 2) * xzoom, (h - b.high * yzoom), (xoffset + (BarWidth  / 2) ) * xzoom, (h - b.low * yzoom) );

                        if (!hideAtt) {
                            canvas.drawLine (barbegin, _t, (xoffset + (BarWidth) / 2) * xzoom,  _t);
                            canvas.drawLine ( (xoffset + (BarWidth) / 2) * xzoom, _b, barbegin + bw, _b);
                        }
                    }
                }

                long seconds = (b.timedate + (timeZoneOffset * 3600) );

                if (showNo) {
                    canvas.drawText ("" + (1 + (seconds % 86400) / secondPeriod), barbegin, (h - b.low  * yzoom) + 20);
                }

                int curday = (seconds + secondPeriod) / 86400;

                if (bDrawDaySplit &&  lastday != 0 && lastday != curday) {
                    canvas.setPen (0x6f000011 | (~backgroundClr & 0x00ffff00), PenStyle.DashDotLine, 2);
                    float mdl = barbegin + ( (singleWidth - (sp / 2.f) ) * xzoom);
                    canvas.drawLine (mdl, -yt, mdl, h - yt );
                }

                lastday = curday;

                if (hoverIndex == bn) {
                    mouseTime = b.timedate * 1000;
                    String info = String.format ("高:" + sPriceFormat + ", 低:" + sPriceFormat + ", 开:" + sPriceFormat + ", 收:" + sPriceFormat + "", b.high, b.low, b.open, b.close);
                    QRect rct = canvas.measureText (0, 0, info);
                    canvas.fillRect (-xt + 3, -yt + 3, rct.width() + 10, 36, 0x1fefefef, QBrush.Style.SolidPattern);
                    canvas.drawText (String.formatDate ("%Y年%m月%d日 %H:%M", mouseTime), -xt + 7, -yt + 14);
                    canvas.drawText (info, -xt + 7, -yt + 32);
                }
            }

            paint.setStrokeWidth (1);
        }

        Vector<DrawObject> objects = data.getDrawableObjects();

        for (DrawObject doj : objects) {
            doj.drawTrading (this, canvas, xzoom, yzoom, viewWidth, h);
        }

        if (currentHistoryPosition != nilptr) {
            if (currentHistory == nilptr) {
                float ot = timeToX (currentHistoryPosition.time), ct = timeToX (currentHistoryPosition.closetime);

                if (ot != 0 && ct != 0) {
                    currentHistory = currentHistoryPosition.getIndicate();

                    currentHistory.setup (ot,
                                          currentHistoryPosition.price,
                                          ct,
                                          currentHistoryPosition.closeprice,
                                          (currentHistoryPosition.posType == ORDER_TYPE.ORDER_TYPE_BUY),
                                          currentHistoryPosition.profit);
                    goto (currentHistoryPosition.time, currentHistoryPosition.price);
                }
            }

            if (currentHistory != nilptr) {
                currentHistory.drawTrading (this, canvas, xzoom, yzoom, viewWidth, h);
            }
        }

        if (currentObject != nilptr) {
            currentObject.drawTrading (this, canvas, xzoom, yzoom, viewWidth, h);
        }

        float fAsk = data.getAsk(), fBid = data.getBid();

        canvas.translate (-xt, -yt);
        
        if (bdrawOrder) {
            if (orderobject.size() != 0) {
                canvas.setAntialiasing (true);

                for (ViewButton vb : orderobject) {
                    if (vb.isMarketPrice() ) {
                        if (vb.isBuy() ) {
                            vb.open_price = fAsk;
                        } else {
                            vb.open_price = fBid;
                        }
                    }

                    vb.drawTrading (this, canvas, xzoom, yzoom, viewWidth, h);
                }

                canvas.setAntialiasing (false);
            } else {
                bdrawOrder = false;
            }
        } else {
            Map<String, OrderObject>  orders = data.getOrdersMap();

            if (orders.size() != 0) {
                var iter = orders.iterator();

                while (iter.hasNext() ) {
                    iter.getValue().drawTrading (this, canvas, xzoom, yzoom, viewWidth, h);
                    iter.next();
                }
            }

            Map<String, OrderObject>  positions = data.getPositionsMap();

            if (positions.size() != 0) {
                var iter = positions.iterator();

                while (iter.hasNext() ) {
                    iter.getValue().drawTrading (this, canvas, xzoom, yzoom, viewWidth, h);
                    iter.next();
                }
            }
        }
        
        canvas.fillRect (viewWidth - 8, 0, TextAreaWid + 8, h, borderClr, QBrush.Style.SolidPattern);
        canvas.fillRect (0, h - 24, w, h, borderClr, QBrush.Style.SolidPattern);
        
        if (showAsk) {
            canvas.setPen (fallClr, PenStyle.DotLine, 0.5);
            canvas.drawLine (0, (h - fAsk * yzoom) + yt, w, h - fAsk * yzoom + yt);
        }

        canvas.setPen (riseClr, PenStyle.DotLine, 0.5);
        canvas.drawLine (0, (h - fBid * yzoom) + yt, w, h - fBid * yzoom + yt);

        int c = h / 30;

        int data_size = data.size();

        if (smallFont == nilptr) {
            smallFont = canvas.getFont();
            smallFont.setPixelSize (11);
        }

        paint.setColor (clrText);
        canvas.setPaint (paint);

        for (int i = 0; i < c; i++) {
            canvas.drawText (String.format (sPriceFormat, ( (i * 30)  + yt) / yzoom), viewWidth + 5, h - (i * 30)  + 8);
        }

        int timesp = 150;
        c = w / timesp;

        for (int i = 0; i < c; i++) {
            int n = XtoIndex (i * timesp);

            if (n >= 0 && n < data_size) {
                Bar b = data[n];
                canvas.drawText (String.formatDate ("|" + sTimeFormat, b.timedate * 1000), i * timesp, h - 8);
            }
        }

        String sAsk = String.format (sPriceFormat, fAsk);
        String sBid = String.format (sPriceFormat, fBid);

        int rts = getRemainSecond();
        String szRTimes = "";

        if (rts > 86400) {
            szRTimes = String.format ("%d.%d:%02d:%02d",  rts / 86400,  (rts % 86400) / 3600,  (rts % 3600) / 60, rts % 60);
        } else if (rts > 3600) {
            szRTimes = String.format ("%d:%02d:%02d", rts / 3600,  (rts % 3600) / 60, rts % 60);
        } else {
            szRTimes = String.format ("%02d:%02d", rts / 60, rts % 60);
        }

        double ybid = priceToY (fBid);
        double yask = priceToY (fAsk);
        double txtY = yask;

        if (showAsk) {
            drawTextOnRect (canvas, sAsk, viewWidth, yask, TextAreaWid + 8, TextAreaHei,  fallClr, 0xffffffff, 0);

            if (showTimeremain) {
                txtY = Math.max (txtY + TextAreaHei, ybid - TextAreaHei);
                drawTextOnRect (canvas, szRTimes, viewWidth, txtY, TextAreaWid + 8, TextAreaHei, 0xff6E4BFA, 0xffffffff, 0);
            }

            txtY = Math.max (txtY + TextAreaHei, ybid);
        } else {
            if (showTimeremain) {
                txtY = ybid - TextAreaHei;
                drawTextOnRect (canvas, szRTimes, viewWidth, txtY, TextAreaWid + 8, TextAreaHei, 0xff6E4BFA, 0xffffffff, 0);
                txtY = Math.max (txtY + TextAreaHei, ybid);
            } else {
                txtY = ybid;
            }
        }


        drawTextOnRect (canvas, sBid, viewWidth, txtY, TextAreaWid + 8, TextAreaHei,  riseClr, 0xffffffff, 0);
        canvas.setClipRect(0, 0, w, h, ClipOperation.NoClip);
        //paint.setStyle(QPainter.Paint.STROKE);
        

        QRect rtAsk = canvas.measureText (0, 0, sAsk);
        QRect ssOpt = canvas.measureText (0, 0, "买入");
        canvas.setFont (yaheiHy);
        int maxW = Math.max (rtAsk.width(), ssOpt.width() );
        canvas.setAntialiasing (true);
        paint.setColor (sellClr);
        int btw = Math.max (75, maxW + 24);
        //canvas.setFont(smallFont);
        int btBase = viewWidth - (btw * 4);
        btnSell.left = btBase;
        btnSell.right = btBase + btw;
        btnSell.top = 8;
        btnSell.bottom = 48;

        canvas.drawRoundedRect (btBase, 8, btw, 40, 0, 0, paint);
        paint.setColor (0xffffffff);
        canvas.setPaint (paint);
        canvas.drawText (sAsk, btBase + (btw - rtAsk.width() ) / 2, 6 + (20 - rtAsk.height() ) / 2 + rtAsk.height() );
        canvas.drawText ("卖出", btBase + (btw - ssOpt.width() ) / 2, 46 - (ssOpt.height() ) / 2);

        btBase += btw + 65;
        paint.setColor (buyClr);
        canvas.drawRoundedRect (btBase, 8, btw, 40, 0, 0, paint);
        btnBuy.left = btBase;
        btnBuy.right = btBase + btw;
        btnBuy.top = 8;
        btnBuy.bottom = 48;

        paint.setColor (0xffffffff);
        canvas.setPaint (paint);
        canvas.drawText (sBid, btBase + (btw - rtAsk.width() ) / 2, 6 + (20 - rtAsk.height() ) / 2 + rtAsk.height() );
        canvas.drawText ("买入", btBase + (btw - ssOpt.width() ) / 2, 46 - (ssOpt.height() ) / 2);

        if (location != nilptr) {
            canvas.drawImage (location, viewWidth - 74, 10);
        }

        locarc.left = viewWidth - 74;
        locarc.right = locarc.left + 36;
        locarc.top = 10;
        locarc.bottom = locarc.top + 36;
        float spread = fAsk - fBid;
        String sspread = String.format (sPriceFormat, spread);
        QRect rtspread = canvas.measureText (0, 0, sspread);
        canvas.setPen (clrText);
        canvas.drawText (sspread, btBase - 65 + (65 - rtspread.width() ) / 2, (45 - rtspread.height() ) / 2 + rtspread.height() );
        /*paint.setColor(0xffffffff);
        canvas.drawRoundedRect(w - TextAreaWid - 183, 16, 40, 16, 0, 0, paint);*/
        canvas.setAntialiasing (false);

        if (showTickView) {
            tickView.onDraw (canvas, data.getTickData(), backgroundClr);
        }
        
        chatRect.left = chatRect.right = 0;
        chatRect.right = w;
        chatRect.bottom = h - 24;

        float xoffset = (start * singleWidth * data.xzoom) + xt;
        float pointH = h;
        
        for (IndicatorShell s : ids) { 
            if (s.hasView()){
                canvas.fillRect(0, h, w, this.VIEW_SPLITER, 0xff828282, QBrush.Style.SolidPattern);
                Indicator _indic = s.getIndicator();
                
                s.toprc = new QRect(0, h, w, h + this.VIEW_SPLITER);// this.drawImageOnCenterPoint (canvas, this.topbar, w / 2, h + 3);

                h += this.VIEW_SPLITER;
                s.rect = new QRect(0, h, w, h + _indic.height());
                canvas.translate(0, h);
                canvas.setClipRect(0, 0, w, _indic.height(), ClipOperation.ReplaceClip);
                _indic.draw(this, canvas, xoffset, start, count, singleWidth * count * this.data.xzoom, _indic.height(), w);
                canvas.setClipRect(0, 0, w, _indic.height(), ClipOperation.NoClip);
                canvas.translate(0, -h);
                h += (_indic.height());
            }
        }
        
        if (!bHideCross) {
            h = pointH;
            canvas.setPen (0xff000000 | (~backgroundClr & 0x00ffffff), PenStyle.DashLine, 0.5);
            float mmy = (height() - my + yt) / yzoom;
            
            canvas.drawLine (mx, 0, mx, rawheight());
         
            if (mouseTime > 0) {
                String cutTime = String.formatDate ("%Y年%m月%d日 %H:%M", mouseTime);
                QRect trect = canvas.measureText (0, 0, cutTime);
                drawTextOnRect (canvas, cutTime, mx - trect.width() / 2, h - 12,   trect.width() + 20, 14, 0xff000000 | (~borderClr & 0x00ffffff), borderClr, 0);
            }
            if (my < (pointH - 24)){
                canvas.setPen (0xff000000 | (~backgroundClr & 0x00ffffff), PenStyle.DashLine, 0.5);
                canvas.drawLine (0, my, w, my);
                drawTextOnRect (canvas, String.format (sPriceFormat, mmy), viewWidth, my,  TextAreaWid + 8, TextAreaHei, 0xff000000 | (~borderClr & 0x00ffffff), borderClr, 0);

                btl = viewWidth - TextAreaHei * 2;
                btr = btl + 24;

                if (mx >= btl && mx <= btr) {
                    drawImageOnCenter (canvas, OrderObject.newOrdh, btl + 24, my, 24, 24);
                } else {
                    drawImageOnCenter (canvas, OrderObject.newOrd, btl + 24, my, 24, 24);
                }
            }
        }

        if (showToolbars) {
            toolbar.onPaint (canvas);
        }
    }

    public int height()override{
        return _chatHeight;
    }
    
    public int rawheight(){
        return super.height();
    }
    
    public void endDraw() {
        if (currentObject == nilptr) {
            return;
        }

        data.addDrawableObject (currentObject);
        currentObject = nilptr;
        drawMode = false;
        setHideCross (false);
        postUpdate();
    }

    public void cancelDraw() {
        currentObject = nilptr;
        drawMode = false;
        setHideCross (false);
        postUpdate();
    }

    public void gotoPrice (double price) {
        data.ytranslate = ( (height() / 2) + (price * data.yzoom) ) - height();
        postUpdate();
    }

    public void goto (long time, double price) {
        data.ytranslate = ( (height() / 2) + (price * data.yzoom) ) - height();
        int bn = data.getBarIndexForTime (time);

        if (bn != -1) {
            data.xtranslate = width() / 2 - ( (BarWidth + sp) * bn) * data.xzoom;
        }

        postUpdate();
    }

    public float priceToY (float p) {
        if (data == nilptr) {
            return 0;
        }

        return height() - ( (p * data.yzoom) - (data.ytranslate + _t_ytranslate) );
    }

    public float timeToX (long t) {
        if (data == nilptr) {
            return 0;
        }

        int barid = data.getBarIndexForTime (t);

        if (barid != -1) {
            return ( (BarWidth + sp) * barid);
        }

        return 0;
    }

    public float YtoPrice (int y) {
        if (data == nilptr) {
            return 0;
        }

        return (height() - y + (data.ytranslate + _t_ytranslate) ) / data.yzoom ;
    }

    public int XtoIndex (int x) {
        if (data == nilptr) {
            return 0;
        }

        float sigw = ( (BarWidth + sp) * data.xzoom);
        float rw = (x - (data.xtranslate + _t_xtranslate) );

        if (rw > 0) {
            return  (rw / sigw);
        }

        return 0;
    }

    public int IndexToX (int n) {
        if (data == nilptr) {
            return 0;
        }

        float sigw = ( (BarWidth + sp) * data.xzoom);
        return n * sigw + (data.xtranslate + _t_xtranslate);
    }


    public String getCurrentSymbol() {
        return currentSymbol;
    }

    public TradingData currentData() {
        return data;
    }

    public String getUnderlyingSymbol() {
        if (data == nilptr) {
            return nilptr;
        }

        return data.getUnderlyingSymbol();
    }

    public int getXTranslate() {
        if (data == nilptr) {
            return 0;
        }

        return data.xtranslate + _t_xtranslate;
    }

    public int getYTranslate() {
        if (data == nilptr) {
            return 0;
        }

        return data.ytranslate + _t_ytranslate;
    }



    public void drawTextOnRect (QPainter canvas, String text, int x, int y, int w, int h, int bc, int tc, int r) {
        paint.setColor (bc);
        canvas.setPaint (paint);
        canvas.setBold (true);
        w = w - 5;
        QRect rect = new QRect (x, y - h / 2.f, x + w, y + h / 2.f);
        canvas.drawRoundedRect (rect, r, r, paint);
        paint.setColor (tc);
        canvas.setPaint (paint);
        canvas.drawText (text, rect, Constant.AlignHCenter | Constant.AlignVCenter);
    }

    bool md = false;
    bool syz = false;
    int zyy = 0, pty = 0;
    int _dx, _dy;
    long lastTime = 0;

    public void updateTime() {
        if (data == nilptr) {
            return ;
        }

        long l = data.getLastTime();

        if (lastTime != l) {
            updateTime (l);
        }
    }

    public double getPositionOnMouse() {
        if (data == nilptr) {
            return 0;
        }

        QPoint pt = QApplication.globalCursorPoint();
        pt = this.mapFromGlobal (pt.x, pt.y);
        return (height() - pt.y + data.ytranslate) / data.yzoom ;
    }
    public void onMouseButtonDblClick (int Button, int x, int y, int flags, int source) override {
        if (data == nilptr || isWaiting){
            return;
        }
        
        var objects = data.getDrawableObjects();
        if (objects.size() > 0) {
            for (DrawObject od : objects) {
                if (od.onMouseButtonDblClick (this, Button, x, y, (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                    postUpdate();
                    return ;
                }
            }
        }
    }
    
    public void onChatMouseDown(int Button, int x, int y){
        if (showTickView && tickView.onMouseDown (this, x, y) ) {
            return ;
        }

        if (showToolbars &&  toolbar.onMouseDown (this, x, y) ) {
            return ;
        }

        bool outofCanvas = x > fullWid - getTextAreaWid();

        if (bdrawOrder) {
            for (DrawObject doj : orderobject) {
                if (doj.onMouseButtonPress (this, Button, x, y,  (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                    postUpdate();
                    return;
                }
            }
        }

        var orders = data.getOrdersMap();
        var positions = data.getPositionsMap();
        var objects = data.getDrawableObjects();

        if (orders.size() != 0) {
            var iter = orders.iterator();

            while (iter.hasNext() ) {
                if (iter.getValue().onMouseButtonPress (this, Button, x, y,  (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                    postUpdate();
                    return;
                }

                iter.next();
            }
        }

        if (positions.size() != 0) {
            var iter = positions.iterator();

            while (iter.hasNext() ) {
                if (iter.getValue().onMouseButtonPress (this, Button, x, y,  (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                    postUpdate();
                    return;
                }

                iter.next();
            }
        }

        if (!outofCanvas && drawMode) {
            if (Button == 2) {
                cancelDraw();
            } else if (currentObject.onMouseButtonPress (this, Button, x, y,  (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                postUpdate();
            }

            return;
        }

        if (Button == 1) {
            int w = fullWid;

            if (x >= btl && x <= btr) {
                //mainMenu.show (x, y);
                float value = (height() - y + data.ytranslate) / data.yzoom ;
                QPoint pt = this.mapToGlobal (x, y);
                _mevent.setPrice (value);
                setActionText (2, "在 " + String.format (data.getPriceFormater(), value) + " 上建立[买入]挂单");
                setActionText (3, "在 " + String.format (data.getPriceFormater(), value) + " 上建立[卖出]挂单");
                mainMenu.popup (pt.x, pt.y) ;
            } else if (x >  w - getTextAreaWid()  && x < w && !syz) {
                syz = true;
                zyy = y;
                pty = y;
            } else if (!md) {
                md = true;
                _dx = x;
                _dy = y;
            }

            if (locarc.contains (x, y) ) {
                locateToCurrent (true);
            } else if (!outofCanvas && objects.size() > 0) {
                currentSelected = nilptr;

                for (DrawObject od : objects) {
                    if (od.onMouseButtonPress (this, Button, x, y, (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                        postUpdate();
                        currentSelected = od;
                        return ;
                    }
                }
            }
        } else if (Button == 2) {
            float value = (height() - y + data.ytranslate) / data.yzoom ;
            chatListener.setPrice (value);

            chatMenus.actions[18].setChecked (KMode == DrawMode.NORMAL_K);
            chatMenus.actions[19].setChecked (KMode == DrawMode.TREND_K);
            chatMenus.actions[20].setChecked (KMode == DrawMode.USA_K);

            chatMenus.actions[26].setChecked (showAsk);
            chatMenus.actions[27].setChecked (showTimeremain);
            chatMenus.actions[28].setChecked (showGrid);
            chatMenus.actions[29].setChecked (isDrawVol);
            chatMenus.actions[30].setChecked (showkNum);
            chatMenus.actions[31].setChecked (showSymbol);

            chatMenus.actions[40].setChecked (showTickView);
            chatMenus.actions[41].setChecked (bDrawDaySplit);
            chatMenus.actions[71].setChecked (showToolbars);
            chatMenus.actions[73].setChecked ( (WindowFlags() & (int) WindowType.WindowStaysOnTopHint) != 0);

            static const ENUM_TIMEFRAMES [] preenums = {ENUM_TIMEFRAMES.PERIOD_M1,
                                                        ENUM_TIMEFRAMES.PERIOD_M2,
                                                        ENUM_TIMEFRAMES.PERIOD_M3,
                                                        ENUM_TIMEFRAMES.PERIOD_M4,
                                                        ENUM_TIMEFRAMES.PERIOD_M5,
                                                        ENUM_TIMEFRAMES.PERIOD_M6,
                                                        ENUM_TIMEFRAMES.PERIOD_M10,
                                                        ENUM_TIMEFRAMES.PERIOD_M12,
                                                        ENUM_TIMEFRAMES.PERIOD_M15,
                                                        ENUM_TIMEFRAMES.PERIOD_M20,
                                                        ENUM_TIMEFRAMES.PERIOD_M30,
                                                        ENUM_TIMEFRAMES.PERIOD_H1,
                                                        ENUM_TIMEFRAMES.PERIOD_H2,
                                                        ENUM_TIMEFRAMES.PERIOD_H3,
                                                        ENUM_TIMEFRAMES.PERIOD_H4,
                                                        ENUM_TIMEFRAMES.PERIOD_H6,
                                                        ENUM_TIMEFRAMES.PERIOD_H8,
                                                        ENUM_TIMEFRAMES.PERIOD_H12,
                                                        ENUM_TIMEFRAMES.PERIOD_D1,
                                                        ENUM_TIMEFRAMES.PERIOD_W1,
                                                        ENUM_TIMEFRAMES.PERIOD_MN1
                                                       };

            if (data != nilptr) {
                ENUM_TIMEFRAMES period = data.currentPeriod();

                for (int i = 48; i < 69; i++) {
                    chatMenus.actions[i].setChecked (period == preenums[i - 48]);
                }
            }
        }
        OrderObject.__currentObject = nilptr;
    }
    
    
    public void onMouseButtonPress (int Button, int x, int y, int flags, int source) override {
        if (data == nilptr || isWaiting) {
            return;
        }
    
        if (chatRect.contains(x, y)){
            onChatMouseDown(Button, x, y);
        }else{
            var ids = this.data.getIndicators();
            for (IndicatorShell _indic : ids) {
                if (_indic.toprc != nilptr && _indic.toprc.contains(x, y)){
                    _indic.dx = x;
                    _indic.dy = y;
                    _indic.oldHeight = _indic.height();
                    this.catchedIndic = _indic;
                    return ;
                }
                if (_indic.needMouseEvent() && _indic.rect != nilptr &&  _indic.rect.contains(x, y)){
                    if (_indic.getIndicator().onChatMouseDown(this, x, y - _indic.rect.top, _indic)){
                        postUpdate();
                        return ;
                    }
                }
            }
        }
        
    }

    bool bdrawOrder = false;

    public void locateToCurrent (bool resetZoom) {
        if (data == nilptr) {
            return;
        }

        if (data.size() > 0) {
            if (resetZoom) {
                data.xzoom = 1.0;
                data.yzoom = height() * 0.75 / data.getRecommandHeight();
            }

            Bar b = data[data.size() - 1];
            data.ytranslate = ( (height() / 2) + (b.open * data.yzoom) ) - height();

            int n = data.size() - ( (fullWid - getTextAreaWid() ) / ( (BarWidth + sp) * data.xzoom) - 5);
            data.xtranslate =  - n * ( (BarWidth + sp) * data.xzoom);
            postUpdate();
        }
    }
    void createMarketPrice (bool _buy) {
        bdrawOrder = true;
        orderobject.add (new ViewButton (_buy, -1) );
        postUpdate();
    }

    void createPlacehold (float price, bool _buy) {
        bdrawOrder = true;
        orderobject.add (new ViewButton (_buy, price) );
        postUpdate();
    }

    void createAlaramOnPrice (float price) {
        beginDraw (OBJECT_TYPE.OBJECT_ALARM);
        Alarm alr = (Alarm) currentObject;
        alr.setPrice (this, price);
        endDraw();
    }

    void createHLineOnPrice (float price) {
        beginDraw (OBJECT_TYPE.OBJECT_HLINE);
        HLine alr = (HLine) currentObject;
        alr.setPrice ( price);
        endDraw();
    }

    public void cancelPlaceHold (ViewButton o) {
        orderobject.remove (o);

        if (orderobject.size() == 0) {
            bdrawOrder = false;
        }

        postUpdate();
    }

    void cancelAllPlacehold() {
        bdrawOrder = false;
        orderobject.clear();
        postUpdate();
    }
    
    public void captureIndicator(IndicatorShell i){
        capturedIndicator = i;
    }

    public void releaseCaptureIndicator(IndicatorShell i){
        if (i == capturedIndicator){
            capturedIndicator = nilptr;
        }
    }

    public void onMouseMove (int Button, int x, int y, int flags, int source) override {

        if (data == nilptr || isWaiting) {
            return;
        }

        if (showTickView && tickView.onMouseMove (this, x, y) ) {
            return ;
        }

        if (showToolbars && toolbar.onMouseMove (this, x, y) ) {
            return ;
        }

        mx = x;
        my = y;
    
        if (capturedIndicator != nilptr){
            capturedIndicator.getIndicator().onChatMouseMove(this, x, y - this.capturedIndicator.rect.top, capturedIndicator);
            postUpdate();
            return ;
        }

        if (this.catchedIndic != nilptr){
            catchedIndic.getIndicator().setHeight(this.catchedIndic.oldHeight + (this.catchedIndic.dy - y));
            postUpdate();
            return ;
        }else
        if (this.chatRect.contains(x, y)){
            onChatMouseMove(Button, x, y);
            return ;
        }else{
            var ids = this.data.getIndicators();
            for (IndicatorShell _indic : ids) {
                if (_indic.toprc != nilptr && _indic.toprc.contains(x, y)){
                    this.setCursor(Constant.SizeVerCursor);
                    return;
                }
                if (_indic.needMouseEvent() && _indic.rect != nilptr &&  _indic.rect.contains(x, y)){
                    if (_indic.getIndicator().onChatMouseMove(this, x, y - _indic.rect.top, _indic)){
                        this.postUpdate();
                        return ;
                    }
                }
            }
            this.setCursor(Constant.CrossCursor);
            this.postUpdate();
            return ;
        }
    }
    
    public void onChatMouseMove (int Button, int x, int y)  {
        hoverIndex = XtoIndex (x);

        if (bdrawOrder) {
            for (DrawObject doj : orderobject) {
                if (doj.onMouseMove (this, Button, x, y,  (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                    postUpdate();
                    return;
                }
            }
        }

        var orders = data.getOrdersMap();
        var positions = data.getPositionsMap();
        var objects = data.getDrawableObjects();

        if (orders.size() != 0) {
            var iter = orders.iterator();

            while (iter.hasNext() ) {
                if (iter.getValue().onMouseMove (this, Button, x, y,  (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                    postUpdate();
                    return;
                }

                iter.next();
            }
        }

        if (positions.size() != 0) {
            var iter = positions.iterator();

            while (iter.hasNext() ) {
                if (iter.getValue().onMouseMove (this, Button, x, y,  (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                    postUpdate();
                    return;
                }

                iter.next();
            }
        }

        if (drawMode) {
            setCursor (Constant.CrossCursor);

            if (currentObject.onMouseMove (this, Button, x, y, (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                postUpdate();
            }

            postUpdate();
            return;
        }

        bool outofCanvas = x >  fullWid - getTextAreaWid();

        if (!outofCanvas && currentSelected != nilptr) {
            if (currentSelected.onMouseMove (this, Button, x, y, (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                postUpdate();
                return ;
            }
        }

        if (syz) {
            float oldp = (height() - pty + data.ytranslate) / data.yzoom ;

            if (y > zyy) {
                data.yzoom = data.yzoom * 0.943;
            } else {
                data.yzoom = data.yzoom * 1.06;
            }

            if (data.yzoom < 0 ) {
                data.yzoom = 0.01;
            }

            data.ytranslate = (oldp * data.yzoom)  - (height() - pty) ;
            zyy = y;
        }


        if (md && data != nilptr) {
            _t_xtranslate = x - _dx;
            _t_ytranslate = y - _dy;
            float pointx = (BarWidth + sp) * data.xzoom;
            float leftest = pointx  + (data.xtranslate + _t_xtranslate);

            if (leftest > 50) {
                _t_xtranslate = 50  - (pointx + data.xtranslate);
            }

            int dcount = data.size();
            pointx = (BarWidth + sp) * dcount * data.xzoom;

            float rightest = pointx  + (data.xtranslate + _t_xtranslate);

            if (rightest <  fullWid / 2) {
                data.xtranslate = (fullWid / 2) - pointx;
                _t_xtranslate = 0;
                _dx = x;
                //_t_xtranslate = (fullWid / 2)  - (pointx + data.xtranslate);
            }

            postUpdate();
        }

        if (outofCanvas  && x < fullWid && !syz) {
            setCursor (Constant.SizeVerCursor);
        } else if (x >= btl && x <= btr) { // 开仓按钮
            setCursor (Constant.PointingHandCursor);
        } else {
            if (btnBuy.contains (x, y) ) {
                buyClr = 0x9f000000 | (0xffffff & buyClr);
                setCursor (Constant.PointingHandCursor);
            } else {
                buyClr = 0x6f000000 | (0xffffff & buyClr);

                if (btnSell.contains (x, y) ) {
                    sellClr = 0x9f000000 | (0xffffff & sellClr);
                    setCursor (Constant.PointingHandCursor);
                } else {
                    sellClr = 0x6f000000 | (0xffffff & sellClr);

                    if (locarc.contains (x, y) ) {
                        setCursor (Constant.PointingHandCursor);
                        location = OrderObject.se_location;
                        showTips (x, y, "定位到最新数据");
                    } else {
                        location = OrderObject.de_location;

                        if (!outofCanvas && objects.size() > 0) {
                            for (DrawObject od : objects) {
                                if (od.onMouseMove (this, Button, x, y, (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                                    postUpdate();
                                    return ;
                                }
                            }
                        }

                        setCursor (Constant.CrossCursor);
                    }
                }
            }
        }



        postUpdate();
    }

    public void showTips (int x, int y, String text) {
        QPoint pt = mapToGlobal (x, y);
        ShowToolTips (pt.x, pt.y, text, 5000);
    }

    public void onMouseButtonRelease (int Button, int x, int y, int flags, int source) override {
        if (data == nilptr || isWaiting) {
            return;
        }

        if (capturedIndicator != nilptr){
            capturedIndicator.getIndicator().onChatMouseUp(this, x, y - this.capturedIndicator.rect.top, capturedIndicator);
            this.postUpdate();
            return ;
        }

        if (this.catchedIndic != nilptr){
            data.IndicatorChanged();
            catchedIndic = nilptr;
        }else
        if (this.chatRect.contains(x, y)){
            onChatMouseUp(Button, x, y);
        }else{
            var ids = this.data.getIndicators();
            for (IndicatorShell _indic : ids) {
                if (_indic.needMouseEvent() && _indic.rect != nilptr &&  _indic.rect.contains(x, y)){
                    if (_indic.getIndicator().onChatMouseUp(this, x, y - _indic.rect.top, _indic)){
                        this.postUpdate();
                        return ;
                    }
                }
            }
        }
        //bool outofCanvas = x >  fullWid - getTextAreaWid();
    }
    
    public void onChatMouseUp(int Button, int x, int y){
        if (showTickView && tickView.onMouseUp (this, x, y) ) {
            return ;
        }

        if (showToolbars && toolbar.onMouseUp (this, x, y) ) {
            return ;
        }
        
        var orders = data.getOrdersMap();
        var positions = data.getPositionsMap();
        //var objects = data.getDrawableObjects();
        
        if (bdrawOrder) {
            for (DrawObject doj : orderobject) {
                if (doj.onMouseButtonRelease (this, Button, x, y,  (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                    postUpdate();
                    return;
                }
            }
        }

        if (orders.size() != 0) {
            var iter = orders.iterator();

            while (iter.hasNext() ) {
                if (iter.getValue().onMouseButtonRelease (this, Button, x, y,  (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                    postUpdate();
                    return;
                }

                iter.next();
            }
        }

        if (positions.size() != 0) {
            var iter = positions.iterator();

            while (iter.hasNext() ) {
                if (iter.getValue().onMouseButtonRelease (this, Button, x, y,  (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                    postUpdate();
                    return;
                }

                iter.next();
            }
        }

        if (drawMode) {
            if (currentObject.onMouseButtonRelease (this, Button, x, y, (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                postUpdate();
            }

            return;
        }

        if (Button == 1) {
            if (md) {
                md = false;
                data.xtranslate += _t_xtranslate;
                data.ytranslate += _t_ytranslate;
                _t_xtranslate = 0;
                _t_ytranslate = 0;
                postUpdate();
            }

            if (syz) {
                syz = false;
            }
        }

        if (currentSelected != nilptr) {
            if (currentSelected.onMouseButtonRelease (this, Button, x, y, (x - data.xtranslate) / data.xzoom, (height() - y + data.ytranslate) / data.yzoom) ) {
                postUpdate();
            }
        }

        if (Button == 1 && data != nilptr) {
            int OrderMarket = CMD_ORDER_NONE;

            if (btnBuy.contains (x, y) ) {
                OrderMarket = CMD_ORDER_MARKETS_BUY;
            } else if (btnSell.contains (x, y) ) {
                OrderMarket = CMD_ORDER_MARKETS_SELL;
            }

            if (OrderMarket != 0) {
                if (data.tradeAllowed() == false) {
                    XTMessageBox.MessageBoxYesNo (this,
                                                  "注意",
                                                  "该品种不在交易时段!",
                                                  "好",
                                                  nilptr,
                                                  nilptr,
                                                  nilptr,
                                                  0,
                                                  false);
                    return ;
                }

                DigiInput.requestInput (TradingView.this, new DigiInput.onInputListener() {
                    public bool onInputOk (DigiInput dlg, String text, String sCount) override {
                        double value = text.parseDouble();
                        int _count = sCount.parseInt();

                        if (_count < 1) {
                            dlg.setError ("不正确的仓位数量!");
                            return false;
                        }


                        if (value < data.minLots() || value > data.maxLots() ) {
                            dlg.setError ("不正确的交易量!");
                            return false;
                        }


                        Preference.setSetting (Dialog.UserIdent() + "_lot_" + data.getCurrentSymbol(), value);
                        if (Setting.isSavePosCount()){
                            Preference.setSetting (Dialog.UserIdent() + "_count_" + data.getCurrentSymbol(), _count);
                        }

                        for (int i = 0; i < _count; i++) {
                            executer.createOrder (nilptr, 0, getCurrentSymbol(), OrderMarket, data.getAsk(), 0, 0, value);
                        }

                        return true;
                    }
                    public bool onInputCancel (DigiInput) override {
                        return true;
                    }
                    public void onChange (DigiInput dlg, String text, String minlots) override {

                    }
                    public String getTitle() override {
                        return "确认市价[" + (OrderMarket == CMD_ORDER_MARKETS_BUY ? "多单" : "空单") + "]交易量";
                    }
                    public String getDescription() override {
                        return "请输入交易量("  + data.minLots()  + " ~ " + data.maxLots() + ")";
                    }
                    public String getDefault() override {
                        double _lot = Preference.getDouble ( Dialog.UserIdent() + "_lot_" + data.getCurrentSymbol() );
                        return String.format ("%.2f", _lot);
                    }
                    public String getDefaultCount() override {
                        int _count = 1;
                        
                        if (Setting.isSavePosCount()){
                           _count =  Preference.getInt (Dialog.UserIdent() + "_count_" + data.getCurrentSymbol() );
                        }
                        
                        if (_count < 0) {
                            _count = 1;
                        }

                        return String.format ("%d", _count);
                    }
                    public void onInit (DigiInput dlg) override {

                    }
                });
            }
        }
    }
    
    public void onChatMouseWheel( int x, int y,int delta, int modifiers){
        if ( (modifiers & Constant.ControlModifier) != Constant.ControlModifier) {
            float oldx = (x - data.xtranslate) / data.xzoom ;

            if (delta > 0) {
                data.xzoom = data.xzoom * 1.1;
            } else {
                data.xzoom = data.xzoom / 1.1;

                if (data.xzoom < 0 ) {
                    data.xzoom = 0.01;
                }
            }

            // 最小缩放率
            if (BarWidth * data.xzoom < MINZOOMWIDTH) {
                data.xzoom = MINZOOMWIDTH / BarWidth;
            }

            if (BarWidth * data.xzoom > MAXZOOMWIDTH) {
                data.xzoom = MAXZOOMWIDTH / BarWidth;
            }

            data.xtranslate =  x - (oldx * data.xzoom);
            fixupTranslate();
        } else {
            float oldy = (height() - y + data.ytranslate) / data.yzoom ;

            if (delta > 0) {
                data.yzoom = data.yzoom * 1.1;
            } else {
                data.yzoom = data.yzoom / 1.1;

                if (data.yzoom < 0 ) {
                    data.yzoom = 0.01;
                }
            }

            data.ytranslate = (oldy * data.yzoom)  - (height() - y) ;

        }

        postUpdate();
    }

    public void onWheel (int button, int x, int y, int Orientation, int delta, bool inverted) override {
        if (data == nilptr || isWaiting) {
            return;
        }

        int modifiers = QApplication.keyboardModifiers();
        if (chatRect.contains(x, y)){
            onChatMouseWheel(x, y, delta, modifiers);
        }else{
            var ids = this.data.getIndicators();
            for (IndicatorShell _indic : ids) {
                if (_indic.needMouseEvent() && _indic.rect != nilptr &&  _indic.rect.contains(x, y)){
                    if (_indic.getIndicator().onChatMouseWheel(this,  x, y - _indic.rect.top, delta, modifiers, _indic)){
                        this.postUpdate();
                        return ;
                    }
                }
            }
        }
        
    }

    public void fixupTranslate() {
        float pointx = (BarWidth + sp) * data.xzoom;
        float leftest = pointx  + (data.xtranslate + _t_xtranslate);

        if (leftest > 50) {
            _t_xtranslate = 50  - (pointx + data.xtranslate);
        }

        int dcount = data.size();
        pointx = (BarWidth + sp) * dcount * data.xzoom;

        float rightest = pointx  + (data.xtranslate + _t_xtranslate);

        if (rightest <  fullWid / 2) {
            //_t_xtranslate = (fullWid / 2)  - (pointx + data.xtranslate);
            data.xtranslate = (fullWid / 2) - pointx;
            _t_xtranslate = 0;
        }
    }

    public bool onKeyPress (int key, bool repeat, int count, String text, int scanCode, int virtualKey, int modifier) override {
        if (isWaiting){
            return false;
        }
        
        if (key == Constant.Key_Escape) {
            cancelDraw();
            return false;
        }

        TradingData data = currentData();

        if (data != nilptr) {
            if (key == 0x41) {
                 createAlaramOnPrice (YtoPrice(my));
            }else
            if (key == 0x53) {
                if (modifier == Constant.ShiftModifier){
                    createMarketPrice(false);
                }else{
                    createPlacehold (YtoPrice(my), false);
                }
            }else
            if (key == 0x42) {
                if (modifier == Constant.ShiftModifier){
                    createMarketPrice(true);
                }else{
                    createPlacehold (YtoPrice(my), true);
                }
            }else
            if (key == 0x52){
                showWait(true, "加载中...");
                data.cleanAndReload();
                executer.query (nilptr, TradingData.CMD_BARS, getSymbol(), "" + (int) data.currentPeriod() );
                symbolImage = nilptr;
                _system_.gc();
            }else
            if (key == Constant.Key_PageUp) {
                data.xtranslate += (getChatWidth() - getTextAreaWid() ) ;
                fixupTranslate();
                postUpdate();
            } else if (key == Constant.Key_PageDown) {
                data.xtranslate -= (getChatWidth() - getTextAreaWid() );
                fixupTranslate();
                postUpdate();
            } else if (key == 43) { //+
                float pt = width() / 2.f;
                float oldx = (pt - data.xtranslate) / data.xzoom ;
                data.xzoom = data.xzoom  * 2;

                if (data.xzoom < 0 ) {
                    data.xzoom = 0.01;
                }

                if (BarWidth * data.xzoom < MINZOOMWIDTH) {
                    data.xzoom = MINZOOMWIDTH / BarWidth;
                }

                if (BarWidth * data.xzoom > MAXZOOMWIDTH) {
                    data.xzoom = MAXZOOMWIDTH / BarWidth;
                }

                data.xtranslate =  pt - (oldx * data.xzoom);
                postUpdate();
            } else if (key == 45) { //+
                float pt = width() / 2.f;
                float oldx = (pt - data.xtranslate) / data.xzoom ;
                data.xzoom  = data.xzoom  * 0.5;

                if (data.xzoom < 0 ) {
                    data.xzoom = 0.01;
                }

                if (BarWidth * data.xzoom < MINZOOMWIDTH) {
                    data.xzoom = MINZOOMWIDTH / BarWidth;
                }

                if (BarWidth * data.xzoom > MAXZOOMWIDTH) {
                    data.xzoom = MAXZOOMWIDTH / BarWidth;
                }

                data.xtranslate =  pt - (oldx * data.xzoom);
                postUpdate();
            }
        }

        if (modifier == Constant.NoModifier && data != nilptr) {
            if (currentSelected != nilptr && key == Constant.Key_Delete) {
                currentSelected.onRemove (this);
                data.getDrawableObjects().remove (currentSelected);
                postUpdate();
            }
        }

        return true;
    }

    public void setKMode (DrawMode dm) {
        KMode = dm;
        postUpdate();
    }

    public void indicate (Position p) {
        currentHistoryPosition = p;
        currentHistory = nilptr;
        postUpdate();
    }
    
    public void setXTranslate(float x){
        if (data == nilptr) {
            return ;
        }
        data.xtranslate = x - _t_xtranslate;
        fixupTranslate();
    }
    
    public void setYTranslate(float y){
        if (data == nilptr) {
            return ;
        }
        data.ytranslate = y - _t_ytranslate;
        fixupTranslate();
    }

};