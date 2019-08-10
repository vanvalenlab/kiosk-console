#!/usr/bin/env python
# -*- coding: utf-8 -*-
import subprocess
import sys
from PyQt5 import QtWidgets
import startScreen
import mainMenu
import inputs
import dropdown
import error
import url
import text
GKE_STATE = 0
AWS_STATE = 0
AWS_CONFIGURED = False
GKE_CONFIGURED = False
GKE_GPU_LIST = []
GKE_REGIONS_LIST = []
#
# SLIGHTLY WEIRD TERMINOLOGY:
#
# label = current slide title
#
# default_input = default text in input box
#
# config_type = AWS or GKE
#

class StartScreenSetup(QtWidgets.QMainWindow, startScreen.Ui_MainWindow):
    """sets up the start screen (intro about van valen lab)"""
    def __init__(self, controller):
        super(StartScreenSetup, self).__init__()
        self.controller = controller
        self.ui = startScreen.Ui_MainWindow()
        self.ui.setupUi(self)
        next_button = self.ui.get_next()
        next_button.clicked.connect(self.controller.make_menu)

class MainMenuSetup(QtWidgets.QMainWindow, mainMenu.Ui_MainWindow):
    """sets up the main menu (the one with the 4 buttons)"""
    def __init__(self, controller):
        super(MainMenuSetup, self).__init__()
        global AWS_CONFIGURED
        global GKE_CONFIGURED
        self.ui = mainMenu.Ui_MainWindow()
        self.ui.setupUi(self, AWS_CONFIGURED, GKE_CONFIGURED)
        self.controller = controller

        aws_button = self.ui.get_aws(self)
        aws_button.clicked.connect(lambda: self.controller.start("AWS"))

        gke_button = self.ui.get_gke(self)
        gke_button.clicked.connect(lambda: self.controller.start("GKE"))

        cluster_button = self.ui.get_cluster(self)
        cluster_button.clicked.connect(lambda: self.controller.start("cluster"))

        exit_button = self.ui.get_exit(self)
        exit_button.clicked.connect(sys.exit)

