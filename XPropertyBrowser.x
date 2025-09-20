//xlang Source, Name:XPropertyBrowser.x
//Date: Fri Aug 15:45:17 2025


interface PropertyListener{
    @NotNilptr 
    String getSetting(String [] options, @NotNilptr String key);
    bool setSetting(@NotNilptr String key, String val);
};

class XPropertyBrowser : public QPropertyBrowser {
    JsonObject currentRecord = nilptr;
    PropertyListener _listener = nilptr;
    
    public XPropertyBrowser(PropertyListener pl){
        _listener = pl;
    }
    
    static class ItemRecord {
        public JsonObject obj;
        public ItemRecord (JsonObject str) {
            obj = str;
        }
    };

    static class ItemValue {
        public ItemRecord ir;
        public String defaultText;

        public ItemValue (ItemRecord _ir, String ds) {
            ir = _ir;
            defaultText = ds;
        }
        public ItemValue (ItemRecord _ir) {
            ir = _ir;
        }
    };
    
    Map<String, QPropertyBrowser.QtVariantProperty> currentProps = new Map<String, QPropertyBrowser.QtVariantProperty>();
    
    public void loadProperites(@NotNilptr JsonObject root, String key){
        currentRecord = root;
        ItemRecord jo = new ItemRecord(currentRecord);
        loadFeature((JsonObject)root.child(), jo, key);
    }
        
