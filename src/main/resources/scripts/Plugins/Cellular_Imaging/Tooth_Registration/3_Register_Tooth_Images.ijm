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
#@ Integer(label="Start at tooth number:", value = 0, style="spinner", description="Leave at 0 to start from beginning.") ToothStart

print("\\Clear");
print("\\Update0:Registering tooth images...");
setBatchMode(true);

ToothStart = ToothStart-1;

for (FolderNum=0; FolderNum<listOfPaths.length; FolderNum++) {
	
	inputdir=listOfPaths[FolderNum];
	
	if (File.exists(inputdir)) {
    	if (File.isDirectory(inputdir) == 0) {
        	print(input + "Is a file, please select only directories containing tooth datasets");
        } else {
        	starttime = getTime();
        	print("\\Update2:Processing folder "+FolderNum+1+": " + inputdir + " ");
        	
        	input = inputdir + "/";
			Annotated_images = input + "Annotated/";

        	File.mkdir(input + "Registered_Preview");
        	Preview_out = input + "Registered_Preview/";
        	File.mkdir(input + "Registered_Full_Res_Merged");
        	FullRes_out = input + "Registered_Full_Res_Merged/";
        	
        	AF_out = input + "Processed/AF/";
        	CRP_out = input + "Processed/CRP/";
        	DMP_out = input + "Processed/DMP/";
        	//Reg_DMP_out = input + "Processed/Registered_DMP/";
			//Reg_Ann_out = input + "Processed/Registered_Annotated/";

			//File.mkdir(input + "Processed/Registered_Annotated");
			//File.mkdir(input + "Processed/Registered_DMP");

        	// List Files
        	annfiles = sorted_image_array(Annotated_images);	
        	AFfiles = sorted_image_array(AF_out);
        	CRPfiles = sorted_image_array(CRP_out);	
        	DMPfiles = sorted_image_array(DMP_out);


 	    	// interate over each tooth
        	
			for (Tooth=ToothStart; Tooth<annfiles.length; Tooth++) {				
				
				// Register Annotated to CRP
				print("\\Update4:Registering tooth number "+Tooth+".");
				
				print("\\Update5: Registering Annotation to CRP image...");
				
				open(Annotated_images + annfiles[Tooth]);
				rename("Annotated");
				setBatchMode("show");
				
				open(CRP_out + CRPfiles[Tooth]);
				rename("CRP");
				
				run("Enhance Contrast", "saturated=0.6");
				run("Grays");
				setBatchMode("show");

				setTool("multipoint");

				waitForUser("Click on corresponding points in both the Annotated and CRP image, the click OK.");


				
				run("Landmark Correspondences", "source_image=Annotated template_image=CRP transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Affine interpolate");

				selectWindow("TransformedAnnotated");
				setBatchMode("show");
				
				run("Duplicate...", "title=[TransformedAnnotated-1]");
				run("16-bit");
				selectWindow("CRP");
				run("Duplicate...", "title=[CRP-1]");
				run("Merge Channels...", "c1=CRP-1 c2=TransformedAnnotated-1 create");
				setSlice(1);
				run("Red");
				setSlice(2);
				run("Green");
				setBatchMode("show");

				
				
				//2nd pass - now 100 loops
				waitForUser("Does the transformation look correct? If not, close both of the transformed images and adjust the corresponding points before clicking OK. Close all images to stop at current tooth.");
				if (isOpen("CRP") == false) {
						print("Registration stopped on tooth: "+Tooth+".");
						exit("Registration stopped. Current tooth: "+Tooth+".");
				}

				for(attempts=1; attempts<100; attempts++) {			
					if (isOpen("TransformedAnnotated") == false) {
						run("Landmark Correspondences", "source_image=Annotated template_image=CRP transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Affine interpolate");				
						selectWindow("TransformedAnnotated");
						setBatchMode("show");
						
						run("Duplicate...", "title=[TransformedAnnotated-1]");
						run("16-bit");
						selectWindow("CRP");
						run("Duplicate...", "title=[CRP-1]");
						run("Merge Channels...", "c1=CRP-1 c2=TransformedAnnotated-1 create");
						setSlice(1);
						run("Red");
						setSlice(2);
						run("Green");
						setBatchMode("show");
						
						waitForUser("Does the transformation look correct? If not, close both of the transformed images and adjust the corresponding points before clicking OK. Close all images to stop at current tooth.");
					} else {
						attempts = 100;
					}
					if (isOpen("CRP") == false) {
						print("Registration stopped on tooth: "+Tooth+1+".");
						exit("Registration stopped. Current tooth is: "+Tooth+1+".");
					}
				}
				
				closewindow("Composite");
				selectWindow("TransformedAnnotated");
				run("16-bit");
				setBatchMode("hide");
				
				//save(Reg_Ann_out + newanntitle);

				closewindow("Annotated");
				
				print("\\Update5: Registering Annotation to CRP image... Complete!");
				
				// Register DMP to CRP...
				print("\\Update6: Registering DMP to CRP image...");
				
				open(DMP_out + DMPfiles[Tooth]);
				rename("DMP");
				run("Enhance Contrast", "saturated=0.6");
				run("Grays");
				setBatchMode("show");

				setTool("multipoint");

				waitForUser("Click on corresponding points in both the DMP and CRP image, the click OK.");


				
				run("Landmark Correspondences", "source_image=DMP template_image=CRP transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Affine interpolate");

				selectWindow("TransformedDMP");
				setBatchMode("show");
				
				run("Duplicate...", "title=[DMP-1]");
				run("16-bit");
				selectWindow("CRP");
				run("Duplicate...", "title=[CRP-1]");
				run("Merge Channels...", "c1=CRP-1 c2=DMP-1 create");
				setSlice(1);
				run("Red");
				setSlice(2);
				run("Green");
				setBatchMode("show");

				
				//2nd pass - edited now 100 loops 
				waitForUser("Does the transformation look correct? If not, close both of the transformed images and adjust the corresponding points before clicking OK. Close all images to stop at current tooth.");
				if (isOpen("CRP") == false) {
						print("Registration stopped on tooth: "+Tooth+".");
						exit("Registration stopped. Current tooth is: "+Tooth+".");
				}

				for(attempts=1; attempts<100; attempts++) {			
					if (isOpen("TransformedDMP") == false) {
						run("Landmark Correspondences", "source_image=DMP template_image=CRP transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Affine interpolate");
						
						selectWindow("TransformedDMP");
						setBatchMode("show");
						
						run("Duplicate...", "title=[DMP-1]");
						run("16-bit");
						selectWindow("CRP");
						run("Duplicate...", "title=[CRP-1]");
						run("Merge Channels...", "c1=CRP-1 c2=DMP-1 create");
						setSlice(1);
						run("Red");
						setSlice(2);
						run("Green");
						setBatchMode("show");
						
						waitForUser("Does the transformation look correct? If not, close both of the transformed images and adjust the corresponding points before clicking OK. Close all images to stop at current tooth.");
					} else {
						attempts = 100;
					}
					if (isOpen("CRP") == false) {
						print("Registration stopped on tooth: "+Tooth+".");
						exit("Registration stopped. Current tooth is: "+Tooth+".");
					}
				}
				closewindow("DMP");
				closewindow("Composite");
				selectWindow("TransformedDMP");
				
				//save(Reg_DMP_out + rawfilename);

				print("\\Update6: Registering DMP to CRP image... Complete!");
				
				print("\\Update8: Saving registered images...");

				open(AF_out + AFfiles[Tooth]);
				rename("AF");
				//selectWindow("TransformedAnnotated");
				//setBatchMode("show");

				
				run("Merge Channels...", "c1=CRP c2=AF c3=TransformedDMP c4=TransformedAnnotated create");
				setSlice(1);
				run("Red");
				setSlice(2);
				run("Green");
				setSlice(3);
				run("Blue");
				setSlice(4);
				run("Grays");
				
				newanntitle = tif_title(annfiles[Tooth]);
				
				save(FullRes_out + newanntitle);//closewindow("TransformedDMP");
				//closewindow("DMP");
				//closewindow("CRP");
				run("Size...", "width=500 constrain average interpolation=Bilinear");
				save(Preview_out + newanntitle);
				close("*");

				print("\\Update8: Saving registered images... Complete!");
								
				
			}


			// Create registered tooth image + previews

			
				
				
				
			}
			
			endtime = getTime();
			dif = (endtime-starttime)/1000;
			print("\\Update9:Processing time =", (dif/60), "minutes");
			
			
			selectWindow("Log");
			saveAs("txt", input+"/Registered_Tooth_Images_Log.txt");

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