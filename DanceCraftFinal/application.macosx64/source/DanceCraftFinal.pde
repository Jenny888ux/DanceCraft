import processing.video.*;
import ddf.minim.*;

//Holds animation movie
Movie animation;

//AudioPlayer player;
AudioPlayer soundtrack;
Minim minim;//audio context
int track = 1; //initial track number
String trackNum; //holds track number for calling from file

PImage welcomelogin, welcomebg, dancecraft, onedancer, multidancers, 
myrecords, quitgame, question, dancebg, switchOn, diamond, play, arrow,
picture1, picture2, picture3, endPicture;

PFont font;

String phase, mode;
String [] files;
String username, time;
String desktopPath = "\\records/";

String [] encouragements = {"Welcome", "You're moving", "Keep it up", "Great job", "Keep dancing", "Awesome", "So cool", "Wow"};

Boolean typingUsername, music, figure;

int startTime;
int diamonds;
int encIndex;
int background;
int recordsIndex;

int [] pointsArray = {};

void setup() {
  smooth();
  phase = "login";
  diamonds = 3;
  size(640,480);
  font=createFont("Arial", 48);
  textFont(font);
  welcomelogin = loadImage("elements/1_welcome_login.jpg");
  welcomebg = loadImage("elements/welcomebg.png");
  dancecraft = loadImage("elements/dancecraft3.png");
  onedancer = loadImage("elements/onedancer.png");
  multidancers = loadImage("elements/multidancers.png");
  myrecords = loadImage("elements/myrecords.png");
  quitgame = loadImage("elements/quitgame.png");
  question = loadImage("elements/question.png");
  dancebg = loadImage("elements/dancebg.jpg");
  switchOn = loadImage("elements/switch_on.png");
  diamond = loadImage("elements/diamond.png");
  play = loadImage("elements/play.png");
  arrow = loadImage("elements/arrow.png");
  encIndex = 0;
  username = "";
  typingUsername = false;
  music = true;
  figure = true;
  points[0] = 0;
  recordsIndex = 1;
  kinectSetup();
  //musicSetup();
  animation = new Movie(this, "elements/danceAnimation.mp4");  
  background = 0;
  minim = new Minim(this);
  randomTrack(); 
  
  soundtrack.play();
}

void draw() {
  if (phase=="login") {
    drawLoginScreen();
  }
  else if (phase=="option") {
    drawOptionScreen();
  }
  else if (phase=="dance") {
    drawDanceScreen();
  }
  else if (phase=="quit") {
    drawQuitScreen();
  }
  else if (phase=="records") {
    drawRecordsScreen();
  }
  else if (phase=="info") {
    drawInfoScreen();
  }
//  if (frameCount%20==0) {
//    points[0] = points[0]+int(random(4));
//  }
}



