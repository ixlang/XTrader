//xlang Source, Name:Setting.x 
//Date: Sun Jul 06:15:55 2025 

class Setting {
    public static int getThemeMode() {
        int n =	new String[] {
            "最好性能",
            "最佳外观"
        }.indexOf(Preference.getString("performance_mode"));

        if ((n < 0) || (n > 1)) {
            n = 0;
        }

        return n;
    }

    public static bool isPrettyMode() {
        return	new String[] {
                    "专业版",
                    "通用版"
                }.indexOf(Preference.getString("main_mode")) != 1;
    }

    public static String getTailoforder() {
        return Preference.getString("tail_of_order");
    }
    
    public static String getTitleOfOrder() {
        String title = Preference.getString("title_of_order");
        if (TextUtils.isEmpty(title)){
            return "账单";
        }
        return title;
    }
    
    public static int getPLDisplayMode(){
        return	new String[] {
                    "金额",
                    "点数"
                }.indexOf(Preference.getString("pldisplay"));
    }
    
    public static int getECOAlert(){
        return	new String[] {
                    "不报警",
                    "全部",
                    ">=低影响力事件",
                    ">=中影响力事件",
                    ">=高影响力事件"
                }.indexOf(Preference.getString("ecalert"));
    }
    
    public static bool isOptionEffect(){
        return Preference.getBool("optionring");
    }
    
    public static int getChatBackColor(){
        return Preference.getInt("chatbk");
    }
    
    public static int getChatForeColor(){
        return Preference.getInt("chatfr");
    }
    
    public static int getChatRiseColor(){
        return Preference.getInt("riseclr");
    }
    
    public static int getChatFallColor(){
        return Preference.getInt("fallclr");
    }
    
    public static int getChatGridColor(){
        return Preference.getInt("gridclr");
    }
    
    public static int getChatBorderColor(){
        return Preference.getInt("borderclr");
    }
    
    public static bool isCustomChatStyle(){
        return new String[] {
            "跟随外观样式",
            "自定义"
        }.indexOf(Preference.getString("defclrcfg")) == 1;
    }
    
    public static bool isSavePosCount(){
        return Preference.getBool("saveposcount");
    }
    
    public static bool isCloseConfirm() {
        return Preference.getString("closeconfirm").equals("True");
    }
    
    public static int getKMode(){
        int km =new String[] {
            "阴阳烛",
            "趋势线",
            "美国线"
        }.indexOf(Preference.getString("kmode"));
                
        if (km == -1){
            return 0;
        }
        return km;
    }
    
    public static bool notifyShowAll() {
        return	new String[] {
                    "仅显示待处理订单",
                    "显示所有订单通知"
                }.indexOf(Preference.getString("ordernotify")) == 1;
    }


    public static bool isNewOrderNotify() {
        return Preference.getString("ringforneworder").equals("True");
    }

    public static bool isAloneHallView() {
        return Preference.getString("alone_hall").equals("True");
    }


    public static bool isHighContrastPair() {
        return Preference.getString("highcontrastpair").equals("True");
    }

    public static bool isMergeByTerminal() {
        return Preference.getString("merge_by_terminal").equals("True");
    }

    public static bool isF2MTipsSound() {
        return Preference.getString("f2msound").equals("True");
    }

    public static bool isPrintOrderPrice() {
        return Preference.getString("order_print_price").equals("True");
    }

    public static bool isPrintOrderDescr() {
        return Preference.getString("print_orderdescr").equals("True");
    }

    public static bool isPrintPackage() {
        return Preference.getString("print_pack").equals("True");
    }

    public static bool isPrintPackagePrice() {
        return Preference.getString("print_packitem_price").equals("True");
    }

    public static bool isPrintPackageTotal() {
        return Preference.getString("print_packtotal").equals("True");
    }

    public static bool isSOPrintPackage() {
        return Preference.getString("so_print_pack").equals("True");
    }

    public static bool isSOPrintPackagePrice() {
        return Preference.getString("so_print_packitem_price").equals("True");
    }

    public static bool isSOPrintPackageTotal() {
        return Preference.getString("so_print_packtotal").equals("True");
    }

    public static bool isPrintGive() {
        return Preference.getString("printgive").equals("True");
    }

    public static bool inputDiscountAmount() {
        return Preference.getString("input_discount_amount").equals("True");
    }

    public static bool isPrintOrderQrcode() {
        return Preference.getString("printorderqrcode").equals("True");
    }


    public static int getDishesOrderby() {
        return	Math.max(new String[] {
                    "名称排序",
                    "名称首字母排序",
                    "价格排序",
                    "默认排序",
                    "推荐指数排序",
                    "加速键排序",
                    "积分价排序"
                }.indexOf(Preference.getString("dishes_orderby")), 0);
    }

    public static int getPrintNetTAWOrder() {
        return	Math.max(new String[] {
                    "不打印",
                    "仅打印已付款订单",
                    "打印"
                }.indexOf(Preference.getString("print_nettakeaway")), 0);
    }

    public static int getPrintBySettle() {
        return	Math.max(new String[] {
                    "不打印",
                    "仅打印线上结账的订单",
                    "打印"
                }.indexOf(Preference.getString("print_bysettle")), 0);
    }
    public static bool isAllRetreatHide() {
        return Preference.getString("allretreathide").equals("True");
    }

