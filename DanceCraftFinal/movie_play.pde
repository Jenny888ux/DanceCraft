<<<<<<< HEAD
//Movie tutorial;
//
//
//
//void movieSetup(){
//    tutorial = new Movie(this, "elements/bee.mov");
//}
//
//void drawMovie(){
//  image(tutorial, 0, 0, 340, 300);
//}
=======
import processing.video.*;

Movie tutorial = new Movie(this, "bee.mov");
void movieSetup(){
  size(200, 200);
  
}

void moviePlay(){
  tutorial.play();
}



void movieEvent(Movie m) {
  m.read();
}



>>>>>>> FETCH_HEAD
