# Sip TRiggered Optogenetic Behavior Enclosure (STROBE) Software and Source
This repository contains the VHDL source (built atop the FlyPAD by Itskov et al), UI source and executable, and Python post-processing scripts for the STROBE device.

The VHDL binaries were built in Quartus II 13.0sp1.

The STROBE UI was built in Visual Studios 2012 in C++ on Windows 10. It will require installation of Qt 5.11 in order to compile. Included in the source are all 3rd party modules ([FTD2XX](http://www.ftdichip.com), [qtcustomplot](https://www.qcustomplot.com/), etc) needed to compile the executable.