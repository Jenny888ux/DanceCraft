import java.util.*;

//Queue<PVector> holdingQueue = new LinkedList<PVector>();
Queue<PVector>[] jointQueue;

//create arrays to hold the totals from the joint queues and the calculated averages, array matches joint ID
float[] totalXs = new float[15];
float[] totalYs = new float[15];
float[] averageXs = new float[15];
float[] averageYs = new float[15];
PVector[] averageV = new PVector[15];

float thresholdDance = 50;

int curRow = 0;

/*
This file contains the functions necessary for playing back "dances" recorded
 by the user.
 */
//-------------------------------------------------------------//
float offsetX; //The offset x of the skeleton
float offsetY; // The offset y of the skeleton
float midWidth = 320 * 4; //middle width of the left half screen
float midHeight = 720; //middle height of the left haft screen

float totalX = 0;
float totalY = 0;

//the two files of dances that happen before the choreo section
String[] danceFileNames= {
  "teacherRecording-warmup.csv", "teacherRecording-technique.csv"
};

//populating with choreo dances, will repopulate with kids' choreos later
String[] danceChoreoFiles= {
  "teacherRecording-snow-1.csv", "teacherRecording-snow-2.csv", 
  "teacherRecording-bird-1.csv", "teacherRecording-bird-2.csv"
};

String[] teacherRecordings= {
  "teacherRecording.csv"
};

boolean useModel = false;
String FN;

/*--------------------------------------------------------------
 reads the csv and retrieves the joint coordinate information, loads them
 into a table
 --------------------------------------------------------------*/
Boolean readCsv(String selection)
{
  //read the csv file if something has been selected
  if (selection != null) {
    println("Loading file: " + selection);
    loadedSkelTable = loadTable(selection, "header");
    skel_data = new PVector [loadedSkelTable.getRowCount()/15][15]; //Initalize skel_data w/ row size = number of "skeletons" and column size = number of joints.
    int i = 0; //count the number of skeletons that are read
    int playVoiceover = 0;
    int index; //count the join of the i skeleton that are read

    //iterate through each row of the table
    for (TableRow row : loadedSkelTable.rows ()) {
      //println (row);
      //get the joint position
      index = row.getInt("joint");
      //Create a new PVector to hold the stuff we're about to grab from the table
      PVector joint = new PVector();
      //Insert that PVector into the skel_data array
      skel_data[i][index] = joint;
      //set coordinates of index joint for i skeleton
      skel_data[i][index].x = row.getFloat("x");
      skel_data[i][index].y = row.getFloat("y");
      skel_data[i][index].z = row.getFloat("z");

      playVoiceover = row.getInt("voiceover");

      if (playVoiceover == 1) {
        voiceoverPlay();
      }

      if (index == 14)
      {
        i++;
      }
    }
    
    //Ready to start dance Playback
    println("Exiting readCSV function");
    return true;
  } else {
    println ("No file selected or incorrect file type.  Must be CSV.");
    return false;
  }
}

/*--------------------------------------------------------------
 draws the points of each of the joints OR draws the 3D model depending on
 if model is turned on or off
 --------------------------------------------------------------*/
