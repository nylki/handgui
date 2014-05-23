/*
this linked list contains lists of tags for each display of tags
 that can be switched through with gestures.
 A maximum amount of tags can be set (depending on screen size).
 also amount of rows should be set.
 
 with selectNext(), selectPrevious(), select(int index)
 it should be possible to set a certain tag collection to be the selected
 These function will take care of setting taret locations for the tag objects
 and initialize all necessary animations. so that a fluid movement is visible.
 
 with remove(TagButton t) it should be possible to remove a tag from the current display
 (eg. when a tag is moved over to the scanning section). Then the dislay should be filled with a new
 tag from the previous List OR triggering a complete reordering.
 
 Reordering:
 sortAlphabetically()
 sortByFavorite()
 will reorder the linked lists.
 
 it should also be possible to access an underlying linked list of all tags, in their proper position.
 
 */

class TagMasterCollection extends LinkedList<LinkedList<TagButton>> {
  public LinkedList<TagButton> selectedGroup;
  private int selectionIndex = 0;
  private LinkedList<TagButton> allTags;
  public int maxTagsPerGroup;
  public int maxWidth;
  public Point location;
  public Rectangle dimension;
  Ani movingAni = null;
  

  public TagMasterCollection(Collection list, int _maxTagsPerGroup, Rectangle box) {
    super();
    this.maxTagsPerGroup = _maxTagsPerGroup;
    this.dimension = box;
    this.allTags = new LinkedList(list);
    println("about to sort alphabetically...");
    sortAlphabetically();
    println("finished sorting alphabetically.");
    println("starting group initialization...");
    initializeGroups();
    println("finished group initialization.");
    this.selectedGroup = this.get(0);
    this.fallFromTop(this.selectedGroup);
    for(TagButton t : this.selectedGroup) t.visible = true;
    printGroups();
  }
  
  private void printGroups(){
    int i=0;
    for(LinkedList<TagButton> group : this){
     println("group: " + i++);
     for(TagButton t : group)
       println(t.text);
    }
  }


  public void select(int index) {
    // move old selection to the right
    LinkedList<TagButton> oldSelectedGroup = selectedGroup;
    moveRight(oldSelectedGroup);
    selectionIndex = index;
    selectedGroup = this.get(selectionIndex);
    // let the new selection fall from the top
    fallFromTop(selectedGroup);
  }

  public void selectPrevious() {
      if(movingAni != null && movingAni.isPlaying()) return;
      
      selectionIndex = (selectionIndex - 1);
      if(selectionIndex < 0) selectionIndex = this.size() - 1;  
      println("new iterator index: " + selectionIndex);
      // move old selection to the right
      LinkedList<TagButton> oldSelectedGroup = selectedGroup;
      moveRight(oldSelectedGroup);
      
       selectedGroup = this.get(selectionIndex);
       setInitPositions(selectedGroup);
      // let the new selection fall from the top
      fallFromTop(selectedGroup);
    
  }

  public void selectNext() {
      if(movingAni != null && movingAni.isPlaying()) return;
    
      selectionIndex = (selectionIndex + 1) %  this.size();
      println("new iterator index: " + selectionIndex);
      // move old selection to the left
      LinkedList<TagButton> oldSelectedGroup = selectedGroup;
      moveLeft(oldSelectedGroup);
      
      selectedGroup = this.get(selectionIndex);
      // let the new selection fall from the top
      fallFromTop(selectedGroup);
  }

  private void moveRight(LinkedList<TagButton> l) {
    // moving the individual tags
    for (TagButton t : l) {
      // using sequences in the future for hand movement
      movingAni = Ani.to(t.dimension, 2.0, "x", t.dimension.x + width*2, Ani.QUAD_OUT);
    }
  }

  private void moveLeft(LinkedList<TagButton> l) {
    // moving the individual tags
    
    for (TagButton t : l) {
      // using sequences in the future for hand movement
      movingAni = Ani.to(t.dimension, 2.0, "x", t.dimension.x - width*2, Ani.QUAD_OUT);
    }
  }


  private void initializeGroups() {
    // initially adding tags to the groups (no positions yet, only amount of tags per group,
    // and as a result creation of groups
    
    // clearing previous list
    this.clear();
    
    int maxRows = this.dimension.height / (tagHeight + tagDistance);
    LinkedList<TagButton> curGroup;
    ListIterator<TagButton> it = allTags.listIterator();
    TagButton t;
    int curRow = 1;
    int newWidth = 0;

    while (it.hasNext ()) {
      curRow = 1;
      newWidth = 0;
      curGroup = new LinkedList<TagButton>();
      this.add(curGroup);
      while (curGroup.size() <= maxTagsPerGroup) {
        if (it.hasNext() == false) break;
        t = it.next();
        newWidth += (t.dimension.width + tagDistance*2);
        if (newWidth > this.dimension.width){
          println("increasing row for: " + t.text);
          curRow++;
          newWidth = 0;
        }
        if (curRow <= maxRows) {
          t.row = curRow;
          curGroup.add(t);
        } else {
           println("tag is overhanging, losing it (FIXME) : " + t.text); 
        }
      }
    }
  }
  

  private void setInitPositions(LinkedList<TagButton> l) {
    int horiz = this.dimension.x;
    int vert = this.dimension.y;
    int prevRow = 1;
    println("setinitpositions for group: " + this.indexOf(l));
    for(TagButton t : l){
      
      if(t.row > prevRow){
       prevRow = t.row;
       horiz = this.dimension.x;
       vert += tagHeight + tagDistance; 
      }
      println("setting positions for " + t.text + " with: " + horiz + ", " + vert);
      t.dimension.setLocation(horiz, vert); 
      horiz += t.dimension.width + tagDistance;
    }
  }

  private void fallFromTop(LinkedList<TagButton> l) {
    setInitPositions(l);
    for(TagButton t : l) t.visible = true;
    // then animate them to fall down (add the offset to the y location again)
    for (TagButton t : l) {
      t.dimension.y -= height/2;
      Ani.to(t.dimension, 1.5, "y", t.dimension.y + this.dimension.height, Ani.BOUNCE_OUT);
    }
  }



  public void removeTag(TagButton t) {
  }





  public void sortAlphabetically() {
    // this will go through allTags and create linkedLists for every n tags to be displayed at once
    Collections.sort(allTags);
    initializeGroups();
  }


  public void sortByFavorite() {
  }
  
}
