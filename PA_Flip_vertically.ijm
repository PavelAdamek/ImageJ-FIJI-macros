//Flip all images vertically

macro "FlipAllImagesVERTICALLY [v]"{

for (i=0;i<nImages;i++) 
	{
        selectImage(i+1);             
        run("Flip Vertically");
	 } 

}
