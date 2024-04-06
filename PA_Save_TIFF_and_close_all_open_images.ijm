// Save and close all open Image windows
macro "PA_Save_TIFF_and_close_all_open_images"{

// get image IDs of all open images
dir = getDirectory("Choose a Directory");
//ids=newArray(nImages);
for (i=0;i<nImages;i++) {
        selectImage(i+1);
        title = getTitle;
       
        saveAs("tiff", dir+title);
} 
run("Close All");
}