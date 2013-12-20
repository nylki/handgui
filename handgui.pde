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
GuiElement caption1, caption2;
ScanArea scanArea;
ArrayList<TagButton> tags = new ArrayList<TagButton>();
<<<<<<< HEAD
ArrayList<TagButton> draggedTags = new ArrayList<TagButton>();
=======
>>>>>>> 1ab0fff90004a76a0c5680c01dd7e54692a8d61b
ArrayList<TagButton> addedTags = new ArrayList<TagButton>();
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
  PImage scanButtonImage = loadImage("capture_2.png" );
  PImage scanButtonImage_hover = loadImage("capture_1.png" );
  
  PShape scanAreaImage = loadShape("frame-03.svg");
  scanButton = new GuiElement((int) (width - scanButtonImage.width/2) -50, (int) (height-scanButtonImage.height/2) -50, scanButtonImage, scanButtonImage_hover, (int) scanButtonImage.width/2, (int) scanButtonImage.height/2);
  scanArea = new ScanArea(0, 0, scanAreaImage, scanAreaImage, (int) scanAreaImage.width, (int) scanAreaImage.height);
  tags.add(new TagButton(width - 300, 50, 100, 50, "Journal", null));
  tags.add(new TagButton(width - 300, 110, 100, 50, "Book", null));
  tags.add(new TagButton(width - 300, 170, 100, 50, "note", null));
  tags.add(new TagButton(width - 300, 230, 100, 50, "sketch", null));
  tags.add(new TagButton(width - 200, 50, 100, 50, "Image", null));
  tags.add(new TagButton(width - 200, 110, 100, 50, "model", null));
  tags.add(new TagButton(width - 200, 170, 100, 50, "techniques", null));
  tags.add(new TagButton(width - 200, 230, 100, 50, "fluid", null));
  
  PImage caption1_image = loadImage("keyword.png");
  PImage caption2_image = loadImage("category.png");
  caption1 = new GuiElement(width - 320, 10, caption1_image, caption1_image, caption1_image.width/2, caption1_image.height/2);
  caption2 = new GuiElement( width - 320, 300, caption2_image, caption2_image, caption2_image.width/2, caption2_image.height/2);

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

  caption1.update();
  caption2.update();
  for (int i = 0; i < tags.size(); i++)
    tags.get(i).update();
  
  //arrange the added tags on the bottom
  TagButton t;
    for (int i = 0; i < addedTags.size(); i++){
      t = addedTags.get(i);
      t.boundingBox.setLocation( 25 + (i * t.boundingBox.width), height - t.boundingBox.height - 10);  
  }
  
}


void draw() {
  background(0);
  update();
  if(scanArea.calibrated == false) return;
  
  if(leap.hasFingers())
    ellipse(fingerPos.x, fingerPos.y, 20, 20);

  for (TagButton t : tags)
    t.display();
  
  caption1.display();
  caption2.display();

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
