# HDCA-FetalLung-SpatialProteomics ImageJ macro
This folder contains an ImageJ macro for analyzing spatial proteomics data from fetal lung tissue with the aim to measure intensity information in artery-close immune cells vs artery-distant immune cells and without using a nucleus-channel-based single-cell segmentation. Instead, this macro uses image processing and simple intensity thresholding to detect vessel and and immune cell regions, and discerns immune cell regions depending on their distance to the vessel regions.

Software: (c) 2024, Jan N. Hansen

## Reusing the code? How to cite this software?
See readme file in the [top folder of this repository](https://github.com/CellProfiling/HDCA-FetalLung-SpatialProteomics/tree/main).

## How to apply this code = run the Imagej macro?
- If you do not have the open-source scientific image analysis software FIJI, download it from the [FIJI homepage](https://fiji.sc/). FIJI is simply installed by unzipping the downloaded repository (Linux, Windows) or placing the downloaded app file (Mac) somewhere on your computer.
- Launch FIJI.
- Open the image you aim to analyze in FIJI - it needs to be a multi-slice stack image, where each slice represents a channel. 
- Drag and drop the .ijm macro file from this repository into the small FIJI window, in turn the macro editor will open.
- Click run in the macro editor and follow the instructions and prompts by the macro.

