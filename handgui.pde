import java.io.*;
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

/*
 ACHTUNG: DIESER TEST IST SO KALIBRIERT, DASS DIE LEAPMOTION IN DER MITTE UND UMGEDREHT
 DES TISCHES/DISPLAYS LIEGEN MUSS. Y WERTE WERDEN ANGEPASST. GESTEN AUS DEM FRAMEWORK SIND NICHT MÖGLICH
 */


// TODO: Greifgeste mit Daumen + Zeigenfinger

LeapMotion leap;
Capture cam;
OpenCV opencv;
ArrayList<Finger> fingers;
GuiElement scanButton;
GuiElement caption1, caption2;
ScanArea scanArea;
ArrayList<TagButton> tags = new ArrayList<TagButton>();
ArrayList<TagButton> draggedTags = new ArrayList<TagButton>();
ArrayList<TagButton> addedTags = new ArrayList<TagButton>();
boolean globalElementDragged = false;
PImage lastPhoto = null;


//GLOBAL
Finger frontFinger;
Finger originalFinger;
PVector fingerPos;
float MIN_FINGER_VISIBLE_TIME = 0.2;
boolean fingerInGUIElement = false; //track if finger was/is in guielement, to reduce load
int tagHeight = 40;
int tagWidth = 80;
int tagDistance = 10;


ArrayList<PImage> imageList = new ArrayList<PImage>();


void setup() {
  size(displayWidth, displayHeight, P2D);
  noSmooth();
  background(0);
  colorMode(RGB, 255, 255, 255);
  PImage scanButtonImage = loadImage("capture_2.png" );
  PImage scanButtonImage_hover = loadImage("capture_1.png" );

  PShape scanAreaImage = loadShape("frame-03.svg");
  scanButton = new GuiElement((int) (width - scanButtonImage.width/3) -200, (int) (height-scanButtonImage.height/3) -100, scanButtonImage, scanButtonImage_hover, (int) scanButtonImage.width/2, (int) scanButtonImage.height/2);

  scanArea = new ScanArea(0, 0, scanAreaImage, scanAreaImage, (int) scanAreaImage.width * 9/10, (int) scanAreaImage.height * 9/10);

  PImage caption1_image = loadImage("keyword.png");
  PImage caption2_image = loadImage("category.png");
  caption1 = new GuiElement(width - 400, 10, caption1_image, caption1_image, caption1_image.width/2, caption1_image.height/2);
  caption2 = new GuiElement( width - 400, 250, caption2_image, caption2_image, caption2_image.width/2, caption2_image.height/2);

  String categories[] = loadStrings("categories.txt");
  for (int i = 0 ; i < categories.length; i++) {
    // spliting columns: 5 tags each column
    int horizontalRightPosition = width - 300 - (tagWidth + tagDistance) * floor(i/4);
    int verticalPosition = tagHeight + (i % 4) * tagHeight + (i % 4) * tagDistance;
    tags.add(new TagButton(horizontalRightPosition, verticalPosition, tagWidth, tagHeight, categories[i], null));
  }


  String keywords[] = loadStrings("keywords.txt");
  for (int i = 0 ; i < keywords.length; i++) {
    // spliting columns: 5 tags each column
    int horizontalRightPosition = width - 250 - (tagWidth*2 + tagDistance) * floor(i/3);
    int verticalPosition = 280 + (i % 3) * tagHeight + (i % 3) * tagDistance;
    tags.add(new TagButton(horizontalRightPosition, verticalPosition, tagWidth*2, tagHeight, keywords[i], null));
  }

  leap = new LeapMotion(this).withGestures();
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } 
  else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i + " : " + cameras[i]);
    }
    cam = new Capture(this, cameras[14]); //cam 13 is what we want
    cam.start();
  }
  opencv = new OpenCV(this, 1920, 1080);
}

