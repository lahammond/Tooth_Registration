// Fluorescence tooth flipper
 
// Author: 	Luke Hammond (lh2881@columbia.edu)
// Cellular Imaging | Zuckerman Institute, Columbia University
// Date:	22nd January 2019
//	
//	This macro horizontally flips tooth section images.
// 			

// Initialization
starttime = getTime();
run("Clear Results"); 

Dialog.create("Tooth Image Flipper");

Dialog.addString("Which Annotated tooth images require Horizontal flipping?", "1,2,3");
Dialog.addString("Which DMP tooth images require Horizontal flipping?", "");

Dialog.show();

AnFlipNo = Dialog.getString();
DMPFlipNo = Dialog.getString();

// Preparation
input = getDirectory("Input directory");
print("\\Clear");
print("\\Update0:Tooth image flipper running:");
setBatchMode(true);

// List preparation

AnFlipIdx = num2array(AnFlipNo,",");
DMPFlipIdx = num2array(DMPFlipNo,",");

print("\\Update1:Horizontally flipping Annotated tooth images:");
Array.print(AnFlipIdx);
print("\\Update3:Horizontally flipping DMP tooth images:");
Array.print(DMPFlipIdx);

print("\\Update4:-------------------------------------");


Annotated_images = input + "Annotated/";
DMP_out = input + "Processed/DMP/";
CRP_out = input + "Processed/CRP/";
AF_out = input + "Processed/AF/";
Preview_out = input + "Preview/";

// Process Annotated Images
files = getFileList(Annotated_images);
files = Array.sort( files );
for(i=0; i<AnFlipIdx.length; i++) {				
	image = files[AnFlipIdx[i]-1];	
	print("\\Update6:Processing annotated image " + (AnFlipIdx[i]) +" of " + files.length +".");
	open(Annotated_images + image);
	ok = File.delete(Annotated_images + image);
	run("Flip Horizontally");
	saveAs("Tiff", Annotated_images + image);
	close();
}

// Process DMP Files
files = getFileList(DMP_out);
files = Array.sort( files );
for(i=0; i<DMPFlipIdx.length; i++) {				
	image = files[DMPFlipIdx[i]-1];	
	print("\\Update6: Processing DMP image " + (DMPFlipIdx[i]) +" of " + files.length +".");
	open(DMP_out + image);
	ok = File.delete(DMP_out + image);
	run("Flip Horizontally");
	saveAs("Tiff", DMP_out + image);
	close();

}
run("Collect Garbage");

		
midendtime = getTime();
middif = (midendtime-starttime)/1000;
print("\\Update7:Tooth image flipping complete. Processing time =", (middif/60), "minutes. ");

// Recreate montage and preview

DeleteDir(input +"Preview/");
File.mkdir(input + "Preview");

print("\\Update8: Recreating scaled down images for checking tooth image quality and orientation.");
//setBatchMode(false);
run("Collect Garbage");

annfiles = sorted_image_array(Annotated_images);	
AFfiles = sorted_image_array(AF_out);
CRPfiles = sorted_image_array(CRP_out);	
DMPfiles = sorted_image_array(DMP_out);


for(i=0; i<annfiles.length; i++) {				
	print("\\Update9:   Processing preview image " + (i+1) +" of " + files.length +".");
	image = annfiles[i];	
									
	open(Annotated_images + image);
	rename("annotated");
	rescale300x300();

	image = AFfiles[i];	
									
	open(AF_out + image);
	rename("AF");
	rescale300x300();
	run("Enhance Contrast", "saturated=0.9");
	getMinAndMax(min, max);
	setMinAndMax(90, max);
	run("RGB Color");

	image = CRPfiles[i];	
									
	open(CRP_out + image);
	rename("CRP");
	rescale300x300();
	run("Enhance Contrast", "saturated=0.35");
	getMinAndMax(min, max);
	setMinAndMax(90, max);
	run("RGB Color");

	image = DMPfiles[i];	
									
	open(DMP_out + image);
	rename("DMP");
	rescale300x300();
	run("Enhance Contrast", "saturated=0.35");
	getMinAndMax(min, max);
	setMinAndMax(1, max);
	run("RGB Color");

	run("Images to Stack", "name=Stack title=[] use");
	run("Make Montage...", "columns=4 rows=1 scale=1  label");
	closewindow("Stack");
	save(Preview_out + (1000+i) + ".tif");
	close();
	
}



run("Collect Garbage");



endtime = getTime();
dif = (endtime-midendtime)/1000;
print("\\Update9: Tooth preivew montages complete. Generation time =", (dif/60), "minutes");

print("\\Update10:------------------------------------------------------------------------");
selectWindow("Log");
saveAs("txt", input+"/Tooth_Flipper_Log.txt");







function NumberedArray(maxnum) {
	//use to create a numbered array from 1 to maxnum, returns numarr
	//e.g. ChArray = NumberedArray(ChNum);
	numarr = newArray(maxnum);
	for (i=0; i<numarr.length; i++){
		numarr[i] = (i+1);
	}
	return numarr;
}



function DeleteDir(Dir){
	listDir = getFileList(Dir);
  	//for (j=0; j<listDir.length; j++)
      //print(listDir[j]+": "+File.length(myDir+list[i])+"  "+File. dateLastModified(myDir+list[i]));
 // Delete the files and the directory
	for (j=0; j<listDir.length; j++)
		ok = File.delete(Dir+listDir[j]);
	ok = File.delete(Dir);
	//if (File.exists(Dir))
	   // print("\\Update10: Unable to delete temporary directory"+ Dir +".");
	//else
	    //print("\\Update10: Temporary directory "+ Dir +" and files successfully deleted.");
}


function num2array(str,delim){
	arr = split(str,delim);
	for(i=0; i<arr.length;i++) {
		arr[i] = parseInt(arr[i]);
	}

	return arr;
}

function closewindow(windowname) {
	if (isOpen(windowname)) { 
      		 selectWindow(windowname); 
       		run("Close"); 
  		} 

  		
}

function sorted_image_array(folder) {
	sortedimages = getFileList(folder);	
	sortedimages = ImageFilesOnlyArray(sortedimages);		
	sortedimages = Array.sort( sortedimages );
	return sortedimages;
}	

function ImageFilesOnlyArray (arr) {
	//pass array from getFileList through this e.g. NEWARRAY = ImageFilesOnlyArray(NEWARRAY);
	setOption("ExpandableArrays", true);
	f=0;
	files = newArray;
	for (i = 0; i < arr.length; i++) {
		if(endsWith(arr[i], ".tif") || endsWith(arr[i], ".nd2") || endsWith(arr[i], ".LSM") || endsWith(arr[i], ".czi") || endsWith(arr[i], ".jpg")  || endsWith(arr[i], ".lsm") ) {   //if it's a tiff image add it to the new array
			files[f] = arr[i];
			f = f+1;
		}
	}
	arr = files;
	arr = Array.sort(arr);
	return arr;
}	

function rescale300x300() {
	getDimensions(width, height, channels, slices, frames);
	if (width > height) {
		run("Size...", "width=300 constrain average interpolation=Bilinear");
		run("Canvas Size...", "width=300 height=300 position=Center zero");
	
	} else {
		newwidth = parseInt(width / (height/300));
		run("Size...", "width="+ newwidth +" constrain average interpolation=Bilinear");
		run("Canvas Size...", "width=300 height=300 position=Center zero");	
	}
}