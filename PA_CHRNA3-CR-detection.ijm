////////////////////////////////////////////////////////////
//////////// GFP + Calretinin detection ////////////////////
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
original=getImageID(); //orig_image_ID


//////////// Set MIN & MAX intensity //////////// 
Stack.setChannel(1);
getStatistics(area, mean, min, max, std, histogram)
max=mean+6*std
min=mean+0.5*std
setMinAndMax(min, max);

Stack.setChannel(2);
getStatistics(area, mean, min, max, std, histogram)
max=mean+6*std
min=mean+0.5*std
setMinAndMax(min, max);

Stack.setChannel(3);
getStatistics(area, mean, min, max, std, histogram)
max=mean+6*std
min=mean+0.5*std
setMinAndMax(min, max);

Stack.setChannel(4);
getStatistics(area, mean, min, max, std, histogram)
max=mean+6*std
min=mean+0.5*std
setMinAndMax(min, max);

Stack.setDisplayMode("composite");
Stack.setActiveChannels("1100"); // red and green will be dislayed

Dialog.create("Identification of green cells");//instruction for next step/macro
Dialog.addMessage("1. Use the OVAL or FREEHAND SELECTION tool for marking GFP+ cells. \n2. Add them by pressing T to ROI manager. \n3. Once you are done, press button D.");
Dialog.show();

setTool("oval");

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

Stack.setDisplayMode("composite");
Stack.setActiveChannels("1110"); // for better visibility of lamina II and III

Dialog.create("Identification of lamina II");//instruction for next step/macro
Dialog.addMessage("1. Use the FREEHAND SELECTION tool for marking the IB4 signal (lamina IIo). \n \n2. Once you are done, press button F.");
Dialog.show();

}


////////////////////////////////////////////////////////////
//////////// Detection of laminae //////////////////////////
////////////////////////////////////////////////////////////

macro "Detect_Lamina_IIo_IB4 [f]" {
	
Stack.setDisplayMode("composite");
Stack.setActiveChannels("1110"); // for better visibility of lamina II and III
	
roiManager("Add");
IB4_index=roiManager("count")-1; // this identify new lamina
roiManager("Select", IB4_index);
roiManager("Rename", "Lam_IIo_IB4");

Dialog.create("Identification of deeper laminae");//instruction for next step/macro
Dialog.addMessage("1. Use the FREEHAND SELECTION tool for marking deeper laminae (lamina IIi). \n2. Once you are done, press button G.");
Dialog.show();

}

////////////////////////////////////////////////////////////
macro "Detect_deeper_Laminae [g]" {

roiManager("Add");
Deep_index=roiManager("count")-1; // this identify new lamina
roiManager("Select", Deep_index);
roiManager("Rename", "Lam_Deep");

Dialog.create("Identification of lamina I");//instruction for next step/macro
Dialog.addMessage("1. Use the FREEHAND SELECTION tool for marking lamina I. \n2. Once you are done, press button H.");
Dialog.show();

}

////////////////////////////////////////////////////////////
macro "Detect_Lamina_I [h]" {
	
image_dir=getDirectory("image");
original_title=getTitle();
original=getImageID(); //orig_image_ID
ROI=image_dir+original_title+"_ROI.zip";	

roiManager("Add");
LamI_index=roiManager("count")-1; // this identify new lamina
roiManager("Select", LamI_index);
roiManager("Rename", "Lam_I");

roiManager("Save", ROI);

Dialog.create("Continue to analysis");//instruction for next step/macro
Dialog.addMessage("Press button R to start count of the cells in different laminae.");
Dialog.show();

}


///////////////////////////////////////////////////////////////////////////////////////////
//////// Final step - getting results based on the overlaped ROIs and Masks ///////////////
///////////////////////////////////////////////////////////////////////////////////////////

