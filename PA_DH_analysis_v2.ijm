// Sets the display range of the active image MIN / MAX.

macro "Set intensity MIN-...[u]" {

	getMinAndMax(min, max)
	setMinAndMax(min-20, max);
    }
   
macro "Set intensity MIN+...[i]" {

	getMinAndMax(min, max)
	setMinAndMax(min+20, max);
    }

macro "Set intensity Max-...[o]" {

	getMinAndMax(min, max)
    setMinAndMax(min, max-20);
    }
    
macro "Set intensity Max+...[p]" {

	getMinAndMax(min, max)
    setMinAndMax(min, max+20);
    }

////////////////////////////////////////////////////////////
//////////// Preselection of cells - GFP signal ////////////
////////////////////////////////////////////////////////////

macro "PA_DH_analysis_1 [a]"{

/// Open Channels and B&C windows for posible manual adjustment ///

roiManager("reset") // It reset ROI manager after previous session...

print("If Log not open, open it"); // This will close/reset Log window - importatnt for next images...
selectWindow("Log");
run("Close" );

run("Channels Tool..."); 
run("Brightness/Contrast...");

image_dir=getDirectory("image");
original_title=getTitle();
original_img=getImageID(); //orig_image_ID

Stack.setChannel(2); // select green channel

//////////// Set MIN & MAX intensity //////////// 
getStatistics(area, mean, min, max, std, histogram)
max=mean+6*std
min=mean+0.5*std
setMinAndMax(min, max);

run("Duplicate...", "title=CellCopy_GFP");
run("8-bit");
run("Gaussian Blur...", "sigma=2");
run("Auto Threshold", "method=MaxEntropy white");
run("Watershed");
run("Analyze Particles...", "size=100-1000 add");

selectImage("CellCopy_GFP");
run("Close");

//////////// Show all ROIs in original image ////////////
selectImage(original_img);
roiManager("deselect");
roiManager("show none");
roiManager("show all");

//////////// Measure DAPI signal for ROI exclusion ///////////////

Stack.setChannel(3);
dapi=getValue("Median");
roiManager("Measure");
k=RoiManager.size;
for (i = 0; i < k; i++) {
Measurement1=getResult("Median", (i));
if(Measurement1<dapi){
roiManager("select", (i));
//Roi.setStrokeColor("red") //if active, ROIs without DAPI will be red
roiManager("delete"); // this delete "cells" without nucleus (ROIs with DAPI intensity below median intensity) 
}
}
close("Results");

roiManager("deselect");
roiManager("show none");
roiManager("show all");

//Stack.setChannel(2); // it will bring the final immage to green active channel - important, because in this channel will be changed ROIs of cells
Stack.setDisplayMode("composite");
Stack.setActiveChannels("0110"); // Channel2 green & Channel3 DAPI will be dislayed

Dialog.create("Preselection of Chrna3+ cells");//instruction for next manual steps
Dialog.addMessage("1. Check preselected cells. \n2. Select and delete FALSE POSITIVE detections. \n3. Use the OVAL tool or FREEHAND SELECTION tool for marking non-recognized cell and press button T to add it in ROI list.\n \n4. IMPORTANT !!! Once the excluding/including of cells is done, press button D to proceed next step - laminae identification...");
Dialog.show();

}

//////////////////////////////////////////////////////////////////////////////////////////
//////////// Rename Cell ROIs and continue to laminae identification ///////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

macro "Rename_ROI_and_lamina_identification [d]" {

ROI_Count=roiManager("count"); //gets the number of rois  
for (roi=0; roi<ROI_Count; roi++) { // loop through the rois    
    roiManager("Select", roi); 
	roiManager("Rename", "Cell"+roi+1); 
}

roiManager("deselect");
roiManager("show none");
roiManager("Show All without labels");

//------- Dislay composite img & instrucitons for next step --------
Stack.setDisplayMode("composite");
Stack.setActiveChannels("1101"); // for better visibility of lamina II and III

Dialog.create("Identification of lamina II");//instruction for next step/macro
Dialog.addMessage("1. Use the FREEHAND SELECTION tool for marking the IB4 signal (lamina IIo). \n \n2. IMPORTANT !!! Mark laminae carefully and DON'T CROSS the cell. Otherwise, the cell won't be analyzed. All cells need to be in some lamina (this is valid for all following steps). \n \n3. Once you are done, press button F.");
Dialog.show();

}

////////////////////////////////////////////////////////////
//////////// Detection of laminae //////////////////////////
////////////////////////////////////////////////////////////

macro "Detect_Lamina_IIo_IB4 [f]" {
	
Stack.setDisplayMode("composite");
Stack.setActiveChannels("1101"); // for better visibility of lamina II and III
	
roiManager("Add");
IB4_index=roiManager("count")-1; // this identify new lamina
roiManager("Select", IB4_index);
roiManager("Rename", "Lam_IIo_IB4");

Dialog.create("Identification of lamina IIi");//instruction for next step/macro
Dialog.addMessage("1. Use the FREEHAND SELECTION tool for marking PKCgamma signal (lamina IIi). \n2. Once you are done, press button G.");
Dialog.show();

}

////////////////////////////////////////////////////////////
macro "Detect_Lamina_IIi_PKCgamma [g]" {

roiManager("Add");
PKC_index=roiManager("count")-1; // this identify new lamina
roiManager("Select", PKC_index);
roiManager("Rename", "Lam_IIi_PKC");

Dialog.create("Identification of lamina I");//instruction for next step/macro
Dialog.addMessage("1. Use the FREEHAND SELECTION tool for marking lamina I. \n2. Once you are done, press button H.");
Dialog.show();

}

