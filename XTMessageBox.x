//xlang Source, Name:XTMessageBox.x 
//Date: Tue Jul 19:43:10 2025 

class XTMessageBox : QDialog {
    QPushButton btnOk, btnCancel, sysclose;
    QLabel content, systitle;
    bool mouseDown = false;
    QPoint dp;
    int ox, oy;
    int result = 0;
    private XTMessageBox(){

    }
    
    public void onAttach()override{ 
        setWindowFlags(WindowType.FramelessWindowHint| WindowType.Dialog);
        setAttribute(Constant.WA_TranslucentBackground, true);
        btnOk = attachByName("btnOk");
        btnCancel = attachByName("btnCancel");
        sysclose = attachByName("sysclose");
        content = attachByName("content");
        systitle = attachByName("systitle");
        
        systitle.setOnMouseEventListener(new onMouseEventListener() {
            public void onMouseButtonPress(QObject obj, int Button, int x, int y, int flags, int source) override{
                dp = mapToGlobal(x, y);
                ox = x();
                oy = y();
                mouseDown = true;
            }
            public void onMouseButtonRelease(QObject obj, int Button, int x, int y, int flags, int source) override{
                mouseDown = false;
            }
            public void onMouseMove(QObject obj, int Button, int x, int y, int flags, int source) override{ 
                if (mouseDown){
                    QPoint cp = mapToGlobal(x, y);
                    move(ox + (cp.x - dp.x), oy + (cp.y - dp.y));
                }
            }
        });
        
        sysclose.setOnClickListener(new onClickListener(){
            void onClick(QObject o, bool b)override{
                result = QMessageBox.Cancel;
                close();
            }
        });
        QGraphicsDropShadowEffect shadow = new QGraphicsDropShadowEffect(this);
                shadow.setOffset(0, 0);
                shadow.setColor(0xff444444);
                shadow.setBlurRadius(30);
                setGraphicsEffect(shadow);
                setContentsMargins(24, 24, 24, 24);
        setModal(true);
    }
    
    public void configure(String szTitle, 
            String szContent, 
            String szYesButton, 
            onClickListener btnYes, 
            String szNoButton, 
            onClickListener btnNo)
    {
        if (szYesButton != nilptr){
            btnOk.setText(szYesButton);
            btnOk.setOnClickListener(new onClickListener(){
                void onClick(QObject o, bool b)override{
                    result = QMessageBox.Yes;
                    btnOk.setEnabled(false);
                    close();
                    if (btnYes != nilptr){
                        btnYes.onClick(o, b);
                    }
                }
            });
        }else{
            btnOk.hide();
        }
        
        if (szNoButton != nilptr){
            btnCancel.setText(szNoButton);
            btnCancel.setOnClickListener(new onClickListener(){
                void onClick(QObject o, bool b)override{
                    btnCancel.setEnabled(false);
                    result = QMessageBox.No;
                    close();
                    if (btnNo != nilptr){
                        btnNo.onClick(o, b);
                    }
                }
            });
        }else{
            btnCancel.hide();
        }
        
        content.setText(szContent);
        systitle.setText(szTitle);
        content.adjustSize();
    }
    
    public static int MessageBoxYesNo(QWidget ctx, 
            String szTitle, 
            String szContent, 
            String szYesButton, 
            onClickListener btnYes, 
            String szNoButton, 
            onClickListener btnNo, 
            int style, 
            bool bCancelable)
    {
		QDialog newDlg = new QDialog();
        if (newDlg.load(UIManager.getUIData(__xPackageResource("ui/messagebox.ui")), ctx) == false){
            return 0;
        }
        
        XTMessageBox msgbox = new XTMessageBox();	
        msgbox.attach(newDlg);
        msgbox.configure(szTitle, szContent, szYesButton, btnYes, szNoButton, btnNo);
        msgbox.exec();
        return msgbox.result;
    }
};