void playBack(Integer rowNum)
{
  //PVector jointPos = new PVector();
  curRow = rowNum;
  //println("playing " + rowNum);

  if (rowNum < skel_data.length) {  //Compare number passed to function and make sure its less than the length of the array of skeleton data
    //println ("Drawing!" + ' ' + rowNum);
    offsetX = alignX(skel_data[0][8]);
    offsetY = alignY(skel_data[0][8]);

    for (int i = 0; i < 15; i++) {
      //      if (jointQueue[i].size() >= 20 && (skel_data[rowNum][i].x > (averageV[i].x + thresholdDance) || skel_data[rowNum][i].y > (averageV[i].y + thresholdDance))){
      //        println("====Threshold reached====");
      //        println("Joint ID: " + i + " Average x: " + averageV[i].x + " Bad Coord: " + skel_data[rowNum][i].x);
      //        println("Joint ID: " + i + " Average y: " + averageV[i].y + " Bad Coord: " + skel_data[rowNum][i].y);
      //      }else{
      if (jointQueue[i].size() >= 5) { //is the queue full??
        totalXs[i] -= jointQueue[i].peek().x;  
        totalYs[i] -= jointQueue[i].peek().y;
        jointQueue[i].remove();
      }

      jointQueue[i].add(skel_data[rowNum][i]);
      totalXs[i] += skel_data[rowNum][i].x;
      totalYs[i] += skel_data[rowNum][i].y;

      averageV[i].x = totalXs[i] / jointQueue[i].size();
      averageV[i].y = totalYs[i] / jointQueue[i].size();

      //println("Joint ID: " + i + " Average x: " + averageV[i].x + " Average y: " + averageV[i].y);
    }
    //    }

    drawBack(averageV[0], averageV[1], false, true); //Head and neck
    drawBack(averageV[1], averageV[2], false, false); //Neck and left shoulder
    drawBack(averageV[2], averageV[4], false, false); //Left shoulder and Left elbow
    drawBack(averageV[4], averageV[6], false, false); //Left elbow and left hand
    drawBack(averageV[1], averageV[3], false, false); //Neck and right shoulder
    drawBack(averageV[3], averageV[5], false, false); //Right shoulder and right elbow
    drawBack(averageV[5], averageV[7], false, false); //Right elbow and right hand
    drawBack(averageV[2], averageV[8], true, false); //Left shoulder and TORSO
    drawBack(averageV[3], averageV[8], true, false); //Right shoulder and TORSO
    drawBack(averageV[8], averageV[9], true, false); //Torso and left Hip
    drawBack(averageV[9], averageV[11], false, false); //Left hip and left Knee
    drawBack(averageV[11], averageV[13], false, false); //left knee and left foot
    drawBack(averageV[8], averageV[10], true, false); ///Torso and right hip
    drawBack(averageV[10], averageV[12], false, false); //Right hip and right knee
    drawBack(averageV[12], averageV[14], false, false); //Right knee and right foot
    drawBack(averageV[10], averageV[9], false, false); //Right hip and left hip

  } else {
    dancePlayback = false;
    numIterationsCompleted = 0;

    if (currentDanceSegment < danceFileNames.length) {
      currentDanceSegment++;
      changeSoundToChoreoSegment();
      println("Dance Segment: " + currentDanceSegment);
    } else if (currentChoreoSegment < danceChoreoFiles.length) {
      currentChoreoSegment++;
      changeSoundToChoreoSegment();
      println("Choreo Segment: " + currentChoreoSegment);
    } else {
      playthroughChoreo++;
      println("Choreo Playthrough: " + playthroughChoreo);
    }
  }
}

/*--------------------------------------------------------------
 draws the points based on the coordinates, adjusts where the drawing occurs on screen
 --------------------------------------------------------------*/
void drawBack(PVector skeA, PVector skeB, Boolean thicker, Boolean isHead)
{

  //Set color of skeleton "bones" to black
  stroke(0);
  //Set weight of line
  strokeWeight (5);

  float xAint = 0.25 * (offsetX + skeA.x);
  float yAint = 0.25 * ((-skeA.y) + offsetY);
  float xBint = 0.25 * (offsetX + skeB.x);
  float yBint = 0.25 * ((-skeB.y) + offsetY);

  float xA;
  float yA;
  float xB;
  float yB;

  if (xAint < xBint) {
    xA = xAint;
    yA = yAint;
    xB = xBint;
    yB = yBint;
  } else {
    xB = xAint;
    yB = yAint;
    xA = xBint;
    yA = yBint;
  }

  //draw a point for the first position (divided in half to fit on left side of screen.  Negated Y value to flip skeleton right side up)
  ellipseMode(CENTER);
  rotate(0);
  if (isHead) {
    fill(0, 0, 0);
    ellipse(xAint, yAint, 40, 60);
  } else {
    ellipse(xA, yA, 5, 5);
  }

  //draw a point for the second position (divided in half to fit on left side of screen.  Negated Y value to flip skeleton right side up)
  ellipse(xB, yB, 5, 5);

  //draw a joint between two  (divided in half to fit all of skeleton onto vertical area of screen.  Negated Y value to flip skeleton right side up)
  //line(xA, yA, xB, yB);

  //Begin drawing the limb between the joints
  //draw oval from one joint to another
  Float distance = distanceFormula(xA, yA, xB, yB);
  //Float radius = distance / 2;
  //Float heigh = distance / 4;

  //placeholders for midpoints and what will be the new point to calc angle from
  Float xM;
  Float yM;
  Float newX;
  Float newY;
  float yMod;
  float xMod;

  //what to modify the point by to get midpoint
  xMod = (xB - xA) / 2;
  if (yA > yB) {
    yMod = (yA - yB) / 2;
  } else {
    yMod = (yB - yA) / 2;
  }

  //figure out which point is the one to be modified to find midpoint
  xM = xB - xMod;
  if (yA > yB) {
    yM = yA - yMod;
  } else {
    yM = yB - yMod;
  }

  newX = xB;
  newY = yM;

  fill(0, 0, 0);

  pushMatrix();
  translate(xM, yM);

  newX = xB - xM;
  newY = yB - yM;
  float r = distanceFormula(xB, yB, xM, yM);
  float xR = r;
  float yR = 0; 
  float distanceA = distanceFormula(xR, yR, newX, newY);

  float radians = acos((sq(r) + sq(r) - sq(distanceA)) / (2 * r * r));
  if (yB < yM) {
    radians = (2 * PI) - radians;
  }

  rotate(radians);
  if (thicker) {
    ellipse(0, 0, distance, 45);
  } else {
    ellipse(0, 0, distance, 10);
  }

  popMatrix();
}


