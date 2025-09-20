//xlang Source, Name:TVToolBar.x 
//Date: Mon Jul 12:53:41 2025 
interface ToolbarListener{
    void onItemClick(OBJECT_TYPE t);
    void onSettingClick();
};

class TVToolBar{
    int x = 350, y = 6;
    
    Vector<OBJECT_TYPE> tools = new Vector<OBJECT_TYPE> ();
    Vector<QImage> images = new Vector<QImage>();
    Vector<QRect> imagesrc = new Vector<QRect>();
    const int compHeight = 32, itemSize = 24, itemsub = (compHeight - itemSize) / 2;
    
    QRect rect = new QRect();
    QPainter.Paint paint = new QPainter.Paint();
    int backgroundColor = 0, highlight = 0, downcolor = 0;
    bool moveDown = false;
    int dx, dy, ox, oy;
    QImage dvimg = new QImage(__xPackageResource("assets/res/dv.png"), "png");
    QImage setting = new QImage(__xPackageResource("assets/res/toolbar/Settings.png"), "png");
    QRect settingrc = new QRect(0, 0, 32, 32);
    int hoverid = -1, downid = -1;
    QImage cache = nilptr;
    
    ToolbarListener listener = nilptr;
    
    public void create(ToolbarListener l){
        listener = l;
    }
    
    public void onPaint(QPainter canvas){
        if (cache == nilptr){
            return ;
        }
        canvas.drawImage(cache, x, y);
        if (hoverid != -1 && hoverid != downid){
            QRect ico = new QRect(x + 32 + (compHeight - itemSize) / 2, y + itemsub, x + 32 + itemsub + itemSize, y + itemSize + itemsub);
            ico.offset(compHeight * hoverid, 0);
            canvas.fillRect(x + 32 + (hoverid * compHeight), y, compHeight, compHeight, highlight, QBrush.Style.SolidPattern);
            canvas.drawImage(images[hoverid], ico, imagesrc[hoverid], ImageConversionFlag.AutoColor | 1);
        }
        
        if (downid != -1){
            QRect ico = new QRect(x + 32 + (compHeight - itemSize) / 2, y + itemsub, x + 32 + itemsub + itemSize, y + itemSize + itemsub);
            ico.offset(compHeight * downid, 0);
            canvas.fillRect(x + 32 + (downid * compHeight), y, compHeight, compHeight, downcolor, QBrush.Style.SolidPattern);
            canvas.drawImage(images[downid], ico, imagesrc[downid], ImageConversionFlag.AutoColor | 1);
        }
    }
    
    void drawCache(QPainter canvas){
        paint.setColor(backgroundColor);
        canvas.drawRoundedRect(rect, 6, 6, paint);
        canvas.drawImage(dvimg, x, y + ((compHeight - 32) / 2));
        canvas.setAntialiasing(true);
        int i = 0;
        
        QRect ico = new QRect(x + 32 + (compHeight - itemSize) / 2, y + itemsub, x + 32 + itemsub + itemSize, y + itemSize + itemsub);
        for (QImage q : images){
            if (downid == i){
                canvas.fillRect(x + 32 + (i * compHeight), y, compHeight, compHeight, downcolor, QBrush.Style.SolidPattern);
            }else
            if (hoverid == i){
                canvas.fillRect(x + 32 + (i * compHeight), y, compHeight, compHeight, highlight, QBrush.Style.SolidPattern);
            }
            canvas.drawImage(q, ico, imagesrc[i], ImageConversionFlag.AutoColor | 1);
            ico.offset(compHeight, 0);
            i++;
        }
        canvas.setAntialiasing(false);
    }
    public void addTool(OBJECT_TYPE t){
        tools.add(t);
    }
    
