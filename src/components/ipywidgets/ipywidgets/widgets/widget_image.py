"""Image class.

Represents an image in the frontend using a widget.
"""

# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

import base64

from .widget import DOMWidget, register
from traitlets import Unicode, CUnicode, Bytes


@register('IPython.Image')
class Image(DOMWidget):
    """Displays an image as a widget.

    The `value` of this widget accepts a byte string.  The byte string is the raw
    image data that you want the browser to display.  You can explicitly define
    the format of the byte string using the `format` trait (which defaults to
    "png")."""
    _view_name = Unicode('ImageView', sync=True)
    
    # Define the custom state properties to sync with the front-end
    format = Unicode('png', sync=True)
    width = CUnicode(sync=True)
    height = CUnicode(sync=True)
    _b64value = Unicode(sync=True)
    
    value = Bytes()
    def _value_changed(self, name, old, new):
        self._b64value = base64.b64encode(new)
