macro "merge_all_from_folders"{

Dialog.create("Merge 4 channels");
Dialog.addMessage("1. Select the folder that contains images for the red channel.\n2. Select the folder that contains images for the green channel.\n3. Select the folder that contains images for the blue channel. \n4. Select the folder that contains images for the magenta channel.\n5. Select destination folder for composite images. \n \n Click OK to proceed");
Dialog.show();

setBatchMode(true);
i=0
    redfolder= getDirectory("Choose a Directory");
    red= getFileList(redfolder);
    n1=lengthOf(red);

    greenfolder= getDirectory("Choose a Directory");
    green= getFileList(greenfolder); 
    n2=lengthOf(green);

    bluefolder= getDirectory("Choose a Directory");
    blue=getFileList(bluefolder);
    n3=lengthOf(blue);
     
    magentafolder= getDirectory("Choose a Directory");
    magenta=getFileList(magentafolder);

    small = n1;
    if(small<n3)
    small = n3;

destination=getDirectory("Choose Source Directory ");

for (i=0; i<small; i++){

    open(greenfolder+green[i]);
    open(redfolder+red[i]);
    open(bluefolder+blue[i]);
    open(magentafolder+magenta[i]);

channel1=red[i];
channel2=green[i];
channel3=blue[i];
channel6=magenta[i];

run ("Merge Channels...", "c1=&channel1 c2=&channel2 c3=&channel3 c6=&channel6 create");

gehbitteoida="composite"+red[i];
filename=destination+gehbitteoida;

saveAs ("tiff", filename);
close();
}
}
