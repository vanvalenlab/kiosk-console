# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'mainwindow.ui'
#
# Created by: PyQt5 UI code generator 5.13.0
#
# WARNING! All changes made in this file will be lost!


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_MainWindow(object):
    def setupUi(self, MainWindow, text, type):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(400, 300)
        self.centralWidget = QtWidgets.QWidget(MainWindow)
        self.centralWidget.setObjectName("centralWidget")
        self.gridLayout = QtWidgets.QGridLayout(self.centralWidget)
        self.gridLayout.setContentsMargins(11, 11, 11, 11)
        self.gridLayout.setSpacing(6)
        self.gridLayout.setObjectName("gridLayout")
        spacerItem = QtWidgets.QSpacerItem(38, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        self.back_button = QtWidgets.QPushButton(self.centralWidget)
        self.back_button.setObjectName("back_button")
        self.gridLayout.addWidget(self.back_button, 1, 1, 1, 1)
        self.gridLayout.addItem(spacerItem, 1, 0, 1, 1)
        spacerItem1 = QtWidgets.QSpacerItem(37, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        spacerItem2 = QtWidgets.QSpacerItem(38, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        if type == "configured":
            self.gridLayout.addItem(spacerItem2, 1, 4, 1, 1)
        elif type == "resetting":
            self.gridLayout.addItem(spacerItem1, 1, 2, 1, 1)
            self.gridLayout.addItem(spacerItem2, 1, 4, 1, 1)
            self.continue_button = QtWidgets.QPushButton(self.centralWidget)
            self.continue_button.setObjectName("continue_button")
            self.gridLayout.addWidget(self.continue_button, 1, 3, 1, 1)
        elif type == "text":
            self.continue_button = QtWidgets.QPushButton(self.centralWidget)
            self.continue_button.setObjectName("continue_button")
            self.gridLayout.addWidget(self.continue_button, 1, 3, 1, 1)
        self.text_message = QtWidgets.QTextBrowser(self.centralWidget)
        self.text_message.setObjectName("text_message")
        self.gridLayout.addWidget(self.text_message, 0, 0, 1, 5)
        MainWindow.setCentralWidget(self.centralWidget)
        self.menuBar = QtWidgets.QMenuBar(MainWindow)
        self.menuBar.setGeometry(QtCore.QRect(0, 0, 400, 22))
        self.menuBar.setObjectName("menuBar")
        MainWindow.setMenuBar(self.menuBar)
        self.mainToolBar = QtWidgets.QToolBar(MainWindow)
        self.mainToolBar.setObjectName("mainToolBar")
        MainWindow.addToolBar(QtCore.Qt.TopToolBarArea, self.mainToolBar)
        self.statusBar = QtWidgets.QStatusBar(MainWindow)
        self.statusBar.setObjectName("statusBar")
        MainWindow.setStatusBar(self.statusBar)

        self.retranslateUi(MainWindow, text, type)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow, text, type):
        _translate = QtCore.QCoreApplication.translate
        word_list = self.parse(text)
        text = ""
        for temp in word_list:
            text += f"<p style=\" margin-top:10px; margin-bottom:0px; margin-left:10px; margin-right:10px; -qt-block-indent:0; text-indent:0px;\">{temp}</p></body></html>"
            text += "<p style=\"-qt-paragraph-type:empty; margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><br /></p>\n"
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        if type == "resetting":
            self.back_button.setText(_translate("MainWindow", "Back to Menu"))
            self.continue_button.setText(_translate("MainWindow", "Continue"))
        elif type == "configured":
            self.back_button.setText(_translate("MainWindow", "Back to Menu"))
        elif type == "text":
            self.back_button.setText(_translate("MainWindow", "Cancel"))
            self.continue_button.setText(_translate("MainWindow", "OK"))
        self.text_message.setHtml(_translate("MainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n"
"<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:\'.SF NS Text\'; font-size:13pt; font-weight:400; font-style:normal;\">\n"
f"{text}"))

    def parse(self, text):
        word_list = []
        while not text.find("\n") == -1:
            new_line = text.find("\n")
            section = text[:new_line]
            text = text[new_line+1:]
            word_list.append(section)
        word_list.append(text)
        return word_list

    def get_cancel(self):
        return self.back_button

    def get_next(self):
        return self.continue_button
