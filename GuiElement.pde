class GuiElement {
  Rectangle boundingBox;
  PImage pixelImage, pixelHoverImage;
  PShape vectorImage, vectorHoverImage;
  float fingerOverTime_beforeUpdate = 0.0;
  float fingerOverTime = 0.0;
  float fingerOverStarted = 0.0;
  final Integer TIMEUNTILACTION = 800;
  boolean dragged = false;
  boolean draggable = false;
  boolean clicked = false;
  boolean previousPinchInside = false;
  float opacity = 255.0;
  int hoverAnimationDuration = TIMEUNTILACTION;
  float hoverAnimationProgress = 0.0; //0.0 to 1.0
  int dummy = 0;
  Ani movingAnimation = Ani.to(this, 0, "dummy", 0, Ani.LINEAR);


  /* we want to simulate a click by
   1. was finger > TIMEUNTILACTION over button
   2. if so: finger dissapears (touched down) -> was finger still in bounderies of
   the button before the touch down? if true, then button is pressed
   */




  GuiElement(int x_, int y_, PImage img, PImage hoverImg, Integer width_, Integer height_) {
    if (width_ == null && height_ == null) {
      boundingBox = new Rectangle(x_, y_, (int)img.width, (int) img.height);
    } 
    else {
      boundingBox = new Rectangle(x_, y_, width_, height_);
    }
    pixelImage = img;
    pixelHoverImage = hoverImg;
    vectorImage = null;
  }

  GuiElement(int x_, int y_, PShape img, PShape hoverImg, Integer width_, Integer height_) {
    if (width_ == null && height_ == null) {
      boundingBox = new Rectangle(x_, y_, (int) img.width, (int) img.height);
    } 
    else {
      boundingBox = new Rectangle(x_, y_, width_, height_);
    }
    pixelImage = null;
    vectorImage = img;  
    vectorHoverImage = hoverImg;
  }

  GuiElement(int x_, int y_, Integer width_, Integer height_) {
    boundingBox = new Rectangle(x_, y_, width_, height_);
    pixelImage = null;
    pixelHoverImage = null;
    vectorImage = null;  
    vectorHoverImage = null;
  }

  void updateDrag() {
    //dragged will be set to true if finger has been > TIMEUNTILACION above this gui element, otherwise false
    // dragged = (fingerOverTime > TIMEUNTILACTION);
    dragged = false;
    if (modifiedFingerPositions.size() < 2) {
      // set this GUI element to dragged if
      //println("less than 2 fingers.");
      if ((distanceThumbToIndexFinger < 130 && this.previousPinchInside == true)) { 
        println("drag");
        this.dragged = true;
        this.previousPinchInside = true;
      }
    }
  }


  void updateFingerState() {
    clicked = false;
    fingerOverTime_beforeUpdate = fingerOverTime;

    if (leap.hasFingers() == false) {
      //reset the time the finger was over the the button
      fingerOverTime = 0.0;
      fingerOverStarted = 0.0;
    } 
    else if (leap.hasFingers() == true) {
      // check if finger is inside this GUI Element/button
      // if it is, add the passed time to *fingerOverTime*, so we can see
      // how long the finger has been hovering over the button
      if (this.boundingBox.contains((int) frontFingerPosition.x, (int) frontFingerPosition.y)) {
        if (fingerOverTime == 0.0) {
          //just entered the element with a finger
          fingerOverTime = 1.0;
          fingerOverStarted = millis();
        } 
        else {
          fingerOverTime =+ millis() - fingerOverStarted;
        }
      } 
      else {
        // no finger on the gui element
        fingerOverTime = 0.0;
      }

      if (fingerOverStarted > TIMEUNTILACTION && frontFingerPosition.z > 700) {
        clicked = true;
      }


      if (modifiedFingerPositions.size() >= 2 && this.dragged == false) {
        previousPinchInside = this.boundingBox.contains((int) centerThumbFinger.x, (int) centerThumbFinger.y);
      }
    }
  }


  void moveTo(int x, int y, float time) {
    if ( movingAnimation.isPlaying() == false) {
      movingAnimation = Ani.to(boundingBox, time, "x", x, Ani.EXPO_IN);
      Ani.to(boundingBox, time, "y", y, Ani.EXPO_IN);
    }
  }

  void update() {

    updateFingerState();
    if (draggable) updateDrag();


    if (fingerOverTime > 0) {
      hoverAnimationProgress = fingerOverTime / hoverAnimationDuration;
    }
  }

  void display() {
    //only displaying functionality here
    if (pixelImage != null) {
      if (fingerOverTime > 0.0) {
        tint(255, map(frontFingerPosition.z, 0.0, 900.0, 255, 0));
        image(pixelImage, boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height);
        tint(255, map(frontFingerPosition.z, 0.0, 900.0, 0, 255));
        image(pixelHoverImage, boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height);
      } 
      else {
        tint(255, opacity);
        image(pixelImage, boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height);
        noTint();
      }
    }
    else if (vectorImage != null) {
      if (fingerOverTime > 0.0) {
        shape(vectorHoverImage, boundingBox.x, boundingBox.y);
      } 
      else {
        //vectorImage.disableStyle();
        //fill(255,0,0, map(mouseX, 0,width, 0, 255));
        shape(vectorImage, boundingBox.x, boundingBox.y);
        //vectorImage.enableStyle();
      }
    }
  }
}