class InputSetup(QtWidgets.QMainWindow, mainMenu.Ui_MainWindow):
    """sets up the input screens (general with textbox, input, and 2 buttons)"""
    def __init__(self, controller, label, default_input, config_type):
        global AWS_STATE
        global GKE_STATE
        global AWS_CONFIGURED
        global GKE_GPU_LIST
        super(InputSetup, self).__init__()
        self.ui = inputs.Ui_MainWindow()
        self.ui.setupUi(self, label, default_input)
        self.controller = controller
        input_box = self.ui.get_user_input()
        self.controller.setup_inputbox(input_box)
        ok_button = self.ui.get_next()
        if config_type == "AWS":
            if AWS_STATE == 1:
                ok_button.clicked.connect(
                    lambda: self.controller.make_input(
                        "AWS Secret Key:", "Access Key ID:", "invalid_default", "AWS", "input"))
            elif AWS_STATE == 2:
                ok_button.clicked.connect(
                    lambda: self.controller.make_input(
                        "AWS S3 Bucket Name:", "AWS Secret Key:",
                        "invalid_default", "AWS", "input"))
            elif AWS_STATE == 3:
                ok_button.clicked.connect(
                    lambda: self.controller.make_input(
                        "Cluster Name:", "AWS S3 Bucket Name:",
                        "deepcell-aws-cluster", "AWS", "input"))
            elif AWS_STATE == 4:
                ok_button.clicked.connect(
                    lambda: self.controller.make_input(
                        "Master Node Machine Type:", "Cluster Name:",
                        "t2.medium", "AWS", "input"))
            elif AWS_STATE == 5:
                ok_button.clicked.connect(
                    lambda: self.controller.make_input(
                        "Worker Node Machine Type:", "Master Node Machine Type:",
                        "t2.medium", "AWS", "input"))
            elif AWS_STATE == 6:
                gpu_list = read_file("aws_gpu.txt")
                ok_button.clicked.connect(
                    lambda: self.controller.make_dropdown(
                        "GPU Instance Type", "Worker Node Machine Type:",
                        gpu_list, "AWS", "input"))
            elif AWS_STATE == 8:
                ok_button.clicked.connect(
                    lambda: self.controller.make_input(
                        "Maximum number of GPU Instances:", "Minimum number of GPU Instances:",
                        "4", "AWS", "input"))
            elif AWS_STATE == 9:
                ok_button.clicked.connect(
                    lambda: self.controller.make_text(
                        "AWS", "\nAmazon Web Services Configuration Complete!\n"+
                        "Cluster is ready to be created", "configured",
                        "Maximum number of GPU Instances:", "input"))
        elif config_type == "GKE":
            if GKE_STATE == 1:
                ok_button.clicked.connect(lambda: self.controller.make_url(
                    "Enter this into a browser, login, and copy the code", "Existing Project ID:", "GKE", "input"))
            elif GKE_STATE == 3:
                ok_button.clicked.connect(lambda: self.controller.make_input(
                    "Bucket Name:", "Cluster Name:", "invalid_default", "GKE", "input"))
            elif GKE_STATE == 4:
                regions_list = read_file("regions.txt")
                ok_button.clicked.connect(
                    lambda: self.controller.make_dropdown(
                        "Choose a Region:", "Bucket Name:",
                        regions_list, "GKE", "input"))
            elif GKE_STATE == 6:
                region_to_gpu()
                ok_button.clicked.connect(lambda: self.controller.make_input(
                    "Minimum Number of Compute (non-GPU) Nodes:",
                    "Node (non-GPU) Type:", "1", "GKE", "input"))
            elif GKE_STATE == 7:
                ok_button.clicked.connect(lambda: self.controller.make_input(
                    "Maximum Number of Compute (non-GPU) Nodes:",
                    "Minimum Number of Compute (non-GPU) Nodes:",
                    "60", "GKE", "input"))
            elif GKE_STATE == 8:
                ok_button.clicked.connect(
                    lambda: self.controller.make_dropdown(
                        "Choose a GPU for prediction (not training) from"+
                        "\nthe GPU types available in your region:",
                        "Maximum Number of Compute (non-GPU) Nodes:",
                        GKE_GPU_LIST, "GKE", "input"))
            elif GKE_STATE == 11:
                ok_button.clicked.connect(
                    lambda: self.controller.make_input(
                        "Maximum number of GPU Nodes:",
                        "Minimum number of GPU Nodes:",
                        "4", "GKE", "input"))
                gpu_to_regions()
            elif GKE_STATE == 12:
                warning = gpu_warning()
                warning_text = warning[0]
                if warning[1]:
                    ok_button.clicked.connect(
                        lambda: self.controller.make_text(
                            "GKE", warning_text,
                            "text", "Maximum number of GPU Nodes:", "input"))
                else:
                    ok_button.clicked.connect(
                        lambda: self.controller.make_error(warning_text))
        setup_cancel(self)

class DropdownSetup(QtWidgets.QMainWindow, mainMenu.Ui_MainWindow):
    """sets up the dropdown screens (general with a radiobox, textbox, and 2 buttons)"""
    def __init__(self, controller, label, dropdown_list, config_type):
        global AWS_STATE
        global GKE_STATE
        global GKE_GPU_LIST
        super(DropdownSetup, self).__init__()
        self.ui = dropdown.Ui_MainWindow()
        self.ui.setupUi(self, label, dropdown_list)
        self.controller = controller

        button_list = self.ui.get_buttons()
        self.controller.setup_button_list(button_list)
        ok_button = self.ui.get_next()
        if config_type == "AWS":
            if AWS_STATE == 7:
                ok_button.clicked.connect(
                    lambda: self.controller.make_input(
                        "Minimum number of GPU Instances:", "GPU Instance Type:",
                        "0", config_type, "dropdown"))
        elif config_type == "GKE":
            if GKE_STATE == 5:
                ok_button.clicked.connect(
                    lambda: self.controller.make_input(
                        "Node (non-GPU) Type:", "Region:",
                        "n1-standard-4", config_type, "dropdown"))
            elif GKE_STATE == 9:
                ok_button.clicked.connect(
                    lambda: self.controller.make_dropdown(
                        "Choose a GPU for training (not prediction) from"+
                        "\nthe GPU types available in your region:", "GPU prediction:",
                        GKE_GPU_LIST, config_type, "dropdown"))
            elif GKE_STATE == 10:
                ok_button.clicked.connect(lambda: self.controller.make_input(
                    "Minimum number of GPU Nodes:", "GPU Training:",
                    "0", config_type, "dropdown"))
        setup_cancel(self)