    public void clear(){
        tools.clear();
    }
    public void refresh(TradingView tv){
        int width = (tools.size() + 1) * compHeight + 48;
        rect = new QRect(x, y, x + width, y + compHeight);
        int bg = tv.backgroundColor();
        int r = (bg >> 16 & 0xff),  g = (bg >> 8 & 0xff), b = bg & 0x00ff, hr, hg, hb, dr, dg, db;
        if (r > 0x80){
            r -= 0xf;
            hr = r - 0x10;
            dr = r - 0x7;
        }else{
            r += 0xf;
            hr = r + 0x10;
            dr = r + 0x7;
        }
        if (g > 0x80){
            g -= 0xf;
            hg = g - 0x10;
            dg = g - 0x7;
        }else{
            g += 0xf;
            hg = g + 0x10;
            dg = g + 0x7;
        }
        if (b > 0x80){
            b -= 0xf;
            hb = b - 0x10;
            db = b - 0x7;
        }else{
            b += 0xf;
            hb = b + 0x10;
            db = b + 0x7;
        }
        highlight = 0xff000000 | (hr << 16) | (hg << 8) | hb; 
        backgroundColor = 0xff000000 | (r << 16) | (g << 8) | b; 
        downcolor = 0xff000000 | (dr << 16) | (dg << 8) | db; 
        paint.setStyle(QPainter.Paint.FILL_AND_STROKE);
        images.clear();
        imagesrc.clear();
        
        for (OBJECT_TYPE t : tools){
            QImage img = nilptr;
            switch (t) {
            	case OBJECT_TYPE.OBJECT_HLINE: /*TODO*/
                img = new QImage(__xPackageResource("assets/res/toolbar/HLINE.png"), "png");
            	break;
                case OBJECT_TYPE.OBJECT_VLINE: /*TODO*/
                img = new QImage(__xPackageResource("assets/res/toolbar/VLINE.png"), "png");
            	break;
                case OBJECT_TYPE.OBJECT_FB: /*TODO*/
                img = new QImage(__xPackageResource("assets/res/toolbar/FB.png"), "png");
            	break;
                case OBJECT_TYPE.OBJECT_TRENDLINE: /*TODO*/
                img = new QImage(__xPackageResource("assets/res/toolbar/TR.png"), "png");
            	break;
                case OBJECT_TYPE.OBJECT_XABCD: /*TODO*/
                img = new QImage(__xPackageResource("assets/res/toolbar/XABCD.png"), "png");
            	break;
                case OBJECT_TYPE.OBJECT_ALARM:
                img = new QImage(__xPackageResource("assets/res/toolbar/alarm.png"), "png");
                break;
                
                case OBJECT_TYPE.OBJECT_ARRAWLEFT:
                img = new QImage(__xPackageResource("assets/res/toolbar/aleft_i.png"), "png");
                break;
                case OBJECT_TYPE.OBJECT_ARRAWRIGHT:
                img = new QImage(__xPackageResource("assets/res/toolbar/aright_i.png"), "png");
                break;
                case OBJECT_TYPE.OBJECT_ARRAWUP:
                img = new QImage(__xPackageResource("assets/res/toolbar/aup_i.png"), "png");
                break;
                case OBJECT_TYPE.OBJECT_ARRAWDOWN:
                img = new QImage(__xPackageResource("assets/res/toolbar/adown_i.png"), "png");
                break;
                case OBJECT_TYPE.OBJECT_TRIANGLE:
                img = new QImage(__xPackageResource("assets/res/toolbar/triangle.png"), "png");
                break;
                case OBJECT_TYPE.OBJECT_CHANNEL:
                img = new QImage(__xPackageResource("assets/res/toolbar/channel.png"), "png");
                break;
                case OBJECT_TYPE.OBJECT_ANDREW:
                img = new QImage(__xPackageResource("assets/res/toolbar/andrew.png"), "png");
                break;
                case OBJECT_TYPE.OBJECT_TEXT:
                img = new QImage(__xPackageResource("assets/res/toolbar/text.png"), "png");
                break;
                case OBJECT_TYPE.OBJECT_LINTETO:
                img = new QImage(__xPackageResource("assets/res/toolbar/lineto.png"), "png");
                break;
            }
            if (img == nilptr){
                img = setting;
            }
            images.add(img);
            imagesrc.add(new QRect(0, 0, img.width(), img.height()));
        }
        
        images.add(setting);
        imagesrc.add(new QRect(0, 0, setting.width(), setting.height()));
            
        cache = new QImage(rect.width(), rect.height(), QImage.Format_ARGB32_Premultiplied);
        QPainter __paint = new QPainter(cache);
        __paint.translate(-x, -y);
        drawCache(__paint);
        __paint.translate(x, y);
        __paint = nilptr;
    }
    
