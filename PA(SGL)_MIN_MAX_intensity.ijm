//Set MIN & MAX intensity

macro "Set_MIN_MAX_intensity"{

for (i=0;i<nImages;i++) 
	{
    selectImage(i+1);           
        
	Stack.setChannel(1); // red
	getStatistics(area, mean, min, max, std, histogram);
	max=mean+6*std;
	min=mean+0.5*std;
	setMinAndMax(min, max);
	
	Stack.setChannel(2); // green
	getStatistics(area, mean, min, max, std, histogram);
	max=mean+6*std;
	min=mean+0.5*std;
	setMinAndMax(min, max);
	
	Stack.setChannel(3); // blue
	getStatistics(area, mean, min, max, std, histogram);
	max=mean+6*std;
	min=mean+0.5*std;
	setMinAndMax(min, max);
           
	} 

}