/*---------------------------------------------------------------
Draw the dance screen. Calls the animation/background image. Calls Kinect class.
----------------------------------------------------------------*/
void drawDanceScreen() {
  background(28,45,17);
  int passedTime = millis() - startTime;
  int secs = passedTime/1000 %60;
  int mins = passedTime/1000/60;
  diamonds = points[0]/100;
  encIndex = diamonds%8;
  if (points[0]%100==0 && points[0]!=0) {
    fill(255,255,255,150);
    rect(0,0,width,height);
  }
  //reads the animation video file, must come first!!
  animation.read();
  if (music == true) {
    if(!soundtrack.isPlaying()){
      soundtrack.pause();
      soundtrack.rewind();
      randomTrack();
      soundtrack.play();
    }
  } else{
    soundtrack.pause();
  }
  //looks to see if dance buddy is activated, if it is, then run animation
  //otherwise, pull the static background
  if (figure == true) {
    //image(switchOn, 90,79,25,25);
    image(animation,width/2,height/2,width*1.1,height);
    background = 0;
  }
  else {
   //summons a rotating static background 
    backgrnd();
    image(dancebg,width/2,height/2,width,height);
  }
  
  textSize(30);
  fill(0);
  if (username.length()>0) {
      textAlign(RIGHT);
      text(encouragements[encIndex]+", "+username+"!", width*.96,height*.1);
  }
  else {
      textAlign(LEFT);
      text(encouragements[encIndex]+"!", width*.6,height*.1);
  }
  textAlign(LEFT);
  time = (nf(mins, 2) + ":" + nf(secs, 2));
  text("TIME: " + time, width*.6, height*.17);
  text("POINTS: " + points[0], width*.6, height*.24);
  for (int i=0; i<diamonds; i++) {
    image(diamond, width*.575 - i*25, height*.218, 394/19,428/19);
  }
  image(myrecords, width*.11, height*.87, 49*2.5, 12*2.5);
  image(quitgame, width*.11, height*.95, 49*2.5, 12*2.5);
  image(arrow, width*.04, height*.03, 206*.2,93*.2);
  fill(255,255,255,75);
  rectMode(CORNER);
  noStroke();
  rect(82,51,15,15,7);
  rect(82,71,15,15,7);
  fill(255);
  textSize(18);
  textAlign(LEFT);
  text("MUSIC", 12,65);
  text("FIGURE",12,85);
  if (music == true) {
    image(switchOn, 90,59,25,25);
  }
  if (figure == true) {
    image(switchOn, 90,79,25,25);
  }
  kinectDance();
  animation.loop();
  if (10000<passedTime && passedTime<10020) {save("pictures/picture1.png");} 
  else if (20000<passedTime && passedTime<20020) {save("pictures/picture2.png");} 
  
  // add to points array
  for (int x=5000; x<3000000; x+=5000) {
    if (x<passedTime && passedTime<x+18) {
    pointsArray = append(pointsArray, points[0]); 
  }
  }
}

void drawRecordsScreen() {
  background(0);
  picture1 = loadImage("pictures/picture1.png");
  picture2 = loadImage("pictures/picture2.png");
  endPicture = loadImage("pictures/endPicture.png");
  imageMode(CORNER);
  image(picture1, 0,0, width/2, height/2);
  image(endPicture, width/2, 0, width/2, height/2);
  rectMode(CENTER);
  fill(190,219,198);
  noStroke();
  rect(width/2, height*.71, width*.95, height*.6);
  imageMode(CENTER);
  image(arrow, width*.04, height*.03, 206*.2,93*.2);
  if (pointsArray.length>1) {
    drawGraph();
  }
}

void drawGraph() {
  float xinc = width*.85/pointsArray.length;
  float ymult = height*.37/pointsArray[pointsArray.length-1];
  if (pointsArray[pointsArray.length-1] == 0) {
    ymult = height*.45;
  }
  float x = width*.15;
  float y = 430;
  textAlign(CENTER);
  textSize(20);
  stroke(0,102,0);
  strokeWeight(5);
  point(x, y-pointsArray[0]*ymult);
  fill(0);
  textSize(10);
  text(5, x, 461);
  for (int i=1; i<pointsArray.length; i++) {
    stroke(0,102,0);
    strokeWeight(5);
    point(x+xinc*i, y-pointsArray[i]*ymult);
    strokeWeight(2);
    line(x+xinc*i, y-pointsArray[i]*ymult, x+xinc*(i-1), y-pointsArray[i-1]*ymult);
    fill(0);
    textSize(10);
    text(5*(i+1), x+xinc*i, 461);
  }
  int scale = 10;
  if (pointsArray[pointsArray.length-1]>50) {scale = 20;}
  if (pointsArray[pointsArray.length-1]>200) {scale = 50;}
  if (pointsArray[pointsArray.length-1]>400) {scale = 100;}
  if (pointsArray[pointsArray.length-1]>800) {scale = 200;}
  if (pointsArray[pointsArray.length-1]>2000) {scale = 500;}
  textSize(10);
  for (int j=scale; j<pointsArray[pointsArray.length-1]; j+=scale) {
    text(j, x-60, y-j*ymult);
  }
  stroke(0);
  strokeWeight(1);
  textSize(20);
  line(x-40, 440, x+width*.8, 440);
  line(x-40, 440, x-40, 250);
  text("SECONDS", 570, 478);
  text("POINTS", x-40, 240);
  textAlign(LEFT);
  text("Total time: "+time, 450, 395);
  text("Total points: "+pointsArray[pointsArray.length-1], 450, 420);
  textSize(40);
  textAlign(CENTER);
  if (username.length()>0) {
    text("Great job, "+username+"!", 320, 240);
  }
  else {
    text("Great job!", 320, 240);
  }
}