////////////////////////////////////////////////////////////
macro "Detect_Lamina_I [h]" {

roiManager("Add");
LamI_index=roiManager("count")-1; // this identify new lamina
roiManager("Select", LamI_index);
roiManager("Rename", "Lam_I");

Dialog.create("Identification of lamina III to V");//instruction for next step/macro
Dialog.addMessage("1. Use the FREEHAND SELECTION tool for marking lamina IV and V. \n2. Once you are done, press button J. \n3. All ROIs will be saved automatically.");
Dialog.show();

}

////////////////////////////////////////////////////////////
macro "Detect_Lamina_III-V [j]" {
	
image_dir=getDirectory("image");
original_title=getTitle();
original_img=getImageID(); //orig_image_ID
ROI=image_dir+original_title+"_ROI.zip";

roiManager("Add");
LamIIItodV_index=roiManager("count")-1; // this identify new lamina
roiManager("Select", LamIIItodV_index);
roiManager("Rename", "Lam_IIItoV");

roiManager("Save", ROI);

Dialog.create("Continue to analysis");//instruction for next step/macro
Dialog.addMessage("Press button R to start count of the cells in different laminae.");
Dialog.show();

}

///////////////////////////////////////////////////////////////////////////////////////////
//////// Final step - getting results based on the overlaped ROIs and Masks ///////////////
///////////////////////////////////////////////////////////////////////////////////////////

macro "FourColourMask [r]" {
	
image_dir=getDirectory("image");
original_title=getTitle();
original_img=getImageID(); //orig_image_ID
ResultsLog=image_dir+original_title+"_Results.csv";	

setBatchMode("hide");

//run("Duplicate...", "title=Mask");
	
RoiManager.selectByName("Lam_I");
run("Create Mask");
rename("Lam_IMask");
roiManager("deselect");
roiManager("show none");
roiManager("Show All without labels");
roiManager("Measure");
selectWindow("Lam_IMask");
close();

k=RoiManager.size;
LamICount=0

for (i = 0; i < (k-4); i++) {  // k - 4 to exclude laminae ROIs in the end of the list
Measurement1=getResult("Mean", i);
//if(Measurement1==255){
if(Measurement1>127.5){  // this decreasing include the cell also in case, that is partly crossed by lamina ROI
LamICount=LamICount+1;
}
}

run("Clear Results");

//--------------------------------------------------------------------------------------------

RoiManager.selectByName("Lam_IIo_IB4");
run("Create Mask");
rename("Lam_IIo_IB4Mask");
roiManager("deselect");
roiManager("show none");
roiManager("Show All without labels");
roiManager("Measure");
selectWindow("Lam_IIo_IB4Mask");
close();
k=RoiManager.size;
LamIIoCount=0
for (i = 0; i < (k-4); i++) {  // k - 4 to exclude laminae ROIs in the end of the list
Measurement1=getResult("Mean", i);
//if(Measurement1==255){
if(Measurement1>127.5){  // this decreasing include the cell also in case, that is partly crossed by lamina ROI
LamIIoCount=LamIIoCount+1;
}
}
run("Clear Results");
//--------------------------------------------------------------------------------------------

RoiManager.selectByName("Lam_IIi_PKC");
run("Create Mask");
rename("Lam_IIi_PKCMask");
roiManager("deselect");
roiManager("show none");
roiManager("Show All without labels");
roiManager("Measure");
selectWindow("Lam_IIi_PKCMask");
close();

k=RoiManager.size;
LamIIiCount=0
for (i = 0; i < (k-4); i++) {  // k - 4 to exclude laminae ROIs in the end of the list
Measurement1=getResult("Mean", i);
//if(Measurement1==255){
if(Measurement1>127.5){  // this decreasing include the cell also in case, that is partly crossed by lamina ROI
LamIIiCount=LamIIiCount+1;
}
}
run("Clear Results");
//--------------------------------------------------------------------------------------------

RoiManager.selectByName("Lam_IIItoV");
run("Create Mask");
rename("Lam_IIItoVMask");
roiManager("deselect");
roiManager("show none");
roiManager("Show All without labels");
roiManager("Measure");
selectWindow("Lam_IIItoVMask");
close();


k=RoiManager.size;
LamIIICount=0
for (i = 0; i < (k-4); i++) {  // k - 4 to exclude laminae ROIs in the end of the list
Measurement1=getResult("Mean", i);
//if(Measurement1==255){
if(Measurement1>127.5){  // this decreasing include the cell also in case, that is partly crossed by lamina ROI
LamIIICount=LamIIICount+1;
}
}
run("Clear Results");
close("Results");

setBatchMode("show");

//--------------------------------------------------------------------------------------------
selectImage(original_img);
Stack.setDisplayMode("composite");
Stack.setActiveChannels("1111"); //("1111") for four channnel image

roiManager("deselect");
roiManager("show none");
roiManager("Show All without labels");

//-------------- Print Results to Log window and save as .csv --------------

print("Image title:, Lam_I, Lam_IIo, Lam_IIi, Lam_III-V");
print(original_title+",	"+LamICount+", "+LamIIoCount+", "+LamIIiCount+", "+LamIIICount);

string = getInfo("log");
File.saveString(string, ResultsLog);

}

//--------------------- END ---------------------

