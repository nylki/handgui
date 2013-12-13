import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import de.voidplus.leapmotion.*;
import development.*;
import java.util.*;
import java.awt.*;
import processing.video.*;

/* Laufzeitanalyse:
 button update:
 Laufzeit O(n*m) mit n=anzahl button und m=anzahl finger
 
 */

/*
 ACHTUNG: DIESER TEST IST SO KALIBRIERT, DASS DIE LEAPMOTION IN DER MITTE UND UMGEDREHT
 DES TISCHES/DISPLAYS LIEGEN MUSS. Y WERTE WERDEN ANGEPASST. GESTEN AUS DEM FRAMEWORK SIND NICHT MÖGLICH
 */

LeapMotion leap;
Capture cam;
OpenCV opencv;
ArrayList<Finger> fingers;
GuiElement scanButton;
ScanArea scanArea;
ArrayList<TagButton> tags = new ArrayList<TagButton>();
boolean globalElementDragged = false;
PImage lastPhoto = null;

//GLOBAL
Finger frontFinger;
PVector fingerPos;


ArrayList<PImage> imageList = new ArrayList<PImage>();


void setup() {
  size(displayWidth, displayHeight, P2D);
  background(0);
  colorMode(RGB, 255, 255, 255);

  PShape scanButtonImage = loadShape("capture_2.svg");
  PShape scanButtonImage_hover = loadShape("capture_1.svg");
  PShape scanAreaImage = loadShape("frame-03.svg");
  scanButton = new GuiElement((int) (width - scanButtonImage.width) -50, (int) (height-scanButtonImage.height) -50, scanButtonImage, scanButtonImage_hover, (int) scanButtonImage.width, (int) scanButtonImage.height);
  scanArea = new ScanArea(0, 0, scanAreaImage, scanAreaImage, (int) scanAreaImage.width, (int) scanAreaImage.height);
  tags.add(new TagButton(width - 220, 20, 100, 50, "Journal", null));
  tags.add(new TagButton(width - 220, 80, 100, 50, "Book", null));
  tags.add(new TagButton(width - 220, 140, 100, 50, "note", null));
  tags.add(new TagButton(width - 220, 200, 100, 50, "sketch", null));
  tags.add(new TagButton(width - 110, 20, 100, 50, "Image", null));
  tags.add(new TagButton(width - 110, 80, 100, 50, "model", null));
  tags.add(new TagButton(width - 110, 140, 100, 50, "techniques", null));
  tags.add(new TagButton(width - 110, 200, 100, 50, "fluid", null));


  leap = new LeapMotion(this).withGestures("swipe");
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } 
  else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this); //cam 13 is what we want
    cam.start();
  }
  opencv = new OpenCV(this, 640, 480);
}

void update(){
  println("update");
    if (cam.available() == true)
    cam.read();
  
  fingers = leap.getFingers();
  if (leap.hasFingers()) {
    //
    //for(Finger f : fingers) {
    
    frontFinger = leap.getFrontFinger();
    fingerPos = frontFinger.getPosition();
    fingerPos.y = map(fingerPos.z, 80, 10, 0, height);
    fingerPos.x += 450;
    fingerPos.y += 100;
    
  }
    //updating scanArea will also update photo taking
  scanArea.update();
  if(scanArea.calibrated == false) return;
  scanButton.update();
  if (scanButton.clicked == true) scanArea.takePhoto();


  for (int i = 0; i < tags.size(); i++)
    tags.get(i).update();
 
}


void draw() {
  background(0);
  update();
  if(scanArea.calibrated == false) return;
  println("calibrated. drawing stuff");
  
  if(leap.hasFingers())
    ellipse(fingerPos.x, fingerPos.y, 20, 20);

  for (TagButton t : tags)
    t.display();

  scanButton.display();
  scanArea.display();

  //if a photo is available in scan area, grab it
  if (scanArea.lastPhoto != null) {
    scanArea.lastPhoto.save("/Users/tom/Desktop/bild_" +  year() + "_" + month() + "_" + day() + "_" + hour() + "_" + minute() + "_" + second() + ".jpg");
    imageList.add(lastPhoto);
  }

  if (lastPhoto != null) {
    rectMode(CORNER);
    image(imageList.get(imageList.size() - 1), 0, 0);
  }
}