    public static bool isTTSReport() {
        return Preference.getString("ttsreport").equals("True");
    }

    public static bool isPrintConsumer() {
        return Preference.getString("printconsumer").equals("True");
    }

    public static bool isPrintOrderByKind() {
        return Preference.getString("printbykind").equals("True");
    }

    public static String getDefaultSettlementTime() {
        return Preference.getString("settlement_deftime");
    }

    public static bool isPrinterServerEnable() {
        return Preference.getString("printerserver") != "不开启";
    }

    public static int getExportEncode() {
        return	Math.max(new String[] {
                    "UTF-8",
                    "GB18030"
                }.indexOf(Preference.getString("export_encode")), 0);
    }

    public static String getOrderRing() {
        return Preference.getString("orderring");
    }

    public static String getBindAddress() {
        String addr = Preference.getString("printerserver");

        if (addr != "不开启") {
            return addr;
        }

        return "";
    }
    public static bool newOrderConfirm() {
        return Preference.getString("preorder").equals("需要确认");
    }
    public static int getOrderConfirm() {
        return Math.max(new String[] {
                   "自动下单",
                   "仅已支付订单自动下单",
                   "需要确认"
               }.indexOf(Preference.getString("preorder")), 0);
    }
    

    public static String [] getShortCmds() {
        return Preference.getString("shortcmds").split(";");
    }


    public static int getRing() {
        return Math.max(new String[] {
                   "铃声1",
                   "铃声2",
                   "铃声3",
                   "铃声4",
                   "铃声5"
               }.indexOf(Preference.getString("orderring")), 0);
    }

    public static bool isDarkTheme() {
        return	Math.max(new String[] {
                    "深色",//#333333
                    "浅色"//#640000
                }.indexOf(Preference.getString("swcolor")), 0) == 0;
    }

    public static int getScanMode() {
        return Math.max(new String[] {
                   "CR",
                   "LF",
                   "CRLF"
               }.indexOf(Preference.getString("scanmode")), 0);
    }

    public static int getPrintMode() {
        int mode = Math.max(new String[] {
                   "单联",
                   "双联",
                   "三联"
               }.indexOf(Preference.getString("printmode")), 0);
        return mode + 1;
    }

    public static int getConsumerMode() {
        return Math.max(new String[] {
                   "必须输入人数",
                   "外卖无须输入人数",
                   "无须输入人数"
               }.indexOf(Preference.getString("consumer_mode")), 0);
    }

    public static int getCashBoxOpenOption() {
        return Math.max(new String[] {
                   "不启用",
                   "提示",
                   "自动打开"
               }.indexOf(Preference.getString("cashopenbox")), 0);
    }

    public static String [] getOrderTitles() {
        String [] keys = {"first_title", "duplex_title", "triplet_title"};

        int n = getPrintMode();
        String []titles = new String[n];

        for(int i : n) {
            titles[i] = Preference.getString(keys[i]);

            if (TextUtils.isEmpty(titles[i])) {
                titles[i] = "第" + (1 + i) + "联";
            }
        }

        return titles;
    }

    public static bool getAutoUpdate() {
        return Preference.getBool("update");
    }

    public static bool isPresetEnabled() {
        return Preference.getBool("preset");
    }

    public static bool isHideReadedMsg() {
        return Preference.getBool("hide_readed");
    }

    public static bool isTofPresetDisabled() {
        return Preference.getBool("tof_preset");
    }

    public static bool isPrintBackretreat() {
        return Preference.getBool("print_backretreat");
    }

    public static bool isPrintChangeDesk() {
        return Preference.getBool("print_changedesk");
    }

    public static bool isOrderReckontime() {
        return Preference.getBool("reckon_time");
    }

    public static bool isPrintOnApplyPreset() {
        return Preference.getBool("print_on_preset");
    }
    
    public static int isPrintOnPayorder() {
        return Math.max(new String[]{
                "不出单",
                "提示",
                "自动出单"
        }.indexOf(Preference.getString("print_on_payorder")), 0);
    }

    public static bool isPrintOnOrder() {
        return Preference.getBool("print_on_order");
    }

    public static bool isMegerSameGoods() {
        return Preference.getBool("meger_same_goods");
    }

    public static bool isAlonePrint() {
        return Preference.getBool("alone_on_order");
    }

    public static bool isUseSoftKeyboard() {
        return Preference.getBool("digi_soft_kb");
    }

    public static bool rightClickGoods() {
        return Preference.getBool("right_click_goods");
    }

    public static bool isOrderPaged() {
        return Preference.getBool("order_paged");
    }

    public static bool fsAfterLogin() {
        return Preference.getBool("fs_after_login");
    }

    public static bool isGoodsPaged() {
        return Preference.getBool("goods_paged");
    }

    public static bool getOrderInTime() {
        return Preference.getBool("order_intime");
    }

    public static bool isPrintSound() {
        return Preference.getBool("print_ring");
    }
    
    public static int getPrintSplit() {
        return Preference.getInt("printsplit");
    }
    
    public static int getCashBoxNo() {
        return Preference.getInt("cashno");
    }

    public static int getCashBoxT1() {
        return Preference.getInt("cashbox_t1");
    }

    public static int getCashBoxT2() {
        return Preference.getInt("cashbox_t2");
    }
};