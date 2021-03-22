# rgb_demo.py
# Import necessary modules
import sys
from PyQt5.QtWidgets import (QApplication, QWidget, QLabel, QHBoxLayout)
from PyQt5.QtGui import QPixmap
from PyQt5.QtCore import Qt
from python.gui.RGBSlider import RGBSlider, style_sheet


class ImageDemo(QWidget):
    def __init__(self):
        super().__init__()
        self.init_ui()

    def init_ui(self):
        """
        Initialize the window and display its contents to the screen.
        """
        self.setMinimumSize(225, 300)
        self.setWindowTitle('9.3 - Custom Widget')

        # Load image
        image = "images/chameleon.png"

        # Create instance of RGB slider widget and pass the image as an argument to RGBSlider
        rgb_slider = RGBSlider(image)

        image_label = QLabel()
        image_label.setAlignment(Qt.AlignTop)
        try:
            with open(image):
                pixmap = QPixmap(image)
                image_label.setPixmap(pixmap)
                image_label.move(25, 40)
        except FileNotFoundError:
            print("Image not found.")

        # Reimplement the label's mousePressEvent
        image_label.mousePressEvent = rgb_slider.get_pixels_value

        h_box = QHBoxLayout()
        h_box.addWidget(rgb_slider)
        h_box.addWidget(image_label)

        self.setLayout(h_box)
        self.show()


if __name__ == '__main__':
    app = QApplication(sys.argv)
    # Use the style_sheet from rgb_slider
    app.setStyleSheet(style_sheet)
    win = ImageDemo()
    sys.exit(app.exec_())
