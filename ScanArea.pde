class ScanArea extends GuiElement {
  float brightness = 0.0;
  int photoStarted = 0;
  boolean calibrated;
  //Rectangle calibratedDimensions = null;
  PImage lastPhoto, calibrationPhoto;
  ArrayList<Contour> lastContours = new ArrayList<Contour>();
  int timeSinceLaunch = 0;                
  int opencvThreshold = 230;
  //canonicalPoints will be determined by calling calibrate()
  Point[] canonicalPoints = new Point[4];
  Point[] unwarpedPoints = new Point[4];
  PImage distortedImage;

  Rectangle refSize;
  Ani photoTakingAnimation;


  ScanArea(int x_, int y_, PShape img, PShape hoverImg, Integer width_, Integer height_) {
    super(x_, y_, img, hoverImg, width_, height_);  
    this.calibrated = false;
    photoTakingAnimation = new Ani(this, 2.0, "brightness", 180, Ani.EXPO_IN_OUT, "onEnd:photoFinished");
  }

  ScanArea(int x_, int y_, PImage img, PImage hoverImg, Integer width_, Integer height_) {
    super(x_, y_, img, hoverImg, width_, height_); 
    this.calibrated = false;
    photoTakingAnimation = new Ani(this, 2.0, "brightness", 180, Ani.EXPO_IN_OUT, "onEnd:photoFinished");
  }


  PImage warpPerspective(PImage inputImage, Point[] distortedPoints, Point[] referencePoints, Rectangle referenceSize) {
    opencv.loadImage(inputImage);
    MatOfPoint2f referenceMarker = new MatOfPoint2f(referencePoints);
    MatOfPoint2f distortedMarker = new MatOfPoint2f(distortedPoints);

    // now we calculate the transformation matrix
    Mat transform = Imgproc.getPerspectiveTransform(distortedMarker, referenceMarker);
    //resulting image as opencv Mat and processing PImage
    Mat resultingImage = new Mat(referenceSize.width, referenceSize.height, CvType.CV_8UC1);
    PImage resultingPImage = new PImage(referenceSize.width, referenceSize.height);
    //calling the actual opencv function to warp the perspective
    //using the inputImage (opencv.getColor()), aplying the transformation Matrix (transform) to make the resultingImage 
    // match the size of referenceSize, which is our scanArea
    Imgproc.warpPerspective(opencv.getColor(), resultingImage, transform, new Size(referenceSize.width, referenceSize.height));

    opencv.toPImage(resultingImage, resultingPImage);
    return resultingPImage;
  }


  void showCalibrationImage() {
    //displaying 1 blue rectangles
    float w = this.dimension.width;
    float h = this.dimension.height;
    fill(0, 0, 255); 
    rect(0, 0, w, h); 
    println("showed calibration image");
  }

  void calibrate() {
    
    if (timeSinceLaunch == 0) timeSinceLaunch = millis();
    if (cam.available() == true && (millis() - timeSinceLaunch > 1000) /* waiting a second before calibrating */) {
      println("now taking calibration photo");
      cam.read();
      opencv.loadImage(cam);
      //loading the new camera snapshot into the opencv object and use the blue color channel
      PImage blueChannel = opencv.getSnapshot(opencv.getB());
      calibrationPhoto = opencv.getSnapshot(opencv.getB());
      opencv.loadImage(blueChannel);
      opencvThreshold += 0.5;
      opencv.threshold(opencvThreshold);
      ArrayList<Contour> contours = opencv.findContours();

      // if no contours found, return and try again with increased threshold next time (see few lines above)
      if (contours.size() < 1) return;
      //otherwise getting the biggest contour and using it as a candidate for the scan areas square

      Contour candidateContour = null;
      float biggestSize = 0.0;
      for (Contour contour : contours) {
        float curSize = (float) (contour.getBoundingBox().getHeight() * contour.getBoundingBox().getWidth());
        if (curSize > biggestSize && curSize > (500*500)) {
          biggestSize = curSize;
          candidateContour = contour;
        }
      }

      //now that we have a big contour which might be our scan area square, we need
      // to limit the corners of the contour to 4 (effectively making it a rectangle)
      // we change the polygionApproximationFactor until the number of points on our
      // polygon is exactly 4
      if (candidateContour != null) {
        candidateContour.setPolygonApproximationFactor(0);
        double currentFactor = 0;
        double optimalFactor = 0;
        double factorIncrease = 0.2;
        int pointCount = candidateContour.getPolygonApproximation().numPoints();

        //loop to get the amounts of points to exactly 4
        while (pointCount != 4 && currentFactor < 60) {
          //here we could also use binary search to optimize, but right now its fast enough
          currentFactor+=factorIncrease;
          candidateContour.setPolygonApproximationFactor(currentFactor);
          pointCount = candidateContour.getPolygonApproximation().numPoints();
        }
        // if we found a factor that produces a 4 point polygon, lets get the optimum value
        // by increasing the factor further until we hit 5 points. then calculate the median
        // of the minimum factor and the maximum factor that produces 4 point polygons.
        double minFactor = currentFactor;
        if (pointCount == 4) {
          while (pointCount != 5 && currentFactor < 60) {
            currentFactor+=factorIncrease;
            candidateContour.setPolygonApproximationFactor(currentFactor);
            pointCount = candidateContour.getPolygonApproximation().numPoints();
          }
        }
        if (pointCount == 5) {
          optimalFactor = (minFactor + currentFactor - factorIncrease) / 2;
        } 
        else {
          optimalFactor = minFactor;
        }

        //set the Polygon approximation factor to the calculated optimum value and display ito
        candidateContour.setPolygonApproximationFactor(optimalFactor);

        if (candidateContour.getPolygonApproximation().numPoints() == 4) {
          Contour polygonalApprox =  candidateContour.getPolygonApproximation();
          // set the unwarpedPoints to the found polygon
          ArrayList<PVector> polygonPoints = polygonalApprox.getPoints();

          refSize = new Rectangle(0, 0, cam.height, (int) (((float) dimension.height) *  ((float) cam.height) / ((float) dimension.width)));


          println("this.boundingBox = " + this.dimension.width + ", " + this.dimension.height);
          //println("refSize = " + cam.height + ", " + (int) ( ((float) this.boundingBox.height) *  ((float) ((float) cam.height) / ((float) this.boundingBox.width))));
          //refSize = eg (480, 800 * (480/960)) = (480,400)

          //refSize = new Rectangle(0, 0, 480, 400);

          unwarpedPoints[0] = new Point(polygonPoints.get(0).x, polygonPoints.get(0).y);
          unwarpedPoints[1] = new Point(polygonPoints.get(1).x, polygonPoints.get(1).y);
          unwarpedPoints[2] = new Point(polygonPoints.get(2).x, polygonPoints.get(2).y);
          unwarpedPoints[3] = new Point(polygonPoints.get(3).x, polygonPoints.get(3).y);


          canonicalPoints[0] = new Point(refSize.width, 0);
          canonicalPoints[1] = new Point(0, 0);
          canonicalPoints[2] = new Point(0, refSize.height);
          canonicalPoints[3] = new Point(refSize.width, refSize.height);

          calibrated = true;

          calibrationPhoto.save("scanbereich.jpg");
          println("calibration complete");
        }
      }
    }
  }  

  void takePhoto() {
    photoStarted = millis();
    photoTakingAnimation.start();
    // the next time scanArea is updated and checkTakingPhoto() is called
    // it will do the steps to take a photo because photoStarted != 0
    // but the time when the photo process started.
    // the process currently consists of increasing light
    // and the actual photo taking and geometrical transformations
  }

  void photoFinished(Ani _animation) {
    while (cam.available () == false) {
      delay(100);
    };
    println("now taking photo");
    cam.read();
    lastPhoto = warpPerspective(cam, unwarpedPoints, canonicalPoints, refSize);
    brightness = 0;
    photoStarted = 0;
  
}


void update() {

  if (calibrated == false) {
    println("caibrated false");
    calibrate();
    return;
  } 

  super.update();

  //if you want to see the calibration image with the recognized box, uncomment the following lines:
  // show calibrated shape with red
  /*
     fill(255,0,0);
   strokeWeight(3);
   stroke(128,128,128);
   beginShape();
   
   image(calibrationPhoto,0,0);
   vertex((float) unwarpedPoints[0].x,(float) unwarpedPoints[0].y); vertex((float) unwarpedPoints[1].x,(float) unwarpedPoints[1].y); 
   vertex((float) unwarpedPoints[2].x, (float) unwarpedPoints[2].y); vertex((float) unwarpedPoints[3].x, (float) unwarpedPoints[3].y); 
   endShape(CLOSE);*/
}

void display() {  
  //showing white >>flash<< when photostarte
  if (photoStarted > 0) {
    fill(brightness);
    rectMode(CORNER);
    rect(0, 0, width, height);
    return;
  }

  if (pixelImage != null) {
    fill(0);
    rect(dimension.x, dimension.y, dimension.width, dimension.height);

    if (fingerOverTime > 100.0) {
      image(pixelHoverImage, dimension.x, dimension.y, dimension.width, dimension.height);
    } 
    else {
      image(pixelImage, dimension.x, dimension.y, dimension.width, dimension.height);
    }
  }
  else if (vectorImage != null) {
    if (fingerOverTime > 100.0) {
      shape(vectorHoverImage, dimension.x, dimension.y, dimension.width, dimension.height);
    } 
    else {
      shape(vectorImage, dimension.x, dimension.y, dimension.width, dimension.height);
    }
  }
}
}
