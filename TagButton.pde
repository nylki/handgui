class TagButton extends GuiElement {
  String text;
  PFont font;
  // we might want to change the color to match the wanted color
  color c = color(50, 180, 220);
  Rectangle originalPosition;



  TagButton(int x_, int y_, Integer width_, Integer height_, String text_, PFont font_) {
    super(x_, y_, width_, height_);
    originalPosition = new Rectangle(this.boundingBox);
    this.draggable = true;
    if (text_ != null) {
      text = text_.toUpperCase();
    } 
    else {
      text = "n/a";
    }

    if (font_ != null) {
      font = font_;
    } 
    else {
      font = createFont("RobotoCondensed-Bold", 18);
    }
  }
  
  
  void updateDrag(){
    boolean draggedBeforeUpdate = this.dragged;
    super.updateDrag();
    if(this.dragged == true && draggedBeforeUpdate == false){
      //just started the drag
      draggedTags.add(this); 
    } else if (this.dragged == false && draggedBeforeUpdate == true){
      //todo: this should do nothing
     //draggedTags.remove(this);
    } 
  }

  void update() {
    super.update();

    //we want action if we move a tag inside the scan area -> making it dissapear & adding the tag to the image
    if (draggedTags.contains(this)) {
      if (leap.hasFingers() == false) {
        if(addedTags.contains(this) == false) 
          this.boundingBox.setLocation(originalPosition.x, originalPosition.y);
        draggedTags.remove(this);
        // if this is an added tag, the finger is removed
        //if (addedTags.contains(this)) addedTags.remove(this);
      } 
      else /* if leap has fingers */ {
        //do nothing, as location setting will be done for all elements around the fingerposition
        //this.boundingBox.setLocation((int) (fingerPos.x - this.boundingBox.width/2), (int) (fingerPos.y - this.boundingBox.height/2));
      }
      
      // if tag/finger is inside scan area -> either add it to the current photo, or make it dragging again to remove it
      //TODO: implement previousFinder so we can check wether finger was in ther ebefore
      if (scanArea.boundingBox.contains(fingerPos.x, fingerPos.y)) {
        if (addedTags.contains(this) == false) {

          println("adding " + this.text + " to the element");
          addedTags.add(this);
          draggedTags.remove(this);
          globalElementDragged = false;
          this.fingerOverTime = 0;
        } 
        else {
          draggedTags.add(this);
          if(addedTags.contains(this)) {
            this.boundingBox.setLocation(originalPosition.x, originalPosition.y);
            addedTags.remove(this);
            draggedTags.remove(this);
            
          }
        }
      }
    }
  }


  void display() {
    textFont(font);
    float x_, y_;
    x_ = this.boundingBox.x;
    y_ = this.boundingBox.y;

    // drawing the cyan rectangle
    rectMode(CORNER);
    if (fingerOverTime > 100.0) {
      fill(c);
      noStroke();
    } 
    else {
      noFill();
      stroke(c);
      strokeWeight(1);
    }
    rect(x_, y_, this.boundingBox.width, this.boundingBox.height);

    // drawing the text
    if (fingerOverTime > 100.0) {
      fill(0);
    } 
    else {
      fill(c);
    }
    rectMode(CENTER);
    textAlign(CENTER, CENTER);
    text(text, (float) this.boundingBox.getCenterX(), (float) this.boundingBox.getCenterY());
    //here custom graphics. not using a loaded image
  }
}