macro "ThreeColourMask [r]" {
	
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

for (i = 0; i < (k-3); i++) {  // k - 3 to exclude laminae ROIs in the end of the list
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
for (i = 0; i < (k-3); i++) {  // k - 3 to exclude laminae ROIs in the end of the list
Measurement1=getResult("Mean", i);
//if(Measurement1==255){
if(Measurement1>127.5){  // this decreasing include the cell also in case, that is partly crossed by lamina ROI
LamIIoCount=LamIIoCount+1;
}
}
run("Clear Results");

//--------------------------------------------------------------------------------------------

RoiManager.selectByName("Lam_Deep");
run("Create Mask");
rename("Lam_Deep_Mask");
roiManager("deselect");
roiManager("show none");
roiManager("Show All without labels");
roiManager("Measure");
selectWindow("Lam_Deep_Mask");
close();


k=RoiManager.size;
LamDeepCount=0
for (i = 0; i < (k-3); i++) {  // k - 3 to exclude laminae ROIs in the end of the list
Measurement1=getResult("Mean", i);
//if(Measurement1==255){
if(Measurement1>127.5){  // this decreasing include the cell also in case, that is partly crossed by lamina ROI
LamDeepCount=LamDeepCount+1;
}
}
run("Clear Results");
close("Results");

setBatchMode("show");

//--------------------------------------------------------------------------------------------
selectImage(original_img);
Stack.setDisplayMode("composite");
Stack.setActiveChannels("1110"); //("1110") for four channnel image

roiManager("deselect");
roiManager("show none");
roiManager("Show All without labels");

//-------------- Print Results to Log window and save as .csv --------------

print("Image title:, Lam_I, Lam_IIo, Deeper_Laminae");
print(original_title+", "+LamICount+", "+LamIIoCount+", "+LamDeepCount);

string = getInfo("log");
File.saveString(string, ResultsLog);

}

//--------------------- END ---------------------



/*
/////////////////////////////////////////////////////////////
//////////// Detection of double positive signal ////////////
/////////////////////////////////////////////////////////////

macro "cell detection [r]" {
	
image_dir=getDirectory("image");
original_title=getTitle();
original=getImageID(); //orig_image_ID
ROI=image_dir+original_title+"_ROI.zip";
Results=image_dir+original_title+"_Results1.csv";
ResultsLog=image_dir+original_title+"_Results2.csv";	
NewImg=image_dir+original_title+"_NewImg.tif";
PAX2_binary=image_dir+original_title+"_PAX2_binary.tif";	



//////////// Creating of PAX2 binary image ///////////
selectImage(original);
Stack.setChannel(1);
run("Duplicate...","title=[PAX2_Copy]");

getStatistics(area, mean, min, max, std, histogram)
max=mean+2*std //// optimized for Calretinin signal
min=mean+2.5*std //// optimized for Calretinin signal
setMinAndMax(min, max);
/// make binary 
run("8-bit");
run("Gaussian Blur...", "sigma=5");
run("Auto Threshold", "method=Default white");
run("Watershed");

selectWindow("PAX2_Copy");
roiManager("Measure");
k=RoiManager.size;
DoublePositive_Count=0
for (i = 0; i < k; i++) {  
Measurement1=getResult("Mean", i);
if(Measurement1>50){ // criteria for overlap
DoublePositive_Count=DoublePositive_Count+1;
}
}
saveAs("Results", Results);
//run("Clear Results");
//close("Results");

saveAs("Tiff", PAX2_binary);
close();

//--------------------------------------------------------------------------------------------

selectImage(original);

Stack.setDisplayMode("composite");
Stack.setActiveChannels("1110"); // all channnels

roiManager("deselect");
roiManager("show none");

selectImage(original);
saveAs("Tiff", NewImg);


roiManager("Show All without labels");

//-------------- Print Results to Log window and save as .csv --------------

print("Image title, #GFP+ cells, #Double positive");
print(original_title+", "+ROI_Count+", "+DoublePositive_Count);

string = getInfo("log");
File.saveString(string, ResultsLog);

}
}
*/