class URLSetup(QtWidgets.QMainWindow, mainMenu.Ui_MainWindow):
    """sets up the URL screen (similar format to inputbox with a copyable textbox)"""
    def __init__(self, controller, label, config_type):
        global GKE_STATE
        super(URLSetup, self).__init__()
        self.ui = url.Ui_MainWindow()
        url_temp = give_url()
        self.ui.setupUi(self, label, url_temp)
        self.controller = controller
        input_box = self.ui.get_user_input()
        self.controller.setup_inputbox(input_box)
        ok_button = self.ui.get_next()
        if config_type == "GKE":
            if GKE_STATE == 2:
                ok_button.clicked.connect(lambda: self.controller.make_input(
                    "Cluster Name:", "security code", "deepcell", "GKE", "URL"))
        setup_cancel(self)
class ErrorSetup(QtWidgets.QMainWindow, mainMenu.Ui_MainWindow):
    """sets up an error screen (message is the error message)"""
    def __init__(self, controller, message):

        super(ErrorSetup, self).__init__()
        self.ui = error.Ui_MainWindow()
        self.ui.setupUi(self, message)
        self.controller = controller
        setup_cancel(self)

class TextSetup(QtWidgets.QMainWindow, mainMenu.Ui_MainWindow):
    """sets up a text screen"""
    #
    # SIMILAR TO AN ERROR SCREEN
    #
    # Difference is a text screen has 2 buttons, back to menu and continue
    #
    # Error only has an ok button. Also Text is more modifiable
    #
    def __init__(self, controller, config_type, message, situation, last_label, previous):

        super(TextSetup, self).__init__()
        global GKE_CONFIGURED
        global AWS_CONFIGURED
        global GKE_STATE
        self.ui = text.Ui_MainWindow()
        self.ui.setupUi(self, message, situation)
        self.controller = controller

        setup_cancel(self)
        if situation == "resetting":
            next_button = self.ui.get_next()
            next_button.clicked.connect(lambda: self.controller.reconfiguring(config_type))
        elif situation == "configured":
            if config_type == "AWS":
                AWS_CONFIGURED = True
            elif config_type == "GKE":
                GKE_CONFIGURED = True
            self.controller.check_input(last_label, config_type, previous)
        elif situation == "text":
            increment()
            self.controller.check_input(last_label, config_type, previous)
            if config_type == "GKE":
                next_button = self.ui.get_next()
                next_button.clicked.connect(
                    lambda: self.controller.make_text(
                        "GKE", "\nGoogle Cloud Configuration Complete!\nCluster "+
                        "is ready to be created", "configured", "Warning:", "text"))
        elif config_type == "cluster":
            if situation == "choosing":
                aws_cluster_button = self.ui.get_next()
                gke_cluster_button = self.ui.get_next2()
                aws_cluster_button.clicked.connect(lambda: cluster_aws())
                gke_cluster_button.clicked.connect(lambda: cluster_gke())
