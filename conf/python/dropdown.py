# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'dropdown.ui'
#
# Created by: PyQt5 UI code generator 5.13.0
#
# WARNING! All changes made in this file will be lost!


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_MainWindow(object):
    def setupUi(self, Dropdown, label, nameList):
        Dropdown.setObjectName("Dropdown")
        Dropdown.resize(400, 300)
        self.centralWidget = QtWidgets.QWidget(Dropdown)
        self.centralWidget.setObjectName("centralWidget")
        self.gridLayout = QtWidgets.QGridLayout(self.centralWidget)
        self.gridLayout.setContentsMargins(11, 11, 11, 11)
        self.gridLayout.setSpacing(6)
        self.gridLayout.setObjectName("gridLayout")
        self.frame_3 = QtWidgets.QFrame(self.centralWidget)
        self.frame_3.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_3.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_3.setObjectName("frame_3")
        self.gridLayout_10 = QtWidgets.QGridLayout(self.frame_3)
        self.gridLayout_10.setContentsMargins(11, 11, 11, 11)
        self.gridLayout_10.setSpacing(6)
        self.gridLayout_10.setObjectName("gridLayout_10")
        self.frame_8 = QtWidgets.QFrame(self.frame_3)
        self.frame_8.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_8.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_8.setObjectName("frame_8")
        self.horizontalLayout_5 = QtWidgets.QHBoxLayout(self.frame_8)
        self.horizontalLayout_5.setContentsMargins(11, 11, 11, 11)
        self.horizontalLayout_5.setSpacing(6)
        self.horizontalLayout_5.setObjectName("horizontalLayout_5")
        spacerItem = QtWidgets.QSpacerItem(40, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        self.horizontalLayout_5.addItem(spacerItem)
        self.cancel = QtWidgets.QPushButton(self.frame_8)
        self.cancel.setObjectName("cancel")
        self.horizontalLayout_5.addWidget(self.cancel)
        self.ok = QtWidgets.QPushButton(self.frame_8)
        self.ok.setObjectName("ok")
        self.horizontalLayout_5.addWidget(self.ok)
        self.gridLayout_10.addWidget(self.frame_8, 2, 0, 1, 1)
        self.frame_4 = QtWidgets.QFrame(self.frame_3)
        self.frame_4.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_4.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_4.setObjectName("frame_4")
        self.gridLayout_5 = QtWidgets.QGridLayout(self.frame_4)
        self.gridLayout_5.setContentsMargins(11, 11, 11, 11)
        self.gridLayout_5.setSpacing(6)
        self.gridLayout_5.setObjectName("gridLayout_5")
        self.horizontalLayout_3 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_3.setSpacing(6)
        self.horizontalLayout_3.setObjectName("horizontalLayout_3")
        self.label = QtWidgets.QLabel(self.frame_4)
        self.label.setObjectName("label")
        self.horizontalLayout_3.addWidget(self.label)
        spacerItem1 = QtWidgets.QSpacerItem(208, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        self.horizontalLayout_3.addItem(spacerItem1)
        self.gridLayout_5.addLayout(self.horizontalLayout_3, 0, 0, 1, 1)
        self.gridLayout_10.addWidget(self.frame_4, 0, 0, 1, 1)
        self.scrollArea = QtWidgets.QScrollArea(self.frame_3)
        self.scrollArea.setWidgetResizable(True)
        self.scrollArea.setObjectName("scrollArea")
        self.scrollAreaWidgetContents = QtWidgets.QWidget()
        self.scrollAreaWidgetContents.setGeometry(QtCore.QRect(0, 0, 320, 228))
        self.scrollAreaWidgetContents.setObjectName("scrollAreaWidgetContents")
        self.gridLayout_2 = QtWidgets.QGridLayout(self.scrollAreaWidgetContents)
        self.gridLayout_2.setContentsMargins(11, 11, 11, 11)
        self.gridLayout_2.setSpacing(6)
        self.gridLayout_2.setObjectName("gridLayout_2")
        spacerItem2 = QtWidgets.QSpacerItem(20, 8, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        #top
        self.gridLayout_2.addItem(spacerItem2, 0, 1, 1, 1)
        spacerItem5 = QtWidgets.QSpacerItem(52, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        #right
        self.gridLayout_2.addItem(spacerItem5, 5, 3, 2, 1)
        spacerItem6 = QtWidgets.QSpacerItem(52, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        #left
        self.gridLayout_2.addItem(spacerItem6, 6, 0, 2, 1)
        spacerItem11 = QtWidgets.QSpacerItem(20, 6, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        #bottom
        self.gridLayout_2.addItem(spacerItem11, 12, 1, 1, 1)
        self.buttonList = []
        for temp in range(len(nameList)):
            self.radioButtonTemp = QtWidgets.QRadioButton(self.scrollAreaWidgetContents)
            self.radioButtonTemp.setObjectName("radioButton")
            self.gridLayout_2.addWidget(self.radioButtonTemp, 2*temp+1, 1, 1, 1)
            self.buttonList.append(self.radioButtonTemp)
            spacerItemTemp = QtWidgets.QSpacerItem(20, 2, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
            self.gridLayout_2.addItem(spacerItemTemp, 2*(temp+1), 1, 1, 1)
        self.scrollArea.setWidget(self.scrollAreaWidgetContents)
        self.gridLayout_10.addWidget(self.scrollArea, 1, 0, 1, 1)
        self.gridLayout.addWidget(self.frame_3, 0, 0, 1, 1)
        Dropdown.setCentralWidget(self.centralWidget)
        self.menuBar = QtWidgets.QMenuBar(Dropdown)
        self.menuBar.setGeometry(QtCore.QRect(0, 0, 372, 22))
        self.menuBar.setObjectName("menuBar")
        Dropdown.setMenuBar(self.menuBar)
        self.mainToolBar = QtWidgets.QToolBar(Dropdown)
        self.mainToolBar.setObjectName("mainToolBar")
        Dropdown.addToolBar(QtCore.Qt.TopToolBarArea, self.mainToolBar)
        self.statusBar = QtWidgets.QStatusBar(Dropdown)
        self.statusBar.setObjectName("statusBar")
        Dropdown.setStatusBar(self.statusBar)

        self.retranslateUi(Dropdown, label, nameList)
        QtCore.QMetaObject.connectSlotsByName(Dropdown)

    def retranslateUi(self, Dropdown,label, nameList):
        _translate = QtCore.QCoreApplication.translate
        Dropdown.setWindowTitle(_translate("Dropdown", "Dropdown"))
        self.cancel.setText(_translate("Dropdown", "Cancel"))
        self.ok.setText(_translate("Dropdown", "OK"))
        self.label.setText(_translate("Dropdown", label))
        self.buttonList[0].setChecked(True)
        for temp in range(len(self.buttonList)):
            self.buttonList[temp].setText(_translate("Dropdown", nameList[temp]))

    def get_cancel(self):
        return self.cancel

    def get_next(self):
        return self.ok

    def get_buttons(self):
        return self.buttonList
