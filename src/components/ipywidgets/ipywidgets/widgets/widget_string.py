"""String class.

Represents a unicode string using a widget.
"""

# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

from .widget import DOMWidget, CallbackDispatcher, register
from traitlets import Unicode, Bool


class _String(DOMWidget):
    """Base class used to create widgets that represent a string."""
    value = Unicode(help="String value", sync=True)
    disabled = Bool(False, help="Enable or disable user changes", sync=True)
    description = Unicode(help="Description of the value this widget represents", sync=True)
    placeholder = Unicode("", help="Placeholder text to display when nothing has been typed", sync=True)

    def __init__(self, value=None, **kwargs):
        if value is not None:
            kwargs['value'] = value
        super(_String, self).__init__(**kwargs)

@register('IPython.HTML')
class HTML(_String):
    """Renders the string `value` as HTML."""
    _view_name = Unicode('HTMLView', sync=True)


@register('IPython.Latex')
class Latex(_String):
    """Renders math inside the string `value` as Latex (requires $ $ or $$ $$ 
    and similar latex tags)."""
    _view_name = Unicode('LatexView', sync=True)


@register('IPython.Textarea')
class Textarea(_String):
    """Multiline text area widget."""
    _view_name = Unicode('TextareaView', sync=True)

    def scroll_to_bottom(self):
        self.send({"method": "scroll_to_bottom"})


@register('IPython.Text')
class Text(_String):
    """Single line textbox widget."""
    _view_name = Unicode('TextView', sync=True)

    def __init__(self, *args, **kwargs):
        super(Text, self).__init__(*args, **kwargs)
        self._submission_callbacks = CallbackDispatcher()
        self.on_msg(self._handle_string_msg)

    def _handle_string_msg(self, _, content, buffers):
        """Handle a msg from the front-end.

        Parameters
        ----------
        content: dict
            Content of the msg."""
        if content.get('event', '') == 'submit':
            self._submission_callbacks(self)

    def on_submit(self, callback, remove=False):
        """(Un)Register a callback to handle text submission.

        Triggered when the user clicks enter.

        Parameters
        ----------
        callback: callable
            Will be called with exactly one argument: the Widget instance
        remove: bool (optional)
            Whether to unregister the callback"""
        self._submission_callbacks.register_callback(callback, remove=remove)
