---

If you are not viewing this repository on github, please check the original repository (https://github.com/CellProfiling/HDCA-FetalLung-SpatialProteomics/) for potential updates!

---

# HDCA-FetalLung-SpatialProteomics ImageJ macro
This folder contains an ImageJ macro for analyzing spatial proteomics data from fetal lung tissue (acquired in the [Human Developmental Cell Atlas project](https://www.humancellatlas.org/dca/)) with the aim to measure intensity information in artery-close immune cells vs artery-distant immune cells and without using a nucleus-channel-based single-cell segmentation. Instead, this macro uses image processing and simple intensity thresholding to detect vessel and and immune cell regions, and discerns immune cell regions depending on their distance to the vessel regions.

Software: (c) 2024, Jan N. Hansen

More information and licensing information is going to follow here shortly.

## Reusing the code? How to cite this software?
The software provided in this repository was developed for data analysis as presented in [this preprint](https://doi.org/10.1101/2024.01.25.577163). 
When using the code in this repository, cite this preprint:

```
High-parametric protein maps reveal the spatial organization in early-developing human lung
Sanem Sariyar, Alexandros Sountoulidis, Jan Niklas Hansen, Sergio Marco Salas, Mariya Mardamshina,
Anna Martinez Casals, Frederic Ballllosera Navarro, Zaneta Andrusivova, Xiaofei Li, Paulo Czarnewski,
Joakim Lundeberg, Sten Linnarsson, Mats Nilsson, Erik Sundström, Christos Samakovlis, Emma Lundberg, Burcu Ayoglu.
bioRxiv 2024.01.25.577163; doi: https://doi.org/10.1101/2024.01.25.577163
```

## How to apply this code = run the Imagej macro?
- If you do not have the open-source scientific image analysis software FIJI, download it from the [FIJI homepage](https://fiji.sc/). FIJI is simply installed by unzipping the downloaded repository (Linux, Windows) or placing the downloaded app file (Mac) somewhere on your computer.
- Launch FIJI.
- Open the image you aim to analyze in FIJI - it needs to be a multi-slice stack image, where each slice represents a channel. 
- Drag and drop the .ijm macro file from this repository into the small FIJI window, in turn the macro editor will open.
- Click run in the macro editor and follow the instructions and prompts by the macro.

