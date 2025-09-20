//xlang Source, Name:Preference.x 
//Date: Sun Jul 06:16:40 2025 

class Preference{
    static JsonObject jssetting = new JsonObject();
    static bool loaded = false;
    static Object lockObject = new Object();

    static void removeKey(String key) {
        if (loaded == false){
            load();
        }
        while (jssetting.has(key)){
            jssetting.remove(key);
        }
    }

    public static bool setSetting(String key , String value){
        synchronized (lockObject) {
            removeKey(key);
            try {
                jssetting.put(key, value);
                save();
                return true;
            } catch (Exception e) {
          
            }
            return false;
        }
    }

    public static bool setSetting(String key , int value){
        synchronized (lockObject) {
            removeKey(key);
            try {
                jssetting.put(key, value);
                save();
                return true;
            } catch (Exception e) {
            
            }
            return false;
        }
    }

    public static bool setSetting(String key , long value){
        synchronized (lockObject) {
            removeKey(key);
            try {
                jssetting.put(key, value);
                save();
                return true;
            } catch (Exception e) {
            
            }
            return false;
        }
    }

    public static bool setSetting(String key , double value){
        synchronized (lockObject) {
            removeKey(key);
            try {
                jssetting.put(key, value);
                save();
                return true;
            } catch (Exception e) {
            
            }
            return false;
        }
    }

    public static bool setSetting(String key , bool value){
        synchronized (lockObject) {
            removeKey(key);
            try {
                jssetting.put(key, value);
                save();
                return true;
            } catch (Exception e) {
            
            }
            return false;
        }
    }

    public static String getString(String key){
        String res ;
        synchronized (lockObject) {
            load();
            res = jssetting.getString(key);
        }
        if (res == nilptr){
            res = "";
        }
        return res;
    }

    public static bool getBool(String key){
        synchronized (lockObject) {
            load();
            return jssetting.getBool(key);
        }
    }

    public static int getInt(String key){
        synchronized (lockObject) {
            load();
            return jssetting.getInt(key);
        }
    }
    
    public static int getInt(String key, int def){
        synchronized (lockObject) {
            load();
            if (jssetting.has(key)){
                return jssetting.getInt(key);
            }
        }
        return def;
    }

    public static long getLong(String key){
        synchronized (lockObject) {
            load();
            return jssetting.getLong(key);
        }
    }

    public static double getDouble(String key){
        synchronized (lockObject) {
            load();
            return jssetting.getDouble(key);
        }
    }

    static String getSettingPath(){
        return AssetsManager.getDataDir().appendPath("setting.cfg");
    }
    
    private static bool bBuffered = false;
    
    public static void beginSave(){
        bBuffered = true;
    }
    
    public static bool endSave(){
        bBuffered = false;
        return save();
    }
    
    static bool save(){
        if (bBuffered){
            return true;
        }
        FileOutputStream fos = nilptr;
        try {
            fos = new FileOutputStream(getSettingPath());
            byte [] data = jssetting.toString(false).getBytes();
            fos.write(data);
            return true;
        } catch (Exception e) {
        
        } finally {
            if (fos != nilptr){
                try {
                    fos.close();
                } catch (Exception e) {
                
                }
            }
        }
        return false;
    }

    static bool load(){
        if (bBuffered){
            return true;
        }
        if (loaded == false) {
            loaded = true;
            FileInputStream fis = nilptr;
            try {
                fis = new FileInputStream(getSettingPath());
                byte[] data = fis.readAllBytes();
                String content = new String(data);
                JsonObject jobj = new JsonObject(content);
                if (jobj != nilptr) {
                    jssetting = jobj;
                }
                return true;
            } catch (Exception e) {
            
            } finally {
                if (fis != nilptr) {
                    try {
                        fis.close();
                    } catch (Exception e) {
                    
                    }
                }
            }
            return false;
        }
        return true;
    }
};