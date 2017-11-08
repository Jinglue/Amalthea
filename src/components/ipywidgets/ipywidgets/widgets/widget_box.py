"""Box class.

Represents a container that can be used to group other widgets.
"""

# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

from .widget import Widget, DOMWidget, register, widget_serialization
from traitlets import Unicode, Tuple, Int, CaselessStrEnum, Instance


@register('IPython.Box')
class Box(DOMWidget):
    """Displays multiple widgets in a group."""
    _model_name = Unicode('BoxModel', sync=True)
    _view_name = Unicode('BoxView', sync=True)

    # Child widgets in the container.
    # Using a tuple here to force reassignment to update the list.
    # When a proper notifying-list trait exists, that is what should be used here.
    children = Tuple(sync=True, **widget_serialization)

    _overflow_values = ['visible', 'hidden', 'scroll', 'auto', 'initial', 'inherit', '']
    overflow_x = CaselessStrEnum(
        values=_overflow_values,
        default_value='', sync=True, help="""Specifies what
        happens to content that is too large for the rendered region.""")
    overflow_y = CaselessStrEnum(
        values=_overflow_values,
        default_value='', sync=True, help="""Specifies what
        happens to content that is too large for the rendered region.""")

    box_style = CaselessStrEnum(
        values=['success', 'info', 'warning', 'danger', ''],
        default_value='', allow_none=True, sync=True, help="""Use a
        predefined styling for the box.""")

    def __init__(self, children = (), **kwargs):
        kwargs['children'] = children
        super(Box, self).__init__(**kwargs)
        self.on_displayed(Box._fire_children_displayed)

    def _fire_children_displayed(self):
        for child in self.children:
            child._handle_displayed()


@register('IPython.Proxy')
class Proxy(Widget):
    """A DOMWidget that holds another DOMWidget or nothing."""
    _model_name = Unicode('ProxyModel', sync=True)
    _view_name = Unicode('ProxyView', sync=True)

    # Child widget of the Proxy
    child = Instance(DOMWidget, allow_none=True, sync=True,
                     **widget_serialization)

    def __init__(self, child, **kwargs):
        kwargs['child'] = child
        super(Proxy, self).__init__(**kwargs)
        self.on_displayed(Proxy._fire_child_displayed)

    def _fire_child_displayed(self):
        if self.child is not None:
            self.child._handle_displayed()


@register('IPython.PlaceProxy')
class PlaceProxy(Proxy):
    """Renders the child widget at the specified selector."""
    _view_name = Unicode('PlaceProxyView', sync=True)
    selector = Unicode(sync=True)


@register('IPython.FlexBox')
class FlexBox(Box):
    """Displays multiple widgets using the flexible box model."""
    _view_name = Unicode('FlexBoxView', sync=True)
    orientation = CaselessStrEnum(values=['vertical', 'horizontal'], default_value='vertical', sync=True)
    flex = Int(0, sync=True, help="""Specify the flexible-ness of the model.""")
    def _flex_changed(self, name, old, new):
        new = min(max(0, new), 2)
        if self.flex != new:
            self.flex = new

    _locations = ['start', 'center', 'end', 'baseline', 'stretch']
    pack = CaselessStrEnum(
        values=_locations,
        default_value='start', sync=True)
    align = CaselessStrEnum(
        values=_locations,
        default_value='start', sync=True)


def VBox(*pargs, **kwargs):
    """Displays multiple widgets vertically using the flexible box model."""
    kwargs['orientation'] = 'vertical'
    return FlexBox(*pargs, **kwargs)


def HBox(*pargs, **kwargs):
    """Displays multiple widgets horizontally using the flexible box model."""
    kwargs['orientation'] = 'horizontal'
    return FlexBox(*pargs, **kwargs)
