//xlang Source, Name:UIManager.x 
//Date: Sun Jul 06:05:43 2025 

class UIManager{
    public static QBuffer getUIData(byte [] buffer){
        QBuffer qb = new QBuffer();
        qb.setBuffer(buffer, 0, buffer.length);
        return qb;
    }
};