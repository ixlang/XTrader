//xlang Source, Name:TextDetail.x 
//Date: Sun Jul 07:40:36 2025 


class TextDetail : QDialog {

	String title = "详细信息";
	String text;
    QScintilla _sci;
    static QRect rect = nilptr;
    QHBoxLayout outputlayout = new QHBoxLayout();
    public interface closeListener{
		void onCreate();
		void onClose(String text, bool updated);
    };
    
    closeListener cl_lis ;
    
	public TextDetail(closeListener l){
		cl_lis = l;
    }
    
	public TextDetail(){
    
    }

    public bool onClose()override{
        rect = new QRect(x(), y(), width(), height());
		if (cl_lis != nilptr){
			String update_txt = _sci.getText();
			cl_lis.onClose(update_txt, text.equals(update_txt) == false);
        }
        return true;
    }
    
   public bool create(String caption,@NotNilptr String str, QWidget parent, bool modal){
		title = caption;
		text = str;
        if (parent == nilptr){
            parent = Dialog.getInstance();
        }
		if (super.create(Dialog.getInstance())){
            outputlayout = new QHBoxLayout();
            outputlayout.create(this);
            
            setLayout(outputlayout);
			_sci = new QScintilla();
			if (_sci.create(this)){
                outputlayout.addWidget(_sci);
                _sci.sendEditor(QScintilla.SCI_SETEOLMODE, QScintilla.SC_EOL_LF, 0);
                setWindowFlags(WindowFlags() | (int)(WindowType.CustomizeWindowHint | WindowType.WindowCloseButtonHint  | WindowType.Dialog  | WindowType.WindowTitleHint));
				setWindowTitle(title);
				_sci.setText(str);
                

				if (modal){
                    setModal(true);
                }
				resize(400, 300);
				
                
                if (cl_lis == nilptr){
					_sci.setReadOnly(true);
                }else{
					cl_lis.onCreate();
                }
                
                if (rect != nilptr){
                    move(rect.left,rect.top);
                    resize(rect.right,rect.bottom);
                }
                
                createContextMenu();
                
                _contextMenu.enableAll(true);
                
                show();
                
                setOnActivateListener(new onActivateListener(){
					void onWindowActivate(@NotNilptr QObject obj)override{
						((QWidget)obj).setOpacity(1.0);
					}
					void onWindowDeactivate(QObject obj)override{
						((QWidget)obj).setOpacity(0.6);
					}
				});
				return true;
            }
        }
        return false;
    }
    
    
    
    
    ContextMenu _contextMenu = new ContextMenu();
    
    public void createContextMenu(){
        static String _default_folder = "", _default_openpath = "", _default_savepath = "";
		onEventListener menuListener = new onEventListener(){
           String toRelativePath(String ref, String path, bool cov){
            bool breslash = false;
               if ((_system_.getPlatformId() == _system_.PLATFORM_WINDOWS)){
                   breslash = true;
               }
               path = String.formatPath(path, breslash);
               if (cov == false || ref == nilptr){
                   return path;
               }
               return String.formatPath(path.toRelativePath(ref,false,true), breslash);
               
           }
		   void onTrigger(QObject obj) override{
				if (obj == _contextMenu.actions[0]){
                    String path = QFileDialog.getFolderPath("浏览文件夹","",_default_folder, TextDetail.this);
                    if (path != nilptr && path.length() > 0){
                        _default_folder = path;
                        _sci.insertText(_sci.currentPosition(), path);
                    }
                }else
                if (obj == _contextMenu.actions[2]){
                    String [] path = QFileDialog.getOpenFileNames("浏览文件", _default_openpath, "*",TextDetail.this);
                    if (path != nilptr){                        
                        for (int i =0; i < path.length; i++){
                            if (i == 0){
                                _default_openpath = path[i].findVolumePath();
                            }
                            _sci.insertText(_sci.currentPosition(),path[i] + "\n");
                        }
                    }
                }else
                if (obj == _contextMenu.actions[3]){
                    String path = QFileDialog.getSaveFileName("选择保存位置",_default_savepath,"*",TextDetail.this);
                    if (path != nilptr && path.length() > 0){                        
                        _default_savepath = path;
                        _sci.insertText(_sci.currentPosition(),path);
                    }
                }else
                if (obj == _contextMenu.actions[5]){
                    _sci.Copy();
                }else
                if (obj == _contextMenu.actions[6]){
                    _sci.Paste();
                }else
                if (obj == _contextMenu.actions[8]){
                    TextDetail.this.close();
                }
		   }
		};
        
		
		
		String []acts = {"浏览文件夹", "-", "浏览文件", "选择保存位置",  "-", "复制", "粘贴", "-", "关闭"};
		_contextMenu.create(_sci, acts, menuListener, nilptr, 0);
	}
};