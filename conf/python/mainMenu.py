# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'mainwindow.ui'
#
# Created by: PyQt5 UI code generator 5.13.0
#
# WARNING! All changes made in this file will be lost!


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_MainWindow(object):
    def setupUi(self, MainWindow, awsConfig, gkeConfig, clusterSetup):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(400, 300)
        self.centralWidget = QtWidgets.QWidget(MainWindow)
        self.centralWidget.setObjectName("centralWidget")
        self.gridLayout_2 = QtWidgets.QGridLayout(self.centralWidget)
        self.gridLayout_2.setContentsMargins(11, 11, 11, 11)
        self.gridLayout_2.setSpacing(6)
        self.gridLayout_2.setObjectName("gridLayout_2")
        self.frame = QtWidgets.QFrame(self.centralWidget)
        self.frame.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame.setObjectName("frame")
        self.gridLayout_3 = QtWidgets.QGridLayout(self.frame)
        self.gridLayout_3.setContentsMargins(11, 11, 11, 11)
        self.gridLayout_3.setSpacing(6)
        self.gridLayout_3.setObjectName("gridLayout_3")
        spacerItem = QtWidgets.QSpacerItem(105, 17, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        self.gridLayout_3.addItem(spacerItem, 0, 0, 1, 1)
        self.gridLayout = QtWidgets.QGridLayout()
        self.gridLayout.setSpacing(6)
        self.gridLayout.setObjectName("gridLayout")
        spacerItem1 = QtWidgets.QSpacerItem(127, 13, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.gridLayout.addItem(spacerItem1, 0, 0, 1, 1)
        self.configAWS = QtWidgets.QPushButton(self.frame)
        self.configAWS.setObjectName("configAWS")
        self.gridLayout.addWidget(self.configAWS, 1, 0, 1, 1)
        spacerItem2 = QtWidgets.QSpacerItem(127, 13, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.gridLayout.addItem(spacerItem2, 2, 0, 1, 1)
        self.configGKE = QtWidgets.QPushButton(self.frame)
        self.configGKE.setObjectName("configGKE")
        self.gridLayout.addWidget(self.configGKE, 3, 0, 1, 1)
        spacerItem3 = QtWidgets.QSpacerItem(127, 13, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.gridLayout.addItem(spacerItem3, 4, 0, 1, 1)
        self.affectCluster = QtWidgets.QPushButton(self.frame)
        self.affectCluster.setObjectName("affectCluster")
        self.gridLayout.addWidget(self.affectCluster, 5, 0, 1, 1)
        spacerItem4 = QtWidgets.QSpacerItem(127, 13, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.gridLayout.addItem(spacerItem4, 6, 0, 1, 1)
        if clusterSetup:
            self.viewClusterAddress = QtWidgets.QPushButton(self.frame)
            self.viewClusterAddress.setObjectName("viewClusterAddress")
            self.gridLayout.addWidget(self.viewClusterAddress, 7, 0, 1, 1)
            spacerItem5 = QtWidgets.QSpacerItem(127, 13, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
            self.gridLayout.addItem(spacerItem5, 8, 0, 1, 1)
            self.benchmarkImageProcessing = QtWidgets.QPushButton(self.frame)
            self.benchmarkImageProcessing.setObjectName("benchmarkImageProcessing")
            self.gridLayout.addWidget(self.benchmarkImageProcessing, 9, 0, 1, 1)
            spacerItem6 = QtWidgets.QSpacerItem(127, 13, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
            self.gridLayout.addItem(spacerItem6, 10, 0, 1, 1)
        self.shell = QtWidgets.QPushButton(self.frame)
        self.shell.setObjectName("shell")
        self.gridLayout.addWidget(self.shell, 11, 0, 1, 1)
        spacerItem7 = QtWidgets.QSpacerItem(127, 13, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.gridLayout.addItem(spacerItem7, 12, 0, 1, 1)
        self.exit = QtWidgets.QPushButton(self.frame)
        self.exit.setObjectName("exit")
        self.gridLayout.addWidget(self.exit, 13, 0, 1, 1)
        spacerItem8 = QtWidgets.QSpacerItem(127, 13, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.gridLayout.addItem(spacerItem8, 14, 0, 1, 1)
        self.gridLayout_3.addLayout(self.gridLayout, 0, 1, 2, 1)
        spacerItem9 = QtWidgets.QSpacerItem(105, 17, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        self.gridLayout_3.addItem(spacerItem9, 1, 2, 1, 1)
        self.gridLayout_2.addWidget(self.frame, 0, 1, 1, 1)
        MainWindow.setCentralWidget(self.centralWidget)
        self.menuBar = QtWidgets.QMenuBar(MainWindow)
        self.menuBar.setGeometry(QtCore.QRect(0, 0, 425, 22))
        self.menuBar.setObjectName("menuBar")
        MainWindow.setMenuBar(self.menuBar)
        self.mainToolBar = QtWidgets.QToolBar(MainWindow)
        self.mainToolBar.setObjectName("mainToolBar")
        MainWindow.addToolBar(QtCore.Qt.TopToolBarArea, self.mainToolBar)
        self.statusBar = QtWidgets.QStatusBar(MainWindow)
        self.statusBar.setObjectName("statusBar")
        MainWindow.setStatusBar(self.statusBar)

        self.retranslateUi(MainWindow, awsConfig, gkeConfig, clusterSetup)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow, awsConfig, gkeConfig, clusterSetup):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        if awsConfig:
            self.configAWS.setText(_translate("MainWindow", "Config AWS (active)"))
        else:
            self.configAWS.setText(_translate("MainWindow", "Config AWS"))
        if gkeConfig:
            self.configGKE.setText(_translate("MainWindow", "Config GKE (active)"))
        else:
            self.configGKE.setText(_translate("MainWindow", "Config GKE"))
        if clusterSetup:
            self.affectCluster.setText(_translate("MainWindow", "Destroy Cluster"))
            self.viewClusterAddress.setText(_translate("MainWindow", "View"))
            self.benchmarkImageProcessing.setText(_translate("MainWindow", "Benchmark"))
        else:
            self.affectCluster.setText(_translate("MainWindow", "Create Cluster"))
        self.shell.setText(_translate("MainWindow", "Drop to Shell"))
        self.exit.setText(_translate("MainWindow", "Exit"))

    def get_aws(self, MainWindow):
        return self.configAWS

    def get_gke(self, MainWindow):
        return self.configGKE

    def get_cluster(self, MainWindow):
        return self.affectCluster

    def get_view(self, MainWindow):
        return self.viewClusterAddress

    def get_benchmarking(self, MainWindow):
        return self.benchmarkImageProcessing

    def get_shell(self, MainWindow):
        return self.shell

    def get_exit(self, MainWindow):
        return self.exit