/*---------------------------------------------------------------
 Realigns where the x and y are
 ----------------------------------------------------------------*/

float alignX(PVector skeA)
{
  if (skeA.x < midWidth)
    return  midWidth - skeA.x;
  else
    return skeA.x - midWidth;
}

float alignY(PVector skeA)
{
  return skeA.y + midHeight;
}


/*---------------------------------------------------------------
 Takes in the name of the csv skeleton file you want to play back and plays it
 ----------------------------------------------------------------*/
void playVideo(String filename) {
  //read the file specified
  if (!dancePlayback) {
    //Load a CSV of skeleton data from into a table and return true if successful.  Otherwise return false.
    FN = sketchPath(recordingsFolder + "/" + filename).toString();
    //dancePlayback = readCsv(sketchPath(recordingsFolder + "/" + filename).toString());
    dancePlayback = readCsv(FN);
    println("loading csv file");
  }
  playBack (numIterationsCompleted); //play back the skeletons
  numIterationsCompleted++;
}


/*--------------------------------------------------------------
 assigns the appropriate list of filenames depending on the current day selected
 --------------------------------------------------------------*/
void fileForDaySelected() {

  if (currentDaySelected == 1) {
    danceChoreoFiles[0] = "teacherRecording-snow-1.csv";
    danceChoreoFiles[1] = "1choreo_1.csv";
    danceChoreoFiles[2] = "teacherRecording-snow-2.csv";
    danceChoreoFiles[3] = "1choreo_3.csv";
  } else if (currentDaySelected == 2) {
    danceChoreoFiles[0] = "teacherRecording-bird-1.csv";
    danceChoreoFiles[1] = "2choreo_1.csv";
    danceChoreoFiles[2] = "teacherRecording-bird-2.csv";
    danceChoreoFiles[3] = "2choreo_3.csv";
  } else if (currentDaySelected == 3) {
    danceChoreoFiles[0] = "teacherRecording-car-1.csv";
    danceChoreoFiles[1] = "3choreo_1.csv";
    danceChoreoFiles[2] = "teacherRecording-car-2.csv";
    danceChoreoFiles[3] = "3choreo_3.csv";
  }
}

/*--------------------------------------------------------------
 logic for playing through the list of files
 --------------------------------------------------------------*/
