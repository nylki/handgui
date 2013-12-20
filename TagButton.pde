class TagButton extends GuiElement{
  String text;
  PFont font;
  
  
  
    TagButton(int x_, int y_, Integer width_, Integer height_, String text_, PFont font_){
    super(x_, y_, width_, height_); 
    if(text_ != null){
      text = text_;
    } else {
      text = "n/a";
    }
    
    if(font_ != null){
      font = font_;
    } else {
      font = createFont("RobotoCondensed-Bold", 40);
    } 
  }
  
  
  
  
  
  
  
  void display() {
    textFont(font);
    
    
    // drawing the cyan rectangle
    noStroke();
    fill(0,170,255);
    rectMode(CORNER);
    rect(this.boundingBox.x, this.boundingBox.y, this.boundingBox.width, this.boundingBox.height);
    
    // drawing the black text
    fill(0,0,0);
    rectMode(CENTER);
    textAlign(CENTER, CENTER);
    text(text, (float) this.boundingBox.getCenterX(), (float) this.boundingBox.getCenterY());
   //here custom graphics. not using a loaded image 
    
    
    
  }
  
  
}
