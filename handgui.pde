import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;

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
// TODO: AUFRÄUMEN: ersetze haltegeste mit pinch Geste: neu aufbauen: translation/verschieben des tags, direkt im Tag selber implementieren, bzw. hinzufügen: applyForce(), setLocation()
// nur ein dragged objekt zulassen: weniger overhead: und vereinfachen!!
//modifier/Action tags: ocr, outline, scan QR-code, (Glitch!)

boolean debugEnabled = false;
boolean calibrationCheat = true;

boolean Redraw = false;
LeapMotion leap;
Capture cam;
OpenCV opencv;
ArrayList<Finger> fingers;
GuiElement scanButton;
GuiElement caption;
ScanArea scanArea;
ArrayList<TagButton> tags = new ArrayList<TagButton>();
TagButton draggedTag;
TagButton selectedTag = null;

ArrayList<TagButton> addedTags = new ArrayList<TagButton>();
// stack of lists of tags. each list represents a visible set, that can be swiped with the finger
Stack<ArrayList<TagButton>> visibleTags  = new Stack<ArrayList<TagButton>>();
boolean globalElementDragged = false;
PImage lastPhoto = null;
Ani draggedLocationAni = null;
TagMasterCollection tagCollection;



//GLOBAL
ArrayList<PVector> modifiedFingerPositions;
PVector modifiedHandPosition = new PVector(0, 0);

PVector previousHand = new PVector(0, 0);
PVector thumb = new PVector(0, 0);
PVector indexFinger = new PVector(0, 0);
PVector centerThumbFinger = new PVector(0, 0);
PVector directionThumbFinger = new PVector(0, 0);
float distanceThumbToIndexFinger = 1000;
PVector directionHandToPinchCenter = new PVector(0, 0);


Finger frontFinger;
PVector frontFingerPosition = new PVector(0, 0);
float MIN_FINGER_VISIBLE_TIME = 0.2;
boolean fingerInGUIElement = false; //track if finger was/is in guielement, to reduce load
int tagHeight = 40;
int tagWidth = 80;
int tagDistance = 10;


ArrayList<PImage> imageList = new ArrayList<PImage>();

class XCoordinateComparator implements Comparator<Finger> {
  @Override
    public int compare(Finger a, Finger b) {
    float ax = a.getPosition().x;
    float bx = b.getPosition().x;
    return ax < bx ? -1 : ax == bx ? 0 : 1;
  }
}

void setup() {
  size(displayWidth, displayHeight, P2D);
  noSmooth();
  background(0);
  colorMode(RGB, 255, 255, 255);
  Ani.init(this);

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
    cam = new Capture(this, cameras[2]); //cam 13 is what we want
    cam.start();
  }
  opencv = new OpenCV(this, 1920, 1080);
  fingers = new ArrayList<Finger>();
  modifiedFingerPositions = new ArrayList<PVector>();


  PImage scanButtonImage = loadImage("capture_2.png" );
  PImage scanButtonImage_hover = loadImage("capture_1.png" );

  PShape scanAreaImage = loadShape("frame-03.svg");
  scanButton = new GuiElement((int) (width - scanButtonImage.width/3) -200, (int) (height-scanButtonImage.height/3) -100, scanButtonImage, scanButtonImage_hover, (int) scanButtonImage.width/2, (int) scanButtonImage.height/2);

  scanArea = new ScanArea(0, 0, scanAreaImage, scanAreaImage, (int) scanAreaImage.width * 9/10, (int) scanAreaImage.height * 9/10);

  PImage caption1_image = loadImage("keyword.png");
  caption = new GuiElement(width - 400, 10, caption1_image, caption1_image, caption1_image.width/2, caption1_image.height/2);

  String tagStrings[] = loadStrings("tags.txt");
  for (int i = 0 ; i < tagStrings.length; i++) {
    // spliting columns: 5 tags each column
    //int horizontalRightPosition = width - 300 - (tagWidth + tagDistance) * floor(i/4);
    //int verticalPosition = tagHeight + (i % 4) * tagHeight + (i % 4) * tagDistance;
    TagButton t = new TagButton(width/2, height/2, tagStrings[i].length() * 15, tagHeight, tagStrings[i], null);
    tags.add(t);
  }
  // creating our collection master to manage our tag groups
  tagCollection = new TagMasterCollection(tags, 7, new Rectangle(width - 550, 50, 450, 450));
}

