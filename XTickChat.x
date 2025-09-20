//xlang Source, Name:XTickChat.x 
//Date: Mon Jul 15:30:10 2025 

class XTickChat{
    int x = 20,  y = 50;
    bool moveDown = false;
    int ox, dx, oy, dy;
    
    public void onDraw(QPainter canvas, double [] data, int backGroundClr){
        canvas.translate(x, y);
        canvas.fillRect(-3, -3, 306, 206, 0x9f000000 | (backGroundClr & 0xffffff), QBrush.Style.SolidPattern);
        canvas.setPen(0xff2962FF, PenStyle.SolidLine, 3);
        canvas.setBrush(0, QBrush.Style.NoBrush);
        canvas.drawRect(-3, -3, 306, 206);
        canvas.setPen(0xff000000 | (~backGroundClr), PenStyle.SolidLine, 1);
        canvas.setClipRect(0, 0, 300, 200, ClipOperation.ReplaceClip);
        canvas.strokePath(data, 1, 300, 200);
        canvas.setClipRect(0, 0, 300, 200, ClipOperation.NoClip);
        canvas.translate(-x, -y);
    }
    
    public void relocal(TradingView tv){
        x = Math.max(0, x);
        y = Math.max(0, y);
        if (tv.getChatWidth() - (int)tv.getTextAreaWid() - 300 > 0){
            x = Math.min(x, tv.getChatWidth() - (int)tv.getTextAreaWid() - 300);
        }
        if (x < 0){
            x = 0;
        }
        if (y < 0){
            y = 0;
        }
        y = Math.min(y, tv.height() - 200);
        tv.postUpdate();
    }
    
    public bool onMouseMove(TradingView tv, int _x, int _y){
        if (moveDown){
            x = Math.max(0, ox + (_x - dx));
            y = Math.max(0, oy + (_y - dy));
            x = Math.min(x, tv.getChatWidth() - (int)tv.getTextAreaWid() - 300);
            y = Math.min(y, tv.height() - 200);
            tv.postUpdate();
            return true;
        }
        if (_x > x && _x < x + 300 && _y > y && _y < y + 200){
            tv.setCursor(Constant.SizeAllCursor);
            return true;
        }
        return false;
    }
    
    public bool onMouseDown(TradingView tv, int _x, int _y){
        if (_x > x && _x < x + 300 && _y > y && _y < y + 200){            
            moveDown = true;
            dx = _x;
            dy = _y;
            ox = x;
            oy = y;
            return true;
        }
        return false;
    }
    
    public bool onMouseUp(TradingView tv, int _x, int _y){
        if (moveDown){
            moveDown = false;
            return true;
        }
        return false;
    }
};