class Controller():
    """controls the setting up the different screens"""
    def __init__(self):
        self.window = StartScreenSetup(self)
        self.user_input = None
        self.button_list = None

    def make_start(self):
        """makes the start screen"""
        make_window(self)

    def make_menu(self):
        """makes the main menu"""
        global AWS_STATE
        global GKE_STATE
        AWS_STATE = 0
        GKE_STATE = 0
        self.window.close()
        self.window = MainMenuSetup(self)
        make_window(self)

    def start(self, config_type):
        """works with the menu in order to process the effects for the user's button choice"""
        global AWS_CONFIGURED
        global GKE_CONFIGURED

        if config_type == "AWS":
            if AWS_CONFIGURED:
                self.make_text("AWS", "\nConfiguring amazon again will clear you last "+
                               "configuration.\nAre you sure you want to continue? ", "resetting",
                               "none", "none")
            else:
                self.make_input("Access Key ID: ", "none", "invalid_default", "AWS", "N/A")

        elif config_type == "GKE":
            if GKE_CONFIGURED:
                self.make_text("GKE", "\nConfiguring google again will clear you last "+
                               "configuration.\nAre you sure you want to continue? ", "resetting",
                               "none", "none")
            else:
                self.make_input("Existing Project ID:", "none", "invalid_default", "GKE", "N/A")

        elif config_type == "cluster":
            if not AWS_CONFIGURED and not GKE_CONFIGURED:
                self.make_error("Configure AWS or GKE before setting up a cluster")
            elif AWS_CONFIGURED and GKE_CONFIGURED:
                self.make_text("cluster", "Choose One", "choosing", "none", "none")
            elif AWS_CONFIGURED:
                self.make_text("cluster", "Setting up AWS", "text", "none", "none")
                #cluster_AWS()
            elif GKE_CONFIGURED:
                self.make_text("cluster", "Setting up GKE", "text", "none", "none")
                #cluster_GKE()

    def setup_inputbox(self, inputbox):
        """makes a inputbox accessible from outside that screen"""
        self.user_input = inputbox

    def make_input(self, label, last_label, default_input, config_type, previous):
        """create the window for an input screen"""
        temp = self.check_input(last_label, config_type, previous)
        if temp == 1:
            increment()
            self.window.close()
            self.window = InputSetup(self, label, default_input, config_type)
            make_window(self)
        else:
            self.make_error(temp)

    def check_input(self, last_label, config_type, previous):
        """reads the inputbox and passes it to the file editor"""
        global AWS_STATE
        global GKE_STATE
        temp_text = ""
        if previous == "input":
            temp_text = self.user_input.text()
            if temp_text in ("invalid_default", ""):
                return "invalid input"
            if config_type == "GKE":
                if GKE_STATE == 1:
                    write_into_file('gkeConfig.txt', 'w+', last_label, temp_text)
                else:
                    write_into_file('gkeConfig.txt', 'a+', last_label, temp_text)
            elif config_type == "AWS":
                if AWS_STATE == 1:
                    write_into_file('awsConfig.txt', 'w+', last_label, temp_text)
                else:
                    write_into_file('awsConfig.txt', 'a+', last_label, temp_text)
            return 1

        if previous == "URL":
            temp_url = self.user_input.text()
            returning = 1
            if check_url_code(temp_url):
                returning = 1
            else:
                return "incorrect code"
            if returning:
                if check_proj_id():
                    return returning
                return "\nInvalid Project ID given linked google account. \nCheck your Project ID on console.cloud.google.com"

        if previous == "dropdown":
            for button in self.button_list:
                if button.isChecked():
                    if config_type == "AWS":
                        write_into_file('awsConfig.txt', 'a+', last_label, button.text())
                    if config_type == "GKE":
                        write_into_file('gkeConfig.txt', 'a+', last_label, button.text())
        return 1

    def setup_button_list(self, button_list):
        """makes a button list accessible from outside that screen"""
        self.button_list = button_list

    def make_dropdown(self, label, last_label, dropdown_list, config_type, previous):
        """create the window for an dropdown screen"""
        temp = self.check_input(last_label, config_type, previous)
        if temp == 1:
            increment()
            self.window.close()
            self.window = DropdownSetup(self, label, dropdown_list, config_type)
            make_window(self)
        else:
            self.make_error(temp)

    def make_error(self, message):
        """create the window for an URL screen"""
        self.window.close()
        self.window = ErrorSetup(self, message)
        make_window(self)

    def make_text(self, config_type, message, situation, last_label, previous):
        """create the window for an URL screen"""
        temp = self.check_input(last_label, config_type, previous)
        if temp == 1:
            self.window.close()
            self.window = TextSetup(self, config_type, message, situation, last_label, previous)
            make_window(self)
        else:
            self.make_error(temp)

    def make_url(self, label, last_label, config_type, previous):
        """create the window for an URL screen"""
        temp = self.check_input(last_label, config_type, previous)
        if temp == 1:
            increment()
            self.window.close()
            self.window = URLSetup(self, label, config_type)
            make_window(self)
        else:
            self.make_error(temp)

    def reconfiguring(self, config_type):
        """this is called when the user decides to reconfigure and reset the setting"""
        global AWS_CONFIGURED
        global GKE_CONFIGURED
        if config_type == "AWS":
            AWS_CONFIGURED = False
            self.start("AWS")
        elif config_type == "GKE":
            GKE_CONFIGURED = False
            self.start("GKE")