void update() {
  // updating scanArea will also update photo taking
  if (calibrationCheat == true && scanArea.calibrated == false) calibrationCheat();
  scanArea.update();
  if (scanArea.calibrated == false) return;
  scanButton.update();
  if (scanButton.clicked == true) {
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
      command[1] = "";
      for (TagButton t : addedTags) {
        // adding actual keywords to the command
        command[1] = command[1] + " " + t.text;
      }
      command[2] = pathString;

      try {
        Process p = Runtime.getRuntime().exec(command);

        BufferedReader stdInput = new BufferedReader(new 
          InputStreamReader(p.getInputStream()));

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
      scanArea.lastPhoto = null;
    }
  }

  modifiedFingerPositions.clear();
  modifiedHandPosition.mult(0);
  frontFingerPosition.mult(0);
  fingers.clear();
  if (leap.hasHands()) {

    //change coordinates of hand and fingers relating to the different usage of the leap motion (tablet mode / 90 degree rotated)
    modifiedHandPosition = leap.getHands().get(0).getPosition();
    float newZ = modifiedHandPosition.y;
    modifiedHandPosition.y = map(modifiedHandPosition.z, 80, 10, 0, height) + 150;
    modifiedHandPosition.x += 250;
    modifiedHandPosition.z = newZ;


    if (leap.hasFingers()) {
      fingers = leap.getFingers();
      frontFinger = leap.getFrontFinger();
      frontFingerPosition = frontFinger.getPosition();
      newZ = frontFingerPosition.y;

      frontFingerPosition.y = map(frontFingerPosition.z, 80, 10, 0, height) + 150;
      frontFingerPosition.x += 250;
      frontFingerPosition.z = newZ;

      Collections.sort(fingers, new XCoordinateComparator());

      for (Finger f : fingers) {
        PVector modifiedPosition = f.getPosition();
        newZ = modifiedPosition.y;
        modifiedPosition.y = map(modifiedPosition.z, 80, 10, 0, height) + 150;
        modifiedPosition.x += 250;
        modifiedPosition.z = newZ;
        modifiedFingerPositions.add(modifiedPosition);
      }


      if (modifiedFingerPositions.size() >= 2) {
        thumb = modifiedFingerPositions.get(0);
        indexFinger = modifiedFingerPositions.get(1);
        directionThumbFinger = PVector.sub(indexFinger, thumb);
        centerThumbFinger = PVector.div(directionThumbFinger, 2);
        centerThumbFinger.add(thumb);

        distanceThumbToIndexFinger = directionThumbFinger.mag();
        directionHandToPinchCenter = PVector.sub(centerThumbFinger, modifiedHandPosition);
      } 
      else if (modifiedFingerPositions.size() == 1 && draggedTag == null) {
        //might not be necessary
        //println("set distanceThumbToIndexFinger high, to prevent accidentally dragging tags");
        // if nothing is being dragged and only a single finger is visible, set the distance of thumb to index finger to something high
        // to prevent accidentally dragging with a single finger
        // distanceThumbToIndexFinger = width;
      }
    }
  }


  //println("hand to centerThumbFinger is: " + directionHandToPinchCenter.x + ", " + directionHandToPinchCenter.y);
  caption.update();
  draggedTag = null;
  for (int i = 0; i < tags.size(); i++) tags.get(i).update();
  // change the location of a dragged tag according to the estimated pinch location
  // maybe put this into the tag itself?
  if (draggedTag != null) {
    println("dragged tag : " + draggedTag.text);
    //we want to arrage the tags circular around the mouse if there are min. 3 tags, otherwise just below the mouse
    PVector estimatedPinchLocation = PVector.add(modifiedHandPosition, directionHandToPinchCenter);        
    draggedTag.dimension.setLocation((int) (estimatedPinchLocation.x - draggedTag.dimension.width/2), 
    (int) (estimatedPinchLocation.y - draggedTag.dimension.height/2));
  }

  //arrange the added tags on the top
  if (addedTags.isEmpty() == false) {
    TagButton t;
    Point newLocation = new Point(scanArea.dimension.x + 20, scanArea.dimension.y + 20);

    for (int i = 0; i < addedTags.size(); i++) {
      t = addedTags.get(i);
      if (t != draggedTag) {

        //animate to new position if tag is not already there
        if (t.dimension.getLocation().equals(newLocation) == false) {
          t.moveTo((int) newLocation.x, (int) newLocation.y, 0.5);
        }
        // increase x location of following tag
        newLocation.x += t.dimension.width + 5;

        //t.boundingBox.setLocation((i * t.boundingBox.width) + 5, t.boundingBox.height + 10);
      }
    }
  }
}


