//xlang Source, Name:FMMStyleManager.x 
//Date: Sun Jul 06:06:00 2025 

class FMMStyleManager {
    public enum Theme {
        Auto = -1,
        Performance = 0,
        Pretty = 1
    };

    QPoint dp;
    int ox, oy;
    bool mouseDown = false;
    QLabel systitle;
    QDialog parentDialog = nilptr;
    QSizeGrip sizegrip = nilptr;
    static byte [] style_light = __xPackageResource("assets/res/qss/style_light.qss");
    static byte [] style_dark = __xPackageResource("assets/res/qss/style_template.qss");
    static byte [] style_full = __xPackageResource("configure/styled_full.txt");
    static byte [] style_mid = __xPackageResource("configure/styled_mid.txt");
    int theme_style = 0;
    static bool useDarkTheme = false;
    
    public static void setUseDarkTheme(bool bd){
        useDarkTheme = bd;
    }
    static String replace_color = nilptr;

    public static void styledDateTimeCtrl(QDateTimeEdit c) {
        c.setStyleSheetString(".QWidget{background-color:#" + getThemeColor() + ";}");
    }

    public static void applyAppearanceColor() {
        XTApplication.getApplication().setStyleSheetString(getThemeString());
        Dialog.UpdateTheme();
    }

    public static String getThemeColor() {
        return replace_color;
    }

    public static String makeThemeString(String text) {
        if (useDarkTheme){
            text = text.replace("34495E", "191919");
        }else{
            text = text.replace("34495E", "333333");
        }
        return text;
    }

    public static String getThemeString() {
        if (Setting.getThemeMode() == Theme.Pretty) {
            return makeThemeString(new String(useDarkTheme ? style_dark : style_light) + "\n" + new String(style_full));
        }
        return makeThemeString(new String(useDarkTheme ? style_dark : style_light) + "\n" + new String(style_mid));
    }

    private void configureComponent(QDialog dialog) {
        //if (theme_style != 0) {
            dialog.setWindowFlags(WindowType.FramelessWindowHint | WindowType.Dialog);

            if (theme_style == Theme.Pretty) {
                dialog.setAttribute(Constant.WA_TranslucentBackground, true);
                dialog.setStyleSheetString(makeThemeString(".QDialog{border: none; background-color: transparent;}"));
            } else {
                dialog.setStyleSheetString(makeThemeString(".QDialog{border: 2px solid #34495E; }"));
                parentDialog.setContentsMargins(2, 2, 2, 2);
            }
        /*} else {
            dialog.setWindowFlags(WindowType.Dialog | WindowType.Drawer);
        }*/
    }

    public void reconfigure() {
        configureComponent(parentDialog);
    }