# General functions used in almost every screen created
def setup_cancel(self):
    """General go back to menu command"""
    cancel_button = self.ui.get_cancel()
    cancel_button.clicked.connect(self.controller.make_menu)

def make_window(self):
    """Makes a window"""
    self.window.setWindowTitle("Kiosk - Van Valen Lab Caltech 2018")
    self.window.show()

def increment():
    """increments both states (this is alright since menu resets both)"""
    global AWS_STATE
    global GKE_STATE
    AWS_STATE += 1
    GKE_STATE += 1

# General functions that read and write files
def write_into_file(filename, file_action, tag, user_input):
    """writes into a given file given text"""
    temp_dict = open(filename, file_action)
    clean_text = user_input.replace("\n", "")
    temp_dict.write(tag+clean_text+"\n")
    temp_dict.close()

def read_file(filename):
    """reads a file and outputs an array of the lines. Removes \n elements afterwards"""
    temp_file = open(filename, "r")
    file_lines = temp_file.readlines()
    line = []
    for temp in file_lines:
        line.append(temp.replace("\n", ""))
    return line

def get_cloud_list():
    """Returns a list of all project ID's from login"""
    cloud_output = str(subprocess.check_output(["./getCloudList.sh"]))
    new_line = cloud_output.find("\\n")
    cloud_list = []

    #This part gets project ID, name, and project number
    while not new_line == -1:
        cloud_output = cloud_output[new_line+2:]
        new_line = cloud_output.find("\\n")
        if not new_line == -1:
            cloud_list.append(cloud_output[:new_line])
    #This goes through and leaves only project ID
    for temp in range(len(cloud_list)):
        first_space = cloud_list[temp].find(" ")
        cloud_list[temp] = cloud_list[temp][:first_space]
    return cloud_list

def check_proj_id():
    """compares the inputed project ID to the linked email's project ID's"""
    config = read_file("gkeConfig.txt")
    proj_id_list = get_cloud_list()
    inputed_proj_id = parse_dict(config, "Project ID:")
    legit = False
    for project in proj_id_list:
        if project == inputed_proj_id:
            legit = True
    return legit


# Creates/checks the url
def give_url():
    """calls shell script and creates a url for users to login with"""
    raw_url = str(subprocess.check_output(["./authenticateGiveURL.sh"]))
    start = raw_url.find("https")
    real_url = raw_url[start:-3]
    return real_url

def check_url_code(code):
    """after logging in, the user gets a code and this takes in the code and checks it"""
    checker = str(subprocess.check_output(["./authenticateTakeCode.sh", code]))
    if checker.find("Worked") == -1:
        return 0
    return 1

# Region/GPU stuff in GKE
def region_to_gpu():
    """calls the shell script that gives the possible GPUs given a certain region"""
    global GKE_GPU_LIST
    config = read_file("gkeConfig.txt")
    for line in config:
        if "Region" in line:
            region = line[line.find(":")+2:]
            temp_list = subprocess.check_output(["./getGPU_GKE.sh", region])
            GKE_GPU_LIST = parse_gpu(temp_list)

def parse_gpu(gpu_list):
    """parses the shell script output into a list of the elements"""
    gpu_list = str(gpu_list)[2:-3]
    fake_list = []
    real_list = []
    while "OFF" in gpu_list or "ON" in gpu_list:
        off_place = gpu_list.find("OFF")
        on_place = gpu_list.find("ON")
        if (off_place < on_place or on_place == -1) and not off_place == -1:
            temp = gpu_list[:off_place-3]
            fake_list.append(temp)
            gpu_list = gpu_list[off_place+4:]
        elif not on_place == -1:
            temp = gpu_list[:on_place-3]
            real_list.append(temp)
            gpu_list = gpu_list[on_place+4:]
    for temp in fake_list:
        real_list.append(temp)
    return real_list

def gpu_to_regions():
    """turns a given gpu into a list of regions that work for that gpu"""
    global GKE_REGIONS_LIST
    config = read_file("gkeConfig.txt")
    predict = ""
    training = ""
    region = ""
    for line in config:
        if "GPU prediction" in line:
            predict = line[line.find(":")+1:]
        elif "GPU training" in line:
            training = line[line.find(":")+1:]
        elif "Region" in line:
            region = line[line.find(":")+1:]
    temp_list = subprocess.check_output(["./getZonesGKE.sh", predict, training, region])
    GKE_REGIONS_LIST = parse_shell_output(temp_list)

