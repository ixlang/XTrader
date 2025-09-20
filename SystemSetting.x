//xlang Source, Name:SystemSetting.x 
//Date: Sun Jul 07:32:30 2025 

class SystemSetting : QDialog {
	static JsonObject _template_root;
    static QRect rect = nilptr;
    private String feature;
    static const int TYPE_OPTIONS = 1, TYPE_STRINGLIST = 2 , TYPE_COLOR = 3;
    
    public bool onClose()override{
        rect = new QRect(x(), y(), width(), height());
        return true;
    }
   
    
    static bool bTemplateLoaded = loadTemplate();
    
    QPushButton btnClose;
    
    QTreeWidget _listview;
    QLineEdit _lineEdit;
    QPropertyBrowser _propTable = new QPropertyBrowser();    
    class ItemRecord{
        public JsonObject obj;
        public ItemRecord(JsonObject str){
            obj = str;
        }
    };
    
    class ItemValue{
        public ItemRecord ir;
        public String defaultText;
        
        public ItemValue(ItemRecord _ir, String ds){
            ir = _ir;
            defaultText = ds;
        }
        public ItemValue(ItemRecord _ir){
            ir = _ir;
        }
    };
    
    Vector<ItemRecord> _propItems = new Vector<ItemRecord>();
    
    Map<String, QPropertyBrowser.QtVariantProperty> currentProps = new Map<String, QPropertyBrowser.QtVariantProperty>();

	int current_sel_setting = 0;
    bool showSci = false;
    
    onTreeViewItemEvent listlistener = new onTreeViewItemEvent(){
        public void onItemClicked(@NotNilptr QTreeWidget list,long item, int column)override{
            if (item != 0){
                current_sel_setting = list.getItemTag(item, 0);
                String seltext = _listview.getItemText(item,0);
                showSci = seltext.equals("文本编辑器配色");
                saveSetting();
                reloadProperty(_lineEdit.getText().lower());
            }
        }
    };
    

	public void reloadProperty(String key){
		_propTable.clear();
		currentProps.clear();
		if (current_sel_setting >=0 && current_sel_setting < _propItems.size()){
            ItemRecord jo = _propItems.get(current_sel_setting);
            if (jo != nilptr){
                loadFeature((JsonObject)jo.obj.child(), jo, key);
                int w = width(), h = height();
                _propTable.resize(w - 200, h - 80);
            }
            //在这里注意
		}
    }
    
    public static String readSlnPropFile(@NotNilptr String file){
        FileInputStream fis = nilptr;
        try{
            fis = new FileInputStream(file);
        }catch(Exception e){
            _system_.consoleWrite("canot read file " + file);
        }
        
        if (fis != nilptr){
            byte []data = fis.readAllBytes();
            return new String(data);
        }
        
        return nilptr;
    }

    public static bool loadTemplate(){
        _template_root = new JsonObject(new String (__xPackageResource("configure/system.setting")));
        return false;
    }
    
    public bool loadSetting(String key){
        _listview.clear();
        _propTable.clear();
		currentProps.clear();
        
		if (_template_root == nilptr){
			loadTemplate();
        }
        
        bool noload = false;
		if (_template_root != nilptr){
			 loadProperites((JsonObject)_template_root.child(), noload, key);
             noload = true;
        }
        return true;
    }
        
    bool oldbuildinsetting = false;
    public void onAttach()override{
        //setWindowFlags(CustomizeWindowHint | WindowMinMaxButtonsHint | WindowCloseButtonHint  | Tool);
        _listview = attachByName( "listProp");
        _lineEdit = attachByName( "lineEdit");
        _propTable.create(this);
        _propTable.move(170, 25);
        _propTable.resize(500, 425);
        
        _lineEdit.setOnEditEventListener(new onEditEventListener() {
            void onTextChanged(QObject,@NotNilptr  String text)override {
                loadSetting(text.lower());
            }
        });
        _propTable.setLables("项","值");
        _propTable.enableAdjust(true);
        _propTable.setHeaderWidths(200, 300);
        
        String [] columns = {"选项"};
        _listview.setColumns(columns);
        _listview.setOnTreeViewItemEvent(listlistener);
        
        if (loadSetting(nilptr) == false){
            close();
            return ;
        }
        
		btnClose = attachByName( "btnClose");

        btnClose.setOnClickListener(
        new onClickListener(){
            public void onClick(QObject obj, bool checked)override{
                saveSetting();
                applySetting();
                close();
            }
        });
        
        setOnLayoutEventListener(new onLayoutEventListener(){
                public void onResize(QObject obj, int w, int h, int oldw, int oldh)override {
                    _lineEdit.resize(141, 28);
					_listview.resize(141, h - 78);
					btnClose.move(w - 100, h - 40);
                    _propTable.resize(w - 200, h - 80);
                }
        });
		
        setWindowTitle("设置");
        setWindowIcon("./assets/res/toolbar/prop.png");
        if (rect != nilptr){
            move(rect.left,rect.top);
            resize(rect.right,rect.bottom);
        }
        setModal(true);
        show();
        oldbuildinsetting = isShowBuildin();//XWorkspace.workspace.XIntelliSense();
        
    }
    