    public void relocal(TradingView tv){
        x = Math.max(0, x);
        y = Math.max(0, y);
        if (tv.getChatWidth() - (int)tv.getTextAreaWid() - rect.width() > 0){
            x = Math.min(x, tv.getChatWidth() - (int)tv.getTextAreaWid() - rect.width());
            y = Math.min(y, tv.height() - rect.height() - 30);
        }
        if (x < 0){
            x = 0;
        }
        if (y < 0){
            y = 0;
        }
        rect.offset(-rect.left + x, -rect.top + y);
        tv.postUpdate();
    }
    
    public bool onMouseMove(TradingView tv, int _x, int _y){
        if (moveDown){
            x = Math.max(0, ox + (_x - dx));
            y = Math.max(0, oy + (_y - dy));
            x = Math.min(x, tv.getChatWidth() - (int)tv.getTextAreaWid() - rect.width());
            y = Math.min(y, tv.height() - rect.height() - 30);
            rect.offset(-rect.left + x, -rect.top + y);
            tv.postUpdate();
            return true;
        }
        if (_x > x && _x < x + 32 && _y > y && _y < y + compHeight){
            tv.setCursor(Constant.SizeAllCursor);
            return true;
        }
        if (rect.contains(_x, _y)){
            int hd = (_x - (rect.left + 32)) / compHeight;
            if (hd > tools.size()){
                hd = -1;
            }
            if (hd != hoverid){
                hoverid = hd;
                tv.setCursor(Constant.PointingHandCursor);
                tv.postUpdate();
            }
            return true;
        }else
        if (hoverid != -1){
            hoverid = -1;
            tv.postUpdate();
            return true;
        }
        return false;
    }
    
    public bool onMouseDown(TradingView tv, int _x, int _y){
        if (_x > x && _x < x + 32 && _y > y && _y < y + compHeight){            
            moveDown = true;
            dx = _x;
            dy = _y;
            ox = x;
            oy = y;
            return true;
        }else
        if (rect.contains(_x, _y)){
            int hd = (_x - (rect.left + 32)) / compHeight;
            if (hd > tools.size()){
                hd = -1;
            }
            if (hd != downid){
                downid = hd;
                tv.postUpdate();
            }
            return true;
        }else
        if (downid != -1){
            downid = -1;
            tv.postUpdate();
            return true;
        }
        return false;
    }
    
