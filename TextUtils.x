//xlang Source, Name:TextUtils.x 
//Date: Sun Jul 06:16:57 2025 

class TextUtils{
    public static bool isEmpty(String text){
        return (text == nilptr) || (text.length() == 0);
    }
    
    public static int u16len(String text){
        if (text != nilptr){
            try{
                return text.toCharArray(false).length;
            }catch(Exception e){
                
            }
            return text.length() / 3;
        }
        return 0;
    }
};