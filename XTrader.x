// xlang

using {
    Qt;
    FileStream;
};

class XTApplication : QApplication {
    Dialog dialog;
    static XTApplication __instance = nilptr;
    public bool create() {
        if (super.createQApplication() ) {
            loadTranslator(AssetsManager.getResource("zh_CN.qm"));
            QObject.setUIEventSynched(false); //设置UI事件不强制同步，避免模态窗口阻塞消息循环
            loadFonts();
            FMMStyleManager.setUseDarkTheme(Setting.isDarkTheme());
            setStyleSheetString(FMMStyleManager.getThemeString());
            __instance = this;
            
            Reconfig();
            SoundMgr.init();
            dialog = new Dialog();
            
            if (dialog.create() ) {
                dialog.show();
                return true;
            }
        }

        return false;
    }
    
    void loadFonts() {
        File f = new File(_system_.getAppDirectory().appendPath("res/fonts"));
        long h = f.open();
        File recv = new File();
        while (f.find(h, recv)) {
            if (recv.isDirectory() == false) {
                QFont.loadFromFile(recv.getPath(), nilptr);
            }
        }
        f.close(h);
    }
    
    public static void Reconfig(){
        FMMStyleManager.setUseDarkTheme(Setting.isDarkTheme());
        if (__instance != nilptr){
            QFont uifont = SystemSetting.getUIFontObject();
            if (uifont != nilptr){
                __instance.setFont(uifont);
            }
            if (__instance.dialog != nilptr){
                __instance.dialog.Reconfig();
            }
            __instance.setStyleSheetString(FMMStyleManager.getThemeString());
        }
    }
    
    public static QApplication getApplication(){
        return __instance;
    }
    
    public static QFont getDefaultFont(){
        return nilptr;
    }
};


int main (String [] args) {
    AssetsManager.initAssets();
    XTApplication app = new XTApplication();

    if (app.create() ) {
        app.run();
    }

    return 0;
}