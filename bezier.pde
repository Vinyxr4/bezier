PVector[] controlPoints = new PVector[0];
int[] endPoints = new int[0];

PVector pointToMesure = new PVector[0];

void setup() {
 size(1024, 600);
 strokeWeight(2);
}

boolean flag = false;
boolean showPoints = true;

void mousePressed() {
  if(flag) {
    controlPoints = append(controlPoints, new PVector(mouseX, mouseY));
  }
}

void keyPressed() {
  if(key == 'c' || key == 'C') {
    controlPoints = new PVector[0];
    endPoints = new int[0];
   }
   if(key == 's') {
     flag = true;
   }

   if(key == 'e') {
    flag = false;

    if(controlPoints.length != 0 && (endPoints.length == 0 || controlPoints.length != endPoints[endPoints.length-1])) {
      endPoints = append(endPoints, controlPoints.length);
    }
   }

   if(key == 'p') {
     showPoints = !showPoints;
   }
}

void drawCurve(PVector[] points, color c) {
  stroke(c);
  
  for(int i = 0; i < points.length - 1; ++i) {
    first = points[i];
    second = points[i+1];

    line(first.x, first.y, second.x, second.y)
  }
}

PVector[] evaluateBezierCurve(points, degree, sampleSize) {
  PVector[] curved = new PVector[0];

  for(int i = 0; i <= sampleSize; ++i) {
    float t = i / sampleSize;
    
    point = evaluateCurvePoint(points, t, degree);
    curved = append(curved, point);
  }

  return curved;
}

PVector evaluateCurvePoint(points, t, degree) {
  PVector[] n = points;
  
  for(int i = 0; i < degree; ++i) {
    PVector[] nn = new PVector[0];
  
    for(int j = 0; j < n.length - 1; ++j) {
      point = PVector.add(PVector.mult(n[j+1], t), PVector.mult(n[j], 1-t));
      
      nn = append(nn, point);
    }

    n = nn;
  }

  return n[0];
}

PVector[] drawBezierCastejau(points, samples, degree) {
  PVector[] curvePoints = new PVector[0];
  
  curvePoints = evaluateBezierCurve(points, degree, samples + 2);
  
  drawCurve(curvePoints, color(255, 0, 0));

  return curvePoints
}

float distanceToCurve(PVector point, PVector[] curvePoints) {
  float distance = 10e6;
    
  for(int i = 0; i < curvePoints.length - 1; ++i) {
    PVector A = curvePoints[i];
    PVector B = curvePoints[i + 1];

    diffCurve = PVector.sub(A, B);
    diffPoint = PVector.sub(A, point);

    dot = PVector.dot(diffPoint, diffCurve);
    mag = diffCurve.magSq();

    float t = dot / mag;
    float minT = t < 0 ? 0 : (t > 1 ? 1 : t);

    PVector minPoint = PVector.lerp(A, B, minT);
    newDistance = PVector.dist(point, minPoint);

    distance = newDistance < distance ? newDistance : distance;
  }

  return distance;
}

void draw () {
  background(0);

  PVector[] control = new PVector[0];
  PVector[] closestCurvePoints = new PVector[0];
  
  float distance = 10e6;
  int j = 0;

  for(int i = 0; i < controlPoints.length; ++i) {
    if(j < endPoints.length && endPoints[j] - 1 == i) {
      control = append(control, controlPoints[i]);

      curvePoints = drawBezierCastejau(control, 40, control.length - 1);

      if(mousePressed && !flag) {
        currentDistance = distanceToCurve(new PVector(mouseX, mouseY), curvePoints);
        tempDistance = currentDistance < distance ? currentDistance : distance;
        
        closestCurvePoints = currentDistance < distance ? curvePoints : closestCurvePoints;
        distance = tempDistance;
      }

      control = new PVector[0];
      ++j;
    } else {
      control = append(control, controlPoints[i]);
    }
  }

  if(mousePressed && !flag) {    
    drawCurve(closestCurvePoints, color(0, 255, 0));
  }
  
  if(showPoints) {
    stroke(255);

    for(int i = 0; i < controlPoints.length; i++) {     
      int x = controlPoints[i].x;
      int y = controlPoints[i].y;
      
      ellipse(x, y, 10, 10);
    }
  }
}