void draw() {
  update();
  background(0);

  if (scanArea.calibrated == false) {
    scanArea.showCalibrationImage();
    return;
  }

  // display all gui elements: buttons, tags, etc.
  
  // first displaying all tags that are not selected. then (if exists) the selected tag
  // so it's above the others
  for (TagButton t : tags){
    if(selectedTag != t) t.display();
  }
  if(selectedTag != null) selectedTag.display();
  
  caption.display();
  scanButton.display();
  scanArea.display();

  // debug: show pinch coordinates
  if (debugEnabled == true) {
    if (modifiedFingerPositions.size() > 1) {
      fill(0, 255, 0);
      ellipse(centerThumbFinger.x, centerThumbFinger.y, 10, 10);
      stroke(0, 128, 128);
      pushMatrix();
      translate(thumb.x, thumb.y);
      line(0, 0, directionThumbFinger.x, directionThumbFinger.y);
      popMatrix();
    }
    if (leap.hasHands()) {
      fill(255, 0, 0);
      ellipse(modifiedHandPosition.x, modifiedHandPosition.y, 50, 50);
      pushMatrix();
      translate(modifiedHandPosition.x, modifiedHandPosition.y);
      line(0, 0, directionHandToPinchCenter.x, directionHandToPinchCenter.y);

      PVector actualPositionBothFingers = PVector.add(modifiedHandPosition, directionHandToPinchCenter);
      text((int) actualPositionBothFingers.x + ", " + (int) actualPositionBothFingers.y, directionHandToPinchCenter.x, directionHandToPinchCenter.y);
      popMatrix();
    }
  }
  ///////////////////


  // draw the cursors/circles where fingers are
  if (modifiedFingerPositions.size() > 0) {
    fill(50, 180, 220, 128);
    for (PVector position : modifiedFingerPositions) {
      float diameterPointer = map(position.z, -height/2, height/2, 6, 30);
      ellipse(position.x, position.y, diameterPointer, diameterPointer);
    }
  }
}


void calibrationCheat() {
  scanArea.calibrated = true;
  Rectangle refSize = new Rectangle(0, 0, cam.height, (int) (((float) scanArea.dimension.height) *  ((float) cam.height) / ((float) scanArea.dimension.width)));
  scanArea.canonicalPoints[0] = new Point(refSize.width, 0);
  scanArea.canonicalPoints[1] = new Point(0, 0);
  scanArea.canonicalPoints[2] = new Point(0, refSize.height);
  scanArea.canonicalPoints[3] = new Point(refSize.width, refSize.height);
  scanArea.unwarpedPoints[0] = scanArea.canonicalPoints[0];
  scanArea.unwarpedPoints[1] = scanArea.canonicalPoints[1];
  scanArea.unwarpedPoints[2] = scanArea.canonicalPoints[2];
  scanArea.unwarpedPoints[3] = scanArea.canonicalPoints[3];
}

void keyPressed() {
  if (key == 'd') debugEnabled = !debugEnabled;

  // toggle calibration cheat, to say it calibration is succesful, when it actually is not. for testing purposes.
  if (key == 'c') {
    calibrationCheat();
  }

  if (key == 'n') {
    tagCollection.selectNext();
  }

  if (key == 'p') {
    tagCollection.selectPrevious();
  }
}
