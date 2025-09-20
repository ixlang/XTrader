//xlang Source, Name:uicomponents/AlertDialog.x
//Date: Sat Sep 02:37:14 2022


interface OnClickListener {
    void onClick(@NotNilptr AlertDialog dialog, int witch);
};

interface OnCloseListener {
    void onClose(@NotNilptr AlertDialog dialog);
};

class AlertDialog : QDialog {
    Builder _build;
    QPushButton btnpos, btnneg, btnneu;
    QWidget content;
    FMMStyleManager fmmbar =  new FMMStyleManager();
    Orientation nOrientation = Orientation.Horizontal;
    public AlertDialog(Builder b) {
        _build = b;
    }

    public void dismiss() {
        close();
    }

    public bool onClose()override {
        if (_build._closeListener != nilptr) {
            _build._closeListener.onClose(this);
        }

        return super.onClose();
    }

    public void setOrientation(Orientation no) {
        nOrientation = no;
    }

    public bool create(QWidget parent) override{
        QBuffer qb = new QBuffer();
        byte [] buffer = __xPackageResource("ui/alertDialog.ui");
        qb.setBuffer(buffer, 0, buffer.length);

        if (load(qb, parent)) {
            btnpos = attachByName("btnpos");
            btnneg = attachByName("btnneg");
            btnneu = attachByName("btnneu");

            setWindowTitle(_build.title);
            fmmbar.configure(this, FMMStyleManager.Theme.Auto);

            content = attachByName("content");

            if (_build._positiveButton != nilptr) {
                btnpos.setText(_build._positiveButton);
                btnpos.setOnClickListener(new onClickListener() {
                    void onClick(QObject, bool checked)override {
                        if (_build._positiveListener != nilptr) {
                            _build._positiveListener.onClick(AlertDialog.this, _build.selectedIndex);
                        } else {
                            close();
                        }
                    }
                });
            } else {
                btnpos.hide();
            }

            if (_build._negativeButton != nilptr) {
                btnneg.setText(_build._negativeButton);
                btnneg.setOnClickListener(new onClickListener() {
                    void onClick(QObject, bool checked)override {
                        if (_build._negativeListener != nilptr) {
                            _build._negativeListener.onClick(AlertDialog.this, _build.selectedIndex);
                        } else {
                            close();
                        }
                    }
                });
            } else {
                btnneg.hide();
            }

            if (_build._neutralButton != nilptr) {
                btnneu.setText(_build._neutralButton);
                btnneu.setOnClickListener(new onClickListener() {
                    void onClick(QObject, bool checked)override {
                        if (_build._neutralListener != nilptr) {
                            _build._neutralListener.onClick(AlertDialog.this, _build.selectedIndex);
                        } else {
                            close();
                        }
                    }
                });
            } else {
                btnneu.hide();
            }

            QBoxLayout qhb;

            if (nOrientation == Orientation.Horizontal) {
                qhb = new QHBoxLayout();
                ((QHBoxLayout)qhb).create(content);
            } else {
                qhb = new QVBoxLayout();
                ((QVBoxLayout)qhb).create(content);
            }

            //content.setLayout(qhb);
            qhb.addWidget(_build.view, 1);

            for (QWidget v : _build.viewlist) {
                qhb.addWidget(v, 0);
            }

            content.adjustSize();

            return true;
        }

        return false;
    }


    public static class Builder {
        QWidget _parent;
        public String title;
        public QWidget view;
        public String _positiveButton;
        public OnClickListener _positiveListener;
        public String _negativeButton;
        public OnClickListener _negativeListener;
        public String _neutralButton;
        public OnClickListener _neutralListener;
        public int selectedIndex = 0;
        public OnCloseListener _closeListener;
        AlertDialog ad;
        Orientation nOrientation = Orientation.Horizontal;
        public Vector<QWidget> viewlist = new Vector<QWidget>();

        public AlertDialog getDialog() {
            return ad;
        }

        public Builder(QWidget parent) {
            _parent = parent;
        }

        public Builder setTitle(String _title) {
            title = _title;
            return this;
        }
        public Builder setNegativeButton(String txt, OnClickListener l) {
            _negativeButton = txt;
            _negativeListener = l;
            return this;
        }
        public Builder setPositiveButton(String txt, OnClickListener l) {
            _positiveButton = txt;
            _positiveListener = l;
            return this;
        }
        public Builder setNeutralButton(String txt, OnClickListener l) {
            _neutralButton = txt;
            _neutralListener = l;
            return this;
        }

        public Builder setOrientation(Orientation no) {
            nOrientation = no;
            return this;
        }

        public Builder setView(QWidget v) {
            view = v;
            return this;
        }

        public Builder setOnCloseListener(OnCloseListener l) {
            _closeListener = l;
            return this;
        }

        public Builder addView(QWidget v) {
            viewlist.add(v);
            return this;
        }

        public bool [] getCheckedItemPositions() {
            bool []bs = new bool[0];

            if (view.instanceOf(QTreeWidget)) {
                QTreeWidget qtr = (QTreeWidget)(view);
                long [] items = qtr.getTopItems();

                bs = new bool[items.length];

                for (int i : items.length) {
                    long item = items[i];

                    if (item != 0) {
                        bs[i] = qtr.isItemCheck(item, 0);
                    } else {
                        bs[i] = false;
                    }
                }
            }

            return bs;
        }