def parse_shell_output(unparsed):
    """takes in an unparsed return from the shell script and turns it into a list"""
    unparsed = str(unparsed)[2:-3]
    real_list = []
    while "," in unparsed:
        break_spot = unparsed.find(",")
        curr_first = unparsed[:break_spot]
        real_list.append(curr_first)
        unparsed = unparsed[break_spot+1:]
    real_list.append(unparsed)
    return real_list

def gpu_warning():
    """returns the text used for gke where it explains at least 2 regions are necessary"""
    #
    #This will return it in a list where the second element reports if at least
    #
    # 2 regions were there
    #
    global GKE_REGIONS_LIST
    length = 0
    warning = "Here are the zones in your chosen region that host the GPU type(s) you chose:\n"
    if len(GKE_REGIONS_LIST) < 2:
        length = 0
    else:
        length = 1
    if len(GKE_REGIONS_LIST) > 1:
        for region_num in range(len(GKE_REGIONS_LIST)-1):
            warning += GKE_REGIONS_LIST[region_num]+", "
    warning += GKE_REGIONS_LIST[len(GKE_REGIONS_LIST)-1]
    warning += "\nIf you see 0 or 1 zones listed above, please reconfigure the cluster before "
    warning += "deploying.\nDifferent choices of GPU(s) and/or region will be necessary."
    return [warning, length]

def parse_dict(file, identifier):
    """looks through a file for a certain phrase/word. Then it takes whatever is past the colon"""
    for line in file:
        if identifier in line:
            colon = line.find(":")
            value = line[colon+1:]
            return value

def cluster_gke():
    """main gke cluster starter"""
    print("gke")
    config = read_file("gkeConfig.txt")
    proj_id = parse_dict(config, "Project ID:")
    cluster_name = parse_dict(config, "Cluster Name:")
    bucket_name = parse_dict(config, "Bucket Name:")
    region = parse_dict(config, "Region:")
    node_type = parse_dict(config, "Node (non-GPU) Type:")
    min_compute_nodes = parse_dict(config, "Minimum Number of Compute (non-GPU) Nodes:")
    max_compute_nodes = parse_dict(config, "Maximum Number of Compute (non-GPU) Nodes:")
    predict_gpu = parse_dict(config, "GPU (predict):")
    train_gpu = parse_dict(config, "GPU (training):")
    possible_zones = parse_dict(config, "Possible Zones given the GPU:")
    min_gpu_nodes = parse_dict(config, "Minimum Number of GPU Nodes:")
    max_gpu_nodes = parse_dict(config, "Maximum Number of GPU Nodes:")
    # test for if any are none (as opposed to a string type)
    try:
        temp = proj_id+" "+cluster_name+" "+bucket_name+" "+region+" "+node_type+" "
        temp += min_compute_nodes+" "+max_compute_nodes+" "+predict_gpu+" "+train_gpu
        temp += " "+possible_zones+" "+min_gpu_nodes+" "+max_gpu_nodes
    except TypeError:
        print("nope")


def cluster_aws():
    """main aws cluster starter"""
    print("aws")
    config = read_file("awsConfig.txt")
    key_id = parse_dict(config, "Access Key ID:")
    secret_key = parse_dict(config, "AWS Secret Key:")
    bucket_name = parse_dict(config, "AWS S3 Bucket Name:")
    cluster_name = parse_dict(config, "Cluster Name:")
    m_nodes = parse_dict(config, "Master Node Machine Type:")
    w_nodes = parse_dict(config, "Worker Nodes Machine Type:")
    gpu_type = parse_dict(config, "GPU Instance Type:")
    min_gpu = parse_dict(config, "Minimum number of GPU Instances:")
    max_gpu = parse_dict(config, "Maximum number of GPU Instances:")
    # test for if any are none (as opposed to a string type)
    try:
        temp = subprocess.check_output(["./awsEnv.sh", key_id, secret_key, bucket_name, cluster_name, min_gpu, max_gpu])
    except subprocess.CalledProcessError as e:
        print(e)
    print(temp)

def main():
    """Executes the program"""
    app = QtWidgets.QApplication(sys.argv)
    hub = Controller()
    hub.make_start()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
