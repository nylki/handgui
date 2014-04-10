class TagButton extends GuiElement {
  int tagClass;  // either KEYWORD or CATEGORY
  String text;
  PFont font;
  // we might want to change the color to match the wanted color
  color rectStrokeColor = color(50, 180, 220);
  color rectFillColor = color(0);
  color textColor = color(50, 180, 220);
  Rectangle originalPosition;
  boolean draggedBeforeUpdate;
  float scaleFactor = 1.0;
  Ani hoverAni_scale = new Ani(this, 0, "scaleFactor", 1.0);
  Ani hoverAni_translatex = new Ani(this, 0, "scaleFactor", 1.0);
  Ani hoverAni_translatey = new Ani(this, 0, "scaleFactor", 1.0);
  boolean selected = false;



  TagButton(int x_, int y_, Integer width_, Integer height_, String text_, PFont font_) {
    super(x_, y_, width_, height_);

    originalPosition = new Rectangle();
    originalPosition.x = this.boundingBox.x;
    originalPosition.y = this.boundingBox.y;
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

    // repeat yoyo style (go up and down)
  }


  void updateDrag() {
    //change draggedTag to this / remove. if necessary
    draggedBeforeUpdate = this.dragged;
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
    if (fingerOverTime > 0 && hoverAni_scale.isPlaying() == false && selectedTag == null) {
      selectedTag = this;
      originalPosition.x = this.boundingBox.x;
      originalPosition.y = this.boundingBox.y;
      originalPosition.width = this.boundingBox.width;
      originalPosition.height = this.boundingBox.height;
      hoverAni_scale = Ani.to(this.boundingBox, 0.2, "width", this.boundingBox.width * 2.2, Ani.BOUNCE_IN);
      Ani.to(this.boundingBox, 0.2, "height", this.boundingBox.height * 2.2, Ani.BOUNCE_IN);
      Ani.to(this.boundingBox, 0.2, "x", this.boundingBox.x - 40, Ani.BOUNCE_IN);
      Ani.to(this.boundingBox, 0.2, "y", this.boundingBox.y - 40, Ani.BOUNCE_IN);
    } 
    else if (fingerOverTime == 0 && selectedTag == this) {
      println("returning tagsize");
      selectedTag = null;
      
      hoverAni_scale = Ani.to(this.boundingBox, 0.2, "x", originalPosition.x, Ani.BOUNCE_OUT);
      Ani.to(this.boundingBox, 0.2, "y", originalPosition.y, Ani.BOUNCE_OUT);
      Ani.to(this.boundingBox, 0.2, "width", originalPosition.width, Ani.BOUNCE_OUT);
      Ani.to(this.boundingBox, 0.2, "height", originalPosition.height, Ani.BOUNCE_OUT);
    }



    if (draggedTag != this && addedTags.contains(this) == true && this.fingerOverTime > 750) {
      // hold finger to remove
      /*
      this.opacity = 0.0;
       this.opacityDownAnimation = true;
       this.boundingBox.setLocation(originalPosition.x, originalPosition.y);
       addedTags.remove(this);
       	  */
    }

    // not dragging anymore, check if we are inside the scanArea

    if (draggedBeforeUpdate == true && dragged == false) {
      if (scanArea.boundingBox.contains(this.boundingBox.x, this.boundingBox.y)) {
        addedTags.add(this);
      } 
      else {
        addedTags.remove(this);
        this.moveTo(originalPosition.x, originalPosition.y, 2.0);
      }
    }
  }

  void display() {
    rectMode(CORNER);
    textFont(font);
    
    if(selectedTag == null){
      rectStrokeColor = color(50, 180, 220);
      rectFillColor = color(0);
      textColor = color(50, 180, 220);
    } else if(selectedTag == this || this.dragged == true){
      rectStrokeColor = color(0);
      rectFillColor = color(50, 180, 220);
      textColor = color(0);
    } else{
      rectStrokeColor = color(50, 180, 220, 128);
      rectFillColor = color(0, 128);
      textColor = color(50, 180, 220, 128); 
      
    }
    
    // drawing the cyan rectangle
    fill(rectFillColor);
    stroke(rectStrokeColor);
    // calculate new size depending on scaleFactor (changed when hovering eg.)
    float newWidth = boundingBox.width;
    float newHeight = boundingBox.height;
    float x_ = this.boundingBox.x;
    float y_ = this.boundingBox.y;
    rect(x_, y_, newWidth, newHeight);
    noStroke();

    rectMode(CENTER);
    textAlign(CENTER, CENTER);
    fill(textColor);
    text(text, (float) this.boundingBox.getCenterX(), (float) this.boundingBox.getCenterY());
    //here custom graphics. not using a loaded image
    noTint();
  }
}
