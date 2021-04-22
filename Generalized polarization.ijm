ScreenClean();

getDateAndTime(year, month, dayofWeek, dayofMonth, hour, minute, second, msec);

file_extension = "tif";


dir = getDirectory("Choose directory");
list = getFileList(dir);


dir1 = dir + " " + year +"." + month + "." + dayofMonth + " " + hour + "." + minute + " - Result\\" ;
File.makeDirectory(dir1);

for (number_of_file = 0; number_of_file<list.length; number_of_file++){
		if (endsWith(list[number_of_file],file_extension) == 1){

			file = dir + list[number_of_file];
			run("Bio-Formats Importer", "open=file autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		
Dialog.create("Select channels");

Stack.getDimensions(width, height, channels, slices, frames);


	if (channels > 1){

		arr_chan=newArray(1);
			arr_chan[0]="1";
			
		for (i=1; i<channels; i++){
			string1 = "";
			string1 = string1 + i+1;
			arr_chan = Array.concat (arr_chan,string1);
		}	
		
		Dialog.addMessage("blue channel");
		Dialog.addChoice("channel", arr_chan);

		Dialog.addMessage("red channel");
		Dialog.addChoice("channel", arr_chan);

Dialog.show();

green_name= "C" + Dialog.getChoice() + "-raw_data";
red_name= "C" + Dialog.getChoice() + "-raw_data";

	//green_chan = Dialog.getChoice();
	//red_chan = Dialog.getChoice();
rename ("raw_data");

run("Split Channels");

selectWindow(green_name);

run("Enhance Contrast...", "saturated=0.0 normalize process_all");
run("32-bit");

run("Enhance Contrast...", "saturated=0.0 normalize process_all");

waitForUser ("measure thresholds");

Dialog.create("Set threshold levels");

Dialog.addNumber("Lower Threshold level", 0);
Dialog.addNumber("Upper Threshold level", 1.00);
Dialog.show();
green_bottom=Dialog.getNumber();
green_top=Dialog.getNumber();

selectWindow(red_name);

run("Enhance Contrast...", "saturated=0.0 normalize process_all");
run("32-bit");

run("Enhance Contrast...", "saturated=0.0 normalize process_all");

waitForUser ("measure thresholds");

Dialog.create("Set threshold levels");

Dialog.addNumber("Lower Threshold level", 0.15);
Dialog.addNumber("Upper Threshold level", 1.00);
Dialog.show();
red_bottom=Dialog.getNumber();
red_top=Dialog.getNumber();
/*
print(red_bottom);
print(red_top);
print(green_bottom);
print(green_top);*/

	}
	number_of_file = list.length;
		}
		
}

ScreenClean();
setBatchMode(true);

for (number_of_file = 0; number_of_file<list.length; number_of_file++){
		if (endsWith(list[number_of_file],file_extension) == 1){
			
//blue_path=File.openDialog("Blue Channel");

//open(blue_path);
			file = dir + list[number_of_file];
			run("Bio-Formats Importer", "open=file autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");


			title=getTitle();
			
			rename ("raw_data");

			run("Split Channels");
			
//run("Rename...", "title=blue");
//blue_ID=getImageID();

selectWindow (green_name);
run("Enhance Contrast...", "saturated=0.0 normalize process_all");
run("32-bit");

run("Enhance Contrast...", "saturated=0.0 normalize process_all");
/*
waitForUser ("measure thresholds");

Dialog.create("Set threshold levels");

Dialog.addNumber("Lower Threshold level", 0.10);
Dialog.addNumber("Upper Threshold level", 1.00);
Dialog.show();
bottom=Dialog.getNumber();
top=Dialog.getNumber();*/


setAutoThreshold("Default dark");
//run("Threshold...");
setThreshold(green_bottom, green_top);
run("NaN Background", "stack");
rename("blue");
/*
run("Duplicate...", "duplicate");
rename("blue-1");
//setAutoThreshold("Default");
//run("Threshold...");




setThreshold(bottom, top);


setThreshold(bottom, top);

run("Convert to Mask", "method=Default background=Default calculate");
run("Invert LUT");

imageCalculator("Multiply stack", "blue","blue-1");
selectWindow("blue-1");
run("Close");

run("Enhance Contrast...", "saturated=0.2 normalize");

//--------------------------------------------------------------------------
*/

selectWindow (red_name);




run("Enhance Contrast...", "saturated=0.0 normalize process_all");
run("32-bit");

run("Enhance Contrast...", "saturated=0.0 normalize process_all");

/*waitForUser ("measure thresholds");
Dialog.create("Set threshold levels");

Dialog.addNumber("Lower Threshold level", bottom);
Dialog.addNumber("Upper Threshold level", 1.00);
Dialog.show();
bottom=Dialog.getNumber();
top=Dialog.getNumber();
*/

setAutoThreshold("Default dark");
//run("Threshold...");
setThreshold(red_bottom, red_top);
run("NaN Background", "stack");
rename("red");
/*
run("Duplicate...", "duplicate");
rename("red-1");
//setAutoThreshold("Default");
//run("Threshold...");

Dialog.create("Set threshold levels");
Dialog.addNumber("Lower Threshold level", bottom);
Dialog.addNumber("Upper Threshold level", top);
Dialog.show();
bottom=Dialog.getNumber();
top=Dialog.getNumber();

setThreshold(bottom, top);

run("Convert to Mask", "method=Default background=Default calculate");
run("Invert LUT");

imageCalculator("Multiply stack", "red","red-1");
selectWindow("red-1");
run("Close");

run("Enhance Contrast...", "saturated=0.35 normalize");

//--------------------------------------------------------------------------
*/


imageCalculator("Subtract create stack", "blue","red");
run("Rename...", "title=subtraction");




run("Image Calculator..." , "image1=blue operation=Add create stack image2=red");
run("Rename...", "title=addition");



run("Image Calculator..." , "image1=subtraction operation=Divide create stack image2=addition");
run("Rename...", "title=GP_image");

run("Rainbow RGB");

filename = dir1 + File.separator + title + " GP image";

saveAs("Tiff", filename);

nBins = 256;
getHistogram(value, count, nBins);

run("Clear Results");
for (i=0; i<nBins; i++){
  setResult("Value", i, value[i]);
  setResult("Count", i, count[i]);
}
updateResults();

filename = filename + " hist.txt";

 saveAs("Results",filename);



ScreenClean();

		}
}

function ScreenClean(){
		
	while (nImages>0) close();

          WinOp=getList("window.titles");
	for(i=0; i<WinOp.length; i++)
	  {selectWindow(WinOp[i]);run ("Close");}

	  fenetres=newArray("B&C","Channels","Threshold");
	for(i=0;i!=fenetres.length;i++)
	   if (isOpen(fenetres[i]))
	    {selectWindow(fenetres[i]);run("Close");}
       }