    public void configure(QDialog dialog, Theme theme) {
        if (theme != Theme.Auto) {
            theme_style = theme;
        } else {
            theme_style = Setting.getThemeMode();
        }

        parentDialog = dialog;
        configureComponent(dialog);

        //if (theme_style != 0) {
            QPushButton sysmin = (QPushButton)dialog.attachByName("sysmin");
            QPushButton sysmax = (QPushButton)dialog.attachByName("sysmax");
            QPushButton sysclose = (QPushButton)dialog.attachByName("sysclose");

            systitle = (QLabel)dialog.attachByName("systitle");

            if (systitle != nilptr) {
                systitle.setText(dialog.getWindowTitle());
                systitle.setOnMouseEventListener(new onMouseEventListener() {
                    public void onMouseButtonPress(QObject obj, int Button, int, int, int flags, int source)override {
                        dp = QApplication.globalCursorPoint();
                        ox = dialog.x();
                        oy = dialog.y();
                        mouseDown = true;
                    }
                    public void onMouseButtonRelease(QObject obj, int Button, int, int, int flags, int source) override{
                        mouseDown = false;
                    }
                    public void onMouseMove(QObject obj, int Button, int, int, int flags, int source) override{
                        if (mouseDown) {
                            QPoint cp = QApplication.globalCursorPoint();
                            dialog.move(ox + (cp.x - dp.x), oy + (cp.y - dp.y));
                        }
                    }
                });
            }

            if (sysclose != nilptr) {
                sysclose.setOnClickListener(new onClickListener() {
                    void onClick(QObject o, bool b)override {
                        dialog.close();
                    }
                });
            }

            if (sysmin != nilptr) {
                sysmin.setOnClickListener(new onClickListener() {
                    void onClick(QObject obj, bool checked)override {
                        dialog.runOnUi(new Runnable() {
                            void run()override {
                                parentDialog.setMinimized(true);
                            }
                        });
                    }
                });
            }

            if (sysmax != nilptr) {
                sysmax.setOnClickListener(new onClickListener() {
                    void onClick(QObject obj, bool checked)override {
                        clickMaximized(sysmax);
                    }
                });
            }

            if (theme_style == Theme.Pretty) {
                QGraphicsDropShadowEffect shadow = new QGraphicsDropShadowEffect(dialog);
                shadow.setOffset(0, 0);
                shadow.setColor(0xff444444);
                shadow.setBlurRadius(30);
                dialog.setGraphicsEffect(shadow);
                dialog.setContentsMargins(24, 24, 24, 24);
            }

            QWidget frmsizeGrip = (QWidget)dialog.attachByName("frmsizeGrip");

            if (frmsizeGrip == nilptr) {
                frmsizeGrip = (QWidget)dialog.attachByName("frmMainsizeGrip");
            }

            if (frmsizeGrip != nilptr) {
                sizegrip = new QSizeGrip();
                sizegrip.create(dialog);
                ((QBoxLayout)frmsizeGrip.getLayout()).addWidget(sizegrip);
            }
        /*} else {
            QWidget titleBar = (QWidget)dialog.attachByName("FMTitleBar");

            if (titleBar != nilptr) {
                titleBar.hide();
            }
        }*/
    }

    public static String getSettingViewStyle() {
        return makeThemeString(".QWidget{background-color: #34495E; border:none; }");
    }

    public static String getLeftStyle() {
        return makeThemeString("#leftfrm{background-color:#34495E;}");
    }

    public void clickMaximized(QPushButton button) {
        if (parentDialog.maximized() == false) {
            if (theme_style == Theme.Pretty) {
                parentDialog.setContentsMargins(0, 0, 0, 0);
            }

            parentDialog.setMaximized(true);
            button.setStyleSheetString(".QPushButton{\n	border-image:url($(assets)/res/sysa.png);\n}");
        } else {
            if (theme_style == Theme.Pretty) {
                parentDialog.setContentsMargins(24, 24, 24, 24);
            }

            parentDialog.setMaximized(false);
            button.setStyleSheetString(".QPushButton{\n	border-image:url($(assets)/res/sysx.png);\n}");
        }
    }

    public void hideSizegrip() {
        if (sizegrip != nilptr) {
            sizegrip.hide();
        }
    }

    public void hideSizegripBar() {
        QWidget frmsizeGrip = (QWidget)parentDialog.findByName("frmsizeGrip");

        if (frmsizeGrip == nilptr) {
            frmsizeGrip = (QWidget)parentDialog.findByName("frmMainsizeGrip");
        }

        if (frmsizeGrip != nilptr) {
            frmsizeGrip.hide();
            QWidget content = (QWidget)parentDialog.findByName("dialogContentWidget");

            if (content == nilptr) {
                content = (QWidget)parentDialog.findByName("ContentWidget");
            }

            if (content != nilptr) {
                content.setStyleSheetString(makeThemeString(
                                                ".QWidget{background:#ffffff;border-left: 2px solid #34495E;border-right: 2px solid #34495E;border-bottom: 2px solid #34495E;}"));
                content.setContentsMargins(1, 0, 1, 1);
            }
        }

    }
    public void setWindowTitle(String text) {
        parentDialog.setWindowTitle(text);
        systitle.setText(text);
    }
};