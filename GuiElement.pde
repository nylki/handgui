class GuiElement {
  Rectangle dimension;
  PImage pixelImage, pixelHoverImage;
  PShape vectorImage, vectorHoverImage;
  
  
  float fingerOverTime = 0.0;
  float fingerOverStarted = 0.0;
  float handOverTime = 0.0;
  float handOverStarted = 0.0;  
  
  
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
  
  
  boolean allowDrag = false; // for example wait atleast 1 second until a tag becomes draggable
  boolean allowSelect = false;
  int timeToAllowSelection = 200;
  int timeToAllowDragging = 1000; // both ^ will be updated after fingerStateUpdate

  GuiElement(int x_, int y_, PImage img, PImage hoverImg, Integer width_, Integer height_) {
    if (width_ == null && height_ == null) {
      this.dimension = new Rectangle(x_, y_, (int)img.width, (int) img.height);
    } else {
      this.dimension = new Rectangle(x_, y_, width_, height_);
    }
    pixelImage = img;
    pixelHoverImage = hoverImg;
    vectorImage = null;
  }

  GuiElement(int x_, int y_, PShape img, PShape hoverImg, Integer width_, Integer height_) {
    if (width_ == null && height_ == null) {
      this.dimension = new Rectangle(x_, y_, (int) img.width, (int) img.height);
    } else {
      this.dimension = new Rectangle(x_, y_, width_, height_);
    }
    pixelImage = null;
    vectorImage = img;  
    vectorHoverImage = hoverImg;
  }

  GuiElement(int x_, int y_, Integer width_, Integer height_) {
    this.dimension = new Rectangle(x_, y_, width_, height_);
    pixelImage = null;
    pixelHoverImage = null;
    vectorImage = null;  
    vectorHoverImage = null;
  }

  void updateDrag() {
    dragged = false;
    if(allowDrag == false) return;
    
    if (leap.hasFingers()) {
      if (previousPinchStrength > 0.7 && this.previousPinchInside == true && fingerOverTime > 1000) { 
        println("drag");
        this.dragged = true;
        this.previousPinchInside = true;
      } else {
        this.previousPinchInside = this.dimension.contains((int) centerThumbIndexFinger.x, (int) centerThumbIndexFinger.y);
      }
    }
  }


  void updateFingerState() {
    clicked = false;

    if (leap.hasFingers() == false) {
      //reset the time the finger was over the the button
      fingerOverTime = 0.0;
      fingerOverStarted = 0.0;
      handOverTime = 0.0;
      handOverStarted = 0.0;
    } else if (leap.hasFingers() == true) {
      
      // check if finger is inside this GUI Element/button
      // if it is, add the passed time to *fingerOverTime*, so we can see
      // how long the finger has been hovering over the button
      if (this.dimension.contains((int) indexFingerPosition.x, (int) indexFingerPosition.y)) {
        if (fingerOverTime == 0.0) {
          //just entered the element with a finger
          fingerOverTime = 1.0;
          fingerOverStarted = millis();
        } else {
          fingerOverTime =+ millis() - fingerOverStarted;
        }
      } else {
        // no finger on the gui element
        fingerOverTime = 0.0;
      }

      // check for hands
      if (this.dimension.contains((int) modifiedHandPosition.x, (int) modifiedHandPosition.y)) {
        if (handOverTime == 0.0) {
          //just entered the element with a finger
          handOverTime = 1.0;
          handOverStarted = millis();
        } else {
          handOverTime =+ millis() - handOverStarted;
        }
      } else {
        // no finger on the gui element
        handOverTime = 0.0;
      }      
    }
  }


  void moveTo(int x, int y, float time) {
    if ( movingAnimation.isPlaying() == false) {
      movingAnimation = Ani.to(dimension, time, "x", x, Ani.EXPO_IN);
      Ani.to(dimension, time, "y", y, Ani.EXPO_IN);
    }
  }

  void update() {
    updateFingerState();
    if (draggable){
      allowDrag = (this.fingerOverTime > timeToAllowDragging);
      updateDrag();
    }
    allowSelect = (this.fingerOverTime > timeToAllowSelection);
    if (fingerOverTime > 0) 
      hoverAnimationProgress = fingerOverTime / hoverAnimationDuration;
    
  }

  void display() {
    //only displaying functionality here
    if (pixelImage != null) {
      if (fingerOverTime > 0.0) {
        tint(255, map(indexFingerPosition.z, 0.0, 900.0, 255, 0));
        image(pixelImage, dimension.x, dimension.y, dimension.width, dimension.height);
        tint(255, map(indexFingerPosition.z, 0.0, 900.0, 0, 255));
        image(pixelHoverImage, dimension.x, dimension.y, dimension.width, dimension.height);
      } else {
        tint(255, opacity);
        image(pixelImage, dimension.x, dimension.y, dimension.width, dimension.height);
        noTint();
      }
    } else if (vectorImage != null) {
      if (fingerOverTime > 0.0) {
        shape(vectorHoverImage, dimension.x, dimension.y);
      } else {
        //vectorImage.disableStyle();
        //fill(255,0,0, map(mouseX, 0,width, 0, 255));
        shape(vectorImage, dimension.x, dimension.y);
        //vectorImage.enableStyle();
      }
    }
  }
}
