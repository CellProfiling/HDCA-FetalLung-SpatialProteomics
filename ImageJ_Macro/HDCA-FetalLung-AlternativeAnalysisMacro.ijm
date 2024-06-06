/**
 * This macro has been written within the Lundberg lab by Jan N. Hansen, jan.hansen@scilifelab.se, in May 2024.
 * All rights reserved.
 * 
 * This program is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

// EVERYTHING IN THIS SCRIPT IS FULLY AUTOMATED, JUST PRESS "Run"
path = File.getDefaultDir;
acta2 = 3;
cd144 = 17;
cd45 = 20;

Dialog.create("ARTERY CLOSE IMMUNE CELL ANALYSIS");
Dialog.addHelp("https://github.com/CellProfiling/");

Dialog.setInsets(0, 0, 0);
Dialog.addMessage("This macro was developed within the CellProfiling / Lundberg group.");
Dialog.setInsets(-5, 0, 0);
Dialog.addMessage("Github repository for submitting issues and updates: https://github.com/CellProfiling/");
Dialog.setInsets(10, 0, 0);
Dialog.addString("Filepath where output files shall be saved", path, 40);
Dialog.setInsets(-5, 0, 0);
Dialog.addMessage("Note that outputfiles are named as <inputfilename>_<filetype>");
Dialog.addMessage("Note that already existing files with same name in this directory will be overwritten");

Dialog.setInsets(10, 0, 0);
Dialog.addNumber("ACTA2 Slice nr (>0)", acta2);
Dialog.addNumber("CD144 Slice nr (>0)", cd144);
Dialog.addNumber("CD45 Slice nr (>0)", cd45);

Dialog.show();

path = Dialog.getString();
acta2 = Dialog.getNumber();
cd144 = Dialog.getNumber();
cd45 = Dialog.getNumber();


// Fetch image name and remove file name ending
imagename = getTitle();
imagename = substring(imagename, 0, indexOf(imagename, ".tif"));

setOption("BlackBackground", true);

//Clear ROIManager
roiManager("reset");

// CREATE ALL KINDS OF MASKS

//Ask the user to draw region of interest and save it
selectImage(imagename + ".tif");
waitForUser("ACTION REQUIRED","Please encircle the tissue region to be analyzed");
roiManager("add");
roiManager("Select", roiManager("count")-1);
roiManager("Save", path + imagename + "_UserSelection.roi");

// Duplicate CD144 channel
selectImage(imagename + ".tif");
run("Select None");
run("Duplicate...", "duplicate channels=" + cd144);

// Blur CD144 channel and create a mask using Triangle threshold algorithm
selectImage(imagename + "-1.tif");
run("Gaussian Blur...", "sigma=4");
resetMinAndMax();
roiManager("Select", roiManager("count")-1);
setAutoThreshold("Triangle dark no-reset");
run("Convert to Mask");
//run("16-bit");
//setMinAndMax(0, 512);

// Duplicate ACTA2 channel
selectImage(imagename + ".tif");
run("Duplicate...", "duplicate channels=" + acta2);

// Blur ACTA2 channel and create a mask using Triangle threshold algorithm
selectImage(imagename + "-2.tif");
run("Gaussian Blur...", "sigma=4");
resetMinAndMax();
roiManager("Select", roiManager("count")-1);
setAutoThreshold("Triangle dark no-reset");
run("Convert to Mask");
//run("16-bit");
//setMinAndMax(0, 512);
run("Maximum...", "radius=5"); //20

// Duplicate CD45 channel
selectImage(imagename + ".tif");
run("Select None");
roiManager("Show None");
run("Duplicate...", "duplicate channels=" + cd45);

// Subtract channel Background in CD45 channel (=Immune cells), blur, and create a mask using Triangle threshold algorithm
selectImage(imagename + "-3.tif");
run("Subtract Background...", "rolling=50");
run("Gaussian Blur...", "sigma=2");
resetMinAndMax();
roiManager("Select", roiManager("count")-1);
setAutoThreshold("Triangle dark no-reset");
run("Convert to Mask");
run("8-bit");

// MOVE ON WITH PROCESSING ALL MASKS
// Combine CD144 and ACTA2 to get regions that represent arterires
imageCalculator("AND create", imagename + "-1.tif", imagename + "-2.tif");
selectImage("Result of " + imagename + "-1.tif");

// Detect and filter out particles that are too small
setOption("ScaleConversions", true);
run("8-bit");
roiManager("Select", roiManager("count")-1); //Add the mask drawn by user to limit what is detected
run("Analyze Particles...", "size=2000-Infinity show=Masks clear include");

// Allow custom edits
selectImage("Mask of Result of " + imagename + "-1.tif");
waitForUser("ACTION REQUIRED","Please customize the mask if needed!\nRemove or draw and add particles.\nTo remove particles, enncircle particles and press DEL.\nTo add particles, draw a ROI for the particle and press F on the keyboard.\nConfirm when done.");
selectImage("Mask of Result of " + imagename + "-1.tif");
saveAs("Tiff", path + imagename + "_CustomizedCD144AndACTA2Selection.tif");

// Find ACTA2 particles with overlap to comnbined mask to get the originally "big" masks circumscribing ACTA2 and CD144 signals (Arteries)
// Filter all ACTA2 particles and delete if they are not overlapping with the filtered data
selectImage(imagename + "-2.tif");
run("8-bit");
run("Analyze Particles...", "size=0-Infinity show=Nothing clear add");
run("Clear Results");
nR = roiManager("count");
selectImage(imagename + "_CustomizedCD144AndACTA2Selection.tif");
for (i = nR-1; i >= 0; i--) {
	roiManager("Select", i);
	run("Measure");
	//print(nResults + ": mean: " + getResultString("Mean", nResults-1));
	if("0" == getResultString("Mean", nResults-1)){
		roiManager("delete");
	}
}

//Create a new image to write the kept particle into a mask
selectImage(imagename + "-1.tif");
run("Select None");
roiManager("Show None");
run("Duplicate...", " ");
selectImage(imagename + "-1-1.tif");
run("Select All");
setBackgroundColor(0, 0, 0);
run("Clear", "slice");

nR = roiManager("count");
for (i = nR-1; i >= 0; i--) {
	roiManager("Select", i);
	roiManager("Save", path + imagename + "_Arteries_"+i+".roi");
	setForegroundColor(255, 255, 255);
	run("Fill", "slice");
}
run("Select None");
roiManager("Show None");

// Allow to customize the detected arteries
selectImage(imagename + "-1-1.tif");
rename(imagename + "_CustomizedArterieMask.tif");
waitForUser("ACTION REQUIRED","Please customize the detected arteries if needed!\nRemove false positive arteries by enncircling them and press DEL.\nConfirm dialog when you are done");
rename(imagename + "_CustomizedArterieMask.tif");
saveAs("Tiff", path + imagename + "_CustomizedArterieMask.tif");


//Enlarge the mask of particles to be considered arteries by 80 px to include closeby immune cells
//80 px corresponds to approximately 40 micron in our case
selectImage(imagename + "_CustomizedArterieMask.tif");
run("Maximum...", "radius=80");

// NEXT CREATE MASKS FOR IMMUNE CELLS IN PROXIMITY
// THis requires that we load the original ROI that the user selected and clear anything outside of the roi
roiManager("Open", path + imagename + "_UserSelection.roi");

// Create mask for immune cells in proximity
imageCalculator("AND create", imagename + "_CustomizedArterieMask.tif", imagename + "-3.tif");
selectImage("Result of " + imagename + "_CustomizedArterieMask.tif");
rename("Mask_CloseCells.tif");
roiManager("Select", roiManager("count")-1); // Select user mask
run("Clear Outside");

// Create mask for immune cells in distance
selectImage(imagename + "_CustomizedArterieMask.tif");
run("Invert");
imageCalculator("AND create", imagename + "_CustomizedArterieMask.tif", imagename + "-3.tif");
selectImage("Result of " + imagename + "_CustomizedArterieMask.tif");
rename("Mask_DistantCells.tif");
roiManager("Select", roiManager("count")-1); // Select user mask
run("Clear Outside");

// Clean up
selectImage(imagename + "-1.tif");
close();
selectImage(imagename + "-2.tif");
close();
selectImage(imagename + "-3.tif");
close();
selectImage("Result of " + imagename + "-1.tif");
close();
selectImage(imagename + "_CustomizedArterieMask.tif");
close();
selectImage(imagename + "_CustomizedCD144AndACTA2Selection.tif");
close();

// Measure intensities for distant cells - Create ROI
selectImage("Mask_DistantCells.tif");
run("Create Selection");
roiManager("Add");
roiManager("Select", roiManager("count")-1);
roiManager("Save", path + imagename + "_ArtDistantImmune.roi");
// Measure
run("Set Measurements...", "area mean standard min bounding integrated median stack redirect=None decimal=3");
run("Clear Results");
selectImage(imagename + ".tif");
roiManager("Select", roiManager("count")-1);
roiManager("Multi Measure");
saveAs("Results", path + imagename + "_ArtDistantImmune.csv");

// Measure intensities for close cells
selectImage("Mask_CloseCells.tif");
run("Create Selection");
roiManager("Add");
roiManager("Select", roiManager("count")-1);
roiManager("Save", path + imagename + "_ArtCloseImmune.roi");
// Measure
run("Clear Results");
selectImage(imagename + ".tif");
roiManager("Select", roiManager("count")-1);
roiManager("Multi Measure");
saveAs("Results", path + imagename + "_ArtCloseImmune.csv");

// Clean up
selectImage("Mask_CloseCells.tif");
close();
selectImage("Mask_DistantCells.tif");
close();

selectImage(imagename + ".tif");
run("Select None");
//Close the original image
close();

//Prompt user that done and results are saved
waitForUser("SUCCESS","The measurement is done and files have been automatically saved to:\n" + path);
