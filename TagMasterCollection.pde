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
  public LinkedList<TagButton> oldSelectedGroup;
  private LinkedList<TagButton> allTags;
  public ListIterator<LinkedList<TagButton>> groupIterator;
  public int maxTagsPerGroup;
  public int maxWidth;
  public Point location;
  public Rectangle dimension;

  public TagMasterCollection(Collection list, int _maxTagsPerGroup, Rectangle box) {
    super();
    this.maxTagsPerGroup = _maxTagsPerGroup;
    this.dimension = box;
    this.allTags = new LinkedList(list);
    println("about to sort alphabetically");
    sortAlphabetically();
    println("finished sorting alphabetically");
    groupIterator = this.listIterator();
    this.selectedGroup = this.get(0);
    this.fallFromTop(this.selectedGroup);
  }




  public void select(int index) {
    // move old selection to the right
    oldSelectedGroup = selectedGroup;
    moveRight(oldSelectedGroup);
    selectedGroup = this.get(index);
    groupIterator = this.listIterator(index);
    // let the new selection fall from the top
    fallFromTop(selectedGroup);
  }

  public void selectPrevious() {
    if (groupIterator.hasPrevious()) {
      // move old selection to the right
      oldSelectedGroup = selectedGroup;
      moveRight(oldSelectedGroup);

      selectedGroup = groupIterator.previous();
      // let the new selection fall from the top
      fallFromTop(selectedGroup);
    }
  }

  public void selectNext() {
    if (groupIterator.hasNext()) {
      // move old selection to the left
      oldSelectedGroup = selectedGroup;
      moveLeft(oldSelectedGroup);
      selectedGroup = groupIterator.next();
      // let the new selection fall from the top
      fallFromTop(selectedGroup);
    }
  }

  private void moveRight(LinkedList<TagButton> l) {
    // moving the individual tags
    for (TagButton t : l) {
      Ani.to(t.dimension, 2, "x", width + tagWidth + 50, Ani.QUAD_OUT);
    }
  }

  private void moveLeft(LinkedList<TagButton> l) {
    // moving the individual tags
    for (TagButton t : l) {
      Ani.to(t.dimension, 2, "x", -tagWidth - 50, Ani.QUAD_OUT);
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
      while (curRow <= maxRows) {
        if (it.hasNext() == false) break;
        t = it.next();
        newWidth += t.dimension.width;
        if (newWidth > this.dimension.width){
          curRow++;
          newWidth = 0;
        }
        if (curRow <= maxRows) {
          curGroup.add(t);
          t.row = curRow;
        }
      }
    }
  }
  




  private void setInitPositions(LinkedList<TagButton> l) {
    int horiz = this.dimension.x;
    int vert = this.dimension.y;
    int prevRow = 1;
    for(TagButton t : l){
      if(t.row > prevRow){
       prevRow = t.row;
       horiz = this.dimension.x;
       vert += tagHeight + tagDistance; 
      }
      t.dimension.setLocation(horiz, vert); 
      horiz += t.dimension.width;
    }
  }

  private void fallFromTop(LinkedList<TagButton> l) {
    setInitPositions(l);
    // then animate them to fall down (add the offset to the y location again)
    for (TagButton t : l) {
      t.dimension.y -= 500;
      Ani.to(t.dimension, 0.9, "y", t.dimension.y + 500, Ani.QUAD_OUT);
    }
    this.selectedGroup = l;
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