void playDances() {
  music = true;
  //loop through each csv file in the current day's dances
  //loop until reach every current file name in array
  if (currentDanceSegment < danceFileNames.length) {
    playVideo(danceFileNames[currentDanceSegment]);
    changeTracks(1);
    changeSoundToChoreoSegment();
  } else if (currentChoreoSegment == 0 || currentChoreoSegment == 2) {
    playVideo(danceChoreoFiles[currentChoreoSegment]);
    changeTrackToDanceDay();
    changeSoundToChoreoSegment();
  } else if (currentChoreoSegment == 1 || currentChoreoSegment == 3) {
    changeTrackToDanceDay();
    changeSoundToChoreoSegment(); 

    //countdown to the recording
    if (recordMode && waitingToRecord) { //haven't recorded yet and record mode activated
      countdownRecord();
    } else if (!recordMode && waitingToRecord) { //haven't recorded yet and record mode waiting
      drawMessage("Press SPACE to begin and end recording.");
    } else if (!recordMode && !waitingToRecord) { //finished recording but not saved yet
      //save current recording to csv file
      if (currentChoreoSegment == 1) {
        saveSkeletonTable(currentDaySelected + "choreo_" + currentChoreoSegment, choreoA); //save full play through of skeletal data
        println("Saving dance: " + currentDaySelected + "choreo_" + currentChoreoSegment);
        keepRecordedDance();
      } else if (currentChoreoSegment == 3){
        saveSkeletonTable(currentDaySelected + "choreo_" + currentChoreoSegment, choreoB); //save full play through of skeletal data
        println("Saving dance: " + currentDaySelected + "choreo_" + currentChoreoSegment);
        keepRecordedDance();
      }
    }
    // else if (!recordMode && !waitingToRecord && savedRecording) { //finished recording, dance is saved in csv
    //  //check to see if they want to save the dance
    //  drawMessage("To KEEP recorded dance, press 'k'." + '\n' + "To REDO recorded dance, press 'r'.");
    //}
  } else if (playthroughChoreo < danceChoreoFiles.length) {
    playVideo(danceChoreoFiles[playthroughChoreo]);
  }

  //when all done reset counters and go back to title screen
  if (currentDanceSegment == danceFileNames.length && currentChoreoSegment == danceChoreoFiles.length && playthroughChoreo == danceChoreoFiles.length) {
    currentDanceSegment = 0; //reset segment count
    currentChoreoSegment = 0; //reset choreo segment count
    pauseMusic();
    music = false;
    totalTime.stop(); //stops the timer for the dancing
    logFile.println ("Total time user has played for Day " + currentDaySelected + ": " + totalTime.getSeconds() + " seconds");
    phase = "title";
  }
}

void keepRecordedDance() {
  if (teacherMode) {
    saveSkeletonTable("teacherRecording", teacherRecording); //save full play through of skeletal data
    println("Saving dance");
    //playVideo("teacherRecording.csv"); //play back what we just recorded
    teacherDone = false;
  } else {
    playVideo(danceChoreoFiles[currentChoreoSegment]);
    //reset all the counters
    waitingToRecord = true;
    countdownReady = 0;
    savedRecording = false;
  }
}

void teacherRecording() {
  if (recordMode) {
    //recording teacher
  } else if (playingBack) {
    //playing back current recording
    playTeacherRecording();
  } else if (!playingBack && !recordMode) {
    //drawMessage("Press 'p' to play current recording." + '\n' + "Press SPACE to begin recording.");
  }
}

void playTeacherRecording() {
  //play back most recent recording
  if (currentDanceSegment < teacherRecordings.length) {
    //playVideo(teacherRecordings[currentDanceSegment]); //play back what we just recorded
    playVideo("teacherRecording- bird-1.csv");
  } else {
    playingBack = false;
  }
}

void redoRecordedDance() {
  if (teacherMode) {
    teacherDone = false;
  } else {
    savedRecording = false;
    waitingToRecord = true;
    countdownReady = 0;
  }
}

float distanceFormula(float xA, float yA, float xB, float yB) {
  float distance = sqrt(sq(xA - xB) + sq(yA - yB));
  return distance;
}

/*--------------------------------------------------------------
 INitislizes the queue array
 --------------------------------------------------------------*/
void initializeQueueArray() {
  jointQueue = new Queue[15];
  for (int i = 0; i < 15; i++) {
    jointQueue[i] = new LinkedList<PVector>();
    averageV[i] = new PVector();
  }
}

/*--------------------------------------------------------------
 Marks the row to play back voiceover
 --------------------------------------------------------------*/
void markVoiceover(int curRow) {
  println(FN);
  loadedSkelTable = loadTable(FN, "header");
  TableRow row = loadedSkelTable.getRow(curRow-2);
  row.setInt("voiceover", 1);
  saveTable(loadedSkelTable, FN, "csv"); //Write table to location
  println("saved "+ FN);
}