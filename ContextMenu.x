//xlang Source, Name:ContextMenu.x 
//Date: Fri Jun 19:37:22 2025 

class ActionIdent {
    public String name;
    public String id;
    public bool enabled;
    public QAction _action;
    public int aid;
    public onEventListener _el;

    public ActionIdent (String _n, String _i, onEventListener el) {
        name = _n;
        id = _i;
        enabled = true;
        _el = el;
    }

    public void setEnabled (bool be) {
        if (enabled != be) {
            enabled = be;
            QAction qa = _action;

            if (qa != nilptr) {
                qa.setEnable (be);
            }
        }
    }

    public void setAction (QAction qa) {
        _action = qa;
    }

};

class ContextMenu {
    QMenu contextMenu = new QMenu();

    public QAction [] actions;

    public void popup (int x, int y) {
        contextMenu.exec (x, y);
    }

    public QMenu getMenu() {
        return contextMenu;
    }

    public void create (@NotNilptr QWidget parent, String [] acts, @NotNilptr  onEventListener listener, ActionIdent[] ais, int policy) {
        bool bc = ( (parent == nilptr) ? contextMenu.create() : contextMenu.create (parent) );

        if (bc) {
            int actlen = 0;
            int baselen = 0;

            if (acts != nilptr) {
                actlen = baselen = acts.length;
            }

            if (ais != nilptr) {
                actlen += ais.length;
            }

            actions = new QAction[actlen];
            List<QMenu> _prtlist = new List<QMenu>();
            QMenu _parent = contextMenu;

            if (policy == 0 && parent != nilptr) {
                parent.setContextMenuPolicy (Constant.ActionsContextMenu);
            }

            if (acts != nilptr) {
                for (int i : acts.length) {
                    if (acts[i].startsWith (">>") ) {
                        QMenu qm = new QMenu();

                        if (qm.create (_parent) ) {
                            QAction action = _parent.addMenu (qm);

                            if (action != nilptr) {
                                if (_prtlist.size() == 0) {
                                    parent.addAction (action);
                                } else {
                                    _parent.addAction (action);
                                }
                            }

                            actions[i] = action;
                            _prtlist.add (_parent);
                            _parent = qm;
                            qm.setTitle (acts[i].substring (2, acts[i].length() ) );
                        }
                    } else if (acts[i].equals ("<<") ) {
                        _parent = _prtlist.pollLast();
                        continue;
                    } else {
                        QAction action = new QAction();

                        if (action.create (_parent) ) {
                            if (acts[i].equals ("-") ) {
                                action.setSeparator (true);
                            } else {
                                action.setEnable (false);
                                action.setText (acts[i]);
                                action.setOnEventListener (listener);
                            }

                            actions[i] = action;

                            if (_prtlist.size() == 0) {
                                parent.addAction (action);
                            } else {
                                _parent.addAction (action);
                            }
                        }
                    }
                }
            }

            if (ais != nilptr) {
                for (int i : ais.length) {
                    QAction action = new QAction();

                    if (action.create (contextMenu) ) {

                        if (ais[i].name.equals ("-") ) {
                            action.setSeparator (true);
                        } else {
                            action.setEnable (ais[i].enabled);
                            action.setText (ais[i].name);
                            action.setOnEventListener (ais[i]._el);
                        }

                        ais[i].setAction (action);
                        actions[i + baselen] = action;
                        parent.addAction (action);
                    }
                }
            }
        }
    }

    public void delete() {
        contextMenu.delete();
    }

    public void createPopup (@NotNilptr QWidget parent, String [] acts, @NotNilptr  onEventListener listener) {
        bool bc = ( (parent == nilptr) ? contextMenu.create() : contextMenu.create (parent) );

        if (bc) {
            int actlen = 0;
            int baselen = 0;

            if (acts != nilptr) {
                actlen = baselen = acts.length;
            }

            actions = new QAction[actlen];
            List<QMenu> _prtlist = new List<QMenu>();
            QMenu _parent = contextMenu;

            if (acts != nilptr) {
                for (int i : acts.length) {
                    if (acts[i].startsWith (">>") ) {
                        QMenu qm = new QMenu();

                        if (qm.create (_parent) ) {
                            QAction action = _parent.addMenu (qm);
                            _parent.addAction (action);
                            actions[i] = action;
                            _prtlist.add (_parent);
                            qm.setTitle (acts[i].substring (2, acts[i].length() ) );
                            _parent = qm;
                        }
                    } else if (acts[i].equals ("<<") ) {
                        _parent = _prtlist.pollLast();
                        continue;
                    } else {
                        QAction action = new QAction();

                        if (action.create (_parent) ) {
                            if (acts[i].equals ("-") ) {
                                action.setSeparator (true);
                            } else {
                                action.setEnable (false);
                                action.setText (acts[i]);
                                action.setOnEventListener (listener);
                            }

                            actions[i] = action;
                            _parent.addAction (action);
                        }
                    }
                }
            }
        }
    }

    public void enableAction (@NotNilptr int []indexs, bool b) {
        for (int i : indexs.length) {
            if (indexs[i] >= 0 && indexs[i] < actions.length) {
                QAction qs = actions[indexs[i]];

                if (qs != nilptr) {
                    qs.setEnable (b);
                }
            }
        }
    }

    public void setEnable (int n, bool be) {
        if (n >= 0 && n < actions.length) {
            if (actions[n] != nilptr) {
                actions[n].setEnable (be);
            }
        }
    }

    public void enableAll (bool be) {
        int id = 0;

        for (; id < actions.length; id++) {
            if (actions[id] != nilptr) {
                actions[id].setEnable (be);
            }
        }
    }
};