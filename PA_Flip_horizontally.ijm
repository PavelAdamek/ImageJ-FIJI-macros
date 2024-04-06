//Flip all images horizontally

macro "PA_FlipAllImagesHORIZONTALLY [h]"{

for (i=0;i<nImages;i++) 
	{
        selectImage(i+1);             
        run("Flip Horizontally");
	 } 

}
