//xlang Source, Name:AssetsManager.x 
//Date: Sun Jul 06:20:02 2025 

class AssetsManager{
    static int assets_osid = _system_.getPlatformId();
    static String dataDir = "";
    public static void initAssets(){
        if (assets_osid == _system_.PLATFORM_ANDROID){
            dataDir = _system_.getWorkDirector();
        }else{
            if (assets_osid == _system_.PLATFORM_WINDOWS){
                dataDir = _system_.getEnvironmentVariable("ALLUSERSPROFILE").appendPath("xtrader");
                if (_system_.fileExists(dataDir) == false){
                    _system_.mkdir(dataDir);
                }
            }else{
                dataDir = _system_.getAppDirectory();
            }
        }
        _system_.mkdir(dataDir.appendPath("tmp"));
        _system_.mkdir(dataDir.appendPath("logs"));
        _system_.mkdir(dataDir.appendPath("chatcfg"));
    }
    
    public static String getDataDir(){
        return dataDir;
    }
    
    public static String getLogsDir(){
        return dataDir.appendPath("logs");
    }
    
    public static String getResource(String file){
        if (assets_osid == _system_.PLATFORM_ANDROID){
            return "assets:/".appendPath(file);
        }
        return _system_.getAppDirectory().appendPath("assets/".appendPath(file));
    }
    
    
};