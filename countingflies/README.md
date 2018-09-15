# Counting Flies per Quadrant in an Olfactory Arena Behavior Experiment Video

**Overview**: This program counts and plots the number of fruit flies per quadrant per frame in an olfactory arena behavior experiment video. These fly counts are then used to calculate and plot average performance index (PI) over time per experiment and across all experiments in a set.

**Requirements**:

* Store all data files in .ufmf video format in a directory that contains the word “Data” (e.g. C:\Behavior_Experiments\Data\2018-05-14\UAS-ChR_TH-Gal4_Arena-Arena\20180514T103551_Arena1_Cam0_1xTrain-OCT+_test_test)
	* Organize and store data in a separate folder for each experiment (e.g. UAS-ChR_TH-Gal4_Arena-Arena)
	* A single experiment consists of up to four test files (one for each combination of odor and arena — eg. Oct or Mch and cam0 or cam1)
* Store files for error trials in a folder called “error”
* Store paths for each set of experiments in an .xls or .xlsx file (e.g. UAS-ChR_TH-Gal4_60US-60CS_Arena.xlsx)

**Selecting and saving arena masks**:
1.	Run the select_quadrants.m script
2.	Copy path for data files to line 7
3.	Copy destination path for mask files to line 8 (e.g. 'C:\Matlab_Scripts\trackingbehavior\countingflies\masks')
4.	When prompted, manually select a single arena quadrant, excluding the center region above the odor output tube. Continue until all four quadrants for each arena have been saved
5. Script will save a set of two dilated masks, an arena mask, and a set of two quadrant border files for each arena

**Analyzing video and generating fly counts**: 
1.	Run the tracking_flies_per_quadrant.m script
2.	Copy path for data files to line 6
3.	Copy path for mask files to line 7 
    1.	This folder must contain dilated quadrant masks, an arena mask, and quadrant border files for each arena
4.	Analyzed file saving convention:
    1.	The analyzed output fly counts are saved to a folder with the same folder structure as the data directory, but “Data” is replaced with “Analysis” (e.g. C:\Behavior_Experiments\Analysis\2018-05-14\UAS-ChR_TH-Gal4_Arena-Arena\20180514T103551_Arena1_Cam0_1xTrain-OCT+_test_test)
    2.	Once a video has been analyzed, the script tags the data folder with a text file called “analyzed.txt”

**Calculating PI**:
1.	Run the calculating_pi_counts.m script
2.	When prompted, select a spreadsheet containing paths for a set of experiments
3.	Script will create a plot of all four sets of fly counts over time per experiment, along with a black bar indicating the time during which odor was delivered to the arena
4.	Script will create plots for average PI over time per experiment and across all experiments in the set
5.	Script will display average PI, standard deviation, and n number of PIs calculated from the set
    1.	Select the range of frames over which to calculate an average PI in lines 13 & 14. Default set to 2400-4500 (corresponds to 80-150 s for a 30 fps acquisition rate)
