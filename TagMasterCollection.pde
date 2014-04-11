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
    allTags = new LinkedList(list);
    sortAlphabetically();
    groupIterator = this.listIterator();
  }




  public void select(int index) {
    // move old selection to the right
    moveRight(selectedGroup);
    selectedGroup = this.get(index);
    groupIterator = this.listIterator(index);
    // let the new selection fall from the top
    fallFromTop(selectedGroup);
  }

  public void selectPrevious() {
    // move old selection to the right
    moveRight(selectedGroup);
    selectedGroup = groupIterator.previous();
    // let the new selection fall from the top
    fallFromTop(selectedGroup);
  }

  public void selectNext() {
    // move old selection to the left
    moveLeft(selectedGroup);
    selectedGroup = groupIterator.next();
    // let the new selection fall from the top
    fallFromTop(selectedGroup);
  }

  private void moveRight(LinkedList<TagButton> l) {
    // moving the individual tags
    for (TagButton t : l) {
      Ani.to(t.dimension, 1, "x", min(width, t.dimension.x + 500), Ani.QUAD_OUT);
    }
  }

  private void moveLeft(LinkedList<TagButton> l) {
    // moving the individual tags
    for (TagButton t : l) {
      Ani.to(t.dimension, 1, "x", min(-(tagWidth), t.dimension.x - width), Ani.QUAD_OUT);
    }
  }

  private void setInitPositions(LinkedList<TagButton> l) {
    // TODO: check if we can do this for every group to determine its size etc.
    // and add tags that d not fit in one group to the next
    int curWidth = 0;
    int curHeight = 0;

    // first setting tags to their relative location with a negative vertical offset to be out of display
    int horizPos = this.dimension.x;
    int vertPos = this.dimension.y;

    // approach: add tags from top to bottom in a grid like manner
    for (TagButton t : l) {
      // if there is room for another tag, add it to the same row
      curWidth += t.dimension.width + tagDistance;
      if (curWidth <= this.dimension.width) {
        t.dimension.setLocation(horizPos, vertPos);
        horizPos = curWidth;
      } 
      else {
        // otherwise try to add it in a next row
        curWidth = t.dimension.width + tagDistance;
        vertPos = curHeight;
        horizPos = this.dimension.x;
        curHeight = vertPos + (t.dimension.height + tagDistance);
        if (curHeight <= this.dimension.height) {
          t.dimension.setLocation(horizPos, vertPos);
        } else {
          break;
        }
      }
    }
  }

    private void fallFromTop(LinkedList<TagButton> l) {

      setInitPositions(l);
      // then animate them to fall down (add the offset to the y location again)
      for (TagButton t : l){
        t.dimension.y -= this.dimension.height;
        Ani.to(t.dimension, 1, "y", t.dimension.y + this.dimension.height, Ani.QUAD_OUT);
        
      }
    
    
  }



  public void removeTag(TagButton t) {
  }




  public void sortAlphabetically() {
    // this will go through allTags and create linkedLists for every n tags to be displayed at once
    Collections.sort(allTags);

    // clearing previous list
    this.clear();

    // creating new groups
    int i = 0;
    while (i <= allTags.size ()) {
      LinkedList<TagButton> curGroup = new LinkedList<TagButton>();
      for (int curCount = 0; curCount <= maxTagsPerGroup; curCount++) {
        curGroup.add(allTags.get(i));
      }
      this.add(curGroup);
    }
  }


  public void sortByFavorite() {
  }
}
