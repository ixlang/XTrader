//xlang Source, Name:DigiInput.x 
//Date: Sun Jul 06:04:41 2025 

class DigiInput : QDialog {
    QPushButton btnOk, btnCancel;
    QLineEdit diginput;
    FMMStyleManager fmbar = new FMMStyleManager();
    QLabel label_detail;
    QLineEdit lineEdit;
    
    public static class onInputListener{
        public void onInit(DigiInput){}
		public bool onInputOk(DigiInput dlg, @NotNilptr String text, @NotNilptr String unitCount);
        public bool onInputCancel(DigiInput dlg);
        public String getTitle();
        public String getDescription();
        public void onChange(DigiInput dlg, String input, @NotNilptr String unitCount);
        public String getDefault();
        public String getDefaultCount();
    };
    
    public onInputListener listener;
	public DigiInput(onInputListener intputlis){
		listener = intputlis;
    }
    
    
    onClickListener keylistener = new onClickListener(){
        void onClick(QObject btn, bool b)override{
            
            String id = btn.getName();
            String val = id.substring(1, id.length());
            String cash = diginput.getText();
            if (val.equals("11")){
                if (cash.length() > 0){
                    String text = cash.substring(0, cash.length() - 1);
                    if (text.length() == 0){
                        text = "0";
                    }
                    diginput.setText(text);
                }
            }else{
                if (val.equals("10")){
                    val = ".";
                }
                
                String addtxt = val;
                if (addtxt.equals(".")){
                    if (cash.length() == 0 || (cash.indexOf('.') != -1)){
                        return ;
                    }
                }else{
                    if (cash.equals("0")){
                        cash = "";
                    }
                }
                if (cash.length() >= 10){
                    return ;
                }
                diginput.setText(cash + addtxt);
            }
        }
    };
    
    
    public void onAttach()override{ 
        setWindowFlags(WindowType.CustomizeWindowHint | WindowType.WindowCloseButtonHint);
        btnOk = attachByName("btnOk");
        btnCancel = attachByName("btnCancel");
        lineEdit = attachByName("lineEdit");
        diginput = attachByName("diginput");
        QLabel label = attachByName("label");
        label_detail = attachByName("label_detail");
        
        setWindowTitle(listener.getTitle());
        fmbar.configure(this, FMMStyleManager.Theme.Auto);
 
        if (label != nilptr){
            diginput.setText(listener.getDefault());
            lineEdit.setText(listener.getDefaultCount());
            btnOk.setOnClickListener(
            new onClickListener(){
                void onClick(QObject obj, bool checked)override{
                    String text = diginput.getText();
                    btnOk.setEnabled(false);
                    if (listener.onInputOk(DigiInput.this, text, lineEdit.getText())){
                        close();
                    }else{
                        btnOk.setEnabled(true);
                    }           
                }
            });
            
            btnCancel.setOnClickListener(
            new onClickListener(){
                void onClick(QObject obj, bool checked)override{
                    btnCancel.setEnabled(false);
                    if (listener.onInputCancel(DigiInput.this)){
                        close();
                    }else{
                        btnCancel.setEnabled(true);
                    }
                }
            });
            
            diginput.setOnEditEventListener(new onEditEventListener() {
                void onTextChanged(QObject,@NotNilptr  String text)override {
                    listener.onChange(DigiInput.this, text, lineEdit.getText());
                }
            });
            
            lineEdit.setOnEditEventListener(new onEditEventListener() {
                void onTextChanged(QObject,@NotNilptr  String text)override {
                    listener.onChange(DigiInput.this, diginput.getText(), text);
                }
            });
            

            
            
            for (int i : 12){
                ((QPushButton)attachByName("k" + i)).setOnClickListener(keylistener);
            }
            
            label.setText(listener.getDescription());
            listener.onInit(this);
            setModal(true);
        }
    }
    
    public void setTips(String text){
        label_detail.setText(text);
        label_detail.setStyleSheetString("#label_detail{color : #000000;}");
    }
    
    public void setError(String text){
        label_detail.setText(text);
        label_detail.setStyleSheetString("#label_detail{color : #ff0000;}");
    }
    
    public static void requestInput(QWidget parent, onInputListener lis){
		QDialog newDlg = new QDialog();
        if (newDlg.load(UIManager.getUIData(__xPackageResource("ui/goods_confirm.ui")), parent) == false){
            return ;
        }
        
        DigiInput wizard = new DigiInput(lis);	
        wizard.attach(newDlg);
        wizard.show();
    }
};