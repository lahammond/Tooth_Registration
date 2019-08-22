// Tooth Alignment Tool
 
// Author: 	Luke Hammond (lh2881@columbia.edu)
// Cellular Imaging | Zuckerman Institute, Columbia University
// Date:	18th January 2019
//	
//	This macro rescales and registers tooth data from different modalities using line ROI registration.
// 	
// 			
// 	Usage:
//		1. Run on folder containing four folders: AF, CRP, DMP, Annotated
//		2. 

// Updates:
// 

// Initialization

run("Options...", "iterations=3 count=1 edm=Overwrite");
run("Set Measurements...", "fit redirect=None decimal=3");
run("Colors...", "foreground=white background=black selection=yellow");
run("Clear Results"); 


// Select input directories

#@ File[] listOfPaths(label="select files or folders", style="both")

print("\\Clear");
print("\\Update0:Reformatting tooth images...");
setBatchMode(true);

for (FolderNum=0; FolderNum<listOfPaths.length; FolderNum++) {
	
	inputdir=listOfPaths[FolderNum];
	
	if (File.exists(inputdir)) {
    	if (File.isDirectory(inputdir) == 0) {
        	print(input + "Is a file, please select only directories containing tooth datasets");
        } else {
        	starttime = getTime();
        	print("\\Update2:Processing folder "+FolderNum+1+": " + inputdir + " ");
        	
        	input = inputdir + "/";

			File.mkdir(input + "Exported_TIF");
        	TIF_out = input + "Exported_TIF/";
			
								
        	files = getFileList(input);	
			files = ImageFilesOnlyArray(files);		
			files = Array.sort( files );

			for(i=0; i<files.length; i++) {				
				image = files[i];					
				print("\\Update4:   Processing image " + (i+1) +" of " + files.length +".");
					
						
				run("Bio-Formats Importer", "open=[" + input + image + "] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
				
				rawfilename =  getTitle();
				newtitle = tif_title(rawfilename);
				getDimensions(dummy, dummy, dummy, currentslices, dummy);
				
				if (currentslices != 1) {
					rename("3DImage");
					run("Z Project...", "projection=[Max Intensity]");
					selectWindow("3DImage");
					close();
					selectWindow("MAX_3DImage");	
				}
				
				
				save(TIF_out + newtitle);
				close();
			}
			print("\\Update4:   Processing images -- Complete!");
				
        
			endtime = getTime();
			dif = (endtime-starttime)/1000;
			print("\\Update6:Processing time =", (dif/60), "minutes");
			
			
			selectWindow("Log");
			saveAs("txt", input+"/Convert_to_2d_Tif_Log.txt");

        }
	}
}


function sorted_image_array(folder) {
	sortedimages = getFileList(folder);	
	sortedimages = ImageFilesOnlyArray(sortedimages);		
	sortedimages = Array.sort( sortedimages );
	return sortedimages;
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
			
        	
function DeleteDir(Dir){
	listDir = getFileList(Dir);
  	//for (j=0; j<listDir.length; j++)
      //print(listDir[j]+": "+File.length(myDir+list[i])+"  "+File. dateLastModified(myDir+list[i]));
 // Delete the files and the directory
	for (j=0; j<listDir.length; j++)
		ok = File.delete(Dir+listDir[j]);
	ok = File.delete(Dir);
	if (File.exists(Dir))
	    print("\\Update13: Unable to delete temporary directory"+ Dir +".");
	else
	    print("\\Update13: Temporary directory "+ Dir +" and files successfully deleted.");
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

function NumberedArray(maxnum) {
	//use to create a numbered array from 1 to maxnum, returns numarr
	//e.g. ChArray = NumberedArray(ChNum);
	numarr = newArray(maxnum);
	for (i=0; i<numarr.length; i++){
		numarr[i] = (i+1);
	}
	return numarr;
}

function closewindow(windowname) {
	if (isOpen(windowname)) { 
      		 selectWindow(windowname); 
       		run("Close"); 
  		} 

  		
}

function tif_title(imagename){
	new = split(imagename, "/");
	if (new.length > 1) {
		imagename = new[new.length-1];
	} 
	nl=lengthOf(imagename);
	nl2=nl-3;
	Sub_Title=substring(imagename,0,nl2);
	Sub_Title = replace(Sub_Title, "(", "_");
	Sub_Title = replace(Sub_Title, ")", "_");
	Sub_Title = replace(Sub_Title, "-", "_");
	Sub_Title = replace(Sub_Title, "+", "_");
	Sub_Title = replace(Sub_Title, " ", "_");
	Sub_Title = replace(Sub_Title, "%", "_");
	Sub_Title = replace(Sub_Title, "&", "_");
	Sub_Title=Sub_Title+"tif";
	return Sub_Title;
}