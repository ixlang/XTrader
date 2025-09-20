//xlang Source, Name:ControlPoint.x 
//Date: Sun Jul 00:24:02 2025 

class ControlPoint{
    static QPainter.Paint paint = new QPainter.Paint();
    static QPainter.Paint strokepaint = new QPainter.Paint();
    static bool bCptInit = false;
    QRect rect = new QRect();
    int curColor = 0xff2962FF;
    
    public ControlPoint(){
        if (!bCptInit){
            paint.setColor (0xff6C80F3);
            paint.setStyle (QPainter.Paint.FILL);
            
            strokepaint.setColor (curColor);
            strokepaint.setStyle (QPainter.Paint.STROKE);
            strokepaint.setStrokeWidth(2);
        }
    }
    
    public void drawAt(QPainter canvas, int x, int y, bool hover){
        if (hover) {
            paint.setColor (0xff000000);
            strokepaint.setColor (curColor);
        } else {
            paint.setColor (0x3f000000);
            strokepaint.setColor (0x3f000000 | (0x00ffffff & curColor));
        }
        
        rect.left = x - 6;
        rect.right = rect.left + 12;

        rect.top = y - 6;
        rect.bottom = rect.top + 12;
        
        canvas.setPaint(strokepaint);
        canvas.drawCircle (rect.centerPoint().x, rect.centerPoint().y, 6, paint);
    }
    
    public void setColor(int c){
        curColor = c;
    }
    
    public bool contains(int x, int y){
        return rect.contains(x, y);
    }
    
    public QRect Rect(){
        return rect;
    }
};