        public Builder setMultiChoiceItems(String [] icons, String [] items, bool [] bs, OnClickListener l) {
            QTreeWidget qtr = new QTreeWidget();
            qtr.create(_parent);
            qtr.setColumns(new String[] {"订单"});
            view = qtr;

            if (bs != nilptr && items.length != bs.length) {
                return nilptr;
            }

            qtr.setHeaderVisible(false);

            if (icons != nilptr) {
                if (icons.length != items.length) {
                    return nilptr;
                }

                for (int i : items.length) {
                    long item = qtr.addItem(icons[i], items[i]);
                    qtr.modifyItemFlags(item, qtr.getItemFlags(item) | QTreeWidget.ItemIsUserCheckable, 0);

                    if (bs != nilptr) {
                        qtr.setItemCheck(item, 0, bs[i]);
                    } else {
                        qtr.setItemCheck(item, 0, false);
                    }
                }
            } else {
                for (int i : items.length) {
                    long item = qtr.addItem(nilptr, items[i]);
                    qtr.modifyItemFlags(item, qtr.getItemFlags(item) | QTreeWidget.ItemIsUserCheckable, 0);

                    if (bs != nilptr) {
                        qtr.setItemCheck(item, 0, bs[i]);
                    } else {
                        qtr.setItemCheck(item, 0, false);
                    }
                }
            }

            qtr.setIndentation(0);
            qtr.setOnTreeViewItemEvent(new onTreeViewItemEvent() {
                void onItemClicked(QTreeWidget tree, long item, int column)override {
                    selectedIndex = tree.indexOfItem(item);

                    if (l != nilptr) {
                        l.onClick(ad, selectedIndex);
                    }
                }
            });

            return this;
        }
        public Builder setItems(String [] icons, String [] items, OnClickListener l) {
            QTreeWidget qtr = new QTreeWidget();
            qtr.create(_parent);
            view = qtr;

            qtr.setHeaderVisible(false);

            if (icons != nilptr) {
                if (icons.length != items.length) {
                    return nilptr;
                }

                for (int i : items.length) {
                    qtr.addItem(icons[i], items[i]);
                }
            } else {
                for (int i : items.length) {
                    qtr.addItem(nilptr, items[i]);
                }
            }

            qtr.setIndentation(0);
            qtr.setOnTreeViewItemEvent(new onTreeViewItemEvent() {
                void onItemClicked(QTreeWidget tree, long item, int column)override {
                    selectedIndex = tree.indexOfItem(item);

                    if (l != nilptr) {
                        l.onClick(ad, selectedIndex);
                    }
                }
            });

            return this;
        }
        public static class ListItem {
            public String icon;
            public String text;
            public bool isBold;
            public int color;
            public int bkcolor;

            public void setContent(String _icon, String _text) {
                icon = _icon;
                text = _text;
            }

            public void setBold(bool b) {
                isBold = b;
            }

            public void setColor(int _color, int _bkColor) {
                color = _color;
                bkcolor = _bkColor;
            }
        };

        public Builder setItems(ListItem [] items, OnClickListener l) {
            QTreeWidget qtr = new QTreeWidget();
            qtr.create(_parent);
            view = qtr;

            qtr.setHeaderVisible(false);

            for (int i : items.length) {
                long item = 0;

                if (items[i].icon != nilptr) {
                    item = qtr.addItem(items[i].icon, items[i].text);
                } else {
                    item = qtr.addItem(items[i].icon, items[i].text);
                }

                if (items[i].color != 0) {
                    qtr.setItemColor(item, 0, items[i].color);
                }

                if (items[i].bkcolor != 0) {
                    qtr.setItemBackColor(item, 0, items[i].bkcolor);
                }

                if (items[i].isBold) {
                    qtr.setItemFontBold(item, 0, true);
                }
            }

            qtr.setIndentation(0);
            qtr.setOnTreeViewItemEvent(new onTreeViewItemEvent() {
                void onItemClicked(QTreeWidget tree, long item, int column)override {
                    selectedIndex = tree.indexOfItem(item);

                    if (l != nilptr) {
                        l.onClick(ad, selectedIndex);
                    }
                }
            });

            return this;
        }

        public void close() {
            ad.close();
        }

        public AlertDialog show() {
            ad = new AlertDialog(this);
            ad.setOrientation(nOrientation);
            ad.create(_parent);
            ad.setModal(true);
            ad.show();
            return ad;
        }
    };
    
    public static AlertDialog showInformation (String title, String text, int TextSize, int w, int h, String btn,  OnClickListener closeListener) {
        AlertDialog.Builder normalDialog =
            new AlertDialog.Builder (Dialog.getInstance() );
        QLabel qrimg = new QLabel();
        qrimg.create();

        if (w != 0 && h != 0) {
            qrimg.setFixedSize (w, h);
        }

        if (TextSize != 0) {
            qrimg.setStyleSheetString (".QLabel{font:" + TextSize + "px;}");
        }

        qrimg.setText (text);
        qrimg.setWordWrap(true);
        qrimg.adjustSize();

        if (title == nilptr) {
            title = "信息";
        }

        normalDialog.setTitle (title);
        normalDialog.setView (qrimg);

        if (btn == nilptr) {
            btn = "关闭";
        }

        normalDialog.setPositiveButton (btn, new OnClickListener() {
            public void onClick (AlertDialog dialog, int which) override{
                dialog.dismiss();

                if (closeListener != nilptr) {
                    closeListener.onClick (dialog, which);
                }
            }
        });

        /*qrimg.setSizePolicy(Policy.Preferred, Policy.Preferred);*/
        return normalDialog.show();
    }
};