void drawLoginScreen() {
    image(welcomelogin,0,0,width,height);
    fill(0);
    textSize(30);
    text(username+(frameCount/10 % 2 == 0 ? "_" : ""), 247,264);
    typingUsername = true;  
}

void drawOptionScreen() {
    typingUsername=false;
    imageMode(CENTER);
    image(welcomebg,width/2,height/2,width,height);
    image(dancecraft,width/2,height*.21,96*4.5,12*10);
    textAlign(CENTER);
    fill(255);
    textSize(40);
    if (username.length()>0) {
      text("Welcome, "+username+"!", width/2,height*.43);
    }
    else {
      text("Welcome!", width/2, height*.43);
    }
    image(onedancer, width/2, height*.6, 55*4.5, 11*4.5);
    image(multidancers, width/2, height*.73, 55*4.5, 11*4.5);
    image(myrecords, width*.11, height*.87, 49*2.5, 12*2.5);
    image(quitgame, width*.11, height*.95, 49*2.5, 12*2.5);
    image(question, width*.98, height*.04, 82*.2,149*.2);
    image(arrow, width*.04, height*.03, 206*.2,93*.2);
}

void drawQuitScreen() {
  username="";
  textSize(30);
  imageMode(CENTER);
  image(welcomebg,width/2,height/2,width,height);
  textAlign(CENTER);
  fill(40,40,40,150);
  rectMode(CENTER);
  noStroke();
  rect(width/2, height*.58, 200,50);
  fill(255);
  text("Thank you for playing!", width/2, height*.4);
  text("PLAY AGAIN", width/2, height*.6);
}

void drawInfoScreen() {
    imageMode(CENTER);
    image(welcomebg,width/2,height/2,width,height);
    image(dancecraft,width/2,height*.21,96*4.5,12*10);
    textAlign(CENTER);
    fill(255);
    textSize(40);
    if (username.length()>0) {
      text("Welcome, "+username+"!", width/2,height*.43);
    }
    else {
      text("Welcome!", width/2, height*.43);
    }
    rectMode(CENTER);
    fill(255,255,255,150);
    rect(width/2, height*.66, 420,170);
    fill(0);
    textSize(30);
    text("INSTRUCTIONS", width/2, height*.55);
    textAlign(LEFT);
    textSize(19);
    text("Dance! You will see yourself on the screen.\nThe more you move, the more points you earn.\nWith enough points, you will earn a diamond!", 123, 300);
    image(play, width/2, height*.92, 418*.25,181*.25);
    image(arrow, width*.04, height*.03, 206*.2,93*.2);
}

void drawBackButton() {
  rectMode(CORNER);
  noStroke();
  fill(95);
  triangle(30,12,30,34,12,23);
  rect(30,12,40,22);
}

void typeUsername() {
  typingUsername = true; 
  username = "";
}

