//xlang Source, Name:SoundMgr.x 
//Date: Wed Jun 23:09:35 2025 

class SoundMgr{
    static QSoundEffect fall_sound = new QSoundEffect(),
            plok_succ = new QSoundEffect(),
            cancel_succ = new QSoundEffect(),
            closuss_succ = new QSoundEffect(),
            succ_sound = new QSoundEffect(),
            alarm_sound = new QSoundEffect(),
            eco_sound = new QSoundEffect();
            
    public static void init(){
        fall_sound.create();fall_sound.setLocalSource(AssetsManager.getResource("res/sound/fall.wav"));
        plok_succ.create();plok_succ.setLocalSource(AssetsManager.getResource("res/sound/plok.wav"));
        succ_sound.create();succ_sound.setLocalSource(AssetsManager.getResource("res/sound/succ.wav"));
        cancel_succ.create();cancel_succ.setLocalSource(AssetsManager.getResource("res/sound/cancelok.wav"));
        closuss_succ.create();closuss_succ.setLocalSource(AssetsManager.getResource("res/sound/cl.wav"));
        alarm_sound.create();alarm_sound.setLocalSource(AssetsManager.getResource("res/sound/6176.wav"));
        eco_sound.create();eco_sound.setLocalSource(AssetsManager.getResource("res/sound/y1478.wav"));
    }
    
    public static void tradsucc(){
        if (Setting.isOptionEffect()){
            succ_sound.play();
        }
    }
    
    public static void ecoCaution(){
        if (Setting.isOptionEffect()){
            eco_sound.play();
        }
    }
    
    public static void placeholdsucc(){
        if (Setting.isOptionEffect()){
            plok_succ.play();
        }
    }
    
    public static void fail(){
        if (Setting.isOptionEffect()){
            fall_sound.play();
        }
    }
    
    public static void cancelOk(){
        if (Setting.isOptionEffect()){
            cancel_succ.play();
        }
    }
        
    public static void closeOk(){
        if (Setting.isOptionEffect()){
            closuss_succ.play();
        }
    }
    
    public static void playAlarm(){
        alarm_sound.play();
    }
};