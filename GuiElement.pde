class GuiElement {
  Rectangle boundingBox;
  PImage pixelImage, pixelHoverImage;
  PShape vectorImage, vectorHoverImage;
  float fingerOverTime = 0.0;
  float fingerOverStarted = 0.0;
  final Integer TIMEUNTILACTION = 800;
  boolean dragged = false;
  boolean draggable = false;
  boolean clicked = false;
  float opacity = 0.0;
  boolean opacityDownAnimation = false;
  int hoverAnimationDuration = TIMEUNTILACTION;
  float hoverAnimationProgress = 0.0; //0.0 to 1.0
  

  /* we want to simulate a click by
    1. was finger > TIMEUNTILACTION over button
    2. if so: finger dissapears (touched down) -> was finger still in bounderies of
      the button before the touch down? if true, then button is pressed
  */

  GuiElement(int x_, int y_, PImage img, PImage hoverImg, Integer width_, Integer height_) {
    if(width_ == null && height_ == null){
      boundingBox = new Rectangle(x_, y_, (int)img.width,(int) img.height);
    } else {
      boundingBox = new Rectangle(x_, y_, width_, height_);
    }
    pixelImage = img;
    pixelHoverImage = hoverImg;
    vectorImage = null;
  }

  GuiElement(int x_, int y_, PShape img, PShape hoverImg, Integer width_, Integer height_) {
    if(width_ == null && height_ == null){
      boundingBox = new Rectangle(x_, y_, (int) img.width, (int) img.height);
    } else {
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
  
  void updateDrag(){
    //dragged will be set to true if finger has been > TIMEUNTILACION above this gui element, otherwise false
    dragged = (fingerOverTime > TIMEUNTILACTION);
  }
  
  
  void updateFingerState(){
    clicked = false;
    if (leap.hasFingers() == false) {
      if(fingerOverTime > TIMEUNTILACTION){
        // interpretate this as a click:
        // if previously there was more than TIMEUNTILACTION a finger in the button
        // and this finger is now removed -> we have a click, because because the finger probably moved
        // onto the surface to *click*
        clicked = true;
        println("just clicked the button with the finger."); 
      }
      //reset the time the finger was over the the button
      fingerOverTime = 0.0;
      fingerOverStarted = 0.0;
      
    } else if(leap.hasFingers() == true && frontFinger.getTimeVisible() > MIN_FINGER_VISIBLE_TIME) {
      // if leap has fingers and finger has been around for atleast MIN_FINGER_VISIBLE_TIME
      
      // check if finger is inside this GUI Element/button
      // if it is, add the passed time to *fingerOverTime*, so we can see
      // how long the finger has been hovering over the button
      if (this.boundingBox.contains((int) fingerPos.x, (int) fingerPos.y)) {
        if (fingerOverTime == 0.0) {
          fingerOverTime = 1.0;
          fingerOverStarted = millis();
        } else {
          fingerOverTime =+ millis() - fingerOverStarted;
        }
      } else {
        // no finger on the gui element
        fingerOverTime = 0.0;
      }
    }    
  }
  
    void update() {
      if(this.opacityDownAnimation == true){
        opacity -= 7.0;
        opacity = constrain(opacity, 0, 255);
        if(opacity <= 1) opacityDownAnimation = false;
      } else if( opacity < 255){
         opacity += 7.0;
         opacity = constrain(opacity,0, 255);
      }
      if(draggable) updateDrag();
      updateFingerState();
      if(fingerOverTime > 0){
        hoverAnimationProgress = fingerOverTime / hoverAnimationDuration;        
      }
  }

  void display() {
    //only displaying functionality here
    if (pixelImage != null) {
      if (fingerOverTime > 0.0) {
        tint(255, map(hoverAnimationProgress, 0.0, 1.0, 255, 0));
        image(pixelImage, boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height);
        tint(255, map(hoverAnimationProgress, 0.0, 1.0, 0, 255));
        image(pixelHoverImage, boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height);
      } 
      else {
        tint(255, opacity);
        image(pixelImage, boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height);
        noTint();
      }
    }
    else if (vectorImage != null) {
      if (fingerOverTime > 100.0) {
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