void mousePressed() {
  if (phase=="login") {
    if (mouseX>455 && mouseX<528 && mouseY>240 && mouseY<273) {
      phase = "option";
    }
    else if (mouseX>151 && mouseX<345 && mouseY>354 && mouseY<400) {
      username = "";
      phase = "option";
    }
    else if (mouseX>383 && mouseX<491 && mouseY>354 && mouseY<400) {
      phase = "quit";
    }
  }
  else if (phase=="option") {
    if (mouseX>196 && mouseX<443 && mouseY>236 && mouseY<314) {
      mode = "onePlayer";
      phase = "dance";
      startTime = millis();
    }
    else if (mouseX>196 && mouseX<443 && mouseY>274 && mouseY<377) {
      mode = "twoPlayer";
      phase = "dance";
      username = "Team";
      startTime = millis();
    }
    else if (mouseX>4 && mouseX<48 && mouseY>6 && mouseY<26) {
      imageMode(CORNER);
      textAlign(LEFT);
      phase = "login";
    }
    else if (mouseX>10 && mouseX<132 && mouseY>444 && mouseY<473) {
      phase = "quit";
    }
    else if (mouseX>10 && mouseX<132 && mouseY>405 && mouseY<435) {
      phase = "records";
    }
    else if (mouseX>620 && mouseX<636 && mouseY>6 && mouseY<38) {
      phase = "info";
    }
  }
  else if (phase=="dance") {
    if (mouseX>83 && mouseX<98 && mouseY>54 && mouseY<69) {
      music = !music;
    }
    else if (mouseX>83 && mouseX<98 && mouseY>74 && mouseY<89) {
      figure = !figure;
    }
    else if (mouseX>4 && mouseX<48 && mouseY>6 && mouseY<26) {
      phase = "option";
      points[0] = 0;
      diamonds = 0;
    }
    else if (mouseX>10 && mouseX<132 && mouseY>405 && mouseY<435) {
      save("pictures/endPicture.png");
      phase = "records";
    }
    else if (mouseX>10 && mouseX<132 && mouseY>444 && mouseY<473) {
      save("pictures/endPicture.png");
      phase = "quit";
      points[0] = 0;
      diamonds = 0;
    }
  }
  else if (phase=="quit") {
    if (mouseX>221 && mouseX<421 && mouseY>256 && mouseY<307) {
      imageMode(CORNER);
      textAlign(LEFT);
      phase = "login";
    }
  }
  else if (phase=="info") {
    if (mouseX>4 && mouseX<48 && mouseY>6 && mouseY<26) {
      phase = "option";
    }
    else if (mouseX>268 && mouseX<372 && mouseY>421 && mouseY<467) {
      phase = "option";
    }
  }
  else if (phase=="records") {
    if (mouseX>4 && mouseX<48 && mouseY>6 && mouseY<26) {
      phase = "option";
      pointsArray = new int[0];
      points[0] = 0;
    }
  }
  //println(mouseX,mouseY);
}

void keyPressed() {
  if (typingUsername == true) {
    username = username + str(key);
    //println(key);
    switch(key) {
          //// FIX THIS LATER
    case BACKSPACE: 
      username = username.substring(0,max(0,username.length()-1));
    case ENTER: 
      username = username.substring(0,max(0,username.length()-1));
      phase = "option";
    }
  }
  if (phase=="records") {  
      save(desktopPath+"report"+recordsIndex+"-"+month()+"-"+day()+"-"+year()+".png");
      println( "printing records...");
      recordsIndex++;
  }
}

//creates the static background
void backgrnd(){
  if(background == 0){
    background = int(random(4)) + 1;
    String dncbg = "elements/" + background + ".png";
    dancebg = loadImage(dncbg);
    image(dancebg,width/2,height/2,width,height);
  }
}

void musicPlay(){
  //calls a random track from the music folder
    randomTrack();
    soundtrack.play();
    
//loop of music playing
  while(music == true){ 
    //plays the music
    if(!soundtrack.isPlaying()){
      soundtrack.pause();
      soundtrack.rewind();
      randomTrack();
      soundtrack.play();
    }
  }
}//Boolean music

void stop()
{
  soundtrack.close();
  minim.stop();
  super.stop();
}

void getTrack(int track){
  trackNum = "music/"+track+".mp3";
  soundtrack = minim.loadFile(trackNum, 2048);
}

void randomTrack(){
  track = int(random(23)) + 1;
  println("Now playing track number: " + track);
  getTrack(track);
}