void update() {
  fingers = leap.getFingers();
  if (leap.hasFingers()) {
    //as we are using the leap 90 deg rotated, we need to change coordinates
    //but for reference we save the original Finger

    frontFinger = leap.getFrontFinger();
    if (frontFinger.getTimeVisible() > MIN_FINGER_VISIBLE_TIME) {
      originalFinger = leap.getFrontFinger();
      fingerPos = frontFinger.getPosition();

      fingerPos.y = map(fingerPos.z, 80, 10, 0, height) + 150;
      fingerPos.x += 550;

    }
  }
  // updating scanArea will also update photo taking
  scanArea.update();
  if (scanArea.calibrated == false) return;
  scanButton.update();
  if (scanButton.clicked == true) {
    println("taking scan photo");
    scanArea.takePhoto();
  }

  // if a photo is available in scan area, grab it
  if (scanArea.lastPhoto != null) {


    String pathString = sketchPath("bilder") +  year() + "_" + month() + "_" + day() + "_" + hour() + "_" + minute() + "_" + second() + ".jpg";
    scanArea.lastPhoto.save(pathString);

    if (addedTags.size() > 0) {

      // adding keyword metadata to the document with the external tool exiv2
      String[] command = new String[3];
      command[0] = dataPath("writeMetadata.sh");
      for (TagButton t : addedTags){
        // adding actual keywords to the command
        command[1] = command[1] + t.text + " ";
      }
      command[2] = pathString;

      try {
        Process p = Runtime.getRuntime().exec(command);

        BufferedReader stdInput = new BufferedReader(new 
          InputStreamReader(p.getInputStream()));

        BufferedReader stdError = new BufferedReader(new 
          InputStreamReader(p.getErrorStream()));

        // read the output from the command
        String s;
        System.out.println("Here is the standard output of the command:\n");
        while ( (s = stdInput.readLine ()) != null) {
          System.out.println(s);
        }
      }
      catch (IOException e) {
        System.out.println("exception when inserting metadata happened - here's what I know: ");
        e.printStackTrace();
        System.exit(-1);
      }

      // open the scanned image with the users default image viewer
      open(pathString);
    }
  }

    caption1.update();
    caption2.update();
    for (int i = 0; i < tags.size(); i++)
      tags.get(i).update();


    //if we have tags that are being dragged, position then around the mouse
    if (draggedTags.isEmpty() == false) {
      TagButton t;
      int draggedTagCount = draggedTags.size();
      for (int i = 0; i < draggedTagCount; i++) {
        t = draggedTags.get(i);
        //we want to arrage the tags circular around the mouse if there are min. 3 tags, otherwise just below the mouse
        if (draggedTagCount < 3) {
          t.boundingBox.setLocation(  tagWidth + (int)(fingerPos.x + (i * tagWidth)), (int) (fingerPos.y - t.boundingBox.height - 10));
        } 
        else {
          // otherwise rotate tags around mouse
          // calculate positions (circle around the mouse)
          float radians = radians((360/draggedTagCount) * (i+1));
          float newX = fingerPos.x + (cos(radians) * (t.boundingBox.width + 40));
          float newY = fingerPos.y + (sin(radians) * (t.boundingBox.height + 40));
          t.boundingBox.setLocation((int) newX, (int) newY);
        }
      }

  }

  caption1.update();
  caption2.update();
  for (int i = 0; i < tags.size(); i++)
    tags.get(i).update();


  //if we have tags that are being dragged, position then around the mouse
  if (draggedTags.isEmpty() == false) {
    TagButton t;
    int draggedTagCount = draggedTags.size();
    for (int i = 0; i < draggedTagCount; i++) {
      t = draggedTags.get(i);
      //we want to arrage the tags circular around the mouse if there are min. 3 tags, otherwise just below the mouse
      if (draggedTagCount < 3) {
        t.boundingBox.setLocation(  tagWidth + (int)(fingerPos.x + (i * tagWidth)), (int) (fingerPos.y - t.boundingBox.height - 10));
      } 
      else {
        // otherwise rotate tags around mouse
        // calculate positions (circle around the mouse)
        float radians = radians((360/draggedTagCount) * (i+1));
        float newX = fingerPos.x + (cos(radians) * (t.boundingBox.width + 40));
        float newY = fingerPos.y + (sin(radians) * (t.boundingBox.height + 40));
        t.boundingBox.setLocation((int) newX, (int) newY);

      }
    }
  }
    //arrange the added tags on the bottom
    if (addedTags.isEmpty() == false) {
      TagButton t;
      for (int i = 0; i < addedTags.size(); i++) {
        t = addedTags.get(i);
        t.boundingBox.setLocation( 25 + (i * t.boundingBox.width), t.boundingBox.height + 10);
      }
    }

}

  
  void draw() {
    background(0);
    update();
    if (scanArea.calibrated == false) return;

    // draw the cursor/circle
    if (leap.hasFingers() && frontFinger.getTimeVisible() > MIN_FINGER_VISIBLE_TIME) {
      float diameterPointer = map(originalFinger.getPosition().y, -height/2, height/2, 6, 30);
      ellipse(fingerPos.x, fingerPos.y, diameterPointer, diameterPointer);
      }

    for (TagButton t : tags)
      t.display();

    caption1.display();
    caption2.display();
    scanButton.display();
    scanArea.display();
  

  //arrange the added tags on the bottom
  if (addedTags.isEmpty() == false) {
    TagButton t;
    for (int i = 0; i < addedTags.size(); i++) {
      t = addedTags.get(i);
      t.boundingBox.setLocation( 25 + (i * t.boundingBox.width), t.boundingBox.height + 10);
    }
  }

}
