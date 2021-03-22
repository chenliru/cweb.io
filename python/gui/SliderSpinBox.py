# RGBSlider.py
# Import necessary modules
# import sys
import sys

from PyQt5.QtWidgets import (QWidget, QLabel, QSlider, QSpinBox, QHBoxLayout, QVBoxLayout, QGridLayout, QApplication)
from PyQt5.QtGui import QImage, QPixmap, QColor, qRgb, QFont
from PyQt5.QtCore import Qt


class SliderSpinBox(QWidget):
    def __init__(self, label, max_value, func):
        super().__init__()

        # self.container = QWidget()
        self.label = QLabel(label)

        # Create sliders and spin boxes
        self.spinbox = QSpinBox()
        self.slider = QSlider(Qt.Horizontal)

        self.slider.setMaximum(max_value)
        self.spinbox.setMaximum(max_value)

        self.value = 0

        self.slider.valueChanged.connect(func)
        self.spinbox.valueChanged.connect(func)

        self.init_ui()

    def init_ui(self):
        """
        Initialize the window and display its contents to the screen.
        """
        self.setMinimumSize(50, 80)
        self.setWindowTitle('Slider & SpinBox')

        self.setup_window()
        # self.show()

    def setup_window(self):
        """
        Create instances of widgets and arrange them in layouts.
        """
        h_box = QHBoxLayout()
        h_box.addWidget(self.label, Qt.AlignRight)
        h_box.addWidget(self.slider, Qt.AlignRight)
        h_box.addWidget(self.spinbox, Qt.AlignRight)

        self.setLayout(h_box)
        # self.container.setLayout(h_box)

        # Use [] to pass arguments to the valueChanged signal
        # The sliders and spin boxes for each color should display the same values and be updated at the same time.
        self.slider.valueChanged.connect(self.update_spinbox)
        self.spinbox.valueChanged.connect(self.update_slider)

    # The following methods update the red, green, and blue
    # sliders and spin boxes.
    def update_spinbox(self, value):
        self.spinbox.setValue(value)
        self.value = value

    def update_slider(self, value):
        self.slider.setValue(value)
        self.value = value


if __name__ == '__main__':
    app = QApplication(sys.argv)
    # Use the style_sheet from rgb_slider
    win = SliderSpinBox("Camera Color", 255)
    sys.exit(app.exec_())
