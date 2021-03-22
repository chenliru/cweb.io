# GuiCam.py
# Import necessary modules

from PyQt5.QtCore import Qt, QSize
from PyQt5.QtGui import QPixmap, QIcon
# from PyQt5.QtMultimedia import QCameraInfo
from PyQt5.QtWidgets import (QApplication, QMainWindow, QListWidget,
                             QListWidgetItem, QLabel, QGroupBox, QPushButton, QVBoxLayout, QMdiArea,
                             QMdiSubWindow, QDockWidget, QWidget, QColorDialog, QRadioButton, QHBoxLayout, QSpinBox,
                             QAction, QStatusBar, QToolBar, QFileDialog, QMessageBox, )
# from gui.RGBSlider import style_sheet
from python.gui.SliderSpinBox import SliderSpinBox

from webcam.WebCam import WebCam
from common.Common import *

from common.Model import Model
from python.model.BarCode import BarCode
from python.model.Color import Color
from python.model.CascadeClassifier import CascadeClassifier
from python.model.Contour import Diff2frame, Diff3frame, Background
from python.model.Lane import Lane
from python.model.Face import Face
from python.model.HOGDescriptor import HOGDescriptor
from python.model.GoodFeature import GoodFeature
from python.model.Sample import Template, Feature, ColorShape
from python.model import Tracker, CamShift
from python.model import SimpleBlob
from python.model.TensorFlow import Tensorflow, Caffe
from python.model import Yolo
from python.model.GrabCut import GrabCut


