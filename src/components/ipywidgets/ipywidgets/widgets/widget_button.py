"""Button class.

Represents a button in the frontend using a widget.  Allows user to listen for
click events on the button and trigger backend code when the clicks are fired.
"""

# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

from .widget import DOMWidget, CallbackDispatcher, register
from traitlets import Unicode, Bool, CaselessStrEnum


@register('IPython.Button')
class Button(DOMWidget):
    """Button widget.
       This widget has an `on_click` method that allows you to listen for the 
       user clicking on the button.  The click event itself is stateless.

       Parameters
       ----------
       description : str
           description displayed next to the button
       tooltip: str
           tooltip caption of the toggle button
       icon: str
           font-awesome icon name
    """
    _view_name = Unicode('ButtonView', sync=True)

    # Keys
    description = Unicode('', help="Button label.", sync=True)
    tooltip = Unicode(help="Tooltip caption of the button.", sync=True)
    disabled = Bool(False, help="Enable or disable user changes.", sync=True)
    icon = Unicode('', help= "Font-awesome icon.", sync=True)

    button_style = CaselessStrEnum(
        values=['primary', 'success', 'info', 'warning', 'danger', ''], 
        default_value='', allow_none=True, sync=True, help="""Use a
        predefined styling for the button.""")
    
    def __init__(self, **kwargs):
        """Constructor"""
        super(Button, self).__init__(**kwargs)
        self._click_handlers = CallbackDispatcher()
        self.on_msg(self._handle_button_msg)

    def on_click(self, callback, remove=False):
        """Register a callback to execute when the button is clicked.

        The callback will be called with one argument,
        the clicked button widget instance.

        Parameters
        ----------
        remove : bool (optional)
            Set to true to remove the callback from the list of callbacks."""
        self._click_handlers.register_callback(callback, remove=remove)

    def _handle_button_msg(self, _, content, buffers):
        """Handle a msg from the front-end.

        Parameters
        ----------
        content: dict
            Content of the msg."""
        if content.get('event', '') == 'click':
            self._click_handlers(self)