    public bool filterFeature(@NotNilptr JsonObject confi,String key){
        bool loaded = false;
       
        while(confi != nilptr){
            String cfgName = confi.getName();
            String type = confi.getString("type");
            if (cfgName != nilptr && type != nilptr){
                if (cfgName.split(':').length == 2){
                    if (type.equals("string")){
                        if (filterString(cfgName, confi,  key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("stringlist")){
                        if (filterStringList(cfgName, confi,  key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("keysequence")){
                        if (filterKeySequence(cfgName, confi,  key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("color")){
                        if (filterColor(cfgName, confi,  key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("options")){
                        if (filterOptions(cfgName, confi, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("bool")){
                        if (filterBoolean(cfgName, confi,  key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("text")){
                        if (filterTextItem(cfgName, confi, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("params")){
                        if (filterTextparams(cfgName, confi,  key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("fileout")){
                        if (filterSavePath(cfgName, confi,  key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("filein")){
                        if (filterOpenPath(cfgName, confi,  key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("folder")){
                        if (filterPath(cfgName, confi,  key)){
                            loaded = true;
                        }
                    }
                }
            }
            confi = (JsonObject)confi.next();
        }
        return loaded;
    }
    
    public bool loadFeature(@NotNilptr JsonObject confi, ItemRecord xp, String key){
        QPropertyBrowser.QtVariantPropertyManager variantManager = new QPropertyBrowser.QtVariantPropertyManager(_propTable);
        bool loaded = true;
        
        while(confi != nilptr){
            String cfgName = confi.getName();
            String type = confi.getString("type");
            if (cfgName != nilptr && type != nilptr){
                if (cfgName.split(':').length == 2){
                    if (type.equals("string")){
                        if (loadString(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("stringlist")){
                        if (loadStringList(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("keysequence")){
                        if (loadKeySequence(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("color")){
                        if (loadColor(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("options")){
                        if (loadOptions(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("bool")){
                        if (loadBoolean(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("text")){
                        if (loadTextItem(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("params")){
                        if (loadTextparams(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("fileout")){
                        if (loadSavePath(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("filein")){
                        if (loadOpenPath(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }else
                    if (type.equals("folder")){
                        if (loadPath(variantManager, cfgName, confi, xp, key)){
                            loaded = true;
                        }
                    }
                }
            }
            confi = (JsonObject)confi.next();
        }
        _propTable.setFactoryForManager(variantManager, new QPropertyBrowser.QtVariantEditorFactory(_propTable));
        _propTable.setPropertiesWithoutValueMarked(true);
        _propTable.setRootIsDecorated(false);
        return loaded;
    }
        
    public void loadProperites( @NotNilptr JsonObject root, bool noload, String key){
        bool loaded = noload;
        //new QPropertyBrowser.QtVariantPropertyManager()
		while(root != nilptr){
			String featName = root.getName();
            JsonObject confi = (JsonObject)root.child();
            if (confi != nilptr){
            if (key == nilptr || featName.lower().indexOf(key) != -1 || filterFeature(confi, key)){ 
                    long litem = _listview.addItem(nilptr, featName);
                    _listview.setItemTag(litem, 0, _propItems.size());
                    ItemRecord jo = new ItemRecord(root);
                    _propItems.add(jo);
                    if ((loaded == false && feature == nilptr) || (feature == featName)){
                        _listview.setItemSelected(litem,true);
                        loadFeature(confi, jo, key);
                        loaded = true;
                    }
                }
            }
			root = (JsonObject)root.next();
		}
    }
    
    public bool filterOpenPath(@NotNilptr String name, @NotNilptr JsonObject root, String filterKey){
        String [] kv = name.split(':');
        String defaultValue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        return true;
    }
    
    public bool loadOpenPath(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr String name, @NotNilptr JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        String defaultValue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addEnumProperty(new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setTagObject(new ItemValue(xp));
        
        String [] options = new String[2];
        options[0] = defaultValue;
        options[1] = "<浏览...>";
        item.setAttributeEnumNames(options);
        
        manager.setPropertyEventListener(item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener(){
            void onVariantPropertyValueChanged(long prop, int dataType, String stringValue)override{
                if (stringValue != nilptr){
                    if (stringValue.parseInt() != 0){
                        item.setValue(defaultValue);
                        String newValue = QFileDialog.getOpenFileName("浏览 - " + kv[0], options[0],"*", Dialog.getInstance());
                        if (newValue != nilptr){
                            //_prop.setValue(_project,_curconfig, kv[1], newValue);
                            options[0] = newValue;
                            item.setAttributeEnumNames(options);
                        }
                        item.setValue("0");
                    }
                }
            }
        });
        _propTable.addProperty(item);
        currentProps.put(kv[1], item);
        return true;
    }
    
    public bool filterPath(@NotNilptr  String name, @NotNilptr JsonObject root, String filterKey){
        String [] kv = name.split(':');
        String defaultText = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultText == nilptr || defaultText.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        return true;
    }
    
    public bool loadPath(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager,@NotNilptr  String name, @NotNilptr JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        String defaultText = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultText == nilptr || defaultText.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        String [] options = new String[2];
        options[0] = defaultText;
        options[1] = "<浏览...>";
        
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addEnumProperty(new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setAttributeEnumNames(options);
        item.setTagObject(new ItemValue(xp));
        
        manager.setPropertyEventListener(item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener(){
            void onVariantPropertyValueChanged(long prop, int dataType, String stringValue)override{
                if (stringValue != nilptr){
                    if (stringValue.parseInt() != 0){
                        item.setValue("0");
                        String newValue = QFileDialog.getFolderPath("选择目录",options[0],nilptr,Dialog.getInstance());
                        if (newValue != nilptr){
                            options[0] = newValue;
                            item.setAttributeEnumNames(options);
                        }
                        item.setValue("0");
                    }
                }
            }
        });
        _propTable.addProperty(item);
        currentProps.put(kv[1], item);
        return true;
    }
    
    public bool filterSavePath(@NotNilptr  String name,@NotNilptr  JsonObject root, String filterKey){
        String [] kv = name.split(':');
        String defaultValue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        return true;
    }
    
    public bool loadSavePath(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager,@NotNilptr  String name,@NotNilptr  JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        String defaultValue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        
        String [] options = new String[2];
        options[0] = defaultValue;
        options[1] = "<浏览...>";
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addEnumProperty(new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setAttributeEnumNames(options);
        item.setTagObject(new ItemValue(xp));
        
        manager.setPropertyEventListener(item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener(){
            void onVariantPropertyValueChanged(long prop, int dataType, String stringValue)override{
                if (stringValue != nilptr){
                    if (stringValue.parseInt() != 0){
                        item.setValue(defaultValue);
                        String newValue = QFileDialog.getOpenFileName("浏览 - " + kv[0], options[0],"*",Dialog.getInstance());
                        if (newValue != nilptr){
                            //_prop.setValue(_project,_curconfig, kv[1], newValue);
                            options[0] = newValue;
                            item.setAttributeEnumNames(options);
                        }
                        item.setValue("0");
                    }
                }
            }
        });
        _propTable.addProperty(item);
        currentProps.put(kv[1], item);
        return true;
    }
    
    public bool filterTextparams(@NotNilptr  String name, @NotNilptr JsonObject root, String filterKey){
        String [] kv = name.split(':');
        String defaultValue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        return true;
    }
    
    public bool loadTextparams(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager,@NotNilptr  String name, @NotNilptr JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        String defaultValue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addEnumProperty(new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setFlags(TYPE_STRINGLIST);
        ItemValue iv = new ItemValue(xp, defaultValue);

        item.setTagObject(iv);
        
        String simpleValue = "", detailValue = "";
        try{
            JsonArray jarv = new JsonArray(defaultValue);
            for (int i = 0, c = jarv.length(); i < c; i++){
                String value = jarv.getString(i);
                if (detailValue.length() > 0){
                    detailValue = detailValue + "\n" + value;
                    simpleValue = simpleValue + ";" + value;
                }else{
                    detailValue = value;
                    simpleValue = value;
                }
            }
        }catch(Exception e){
            
        }
        
        String [] options = new String[2];
        options[0] = simpleValue;
        options[1] = "<编辑...>";
        

        item.setAttributeEnumNames(options);
        
        manager.setPropertyEventListener(item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener(defaultValue){
            public onPropertyEventListener(String def){
                defText = def;
            }
            String defText = "";
            void onVariantPropertyValueChanged(long prop, int dataType, String stringValue)override{
                if (stringValue != nilptr){
                    if (stringValue.parseInt() != 0){
                    
                        TextDetail td = nilptr;
                        td = new TextDetail(new TextDetail.closeListener() {
                            void onClose(@NotNilptr String text, bool updated) override{
                                if (updated){
                                    detailValue = text.trim(true);
                                    String [] newValue = detailValue.split('\n');
                                    JsonArray jset = new JsonArray();
                                    for (int i = 0; i < newValue.length; i++){
                                        jset.put(newValue[i]);
                                    }
                                    defText = jset.toString(true);
                                    iv.defaultText = defText;
                                    //_prop.setValue(_project,_curconfig, kv[1], defaultValue);
                                    simpleValue = text.trim(true).replace("\n", ";");
                                    options[0] = simpleValue;
                                    item.setAttributeEnumNames(options);
                                }
                                item.setValue("0");
                            }

                            void onCreate() override{ 
                                td.centerScreen();
                            }
                        });
                        td.create("编辑 - " + kv[0], detailValue, Dialog.getInstance(), true);
                    }
                }
            }
        });
        _propTable.addProperty(item);
        currentProps.put(kv[1], item);
        return true;
    }
    
    public bool filterTextItem(@NotNilptr  String name,@NotNilptr  JsonObject root, String filterKey){
        String [] kv = name.split(':');
        
        String defaultValue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        return true;
    }
    
    public bool loadTextItem(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager,@NotNilptr  String name,@NotNilptr  JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        
        String defaultValue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addEnumProperty(new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setTagObject(new ItemValue(xp));
        String [] options = new String[2];
        options[0] = defaultValue;
        options[1] = "<编辑...>";
        item.setAttributeEnumNames(options);
        
        manager.setPropertyEventListener(item,
        new QPropertyBrowser.PropertyManager.onPropertyEventListener(){
            void onVariantPropertyValueChanged(long prop, int dataType, String stringValue)override{
                if (stringValue != nilptr){
                    if (stringValue.parseInt() != 0){
                    
                        TextDetail td = nilptr;
                        td = new TextDetail(new TextDetail.closeListener() {
                            void onClose(@NotNilptr String text, bool updated) override{
                                if (updated){
                                    String newValue = text.trim(true);
                                    //_prop.setValue(_project,_curconfig, kv[1], newValue);
                                    options[0] = newValue;
                                    item.setAttributeEnumNames(options);
                                }
                                item.setValue("0");
                            }

                            void onCreate() override{
                                td.centerScreen();
                            }
                        });
                        
                        td.create("编辑 - " + kv[0], options[0], Dialog.getInstance(), true);
                        
                    }
                }
            }
        });
        _propTable.addProperty(item);
        currentProps.put(kv[1], item);
        return true;
    }
    
    public bool filterString(@NotNilptr  String name,@NotNilptr  JsonObject root, String filterKey){
        String [] kv = name.split(':');
        String defaultValue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        return true;
    }
    
    public bool loadString(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager,@NotNilptr  String name,@NotNilptr  JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        String defaultValue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addProperty(new QPropertyBrowser.QtVariantProperty(),QVariant.String, kv[0]);
        item.setTagObject(new ItemValue(xp));
        _propTable.addProperty(item);
        item.setValue(defaultValue);
        currentProps.put(kv[1], item);
        return true;
    }

    public bool filterBoolean(@NotNilptr  String name,@NotNilptr  JsonObject root, String filterKey){
        String [] kv = name.split(':');
        String defaultValue = getSetting(nilptr , kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        return true;
    }
    
    public bool loadBoolean(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager,@NotNilptr  String name,@NotNilptr  JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        String defaultValue = getSetting(nilptr , kv[1]);
        if (filterKey != nilptr && filterKey != "" && (defaultValue == nilptr || defaultValue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addEnumProperty(new QPropertyBrowser.QtVariantProperty(), kv[0]);
  
        item.setTagObject(new ItemValue(xp));
        item.setFlags(TYPE_OPTIONS);
        
        
        
        if (defaultValue != nilptr){
            if (defaultValue.equals("True")){
                defaultValue = "1";
            }else{
                defaultValue = "0";
            }
        }
    
        String [] options = {"否(False)", "是(True)"};

        
        item.setAttributeEnumNames(options);
        item.setValue(defaultValue);
        _propTable.addProperty(item);
        currentProps.put(kv[1], item);
        return true;
    }
    
    public bool filterOptions(@NotNilptr  String name,@NotNilptr  JsonObject root, String filterKey){
        String [] kv = name.split(':');
        String selvalue = getSetting(nilptr , kv[1]);
        String allVal = "";
        
        
        
        JsonArray list = root.getArray("list");
        
        if (list == nilptr){
            return true;
        }
        String [] options = new String[0];
        if (selvalue != nilptr){
            int count = list.length();
            String addition = nilptr;
            
            if (selvalue.length() == 0 || selvalue.equals("Not Set") || selvalue.equals("未设置")){
                selvalue = "0";
            }else{
                bool bfound = false;
                String ends = "(" + selvalue + ")";
                for (int i : list.length()){
                    String szItem = list.getString(i);
                    if (szItem != nilptr){
                        if (szItem.endsWith(ends) || szItem.equals(selvalue)){
                            selvalue = "" + i;
                            bfound = true;
                            break;
                        }
                    }
                }
                if (!bfound){
                    count++;
                    addition = ends;
                    selvalue = "" + list.length();
                }
            }
        
            options = new String[count];
            for (int i : list.length()){
                options[i] = list.getString(i);
                allVal = allVal + ";" + options[i];
            }
            
            if (addition != nilptr){
                options[count - 1] = "未知" + addition;
                allVal = allVal + ";" + options[count - 1];
            }
        }
        allVal = allVal + ";" + selvalue;
        if (filterKey != nilptr && filterKey != "" && (allVal == nilptr || allVal.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        
        return true;
    }
    
    public bool loadOptions(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager,@NotNilptr  String name,@NotNilptr  JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        String selvalue = getSetting(nilptr , kv[1]);
        String allVal = "";
        
        
        
        JsonArray list = root.getArray("list");
        
        if (list == nilptr){
            return true;
        }
        String [] options = new String[0];
        if (selvalue != nilptr){
            int count = list.length();
            String addition = nilptr;
            
            if (selvalue.length() == 0 || selvalue.equals("Not Set") || selvalue.equals("未设置")){
                selvalue = "0";
            }else{
                bool bfound = false;
                String ends = "(" + selvalue + ")";
                for (int i : list.length()){
                    String szItem = list.getString(i);
                    if (szItem != nilptr){
                        if (szItem.endsWith(ends) || szItem.equals(selvalue)){
                            selvalue = "" + i;
                            bfound = true;
                            break;
                        }
                    }
                }
                if (!bfound){
                    count++;
                    addition = ends;
                    selvalue = "" + list.length();
                }
            }
        
            options = new String[count];
            for (int i : list.length()){
                options[i] = list.getString(i);
                allVal = allVal + ";" + options[i];
            }
            
            if (addition != nilptr){
                options[count - 1] = "未知" + addition;
                allVal = allVal + ";" + options[count - 1];
            }
        }
        allVal = allVal + ";" + selvalue;
        if (filterKey != nilptr && filterKey != "" && (allVal == nilptr || allVal.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addEnumProperty(new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setTagObject(new ItemValue(xp));
        item.setFlags(TYPE_OPTIONS);
        item.setAttributeEnumNames(options);
        item.setValue(selvalue);
        _propTable.addProperty(item);
        currentProps.put(kv[1], item);
        return true;
    }
    
    public bool filterKeySequence(@NotNilptr  String name,@NotNilptr  JsonObject root, String filterKey){
        String [] kv = name.split(':');
        String selvalue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (selvalue == nilptr || selvalue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        return true;
    }
    
    public bool loadKeySequence(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager,@NotNilptr  String name,@NotNilptr  JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        String selvalue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (selvalue == nilptr || selvalue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addProperty(new QPropertyBrowser.QtVariantProperty(),QVariant.KeySequence, kv[0]);

        item.setTagObject(new ItemValue(xp));
        
        _propTable.addProperty(item);
        item.setValue(selvalue);
        currentProps.put(kv[1], item);
        return true;
    }
    
    public static String splitColor(@NotNilptr String text){
        if (text.startsWith("#")){
            if (text.length() == 7){
                return "ff" + text.substring(5,7) + text.substring(3,5) + text.substring(1,3);
            }
            if (text.length() == 9){
                return text.substring(1,3) + text.substring(7,9) + text.substring(5,7) + text.substring(3,5);
            }
            
        }else
        if (text.startsWith("0x")){
            return text.substring(2,text.length());
        }
        return "ff000000";
    }
    
    public static String getColor(@NotNilptr String text,@NotNilptr  String prefix){
        if (text.startsWith(prefix)){
            return text;
        }
        
        if (text.startsWith("#")){
            if (prefix.equals("0x")){
                return prefix + splitColor(text);
            }
            return "0xff000000";
        }
        if (text.startsWith("0x")){
            if (prefix.equals("#")){
                return prefix + splitColor(text.replace("0x", prefix));
            }
            return "#ff000000";
        }
        text = text.replace("[", "").replace("]", "").replace("(", ",").replace(")", "");
        String [] colors = text.split(',');
        if (colors.length == 4){
            for (int i = 0; i < 4; i++){
                colors[i] = String.format("%02X", colors[i].trim(true).parseInt());
            }
                
            String outcolor =  "";
            if (prefix.equals("0x")){
                outcolor = prefix + colors[3] + colors[2] + colors[1] + colors[0];
            }else{
                outcolor = prefix + colors[3] + colors[0] + colors[1] + colors[2];
            }
            
            return outcolor;
        }
        return prefix + "00000000";
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
    
    public bool filterColor(@NotNilptr  String name, JsonObject root, String filterKey){
        String [] kv = name.split(':');
        String strvalue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (strvalue == nilptr || strvalue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        return true;
    }
    
    public bool loadColor(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager,@NotNilptr  String name, JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        String strvalue = getSetting(nilptr, kv[1]);
        if (filterKey != nilptr && filterKey != "" && (strvalue == nilptr || strvalue.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addProperty(new QPropertyBrowser.QtVariantProperty(),QVariant.Color, kv[0]);
        
        item.setTagObject(new ItemValue(xp));
        
        QPropertyBrowser.QtBrowserItem pitem = _propTable.addProperty(item);
        
        _propTable.setItemExpand(pitem,false);
        item.setValue (String.format("#%08X", strvalue.parseInt()));
        currentProps.put(kv[1], item);
        item.setFlags(TYPE_COLOR);
        manager.setPropertyEventListener(item,
            new QPropertyBrowser.PropertyManager.onPropertyEventListener(){
                void onVariantPropertyValueChanged(long prop, int dataType, String stringValue)override{
                    if (stringValue != nilptr){
                        Preference.setSetting(kv[1], stringValue);
                    }
                }
            });
        return true;
    }

    public bool filterStringList(@NotNilptr String name, @NotNilptr JsonObject root, String filterKey){
        String [] kv = name.split(':');
        
        JsonArray list = root.getArray("list");
        String [] options = new String[0];
        String allVal = "";
        if (list != nilptr){
            options = new String[list.length()];
            for (int i = 0;i < options.length; i++){
                options[i] = list.getString(i);
                if (options[i].startsWith("$(")){
                    String svalue = options[i].substring(2,options[i].length() - 1);
                    options[i] = getSetting(nilptr, svalue);
                }
                allVal = allVal + ";" + options[i];
            }
        }
            
        String defaultValue = getSetting(options, kv[1]);
        allVal = allVal + ";" + defaultValue;
        
        if (filterKey != nilptr && filterKey != "" && (allVal == nilptr || allVal.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        return true;
    }
    
    public bool loadStringList(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager, @NotNilptr String name, @NotNilptr JsonObject root, ItemRecord xp, String filterKey){
        String [] kv = name.split(':');
        
        JsonArray list = root.getArray("list");
        String [] options = new String[0];
        String allVal = "";
        if (list != nilptr){
            options = new String[list.length()];
            for (int i = 0;i < options.length; i++){
                options[i] = list.getString(i);
                if (options[i].startsWith("$(")){
                    String svalue = options[i].substring(2,options[i].length() - 1);
                    options[i] = getSetting(nilptr, svalue);
                }
                allVal = allVal + ";" + options[i];
            }
        }
            
        String defaultValue = getSetting(options, kv[1]);
        allVal = allVal + ";" + defaultValue;
        
        if (filterKey != nilptr && filterKey != "" && (allVal == nilptr || allVal.lower().indexOf(filterKey) == -1) && kv[0].lower().indexOf(filterKey) == -1){
            return false;
        }
        
        QPropertyBrowser.QtVariantProperty item = (QPropertyBrowser.QtVariantProperty)manager.addEnumProperty(new QPropertyBrowser.QtVariantProperty(), kv[0]);
        item.setTagObject(new ItemValue(xp));
        item.setAttributeEnumNames(options);
        item.setValue(defaultValue);
        _propTable.addProperty(item);
        currentProps.put(kv[1], item);
        onLoadList(manager,item, kv[1], defaultValue);
        return true;
    }
    
    public void onLoadList(@NotNilptr QPropertyBrowser.QtVariantPropertyManager manager,@NotNilptr QPropertyBrowser.QtVariantProperty item,@NotNilptr  String kv, String defaultValue){
        String filterKey = _lineEdit.getText().lower();
        
        if (kv.equals("ui_font")){
			manager.setPropertyEventListener(item,
            new QPropertyBrowser.PropertyManager.onPropertyEventListener(){
				void onVariantPropertyValueChanged(long prop, int dataType, String stringValue)override{
					if (stringValue != nilptr){
                        if (stringValue.parseInt() != 0){
							item.setValue(defaultValue);
							flushSetting();
							String newFont = QFontDialog.getFontDialog("选择字体",getSetting(nilptr,"ui_font"),Dialog.getInstance());
                            
							if (newFont != nilptr){
								Preference.setSetting("ui_font", newFont);
								reloadProperty(filterKey);
                            }else{
								item.setValue("0");
                            }
                        }
                    }
				}
            });
        }else
        if (kv.equals("chat_font")){
			manager.setPropertyEventListener(item,
            new QPropertyBrowser.PropertyManager.onPropertyEventListener(){
				void onVariantPropertyValueChanged(long prop, int dataType, String stringValue)override{
					if (stringValue != nilptr){
                        if (stringValue.parseInt() != 0){
							item.setValue(defaultValue);
							flushSetting();
							String newFont = QFontDialog.getFontDialog("选择字体",getSetting(nilptr,"chat_font"),Dialog.getInstance());
                            
							if (newFont != nilptr){
								Preference.setSetting("chat_font", newFont);
								reloadProperty(filterKey);
                            }else{
								item.setValue("0");
                            }
                        }
                    }
				}
            });
        }else
        if (kv.equals("workspace")){
			manager.setPropertyEventListener(item,
            new QPropertyBrowser.PropertyManager.onPropertyEventListener(){
				void onVariantPropertyValueChanged(long prop, int dataType, String stringValue)override{
					if (stringValue != nilptr){
                        if (stringValue.parseInt() != 0){
							item.setValue(defaultValue);
							flushSetting();
							String newFont = QFileDialog.getFolderPath("选择默认工作空间",getSetting(nilptr,"workspace"),nilptr,Dialog.getInstance());
							if (newFont != nilptr){
								Preference.setSetting("workspace", newFont);
								reloadProperty(filterKey);
                            }else{
								item.setValue("0");
                            }
                        }
                    }
				}
            });
        }
    }        
    
    public static void applySetting(){
        XTApplication.Reconfig();
    }
    
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
                    if (item.getFlags() == 2){
                        try{
                            ItemValue ir = (ItemValue)item.getTagObject();
                            value = ir.defaultText;
                        }catch(Exception e){
                            
                        }
                    }else
                    if (item.getFlags() == 1){
                        if (value.equals("未设置") == false && value.equals("Not Set") == false){
                            int lp = value.indexOf('('), rp = value.lastIndexOf(')');
                            if (lp != -1 && rp != -1){
                                value = value.substring(lp + 1,rp);
                            }
                        }else{
                            value = "";
                        }
                    }
                    
                    if (false == setSetting(key, value)){
                        QMessageBox.Critical("错误", "无法保存设置:" + key, QMessageBox.Ok, QMessageBox.Ok);
                    }
                }
            }
        }
    }
    
    public void saveSetting(){
		flushSetting();
    }
    
    @NotNilptr public String getSetting(String [] options, @NotNilptr String key){
		String val = Preference.getString(key);
        if (val == nilptr){
            val = "";
        }
        if (options != nilptr){
            for (int i = 0; i < options.length; i++){
                if (options[i].equals(val)){
                    val = "" + i;
                    break;
                }
            }
        }
        return val;
    }
    
    public static bool setSetting(@NotNilptr String key, String val){
		return Preference.setSetting(key, val);
    }
    
    @NotNilptr public static String get(@NotNilptr String key){
		return Preference.getString(key);
    }
    
    public static bool isDarkStyle(){
		return get("style").equals("深色");
    }
        
    @NotNilptr public static String getStyle(){
		return get("style");
    }
    public static bool getBoolean(String key){
		return get(key).equals("True");
    }
    public static bool isIntellisense(){
		return get("intelsence").equals("开启");
    }
    public static bool isOutputWrap(){
		return get("outputwrap").equals("开启");
    }
    public static bool isEditWrap(){
		return get("editwrap").equals("开启");
    }
    public static bool isAutoSave(){
		return get("autosave").equals("开启");
    }
    public static bool isEditMd(){
		return get("mdmethod").equals("编辑");
    }
    public static bool isEditWeb(){
		return get("htmlmethod").equals("编辑");
    }
    public static bool isSwitchToInfo(){
		return get("switchinfo").equals("开启");
    }
    public static bool isUnixPath(){
        return get("unixpath").equals("开启");
    }
    public static int getLogcatMaxitems(){
		return get("logcatmax").parseInt();
    }
    public static bool outputThreadStat(){
        return get("threadstat").equals("开启");
    }
    public static bool nativeTrace(){
        return get("nativetrace").equals("开启");
    }
    public static bool outputGCStat(){
        return get("gcstat").equals("开启");
    }
    public static bool repallconfirm(){
		return get("repallconfirm").equals("开启");
    }
    
    public static bool isMatchBrace(){
		return get("brace").equals("开启");
    }
    
    public static bool isAutoIdent(){
		return get("ident").equals("开启");
    }
    
    public static bool isRelocalStdout(){
		return get("stdoutrel").equals("开启");
    }
    
    public static bool isShowLineNumber(){
		return get("linenumber").equals("开启");
    }
    
    public static int isAutoDownloadPkg(){
		return new String[]{
            "关闭",
            "提示",
            "开启"
        }.indexOf(get("autodownloadpkg"));
    }
    
    public static int getReportException(){
		return new String[]{
            "未被捕获的",
            "全部",
            "关闭"
        }.indexOf(get("report_exception"));
    }
    
    public static bool isAutoInstallPkg(){
		return get("autoinstallpck").equals("开启");
    }
    
    public static bool isAssociateXprj(){
		return getBoolean("associate_xprj");
    }
    
    public static bool isAssociateX(){
		return getBoolean("associate_x");
    }
    
    public static bool isAssociateCxx(){
		return getBoolean("associate_cxx");
    }
    
    public static bool isAutoImportPkg(){
		return get("autoloadpkg").equals("开启");
    }
    
    public static bool isShowFolding(){
		return get("showfolding").equals("开启");
    }
    
    public static bool isIndentGuide(){
		return get("indentguide").equals("开启");
    }
    public static bool welcomeOnStart(){
		return get("welcomeonstart").equals("开启") ;
    }
    public static bool welcomeOnClose(){
		return get("welcomeonclose").equals("开启") ;
    }
    
    public static bool isShowBuildin(){
		return get("showbuildin").equals("开启");
    }
    
    public static bool isUseTabstop(){
		return get("tabstop").equals("制表符");
    }
    
    public static bool isUseArgfile(){
		return get("argfile").equals("开启");
    }
    
    public static bool isCustomColor(){
		return (get("style_color").equals("自动") == false);
    }
    
    public static int getColorRef(@NotNilptr String key){
        String strvalue = get(key);
        String color = getColor(strvalue, "0x");
        if (color != nilptr){
            return color.parseHex();
        }
        return 0;
    }
    
    public static int getTabWidth(){
		int nw = get("tabwidth").parseInt();
        if (nw < 1){
			nw = 1;
        }
        return nw;
    }
    
    public static QFont getUIFontObject(){
        QFont uiFont;
        String sfont = get("ui_font");
        if (sfont.length() > 0){
            uiFont = QFont.loadFromString(sfont); 
        }

        if (uiFont == nilptr){
            uiFont = XTApplication.getDefaultFont();
        }
        return uiFont;
    }
      
    public static String getUIFontString(){
        return get("ui_font");
    }
    
    public static String getUIFont(){
    
		String font = "";
        QFont _font = getUIFontObject();
        
		if (_font != nilptr){
			font = _font.familyName();
        }

		if (font == nilptr || font.length() == 0){
			//bool bmac = (_system_.getPlatformId() == 2);
			font = "JetBrains Mono Medium";
		}
            
        return font;
    }
        
    public static int getUIFontSize(){
    
		int font_size = 0;
        
		QFont _font = getUIFontObject();
        
        if (_font != nilptr){
			font_size = _font.pointSize() * 100;
        }
        
        if (font_size == 0){
			if (_system_.getPlatformId() == 2){
				font_size = 1150;
			}else{
				font_size = 1000;
			}
		}
            
        return font_size;
    }
    
    public void setFeature(String __feature){
        feature = __feature;
    }
    
    public static bool showSetting() {
        QDialog newDlg = new QDialog();

        if (newDlg.load(UIManager.getUIData(__xPackageResource("ui/setting.ui")), Dialog.getInstance()) == false) {
            return false;
        }

        SystemSetting wizard = new SystemSetting();
        wizard.attach(newDlg);
        return true;
    }

    public static bool showSettingFor(String feature) {
        QDialog newDlg = new QDialog();

        if (newDlg.load(UIManager.getUIData(__xPackageResource("ui/setting.ui")), Dialog.getInstance()) == false) {
            return false;
        }

        SystemSetting wizard = new SystemSetting();
        wizard.setFeature(feature);
        wizard.attach(newDlg);
        return true;
    }
    
};