    public bool filterFeature (@NotNilptr JsonObject confi, String key) {
        bool loaded = false;

        while (confi != nilptr) {
            String cfgName = confi.getName();
            String type = confi.getString ("type");

            if (cfgName != nilptr && type != nilptr) {
                if (cfgName.split (':').length == 2) {
                    if (type.equals ("string") ) {
                        if (filterString (cfgName, confi,  key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("stringlist") ) {
                        if (filterStringList (cfgName, confi,  key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("keysequence") ) {
                        if (filterKeySequence (cfgName, confi,  key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("color") ) {
                        if (filterColor (cfgName, confi,  key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("options") ) {
                        if (filterOptions (cfgName, confi, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("bool") ) {
                        if (filterBoolean (cfgName, confi,  key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("text") ) {
                        if (filterTextItem (cfgName, confi, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("params") ) {
                        if (filterTextparams (cfgName, confi,  key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("fileout") ) {
                        if (filterSavePath (cfgName, confi,  key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("filein") ) {
                        if (filterOpenPath (cfgName, confi,  key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("folder") ) {
                        if (filterPath (cfgName, confi,  key) ) {
                            loaded = true;
                        }
                    }
                }
            }

            confi = (JsonObject) confi.next();
        }

        return loaded;
    }

    public bool loadFeature (@NotNilptr JsonObject confi, ItemRecord xp, String key) {
        QPropertyBrowser.QtVariantPropertyManager variantManager = new QPropertyBrowser.QtVariantPropertyManager (this);
        bool loaded = true;

        while (confi != nilptr) {
            String cfgName = confi.getName();
            String type = confi.getString ("type");

            if (cfgName != nilptr && type != nilptr) {
                if (cfgName.split (':').length == 2) {
                    if (type.equals ("string") ) {
                        if (loadString (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("stringlist") ) {
                        if (loadStringList (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("keysequence") ) {
                        if (loadKeySequence (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("color") ) {
                        if (loadColor (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("options") ) {
                        if (loadOptions (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("font") ) {
                        if (loadFont (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("bool") ) {
                        if (loadBoolean (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("text") ) {
                        if (loadTextItem (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("params") ) {
                        if (loadTextparams (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("fileout") ) {
                        if (loadSavePath (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("filein") ) {
                        if (loadOpenPath (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    } else if (type.equals ("folder") ) {
                        if (loadPath (variantManager, cfgName, confi, xp, key) ) {
                            loaded = true;
                        }
                    }
                }
            }

            confi = (JsonObject) confi.next();
        }

        setFactoryForManager (variantManager, new QPropertyBrowser.QtVariantEditorFactory (this) );
        setPropertiesWithoutValueMarked (true);
        setRootIsDecorated (false);
        return loaded;
    }

    /*public void loadProperites ( @NotNilptr JsonObject root, bool noload, String key) {
        bool loaded = noload;

        //new QPropertyBrowser.QtVariantPropertyManager()
        while (root != nilptr) {
            String featName = root.getName();
            JsonObject confi = (JsonObject) root.child();

            if (confi != nilptr) {
                if (key == nilptr || featName.lower().indexOf (key) != -1 || filterFeature (confi, key) ) {
                    long litem = _listview.addItem (nilptr, featName);
                    _listview.setItemTag (litem, 0, _propItems.size() );
                    ItemRecord jo = new ItemRecord (root);
                    _propItems.add (jo);

                    if ( (loaded == false && feature == nilptr) || (feature == featName) ) {
                        _listview.setItemSelected (litem, true);
                        loadFeature (confi, jo, key);
                        loaded = true;
                    }
                }
            }

            root = (JsonObject) root.next();
        }
    }*/
    
    
    static const int TYPE_OPTIONS = 1, TYPE_STRINGLIST = 2 , TYPE_COLOR = 3;
    
    public void flushSetting(){
        Map.Iterator<String, QPropertyBrowser.QtVariantProperty> iter = currentProps.iterator();
        for (; iter.hasNext(); iter.next()){
            String key = iter.getKey();
            
            if (key== nilptr){
                key = "unknow";
            }
            
            QPropertyBrowser.QtVariantProperty item = iter.getValue();
            
            if (item != nilptr){
                String value = item.getValue();
                if (value != nilptr){
                    if (item.getFlags() == TYPE_STRINGLIST){
                        try{
                            ItemValue ir = (ItemValue)item.getTagObject();
                            value = ir.defaultText;
                        }catch(Exception e){
                            
                        }
                    }else
                    if (item.getFlags() == TYPE_OPTIONS){
                        if (value.equals("未设置") == false && value.equals("Not Set") == false){
                            int lp = value.indexOf('('), rp = value.lastIndexOf(')');
                            if (lp != -1 && rp != -1){
                                value = value.substring(lp + 1,rp);
                            }
                        }else{
                            value = "";
                        }
                    }else
                    if (item.getFlags() == TYPE_COLOR){
                        value = "" + parseColor(value);
                    }
                    setSetting(key, value);
                }
            }
        }
    }
    
    public bool filterOpenPath (@NotNilptr String name, @NotNilptr JsonObject root, String filterKey) {
        String [] kv = name.split (':');
        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }

    public bool loadOpenPath (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr String name, @NotNilptr JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');
        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addEnumProperty (new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setTagObject (new ItemValue (xp) );

        String [] options = new String[2];
        options[0] = defaultValue;
        options[1] = "<浏览...>";
        item.setAttributeEnumNames (options);

        manager.setPropertyEventListener (item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener() {
            void onVariantPropertyValueChanged (long prop, int dataType, String stringValue) override {
                if (stringValue != nilptr) {
                    if (stringValue.parseInt() != 0) {
                        item.setValue (defaultValue);
                        String newValue = QFileDialog.getOpenFileName ("浏览 - " + kv[0], options[0], "*", Dialog.getInstance() );

                        if (newValue != nilptr) {
                            //_prop.setValue(_project,_curconfig, kv[1], newValue);
                            options[0] = newValue;
                            item.setAttributeEnumNames (options);
                        }

                        item.setValue ("0");
                    }
                }
            }
        });
        addProperty (item);
        currentProps.put (kv[1], item);
        return true;
    }

    public bool filterPath (@NotNilptr  String name, @NotNilptr JsonObject root, String filterKey) {
        String [] kv = name.split (':');
        String defaultText = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultText == nilptr || defaultText.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }

    public bool loadPath (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr  String name, @NotNilptr JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');
        String defaultText = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultText == nilptr || defaultText.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        String [] options = new String[2];
        options[0] = defaultText;
        options[1] = "<浏览...>";

        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addEnumProperty (new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setAttributeEnumNames (options);
        item.setTagObject (new ItemValue (xp) );

        manager.setPropertyEventListener (item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener() {
            void onVariantPropertyValueChanged (long prop, int dataType, String stringValue) override {
                if (stringValue != nilptr) {
                    if (stringValue.parseInt() != 0) {
                        item.setValue ("0");
                        String newValue = QFileDialog.getFolderPath ("选择目录", options[0], nilptr, Dialog.getInstance() );

                        if (newValue != nilptr) {
                            options[0] = newValue;
                            item.setAttributeEnumNames (options);
                        }

                        item.setValue ("0");
                    }
                }
            }
        });
        addProperty (item);
        currentProps.put (kv[1], item);
        return true;
    }

    public bool filterSavePath (@NotNilptr  String name, @NotNilptr  JsonObject root, String filterKey) {
        String [] kv = name.split (':');
        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }

    public bool loadSavePath (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr  String name, @NotNilptr  JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');
        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        String [] options = new String[2];
        options[0] = defaultValue;
        options[1] = "<浏览...>";
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addEnumProperty (new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setAttributeEnumNames (options);
        item.setTagObject (new ItemValue (xp) );

        manager.setPropertyEventListener (item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener() {
            void onVariantPropertyValueChanged (long prop, int dataType, String stringValue) override {
                if (stringValue != nilptr) {
                    if (stringValue.parseInt() != 0) {
                        item.setValue (defaultValue);
                        String newValue = QFileDialog.getOpenFileName ("浏览 - " + kv[0], options[0], "*", Dialog.getInstance() );

                        if (newValue != nilptr) {
                            //_prop.setValue(_project,_curconfig, kv[1], newValue);
                            options[0] = newValue;
                            item.setAttributeEnumNames (options);
                        }

                        item.setValue ("0");
                    }
                }
            }
        });
        addProperty (item);
        currentProps.put (kv[1], item);
        return true;
    }

    public bool filterTextparams (@NotNilptr  String name, @NotNilptr JsonObject root, String filterKey) {
        String [] kv = name.split (':');
        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }
    
    
    
    public bool loadTextparams (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr  String name, @NotNilptr JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');
        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addEnumProperty (new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setFlags (TYPE_STRINGLIST);
        ItemValue iv = new ItemValue (xp, defaultValue);

        item.setTagObject (iv);

        String simpleValue = "", detailValue = "";

        try {
            JsonArray jarv = new JsonArray (defaultValue);

            for (int i = 0, c = jarv.length(); i < c; i++) {
                String value = jarv.getString (i);

                if (detailValue.length() > 0) {
                    detailValue = detailValue + "\n" + value;
                    simpleValue = simpleValue + ";" + value;
                } else {
                    detailValue = value;
                    simpleValue = value;
                }
            }
        } catch (Exception e) {

        }

        String [] options = new String[2];
        options[0] = simpleValue;
        options[1] = "<编辑...>";


        item.setAttributeEnumNames (options);

        manager.setPropertyEventListener (item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener (defaultValue) {
            public onPropertyEventListener (String def) {
                defText = def;
            }
            String defText = "";
            void onVariantPropertyValueChanged (long prop, int dataType, String stringValue) override {
                if (stringValue != nilptr) {
                    if (stringValue.parseInt() != 0) {

                        TextDetail td = nilptr;
                        td = new TextDetail (new TextDetail.closeListener() {
                            void onClose (@NotNilptr String text, bool updated) override{
                                if (updated) {
                                    detailValue = text.trim (true);
                                    String [] newValue = detailValue.split ('\n');
                                    JsonArray jset = new JsonArray();

                                    for (int i = 0; i < newValue.length; i++) {
                                        jset.put (newValue[i]);
                                    }

                                    defText = jset.toString (true);
                                    iv.defaultText = defText;
                                    //_prop.setValue(_project,_curconfig, kv[1], defaultValue);
                                    simpleValue = text.trim (true).replace ("\n", ";");
                                    options[0] = simpleValue;
                                    item.setAttributeEnumNames (options);
                                }

                                item.setValue ("0");
                            }

                            void onCreate() override{
                                td.centerScreen();
                            }
                        });
                        td.create ("编辑 - " + kv[0], detailValue, Dialog.getInstance(), true);
                    }
                }
            }
        });
        addProperty (item);
        currentProps.put (kv[1], item);
        return true;
    }

    public bool filterTextItem (@NotNilptr  String name, @NotNilptr  JsonObject root, String filterKey) {
        String [] kv = name.split (':');

        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }

    public bool loadTextItem (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr  String name, @NotNilptr  JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');

        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addEnumProperty (new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setTagObject (new ItemValue (xp) );
        String [] options = new String[2];
        options[0] = defaultValue;
        options[1] = "<编辑...>";
        item.setAttributeEnumNames (options);

        manager.setPropertyEventListener (item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener() {
            void onVariantPropertyValueChanged (long prop, int dataType, String stringValue) override {
                if (stringValue != nilptr) {
                    if (stringValue.parseInt() != 0) {

                        TextDetail td = nilptr;
                        td = new TextDetail (new TextDetail.closeListener() {
                            void onClose (@NotNilptr String text, bool updated) override{
                                if (updated) {
                                    String newValue = text.trim (true);
                                    //_prop.setValue(_project,_curconfig, kv[1], newValue);
                                    options[0] = newValue;
                                    item.setAttributeEnumNames (options);
                                }

                                item.setValue ("0");
                            }

                            void onCreate() override{
                                td.centerScreen();
                            }
                        });

                        td.create ("编辑 - " + kv[0], options[0], Dialog.getInstance(), true);

                    }
                }
            }
        });
        addProperty (item);
        currentProps.put (kv[1], item);
        return true;
    }

    public bool filterString (@NotNilptr  String name, @NotNilptr  JsonObject root, String filterKey) {
        String [] kv = name.split (':');
        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }

    public bool loadString (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr  String name, @NotNilptr  JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');
        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addProperty (new QPropertyBrowser.QtVariantProperty(), QVariant.String, kv[0]);
        item.setTagObject (new ItemValue (xp) );
        addProperty (item);
        item.setValue (defaultValue);
        currentProps.put (kv[1], item);
        return true;
    }

    public bool filterBoolean (@NotNilptr  String name, @NotNilptr  JsonObject root, String filterKey) {
        String [] kv = name.split (':');
        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }

    public bool loadBoolean (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr  String name, @NotNilptr  JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');
        String defaultValue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addEnumProperty (new QPropertyBrowser.QtVariantProperty(), kv[0]);

        item.setTagObject (new ItemValue (xp) );
        item.setFlags (TYPE_OPTIONS);



        if (defaultValue != nilptr) {
            if (defaultValue.equals ("True") ) {
                defaultValue = "1";
            } else {
                defaultValue = "0";
            }
        }else{
            defaultValue = "0";
        }

        String [] options = {"否(False)", "是(True)"};


        item.setAttributeEnumNames (options);
        item.setValue (defaultValue);
        addProperty (item);
        currentProps.put (kv[1], item);
        return true;
    }

    public bool filterOptions (@NotNilptr  String name, @NotNilptr  JsonObject root, String filterKey) {
        String [] kv = name.split (':');
        String selvalue = getSetting (nilptr, kv[1]);
        String allVal = "";



        JsonArray list = root.getArray ("list");

        if (list == nilptr) {
            return true;
        }

        String [] options = new String[0];

        if (selvalue != nilptr) {
            int count = list.length();
            String addition = nilptr;

            if (selvalue.length() == 0 || selvalue.equals ("Not Set") || selvalue.equals ("未设置") ) {
                selvalue = "0";
            } else {
                bool bfound = false;
                String ends = "(" + selvalue + ")";

                for (int i : list.length() ) {
                    String szItem = list.getString (i);

                    if (szItem != nilptr) {
                        if (szItem.endsWith (ends) || szItem.equals (selvalue) ) {
                            selvalue = "" + i;
                            bfound = true;
                            break;
                        }
                    }
                }

                if (!bfound) {
                    count++;
                    addition = ends;
                    selvalue = "" + list.length();
                }
            }

            options = new String[count];

            for (int i : list.length() ) {
                options[i] = list.getString (i);
                allVal = allVal + ";" + options[i];
            }

            if (addition != nilptr) {
                options[count - 1] = "未知" + addition;
                allVal = allVal + ";" + options[count - 1];
            }
        }

        allVal = allVal + ";" + selvalue;

        if (filterKey != nilptr && filterKey != "" && (allVal == nilptr || allVal.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }

    
    
    public bool loadFont (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr  String name, @NotNilptr  JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');
        String selvalue = getSetting (nilptr, kv[1]);
        
        String [] options = new String[]{selvalue, "选择字体..."};
        
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addEnumProperty (new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setTagObject (new ItemValue (xp) );
        item.setFlags (TYPE_OPTIONS);
        item.setAttributeEnumNames (options);
        item.setValue ("0");
        addProperty (item);
        currentProps.put (kv[1], item);
        
        manager.setPropertyEventListener(item,
            new QPropertyBrowser.PropertyManager.onPropertyEventListener(){
				void onVariantPropertyValueChanged(long prop, int dataType, String stringValue)override{
					if (stringValue != nilptr){
                        if (stringValue.parseInt() != 0){
							item.setValue(selvalue);

							String newFont = QFontDialog.getFontDialog("选择字体",getSetting(nilptr,"ui_font"),Dialog.getInstance());
                            
							if (newFont != nilptr){
								options = new String[]{newFont, "选择字体..."};
								item.setAttributeEnumNames (options);
                                item.setValue ("0");
                            }else{
								item.setValue("0");
                            }
                        }
                    }
				}
            });
        return true;
    }
    
    public bool loadOptions (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr  String name, @NotNilptr  JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');
        String selvalue = getSetting (nilptr, kv[1]);
        String allVal = "";



        JsonArray list = root.getArray ("list");

        if (list == nilptr) {
            return true;
        }

        String [] options = new String[0];

        if (selvalue != nilptr) {
            int count = list.length();
            String addition = nilptr;

            if (selvalue.length() == 0 || selvalue.equals ("Not Set") || selvalue.equals ("未设置") ) {
                selvalue = "0";
            } else {
                bool bfound = false;
                String ends = "(" + selvalue + ")";

                for (int i : list.length() ) {
                    String szItem = list.getString (i);

                    if (szItem != nilptr) {
                        if (szItem.endsWith (ends) || szItem.equals (selvalue) ) {
                            selvalue = "" + i;
                            bfound = true;
                            break;
                        }
                    }
                }

                if (!bfound) {
                    count++;
                    addition = ends;
                    selvalue = "" + list.length();
                }
            }

            options = new String[count];

            for (int i : list.length() ) {
                options[i] = list.getString (i);
                allVal = allVal + ";" + options[i];
            }

            if (addition != nilptr) {
                options[count - 1] = "未知" + addition;
                allVal = allVal + ";" + options[count - 1];
            }
        }

        allVal = allVal + ";" + selvalue;

        if (filterKey != nilptr && filterKey != "" && (allVal == nilptr || allVal.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addEnumProperty (new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setTagObject (new ItemValue (xp) );
        item.setFlags (TYPE_OPTIONS);
        item.setAttributeEnumNames (options);
        item.setValue (selvalue);
        addProperty (item);
        currentProps.put (kv[1], item);
        return true;
    }

    public bool filterKeySequence (@NotNilptr  String name, @NotNilptr  JsonObject root, String filterKey) {
        String [] kv = name.split (':');
        String selvalue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (selvalue == nilptr || selvalue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }

    public bool loadKeySequence (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr  String name, @NotNilptr  JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');
        String selvalue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (selvalue == nilptr || selvalue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addProperty (new QPropertyBrowser.QtVariantProperty(), QVariant.KeySequence, kv[0]);

        item.setTagObject (new ItemValue (xp) );

        addProperty (item);
        item.setValue (selvalue);
        currentProps.put (kv[1], item);
        return true;
    }

    public static String splitColor (@NotNilptr String text) {
        if (text.startsWith ("#") ) {
            if (text.length() == 7) {
                return "ff" + text.substring (5, 7) + text.substring (3, 5) + text.substring (1, 3);
            }

            if (text.length() == 9) {
                return text.substring (1, 3) + text.substring (7, 9) + text.substring (5, 7) + text.substring (3, 5);
            }

        } else if (text.startsWith ("0x") ) {
            return text.substring (2, text.length() );
        }

        return "ff000000";
    }

    public static String getColor (@NotNilptr String text, @NotNilptr  String prefix) {
        if (text.startsWith (prefix) ) {
            return text;
        }

        if (text.startsWith ("#") ) {
            if (prefix.equals ("0x") ) {
                return prefix + splitColor (text);
            }

            return "0xff000000";
        }

        if (text.startsWith ("0x") ) {
            if (prefix.equals ("#") ) {
                return prefix + splitColor (text.replace ("0x", prefix) );
            }

            return "#ff000000";
        }

        text = text.replace ("[", "").replace ("]", "").replace ("(", ",").replace (")", "");
        String [] colors = text.split (',');

        if (colors.length == 4) {
            for (int i = 0; i < 4; i++) {
                colors[i] = String.format ("%02X", colors[i].trim (true).parseInt() );
            }

            String outcolor =  "";

            if (prefix.equals ("0x") ) {
                outcolor = prefix + colors[3] + colors[2] + colors[1] + colors[0];
            } else {
                outcolor = prefix + colors[3] + colors[0] + colors[1] + colors[2];
            }

            return outcolor;
        }

        return prefix + "00000000";
    }

    public bool filterColor (@NotNilptr  String name, JsonObject root, String filterKey) {
        String [] kv = name.split (':');
        String strvalue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (strvalue == nilptr || strvalue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }
    
    public String parseColor(String text){
        if (text.startsWith("#")){
            return "" + (text.substring(1).parseHex());
        }
        if (text.indexOf('[') != -1){
            text = text.replace ("[", "").replace ("]", "").replace ("(", ",").replace (")", "");
            String [] colors = text.split (',');

            if (colors.length == 4) {
                for (int i = 0; i < 4; i++) {
                    colors[i] = String.format ("%02X", colors[i].trim (true).parseInt() );
                }
                String outcolor = colors[3] + colors[0] + colors[1] + colors[2];
                return "" + outcolor.parseHex();
            }
        }
        return text;
    }

    public bool loadColor (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr  String name, JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');
        String strvalue = getSetting (nilptr, kv[1]);

        if (filterKey != nilptr && filterKey != "" && (strvalue == nilptr || strvalue.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addProperty (new QPropertyBrowser.QtVariantProperty(), QVariant.Color, kv[0]);

        item.setTagObject (new ItemValue (xp) );

        QPropertyBrowser.QtBrowserItem pitem = addProperty (item);

        setItemExpand (pitem, false);

        item.setValue (String.format("#%08X", strvalue.parseInt()));
        currentProps.put (kv[1], item);
        item.setFlags(TYPE_COLOR);
        
        manager.setPropertyEventListener (item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener() {
            void onVariantPropertyValueChanged (long prop, int dataType, String stringValue) override {
                if (stringValue != nilptr) {
                    setSetting (kv[1], parseColor(stringValue));
                }
            }
        });
        return true;
    }

    public bool filterStringList (@NotNilptr String name, @NotNilptr JsonObject root, String filterKey) {
        String [] kv = name.split (':');

        JsonArray list = root.getArray ("list");
        String [] options = new String[0];
        String allVal = "";

        if (list != nilptr) {
            options = new String[list.length()];

            for (int i = 0; i < options.length; i++) {
                options[i] = list.getString (i);

                if (options[i].startsWith ("$(") ) {
                    String svalue = options[i].substring (2, options[i].length() - 1);
                    options[i] = getSetting (nilptr, svalue);
                }

                allVal = allVal + ";" + options[i];
            }
        }

        String defaultValue = getSetting (options, kv[1]);
        allVal = allVal + ";" + defaultValue;

        if (filterKey != nilptr && filterKey != "" && (allVal == nilptr || allVal.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        return true;
    }

    public bool loadStringList (@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr String name, @NotNilptr JsonObject root, ItemRecord xp, String filterKey) {
        String [] kv = name.split (':');

        JsonArray list = root.getArray ("list");
        String [] options = new String[0];
        String allVal = "";

        if (list != nilptr) {
            options = new String[list.length()];

            for (int i = 0; i < options.length; i++) {
                options[i] = list.getString (i);

                if (options[i].startsWith ("$(") ) {
                    String svalue = options[i].substring (2, options[i].length() - 1);
                    options[i] = getSetting (nilptr, svalue);
                }

                allVal = allVal + ";" + options[i];
            }
        }

        String defaultValue = getSetting (options, kv[1]);
        allVal = allVal + ";" + defaultValue;

        if (filterKey != nilptr && filterKey != "" && (allVal == nilptr || allVal.lower().indexOf (filterKey) == -1) && kv[0].lower().indexOf (filterKey) == -1) {
            return false;
        }

        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty) manager.addEnumProperty (new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setTagObject (new ItemValue (xp) );
        item.setAttributeEnumNames (options);
        item.setValue (defaultValue);
        addProperty (item);
        currentProps.put (kv[1], item);
        return true;
    }

    public void clear()override{
        super.clear();
        currentProps.clear();
    }
    
    public void reloadProperty(String filterKey){
        clear();
        loadProperites(currentRecord, "");
    }
    
    @NotNilptr public String getSetting(String [] options, @NotNilptr String key){
        String value = nilptr;
        if (_listener != nilptr){
            value = _listener.getSetting(options, key);
        }
        if (value == nilptr){
            return "";
        }
        return value;
    }
    
    public bool setSetting(@NotNilptr String key, String val){
        if (_listener != nilptr){
            return _listener.setSetting(key, val);
        }
		return true;
    }
};