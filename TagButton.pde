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
      font = createFont("RobotoCondensed-Bold", 16);
    }
  }


  void updateDrag() {
    //change draggedTag to this / remove. if necessary
    boolean draggedBeforeUpdate = this.dragged;
    super.updateDrag();
    //if(draggedTag != null && draggedTag != this) return;
    if (this.dragged == true) 
    {
      println(this.text + " is dragged." );
      draggedTag = this;
    }
    
  }

  void update() {
    super.update();

    //we want action if we move a tag inside the scan area -> making it dissapear & adding the tag to the image
    if (draggedTag == this) {
    } 
    else if (draggedTag != this && addedTags.contains(this) == true && this.fingerOverTime > 750) {
      // hold finger to remove
      this.opacity = 0.0;
      this.opacityDownAnimation = true;
      this.boundingBox.setLocation(originalPosition.x, originalPosition.y);
      addedTags.remove(this);
    }
  }

  void display() {
    rectMode(CORNER);
    textFont(font);
    float x_, y_;
    x_ = this.boundingBox.x;
    y_ = this.boundingBox.y;

    // drawing the cyan rectangle
    if (fingerOverTime > 0) {
      fill(c, map(hoverAnimationProgress, 0.0, 1.0, 0, 255));
      noStroke();
    } 
    else {
      noFill();
      stroke(c, opacity);
      strokeWeight(1);
    }
    rect(x_, y_, this.boundingBox.width, this.boundingBox.height);

    // drawing the text
    if (fingerOverTime > 0.0) {
      fill(0, map(hoverAnimationProgress, 0.0, 1.0, 0, 255));
    } 
    else {
      fill(c, opacity);
    }
    rectMode(CENTER);
    textAlign(CENTER, CENTER);
    text(text, (float) this.boundingBox.getCenterX(), (float) this.boundingBox.getCenterY());
    //here custom graphics. not using a loaded image

    noTint();
  }
}