class GuiCam(QMainWindow):
    def __init__(self):
        super(GuiCam, self).__init__()

        self.cameras = []
        self.cam_sync = True

        # Create Camera sub_window contents
        self.list_cameras = QListWidget()
        self.list_cameras.setAlternatingRowColors(True)
        self.button_select_camera = QPushButton("Select Camera")

        # Add availableCameras to a list to be displayed in list widget.
        # Use QCameraInfo() to auto detected local camera(s) and list available cameras.
        # cameras = QCameraInfo().availableCameras()
        # self.init_list(self.list_cameras, [cam.deviceName() for cam in list(cameras)])  # + list(videos))

        self.init_list(self.list_cameras, ["Front Camera", "Real Camera"])  # + list(videos))

        # dictionary data structure to construct camera filter functions tuning parameters
        self.functions = {thresholding: [["0: Disable Filter; 1:Active Filter", 1],
                                         ["0:gray; 1:Simple Thresholding; 2:Adaptive Thresholding", 0],
                                         ["Simple Thresholding: 0:BINARY; 1:BINARY_INV; 2:TRUNC; 3:TOZERO; "
                                          "4:TOZERO_INV; 5:THRESH_OTSU", 0],
                                         ["Simple Thresholding: Threshold value", 127],
                                         ["Kernel", 0]],
                          smoothing: [["0: Disable Filter; 1:Active Filter", 1],
                                      ["0:Averaging; 1:Gaussian; 2:Median; 3: Bilateral; 4: De Noise", 0],
                                      ["", 0],
                                      ["", 0],
                                      ["Kernel", 0]],
                          morphology: [["0: Disable Filter; 1:Active Filter", 1],
                                       ["0:Erosion; 1:Dilation; 2:Morphology; ", 0],
                                       ["Morphology Operator 0:Open;1:Close;2:GRADIENT;3:TOPHAT;4:BLACKHAT", 0],
                                       ["morph_element 0:RECT; 1:CROSS; 2:ELLIPSE", 0],
                                       ["Kernel", 0]],
                          histograms: [["0: Disable Filter; 1:Active Filter", 1],
                                       ["0:Equalization; 1:adaptive equalization; 2:Contrast&Brightness; 3:gamma; "
                                        "4:low-light;", 0],
                                       ["alpha-contrast", 50],
                                       ["beta-brightness", 50],
                                       ["", 0]],
                          arithmetic: [["0: Disable Filter; 1:Active Filter", 1],
                                       ["", 0],
                                       ["Scale", 0],
                                       ["alpha-contrast", 50],
                                       ["beta-brightness", 50]],
                          transformations: [["0: Disable Filter; 1:Active Filter", 1],
                                            ["0:Scaling(select rect); 1:Perspective(by select 4 points); "
                                             "2:Affine(by select 3 points);", 0],
                                            ["Scaling factor", 0],
                                            ["", 0],
                                            ["", 0]],
                          extraction: [["0: Disable Filter; 1:Active Filter", 1], ["", 0], ["", 0], ["", 0], ["", 0]],
                          none: [["", 0], ["", 0], ["", 0], ["", 0], ["", 0]], }

        # hold camera filter functions
        # data struct: {function: [["description", value],,,]}
        self.spinbox_tip_value = []
        # Camera AI parts
        self.models = [BarCode,
                       Color,
                       CascadeClassifier,
                       Diff2frame,
                       Diff3frame,
                       Background,
                       Lane,
                       Face,
                       HOGDescriptor,
                       GoodFeature,
                       Tracker,
                       CamShift,
                       Template,
                       ColorShape,
                       Feature,
                       SimpleBlob,
                       Caffe,
                       Tensorflow,
                       Yolo,
                       GrabCut,
                       Model, ]
        self.spin_boxes = []  # hold camera filter function parameters using spinbox value
        self.list_functions = QListWidget()
        self.list_functions.setAlternatingRowColors(True)
        self.button_select_filter = QPushButton("Select filter")
        self.dialog_color = QColorDialog()

        self.camera_contents = QWidget()
        self.dock_camera = QDockWidget()

        self.filter_contents = QWidget()
        self.dock_filter = QDockWidget()

        self.color_contents = QWidget()
        self.dock_color = QDockWidget()

        # Create Model sub_window contents
        # self.models = []  # hold AI models for objects detecting and tracing
        self.list_models = QListWidget()
        self.list_models.setAlternatingRowColors(True)
        self.button_select_model = QPushButton("Select Model")
        self.gbox_model = QGroupBox()

        self.sub_window_models = QMdiSubWindow()
        self.sub_window_models.setAttribute(Qt.WA_DeleteOnClose)
        self.sub_window_models.setWindowTitle("AI Model")

        # Create View sub_window contents
        self.label_image = QLabel()
        self.label_image.setAlignment(Qt.AlignTop)

        self.sub_window_view = QMdiSubWindow()
        self.sub_window_view.setAttribute(Qt.WA_DeleteOnClose)
        self.sub_window_view.setWindowTitle("View")

        # Create Menu Actions
        self.act_file_open = QAction(QIcon('images/open_file.png'), "Open", self)
        self.act_file_close = QAction(QIcon('images/close_file.png'), "Close", self)
        self.act_file_save = QAction(QIcon('images/save_file.png'), "Save", self)
        self.act_file_record = QAction(QIcon('images/record_file.png'), "Record", self)
        self.act_file_print = QAction(QIcon('images/print.png'), "Print", self)
        self.act_file_exit = QAction(QIcon('images/exit.png'), 'Exit', self)

        self.act_edit_image = QAction(QIcon('images/add_image.png'), "Add image", self)
        self.act_edit_logo = QAction(QIcon('images/add_logo.png'), "Add logo", self)

        self.init_ui()

    def init_ui(self):
        """
        Initialize the window and display its contents to the screen
        """
        # defines the location of the window on computer screen and its
        # dimensions, width and height. So the window we just started is located
        # at x=100,; y=100 in the window and has width=1600 and height=800

        self.setGeometry(900, 100, 1600, 800)
        self.setWindowTitle('12.2 – Camera GUI')

        self.init_menu()
        self.init_toolbar()
        self.init_camera()
        self.init_filter()
        self.init_color()
        self.init_model()
        self.init_window()

        self.show()

    @staticmethod
    def init_list(list_widget, list_widget_items):
        list_widget.clear()
        for item_text in list_widget_items:
            item = QListWidgetItem()
            item.setText(str(item_text))
            list_widget.addItem(item)

    def init_menu(self):
        """
        Create menu for CVision GUI
        """
        # Create actions for file menu
        self.act_file_open.setShortcut('Ctrl+O')
        self.act_file_open.setStatusTip('Open a new image/video')
        self.act_file_open.triggered.connect(self.open_file)

        self.act_file_close.setShortcut('Ctrl+E')
        self.act_file_close.setStatusTip('Close an image/video')
        self.act_file_close.triggered.connect(self.close_file)

        self.act_file_save.setShortcut('Ctrl+S')
        self.act_file_save.setStatusTip('Save image')
        self.act_file_save.triggered.connect(self.save_file)

        self.act_file_record.setShortcut('Ctrl+R')
        self.act_file_record.setStatusTip('Record video')
        self.act_file_record.triggered.connect(self.record_file)

        self.act_file_print.setShortcut('Ctrl+P')
        self.act_file_print.setStatusTip('Print image')
        self.act_file_print.triggered.connect(self.print)
        self.act_file_print.setEnabled(False)

        self.act_file_exit.setShortcut('Ctrl+Q')
        self.act_file_exit.setStatusTip('Quit program')
        self.act_file_exit.triggered.connect(self.exit)

        # Create actions for edit menu
        self.act_edit_image.setShortcut('Ctrl+A')
        self.act_edit_image.setStatusTip('Open a blend image')
        self.act_edit_image.triggered.connect(self.add_image)

        self.act_edit_logo.setShortcut('Ctrl+L')
        self.act_edit_logo.setStatusTip('Open a logo image')
        self.act_edit_logo.triggered.connect(self.add_logo)

        # Create menu_bar
        menu_bar = self.menuBar()
        menu_bar.setNativeMenuBar(False)

        # Create file menu and add actions
        file_menu = menu_bar.addMenu('File')
        file_menu.addAction(self.act_file_open)
        file_menu.addAction(self.act_file_close)
        file_menu.addAction(self.act_file_save)
        file_menu.addAction(self.act_file_record)
        file_menu.addSeparator()
        file_menu.addAction(self.act_file_print)
        file_menu.addSeparator()
        file_menu.addAction(self.act_file_exit)

        # Create edit menu and add actions
        edit_menu = menu_bar.addMenu('Edit')
        edit_menu.addAction(self.act_edit_image)
        edit_menu.addAction(self.act_edit_logo)

        # Create view menu and add actions
        view_menu = menu_bar.addMenu('View')
        view_menu.addAction(self.dock_camera.toggleViewAction())
        view_menu.addAction(self.dock_filter.toggleViewAction())
        view_menu.addAction(self.dock_color.toggleViewAction())

        # Display info about tools, menu, and view in the status bar
        self.setStatusBar(QStatusBar(self))

    def init_toolbar(self):
        """
        Create toolbar for CVision GUI
        """
        tool_bar = QToolBar("Photo Editor Toolbar")
        tool_bar.setIconSize(QSize(24, 24))
        self.addToolBar(tool_bar)

        # Add actions to toolbar
        tool_bar.addAction(self.act_file_open)
        tool_bar.addAction(self.act_file_close)
        tool_bar.addAction(self.act_file_save)
        tool_bar.addAction(self.act_file_record)
        tool_bar.addAction(self.act_file_print)

        tool_bar.addSeparator()
        tool_bar.addAction(self.act_edit_image)
        tool_bar.addAction(self.act_edit_logo)

        # tool_bar.addAction(self.clear_act)
        tool_bar.addSeparator()
        tool_bar.addAction(self.act_file_exit)

    def open_file(self):
        """
        Open an image file and display its contents in label widget.
        Display error message if image can't be opened.
        """
        file, _ = QFileDialog.getOpenFileName(self, "Open Image", f"{CWD}//data//Sample//",
                                              "Video Files (*.mp4 *.avi );;"
                                              "JPG Files (*.jpeg *.jpg );;"
                                              "PNG Files (*.png);;"
                                              "Bitmap Files (*.bmp);;"
                                              "GIF Files (*.gif);;"
                                              "All Files (*)")
        if file:
            self.select_camera(file)
        else:
            QMessageBox.information(self, "Error", "Unable to open image.", QMessageBox.Ok)

        self.act_file_print.setEnabled(True)

    def add_image(self):
        """
        Open an image file as back ground blending image.
        Display error message if image can't be opened.
        """
        for cam in self.cameras:
            file, _ = QFileDialog.getOpenFileName(self, "Open Image", f"{CWD}//data//Sample//",
                                                  "JPG Files (*.jpeg *.jpg );;"
                                                  "PNG Files (*.png);;"
                                                  "Bitmap Files (*.bmp);;"
                                                  "GIF Files (*.gif)")
            if file:
                cam.image_background = cv2.imread(file)
                cam.register_filters(rotation, arithmetic)  # add image arithmetic algorithm

                self.spinbox_tip_value = [["0: Disable Filter; 1:Active Filter", 1],
                                          ["", 0],
                                          ["Switch foreground/background image", 0],
                                          ["alpha", 127],
                                          ["beta", 50]]
                self.set_spinbox()
            else:
                QMessageBox.information(self, "Error", "Unable to add image.", QMessageBox.Ok)

        self.button_select_filter.setText(f"Select: Add Image")

    def add_logo(self):
        """
        Open an image file as back ground blending image.
        Display error message if image can't be opened.
        """
        for cam in self.cameras:
            file, _ = QFileDialog.getOpenFileName(self, "Open Logo", f"{CWD}//data//Sample//",
                                                  "JPG Files (*.jpeg *.jpg );;"
                                                  "PNG Files (*.png);;"
                                                  "Bitmap Files (*.bmp);;"
                                                  "GIF Files (*.gif)")
            if file:
                cam.image_logo = cv2.imread(file)  # add logo icon
                cam.register_filters(rotation, arithmetic)  # add image arithmetic algorithm

                self.spinbox_tip_value = [["0: Disable Filter; 1:Active Filter", 1],
                                          ["", 0],
                                          ["0:THRESH_BINARY; 1:THRESH_BINARY_INV", 0],
                                          ["threshold", 230],
                                          ["scale", 255]]
                self.set_spinbox()

            else:
                QMessageBox.information(self, "Error", "Unable to open logo image.", QMessageBox.Ok)

            self.button_select_filter.setText(f"Select: Add Logo")

    def close_file(self):
        self.stop_camera()
        self.cameras.clear()

    def save_file(self):
        for cam in self.cameras:
            cam.save_image(cam.filter_image)

    def record_file(self):
        for cam in self.cameras:
            cam.boolean_record = not cam.boolean_record

    def print(self):
        pass

    def exit(self):
        self.close_file()
        self.close()

    def init_camera(self):
        # Camera Control Dock
        layout_vbox_camera = QVBoxLayout()

        slider_spinbox_direction = SliderSpinBox("Angle", 360, self.update_angle)
        slider_spinbox_direction.setStatusTip("Rotate image")

        label_camera = QLabel("Available Cameras")

        # Create instances of radio buttons
        radio_sync = QRadioButton("Sync")
        radio_sync.setChecked(True)
        radio_sync.setStatusTip("Camera Capture in Main() thread")
        radio_sync.toggled.connect(lambda: self.radio_toggle(radio_sync))
        radio_async = QRadioButton("Async")
        radio_async.setStatusTip("Camera Capture in respective thread")
        radio_async.toggled.connect(lambda: self.radio_toggle(radio_async))

        # Set up layout and add child widgets to the layout
        radio_h_box = QHBoxLayout()
        radio_h_box.addWidget(label_camera)
        radio_h_box.addStretch()  # used to help arrange widgets in a layout manager.
        radio_h_box.addWidget(radio_sync)
        radio_h_box.addWidget(radio_async)

        # Set a specific layout manager inside a parent window or widget
        radio_contents = QWidget()
        radio_contents.setLayout(radio_h_box)

        # Create button that will allow user to select camera
        self.button_select_camera.clicked.connect(self.select_camera)

        layout_vbox_camera.addWidget(radio_contents)
        layout_vbox_camera.addWidget(self.list_cameras)
        layout_vbox_camera.addWidget(slider_spinbox_direction)
        layout_vbox_camera.addWidget(self.button_select_camera)

        # Create child widgets and layout
        self.camera_contents.setLayout(layout_vbox_camera)

    def init_filter(self):
        # Camera Control Dock
        layout_vbox_filter = QVBoxLayout()

        label_filter = QLabel("Available Filters")

        # Set up layout and add child widgets to the layout
        label_h_filter = QLabel("Filter parameters")
        filter_h_box = QHBoxLayout()
        filter_h_box.addWidget(label_h_filter)

        # create 5 instances of QSpinBox class to hold camera filter function parameters
        for i in range(5):
            spinbox = QSpinBox()
            spinbox.setMaximum(255)
            spinbox.valueChanged.connect(self.update_filter_param)
            filter_h_box.addWidget(spinbox)
            self.spin_boxes.append(spinbox)

        # Set a specific layout manager inside a parent window or widget
        filter_contents = QWidget()
        filter_contents.setLayout(filter_h_box)

        # Create button that will allow user to select camera filter
        self.button_select_filter.clicked.connect(self.select_filter)
        self.button_select_filter.setDisabled(True)

        layout_vbox_filter.addWidget(label_filter)
        layout_vbox_filter.addWidget(self.list_functions)
        layout_vbox_filter.addWidget(filter_contents)
        # layout_vbox_camera.addWidget(slider_spinbox_filter)
        layout_vbox_filter.addWidget(self.button_select_filter)

        # Create child widgets and layout
        self.filter_contents.setLayout(layout_vbox_filter)

    def init_color(self):
        # Color Control Dock
        layout_vbox_color = QVBoxLayout()

        slider_spinbox_color = SliderSpinBox("Color %: ", 100, self.update_color_param)
        slider_spinbox_color.setStatusTip("Blend image background color")

        # Create instance of QColorDialog widget and pass the image as an argument to RGBSlider
        self.dialog_color.setOption(QColorDialog.NoButtons)
        self.dialog_color.currentColorChanged.connect(self.update_color)

        layout_vbox_color.addWidget(self.dialog_color)
        layout_vbox_color.addWidget(slider_spinbox_color)

        # Create child widgets and layout
        self.color_contents.setLayout(layout_vbox_color)

    def init_model(self):
        # Set up list widget that will display identified
        # models on your computer.
        label_model = QLabel("Available models")

        # Create button that will allow user to select model
        self.button_select_model.clicked.connect(self.select_models)
        self.button_select_model.setDisabled(True)

        # Create child widgets and layout for model controls sub_window
        layout_vbox_model = QVBoxLayout()
        layout_vbox_model.addWidget(label_model)
        layout_vbox_model.addWidget(self.list_models)
        layout_vbox_model.addWidget(self.button_select_model)

        # Create layout for model controls sub_window
        self.gbox_model.setTitle("Model Controls")
        self.gbox_model.setLayout(layout_vbox_model)

    def init_window(self):
        """
        Set up QMdiArea parent and sub_windows.
        Add available cameras on local system as items to
        list widget.
        """
        # Load image in sub_window_view
        self.load_image("images/chameleon.png")
        self.sub_window_view.setWidget(self.label_image)
        self.sub_window_models.setWidget(self.gbox_model)

        # Create QMdiArea widget to manage sub_windows
        mdi_area = QMdiArea()
        mdi_area.tileSubWindows()

        # mdi_area.addSubWindow(self.sub_window_camera)
        mdi_area.addSubWindow(self.sub_window_models)
        mdi_area.addSubWindow(self.sub_window_view)

        # Set up dock widget
        self.dock_camera.setWindowTitle("Camera Control")
        self.dock_camera.setAllowedAreas(Qt.LeftDockWidgetArea | Qt.RightDockWidgetArea)
        self.dock_camera.setWidget(self.camera_contents)

        self.dock_filter.setWindowTitle("Camera Filter")
        self.dock_filter.setWidget(self.filter_contents)

        self.dock_color.setWindowTitle("Camera Color")
        self.dock_color.setWidget(self.color_contents)
        self.dock_color.setVisible(False)

        # Set initial location of dock widget in main window
        self.addDockWidget(Qt.RightDockWidgetArea, self.dock_camera)
        self.addDockWidget(Qt.RightDockWidgetArea, self.dock_filter)
        self.addDockWidget(Qt.RightDockWidgetArea, self.dock_color)

        # Set mdi_area widget as the central widget of main window
        self.setCentralWidget(mdi_area)

    def load_image(self, image):
        try:
            with open(image):
                pixmap = QPixmap(image)
                self.label_image.setPixmap(pixmap)
                self.label_image.move(25, 40)
        except FileNotFoundError:
            print("Image not found.")

    def radio_toggle(self, radio):
        if radio.text() == "Sync" and radio.isChecked():
            self.cam_sync = True
        else:
            self.cam_sync = False

    def select_camera(self, name=None):
        """
        Slot for selecting one of the available cameras displayed in list
        widget.
        """
        def camera(device_name):
            webcam = WebCam(device=device_name, sync=self.cam_sync)
            self.cameras.append(webcam)

            for webcam in self.cameras:
                webcam.register_filters(rotation, arithmetic, none)

                # srv = ('127.0.0.1', 61215, '10000000e7268f60')
                # webcam = WebCam(channel=0, service=srv, device=1, sync=False)
                #
                webcam.gui = self
                webcam.start()
                webcam.start_show()

            self.init_list(self.list_functions, [func.__name__ for func in list(self.functions.keys())])
            self.button_select_filter.setEnabled(True)

            self.init_list(self.list_models, [model.name for model in self.models])
            self.button_select_model.setEnabled(True)
            self.load_image("images/chenliru.jpg")

        try:
            for cam in self.cameras:
                cam.stop_show()  # stop camera show if there is a camera instance already
            self.cameras.clear()

            if self.list_cameras.currentItem() is not None and not name:
                name = self.list_cameras.currentRow()
            camera(name)

        except Exception as e:
            print(f"No cameras detected {e}.")

    def stop_camera(self):
        for cam in self.cameras:
            cam.stop_show()  # stop camera show if there is a camera instance already

    def select_models(self):
        """
        Slot for selecting one of the available AI models displayed in list
        widget.
        """
        position = self.list_models.currentRow()
        ai_model = self.models[position]()
        for cam in self.cameras:
            cam.register_models(ai_model)

        self.button_select_model.setText(f"Select: {ai_model.name}")

    def select_filter(self):
        """
        Slot for selecting one of the available camera filters displayed in list
        widget.
        self.filters = ["log", "gamma", "hist", "yarcb"]
        """
        position = self.list_functions.currentRow()
        funcs = [*self.functions.keys()]  # get keys as list
        func = funcs[position]
        for cam in self.cameras:
            cam.register_filters(rotation, arithmetic, func)

        self.spinbox_tip_value = [*self.functions.values()][position]  # get values as list
        self.set_spinbox()

        self.button_select_filter.setText(f"Select: {func.__name__}")

    def set_spinbox(self):
        tip = np.array(self.spinbox_tip_value)[:, 0]
        value = np.array(self.spinbox_tip_value)[:, 1]
        for i, spinbox in enumerate(self.spin_boxes):
            spinbox.setValue(int(value[i]))
            spinbox.setStatusTip(tip[i])
            spinbox.setDisabled(True) if tip[i] == "" else spinbox.setEnabled(True)

    def update_filter_param(self):
        """
        Slot for selecting one of the available camera filters parameters
        """
        # pass
        for cam in self.cameras:
            for i in range(5):
                cam.filter_param[i] = self.spin_boxes[i].value()

    def update_angle(self, value):
        """
        Slot for selecting one of the available camera installation direction
        """
        for cam in self.cameras:
            cam.angle = value

    def update_color_param(self, value):
        """
        Slot for updating camera color parameter.
        """
        for cam in self.cameras:
            cam.color_param = value

    def update_color(self):
        """
        Slot for selecting one of the available camera color
        """
        for cam in self.cameras:
            rgb = list(self.dialog_color.currentColor().getRgb())
            cam.color = rgb


# Run program
if __name__ == '__main__':
    app = QApplication(sys.argv)  # Create application object
    # app.setStyleSheet(style_sheet)
    app.setAttribute(Qt.AA_DontShowIconsInMenus, True)
    gui = GuiCam()  # Create Gui Window Interface
    # sys.exit(app.exec_())  # Start the event loop and use sys.exit to close the application