    public bool onMouseUp(TradingView tv, int _x, int _y){
        if (moveDown){
            moveDown = false;
            return true;
        }
        if (downid != -1){
            if (downid == tools.size()){
                listener.onSettingClick();
            }else{
                listener.onItemClick(tools[downid]);
            }
            downid = -1;
            tv.postUpdate();
            return true;
        }
        return false;
    }
    
    
    public static String getComponentImageFile (OBJECT_TYPE wt) {
        switch (wt) {

        case OBJECT_TYPE.OBJECT_HLINE: /*TODO*/
            return AssetsManager.getResource("res/toolbar/HLINE.png");
            break;

        case OBJECT_TYPE.OBJECT_VLINE: /*TODO*/
            return AssetsManager.getResource("res/toolbar/VLINE.png");
            break;

        case OBJECT_TYPE.OBJECT_FB: /*TODO*/
            return AssetsManager.getResource("res/toolbar/FB.png");
            break;

        case OBJECT_TYPE.OBJECT_TRENDLINE: /*TODO*/
            return AssetsManager.getResource("res/toolbar/TR.png");
            break;

        case OBJECT_TYPE.OBJECT_XABCD: /*TODO*/
            return AssetsManager.getResource("res/toolbar/XABCD.png");
            break;

        case OBJECT_TYPE.OBJECT_ALARM:
            return AssetsManager.getResource("res/toolbar/alarm.png");
            break;

        case OBJECT_TYPE.OBJECT_ARRAWLEFT:
            return AssetsManager.getResource("res/toolbar/aleft_i.png");
            break;

        case OBJECT_TYPE.OBJECT_ARRAWRIGHT:
            return AssetsManager.getResource("res/toolbar/aright_i.png");
            break;

        case OBJECT_TYPE.OBJECT_ARRAWUP:
            return AssetsManager.getResource("res/toolbar/aup_i.png");
            break;

        case OBJECT_TYPE.OBJECT_ARRAWDOWN:
            return AssetsManager.getResource("res/toolbar/adown_i.png");
            break;

        case OBJECT_TYPE.OBJECT_TRIANGLE:
            return AssetsManager.getResource("res/toolbar/triangle.png");
            break;

        case OBJECT_TYPE.OBJECT_CHANNEL:
            return AssetsManager.getResource("res/toolbar/channel.png");
            break;

        case OBJECT_TYPE.OBJECT_ANDREW:
            return AssetsManager.getResource("res/toolbar/andrew.png");
            break;
            
        case OBJECT_TYPE.OBJECT_TEXT:
            return AssetsManager.getResource("res/toolbar/text.png");
            break;
            
        case OBJECT_TYPE.OBJECT_LINTETO:
            return AssetsManager.getResource("res/toolbar/lineto.png");
            break;
        }
        
        return nilptr;
    }
    
    
    public static String getComponentPrefix (OBJECT_TYPE wt) {
        switch (wt) {

        case OBJECT_TYPE.OBJECT_HLINE: /*TODO*/
            return "HL";
            break;

        case OBJECT_TYPE.OBJECT_VLINE: /*TODO*/
            return "FL";
            break;

        case OBJECT_TYPE.OBJECT_FB: /*TODO*/
            return "FB";
            break;

        case OBJECT_TYPE.OBJECT_TRENDLINE: /*TODO*/
            return "TL";
            break;

        case OBJECT_TYPE.OBJECT_XABCD: /*TODO*/
            return "X5";
            break;

        case OBJECT_TYPE.OBJECT_ALARM:
            return "AL";
            break;

        case OBJECT_TYPE.OBJECT_ARRAWLEFT:
            return "AWL";
            break;

        case OBJECT_TYPE.OBJECT_ARRAWRIGHT:
            return "AWR";
            break;

        case OBJECT_TYPE.OBJECT_ARRAWUP:
            return "AWU";
            break;

        case OBJECT_TYPE.OBJECT_ARRAWDOWN:
            return "AWD";
            break;

        case OBJECT_TYPE.OBJECT_TRIANGLE:
            return "TR";
            break;

        case OBJECT_TYPE.OBJECT_CHANNEL:
            return "CH";
            break;

        case OBJECT_TYPE.OBJECT_ANDREW:
            return "AD";
            break;
            
        case OBJECT_TYPE.OBJECT_TEXT:
            return "TX";
            break;
            
        case OBJECT_TYPE.OBJECT_LINTETO:
            return "LT";
            break;
        }
        
        return "UN";
    }
    
    public static String getComponentTypeString (OBJECT_TYPE wt) {
        switch (wt) {

        case OBJECT_TYPE.OBJECT_HLINE: /*TODO*/
            return "水平线";
            break;

        case OBJECT_TYPE.OBJECT_VLINE: /*TODO*/
            return "垂直线";
            break;

        case OBJECT_TYPE.OBJECT_FB: /*TODO*/
            return "斐波拉切回撤";
            break;

        case OBJECT_TYPE.OBJECT_TRENDLINE: /*TODO*/
            return "趋势线";
            break;

        case OBJECT_TYPE.OBJECT_XABCD: /*TODO*/
            return "谐波形态";
            break;

        case OBJECT_TYPE.OBJECT_ALARM:
            return "警报";
            break;

        case OBJECT_TYPE.OBJECT_ARRAWLEFT:
            return "左箭头";
            break;

        case OBJECT_TYPE.OBJECT_ARRAWRIGHT:
            return "右箭头";
            break;

        case OBJECT_TYPE.OBJECT_ARRAWUP:
            return "上箭头";
            break;

        case OBJECT_TYPE.OBJECT_ARRAWDOWN:
            return "下箭头";
            break;

        case OBJECT_TYPE.OBJECT_TRIANGLE:
            return "三角";
            break;

        case OBJECT_TYPE.OBJECT_CHANNEL:
            return "通道";
            break;

        case OBJECT_TYPE.OBJECT_ANDREW:
            return "安德鲁音叉";
            break;
            
        case OBJECT_TYPE.OBJECT_TEXT:
            return "文本";
        break;
        
        case OBJECT_TYPE.OBJECT_LINTETO:
            return "箭头";
        break;
        }
        
        return "未知";
    }
};