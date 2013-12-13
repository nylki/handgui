class TagButton extends GuiElement{
  String text;
  PFont font;
  // we might want to change the color to match the wanted color
  color c = color(50, 180, 220);
  
  
  
 TagButton(int x_, int y_, Integer width_, Integer height_, String text_, PFont font_) {
    super(x_, y_, width_, height_);
    this.draggable = false;
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
  
  void update( ){
    super.update();
    
    //we want action if we move a tag inside the scan area -> making it dissapear & adding the tag to the image
    if(scanArea.boundingBox.contains(this.boundingBox.getCenterX(), this.boundingBox.getCenterY())){
      println("adding " + this.text + " to the element");
      tags.remove(this);
      globalElementDragged = false;
    }
    
    // creating a copy of the tag if user is over the tag more than seconds
    // TODO: as we only have the same tag once -> we can actually use the tag itself, drag it, and if dropped on the area, add it to the image, otherwise
    // let it move back to its position. If a photo was succesfully taken: let all tags bounce back to their initial position
    //if we take a photo
    if( (this.fingerOverTime > 1000.0) && this.draggable == false){
      TagButton copiedTag = new TagButton(this.boundingBox.x, this.boundingBox.y, this.boundingBox.width, this.boundingBox.height, this.text, this.font);
      copiedTag.draggable = true;
      copiedTag.dragged = true;
      copiedTag.fingerOverTime = 1600;
      println("adding copied tag");
      tags.add(copiedTag);
      this.fingerOverTime = 0.0;
      
     //create a copy and let that be draggable!
    } else if(this.draggable == true){
      if(this.fingerOverTime == 0) {
        tags.remove(this);
        globalElementDragged = false;
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
    } else {
      fill(c);
    }
    rectMode(CENTER);
    textAlign(CENTER, CENTER);
    text(text, (float) this.boundingBox.getCenterX(), (float) this.boundingBox.getCenterY());
    //here custom graphics. not using a loaded image
  }
  
  
}
