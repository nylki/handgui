class TagButton extends GuiElement implements Comparable<TagButton> {
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
  boolean visible = false;
  int row;



  TagButton(int x_, int y_, Integer width_, Integer height_, String text_, PFont font_) {
    super(x_, y_, width_, height_);

    originalPosition = new Rectangle();
    originalPosition.x = this.dimension.x;
    originalPosition.y = this.dimension.y;
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
      font = createFont("RobotoCondensed-Bold", 24);
    }
  }

  @Override
    public int compareTo(TagButton other) {
    int result = this.text.compareTo(other.text);
    return result;
  }


  void updateDrag() {
    // change draggedTag to this.
	// saving previous dragging state, so we can see if a tag just got dropped
    draggedBeforeUpdate = this.dragged;
    super.updateDrag();
    if (this.dragged == true) 
    {
      println(this.text + " is dragged." );
      draggedTag = this;
    }
  }

  void update() {
    super.update();
    if (allowSelect && hoverAni_scale.isPlaying() == false && justSelected == false) {
      selectedTag = this;
      justSelected = true;
      originalPosition.x = this.dimension.x;
      originalPosition.y = this.dimension.y;
      originalPosition.width = this.dimension.width;
      originalPosition.height = this.dimension.height;
      hoverAni_scale = Ani.to(this.dimension, 0.2, "width", this.dimension.width * 2, Ani.BOUNCE_IN_OUT);
      Ani.to(this.dimension, 0.2, "height", this.dimension.height * 2, Ani.BOUNCE_IN_OUT);
      Ani.to(this.dimension, 0.2, "x", this.dimension.x - 40, Ani.BOUNCE_IN_OUT);
      Ani.to(this.dimension, 0.2, "y", this.dimension.y - 40, Ani.BOUNCE_IN_OUT);
    } 
    else if (justSelected == true && allowSelect == false && selectedTag == this && hoverAni_scale.isPlaying() == false) {
      selectedTag = null;
      justSelected = false;
      hoverAni_scale = Ani.to(this.dimension, 0.2, "x", originalPosition.x, Ani.BOUNCE_IN_OUT);
      Ani.to(this.dimension, 0.2, "y", originalPosition.y, Ani.BOUNCE_IN_OUT);
      Ani.to(this.dimension, 0.2, "width", originalPosition.width, Ani.BOUNCE_IN_OUT);
      Ani.to(this.dimension, 0.2, "height", originalPosition.height, Ani.BOUNCE_IN_OUT);
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
      if (scanArea.dimension.contains(this.dimension.x, this.dimension.y)) {
        addedTags.add(this);
      } 
      else { // remove tag from the added list (swipe gesture would be nice here)
        addedTags.remove(this);
        this.moveTo(originalPosition.x, originalPosition.y, 2.0);
      }
    }
  }

  void display() {
    println("allow drag? " + this.allowDrag);
    if(this.visible == false) return;
    rectMode(CORNER);
    textFont(font);

    if (selectedTag == null) {
      rectStrokeColor = color(50, 180, 220);
      rectFillColor = color(0);
      textColor = color(50, 180, 220);
    } 
    else if (selectedTag == this || this.dragged == true) {
      
      rectStrokeColor = color(0);
      if(this.allowDrag) rectStrokeColor = color(0,255,0);

      rectFillColor = color(50, 180, 220);
      
      textColor = color(0);
    } 
    else {
      rectStrokeColor = color(50, 180, 220, 128);
      rectFillColor = color(0, 128);
      textColor = color(50, 180, 220, 128);
    }

    // drawing the cyan rectangle
    fill(rectFillColor);
    stroke(rectStrokeColor);
    // calculate new size depending on scaleFactor (changed when hovering eg.)
    float newWidth = dimension.width;
    float newHeight = dimension.height;
    float x_ = this.dimension.x;
    float y_ = this.dimension.y;
    rect(x_, y_, newWidth, newHeight);
    noStroke();

    rectMode(CENTER);
    textAlign(CENTER, CENTER);
    fill(textColor);
    text(text, (float) this.dimension.getCenterX(), (float) this.dimension.getCenterY());
    //here custom graphics. not using a loaded image
    noTint();
  }
}
