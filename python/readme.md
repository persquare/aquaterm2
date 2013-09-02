
## Usage

    from aquaterm import *
    from Foundation import *
    a = AQTAdapter.alloc().init()
    a.openPlotWithIndex_(1)
    a.setPlotSize_(NSSize(800,800))
    a.setPlotTitle_("Title")
    a.renderPlot()

## FIXME
* [Done] Path to built products dir in `__init__.py`