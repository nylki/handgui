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

  void update( ) {
    super.update();

    //we want action if we move a tag inside the scan area -> making it dissapear & adding the tag to the image
    if (this.dragged == true) {
      if ((this.fingerOverTime == 0)) {
        this.boundingBox.setLocation(originalPosition.x, originalPosition.y);
        if (addedTags.contains(this)) addedTags.remove(this);
        globalElementDragged = false;
      } 
      else {
        this.boundingBox.setLocation((int) (fingerPos.x - this.boundingBox.width/2), (int) (fingerPos.y - this.boundingBox.height/2));
      }
      
      // if tag is inside scan area -> either add it to the current photo, or make it dragging again to remove it
      if (scanArea.boundingBox.contains(this.boundingBox.getCenterX(), this.boundingBox.getCenterY())) {
        if (addedTags.contains(this) == false) {

          println("adding " + this.text + " to the element");
          addedTags.add(this);
          globalElementDragged = false;
          this.fingerOverTime = 0;
        } 
        else {

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
