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

Stack.setDisplayMode("composite");
Stack.setActiveChannels("010"); // Channel2 green will be dislayed

Dialog.create("Identification of green cells");//instruction for next step/macro
Dialog.addMessage("1. Use the OVAL or FREEHAND SELECTION tool for marking GFP+ cells. \n2. Add them by pressing T to ROI manager. \n3. Once you are done, press button D.");
Dialog.show();

setTool("oval");

}

/////////////////////////////////////////////////////////////
//////////// Detection of double positive signal ////////////
/////////////////////////////////////////////////////////////

macro "cell detection [d]" {
	
image_dir=getDirectory("image");
original_title=getTitle();
original=getImageID(); //orig_image_ID
ROI=image_dir+original_title+"_ROI.zip";
Results=image_dir+original_title+"_1Results.csv";
ResultsLog=image_dir+original_title+"_2Results.csv";	
NewImg=image_dir+original_title+"_NewImg.tif";
CB_binary=image_dir+original_title+"_CB_binary.tif";

ROI_Count=roiManager("count"); //gets the number of rois  
for (roi=0; roi<ROI_Count; roi++) { // loop through the rois    
    roiManager("Select", roi); 
	roiManager("Rename", "Cell"+roi+1); 
}

roiManager("Show All without labels");
roiManager("Save", ROI);
roiManager("deselect");
roiManager("show none");

//////////// Creating of CB binary image ///////////
selectImage(original);
Stack.setChannel(3);
run("Duplicate...","title=[CB_Copy]");
//////////// Set MIN & MAX intensity //////////// 
getStatistics(area, mean, min, max, std, histogram)
max=mean+6*std
min=mean+1*std
setMinAndMax(min, max);
run("8-bit");
run("Gaussian Blur...", "sigma=2");
run("Auto Threshold", "method=Default white");
run("Watershed");


selectWindow("CB_Copy");
roiManager("Measure");
k=RoiManager.size;
DoublePositive_Count=0
for (i = 0; i < k; i++) {  
Measurement1=getResult("Mean", i);
if(Measurement1>40){ // criteria for overlap
DoublePositive_Count=DoublePositive_Count+1;
}
}
saveAs("Results", Results);
run("Clear Results");
close("Results");

saveAs("Tiff", CB_binary);
close();

//--------------------------------------------------------------------------------------------

selectImage(original);

Stack.setChannel(3);
getStatistics(area, mean, min, max, std, histogram)
max=mean+6*std
min=mean+0.5*std
setMinAndMax(min, max);

Stack.setDisplayMode("composite");
Stack.setActiveChannels("111"); // all channnels

roiManager("deselect");
roiManager("show none");

selectImage(original);
saveAs("Tiff", NewImg);


roiManager("Show All without labels");

//-------------- Print Results to Log window and save as .csv --------------

print("Image title, #GFP+ cells, #CB_Double positive");
print(original_title+", "+ROI_Count+", "+DoublePositive_Count);

string = getInfo("log");
File.saveString(string, ResultsLog);

}
}
