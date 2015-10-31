Congratulations! You have downloaded MIRtoolbox 1.6.1
��������������������������

The list of new features and bug fixes offered by this new version is shown in the ReleaseNotes text file located in the toolbox folder, and also available from our website. New versions of the toolbox will also be released at the same address:
http://www.jyu.fi/hum/laitokset/musiikki/en/research/coe/materials/mirtoolbox

Please inform me if you find any bug when using the toolbox.

**

Conditions of Use
-----------------The Toolbox is free software; you can redistribute it and/or modify it under the terms of version 2 of GNU General Public License as published by the Free Software Foundation. 
When MIRtoolbox is used for academic research, we would highly appreciate if scientific publications of works partly based on MIRtoolbox cite one of the following publications:
Olivier Lartillot, Petri Toiviainen, �A Matlab Toolbox for Musical Feature Extraction From Audio�, International Conference on Digital Audio Effects, Bordeaux, 2007.
Olivier Lartillot, Petri Toiviainen, Tuomas Eerola, �A Matlab Toolbox for Music Information Retrieval�, in C. Preisach, H. Burkhardt, L. Schmidt-Thieme, R. Decker (Eds.), Data Analysis, Machine Learning and Applications, Studies in Classification, Data Analysis, and Knowledge Organization, Springer-Verlag, 2008.
For commercial use of MIRtoolbox, please contact the authors.

**

Please register to the MIRtoolbox announcement list.�
--------------------------------------------
http://www.freelists.org/list/mirtoolboxnews
--------------------------------------------
This will allow us to estimate the number of users, and this will allow you in return to get informed on the new major releases (including critical bug fixes).

**

MIRtoolbox requires Matlab version 7 and Mathworks' Signal Processing toolbox.

**

This distribution actually includes four different toolboxes:

- the MIRtoolbox itself, version 1.5,

- the Auditory toolbox, version 2, by Malcolm Slaney
(also available directly at http://cobweb.ecn.purdue.edu/~malcolm/interval/1998-010/),

- the Netlab toolbox, version 3.3, by Ian Nabney
(also available directly at http://www.ncrg.aston.ac.uk/netlab/)

- the SOM toolbox, version 2.0, by Esa Alhoniemi, Johan Himberg, Jukka Parviainen and Juha Vesanto
(also available directly at http://www.cis.hut.fi/projects/somtoolbox/)

**

MIRtoolbox license is based on GPL 2.0. As such, it can integrate codes from other GPL 2.0 projects, as long as their origins are explicitly stated.
- codes from the Music Analysis Toolbox by Elias Pampalk (2004), related to the computation of Terhardt outer ear modeling, Bark band decomposition and masking effects.

- openbdf and readbdf script by T.S. Lorig to read BDF files, based on openedf and readedf by Alois Schloegl,

- implementation of Earth Mover Distance written by Yossi Rubner and wrapped for Matlab by Elias Pampalk.

Code integrated with BSD license:
- mp3read for Matlab by Dan Ellis, which calls the mpg123 decoder and the mp3info scanner,
- aiffread for Matlab by Kenneth Eaton.

**

To install MIRtoolbox in your Matlab environment, copy all the toolboxes folders (or only those that are not installed yet in your computer) into your Matlab "toolbox" folder. Then add each folder in your Matlab path.

**

NOTICE: If you replace an older version of MIRtoolbox with a new one, please update your Matlab path using the following command:
rehash toolboxcache
Update also the class structure of the toolbox, either by restarting Matlab, or by typing the following command:
clear classes

**

To get an overview of the functions available in the toolbox, type:
help mirtoolbox

A complete documentation in PDF is provided in the main toolbox folder. For absolute Matlab beginners, we suggest to read MIRtoolboxPrimer.

A short documentation for each function is available directly in Matlab using the help command. For instance: help miraudio

Examples of use of the toolbox are shown in the MIRToolboxDemos folder:
mirdemo
demo1basics
demo2timbre
demo3segmentation
demo4tempo
demo5export
demo6curves
demo7tonality
demo8classification
demo9retrieval