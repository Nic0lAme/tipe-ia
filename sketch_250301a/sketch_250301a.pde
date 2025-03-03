import java.util.HashSet;

void setup() {
  size(2180, 400);
  
  noLoop();
}

int wordMarge = 3;
int lineMarge = 8;

void draw() {
  PImage img = loadImage("./Message - NicolasMA.jpg");
  img.resize(width, height);
  image(img, 0, 0);
  
  img.filter(THRESHOLD, 0.5);  
  
  ArrayList<ArrayList<PVector>> chars = ContourDetection(img, 20);
  println(chars.size());
  
  ArrayList<int[]> rects = new ArrayList<int[]>();
  for(ArrayList<PVector> c : chars) {
    if(!IsClockwise(c)) continue;
    
    int[] rect = RectFromContour(c);
    //if(rect[2] / rect[3] > 10 || rect[2] / rect[3] < 0.1) continue;
    
    rects.add(rect);
  }
  
  
  
  for(int[] r : rects) {
    stroke(255,0,0);
    noFill();
    rect(r[0], r[1], r[2], r[3]);
    
    fill(255, 0, 0);
    //text(chars.indexOf(c), rect[0], rect[1] - 10);
  }
  
  ArrayList<ArrayList<int[]>> words = RectGroups(rects, 1.4, 1.2);
  ArrayList<int[]> wordsRects = new ArrayList<int[]>();
  for(ArrayList<int[]> w : words) {
    wordsRects.add(CompilRect(w));
  }
  
  for(ArrayList<int[]> g : words) {
    int[] rect = CompilRect(g);
    
    stroke(0, 255, 0);
    strokeWeight(1);
    noFill();
    rect(rect[0] - wordMarge, rect[1] - wordMarge, rect[2] + 2 * wordMarge, rect[3] + 2 * wordMarge);
  }
  
  ArrayList<ArrayList<int[]>> lines = RectGroups(wordsRects, 8, 0.5);
  for(ArrayList<int[]> g : lines) {
    int[] rect = CompilRect(g);
    
    stroke(0, 0, 255);
    strokeWeight(2);
    noFill();
    rect(rect[0] - lineMarge, rect[1] - lineMarge, rect[2] + 2 * lineMarge, rect[3] + 2 * lineMarge);
  }
}

ArrayList<ArrayList<int[]>> RectGroups(ArrayList<int[]> rect, float hMarge, float vMarge) {
  return RectGroups(rect.toArray(new int[0][]), hMarge, vMarge);
}

ArrayList<ArrayList<int[]>> RectGroups(int[][] rect, float hMarge, float vMarge) {
  PVector[] centers = new PVector[rect.length];
  for(int k = 0; k < rect.length; k++) {
    centers[k] = new PVector(rect[k][0] + rect[k][2] / 2, rect[k][1] + rect[k][3] / 2);
  }
  
  ArrayList<ArrayList<Integer>> indexGroups = new ArrayList<ArrayList<Integer>>();
  for(int k = 0; k < rect.length; k++) {
    ArrayList<Integer> indexGroup = new ArrayList<Integer>();
    
    float size = pow((float)rect[k][2] * rect[k][3] * rect[k][3], 0.33);
    // float size = rect[k][3];
    
    for(int dx = -floor(hMarge * size); dx <= floor(hMarge * size); dx++) {
      for(int dy = -floor(vMarge * size); dy <= floor(vMarge * size); dy++) {
        forelem:
        for(int l = 0; l < rect.length; l++) {
          if(centers[l].x != centers[k].x + dx || centers[l].y != centers[k].y + dy) continue;
          
          // L'élément l est dans le voisinage de k
          for(ArrayList<Integer> g : indexGroups) {
            if(g.contains(l)) {
              indexGroup.addAll(g);
              indexGroups.remove(g);
              continue forelem;
            }
          }
          // L'élément l n'appartient pour le moment à aucun voisinage
          indexGroup.add(l);
        }
      }
    }
    
    HashSet<Integer> set = new HashSet<>(indexGroup);
    indexGroup.clear();
    indexGroup.addAll(set);
    
    indexGroups.add(indexGroup);
  }
  
  println(indexGroups);
  
  ArrayList<ArrayList<int[]>> groups = new ArrayList<ArrayList<int[]>>();
  for(ArrayList<Integer> g : indexGroups) {
    ArrayList<int[]> group = new ArrayList<int[]>();
    for(int e : g) group.add(rect[e]);
    groups.add(group);
  }
  
  return groups;
}

int[] CompilRect(ArrayList<int[]> rects) {
  return CompilRect(rects.toArray(new int[0][]));
}

int[] CompilRect(int[][] rects) {
  int left = rects[0][0]; int right = rects[0][2] + rects[0][0];
  int top = rects[0][1]; int bottom = rects[0][3] + rects[0][1];
  
  for(int k = 1; k < rects.length; k++) {
    left = min(rects[k][0], left);
    right = max(rects[k][2] + rects[k][0], right);
    top = min(rects[k][1], top);
    bottom = max(rects[k][3] + rects[k][1], bottom);
  }
  
  return new int[]{left, top, right - left, bottom - top};
}

ArrayList<ArrayList<PVector>> ContourDetection(PImage img) {
  return ContourDetection(img, 50);
}

ArrayList<ArrayList<PVector>> ContourDetection(PImage img, int minSize) {
  ArrayList<ArrayList<PVector>> contours = new ArrayList<ArrayList<PVector>>(); // Oui, je sais ce que tu penses...
  ArrayList<PVector> visited = new ArrayList<PVector>();
  
  PVector[] dirs = new PVector[]{new PVector(1, 0), new PVector(1, 1), new PVector(0, 1), new PVector(-1, 1), new PVector(-1, 0), new PVector(-1, -1), new PVector(0, -1), new PVector(1, -1)};
  
  img.loadPixels();
  for(int j = 0; j < img.height; j++) {
    for(int i = 0; i < img.width; i++) {
      if(img.pixels[i + j*img.width] == -16777216 && (i == 0 || img.pixels[i + j*img.width - 1] != -16777216) && !visited.contains(new PVector(i, j))) {
        ArrayList<PVector> contour = new ArrayList<PVector>();
        int x = i; int y = j;
        int dir = 0;
        
        cw:
        while(true) {
          contour.add(new PVector(x, y));
          
          for(int k = 0; k <= 8; k++) {
            if(k==8) break cw; //Le pixel est isolé
            
            PVector toCheck = new PVector(x,y).add(dirs[(dir + k + 1) % 8]);
            if(toCheck.x < 0 || toCheck.x >= img.width || toCheck.y < 0 || toCheck.y >= img.height) continue;
            
            if(img.pixels[(int)toCheck.x + (int)toCheck.y * img.width] == -16777216) {
              x = (int)toCheck.x; y = (int)toCheck.y;
              dir = (dir + k + 5) % 8;
              break;
            }
          }
          
          // Condition d'arret : passage deux fois sur le même pixel de la même manière
          if(contour.size() >= 2) {
            for(int k = 0; k < contour.size() - 1; k++) {
              if(contour.get(k).x == contour.get(contour.size() - 1).x && contour.get(k).y == contour.get(contour.size() - 1).y && contour.get(k+1).x == x && contour.get(k+1).y == y) break cw;
            }
          }
        }
        
        if(contour.size() > minSize) {
          contours.add(contour);
          visited.addAll(contour);
        }
      }
    }
  }
  
  return contours;
}

int[] RectFromContour(ArrayList<PVector> contour) {
  return RectFromContour(contour.toArray(new PVector[0]));
}

int[] RectFromContour(PVector[] contour) {
  int minX = (int)contour[0].x;
  int minY = (int)contour[0].y;
  int maxX = (int)contour[0].x;
  int maxY = (int)contour[0].y;
  
  for(PVector p : contour) {
    minX = min(minX, (int)p.x);
    minY = min(minY, (int)p.y);
    maxX = max(maxX, (int)p.x);
    maxY = max(maxY, (int)p.y);
  }
  
  return new int[]{minX, minY, maxX - minX, maxY - minY};
}

boolean IsClockwise(ArrayList<PVector> contour) {
  return IsClockwise(contour.toArray(new PVector[0]));
}

boolean IsClockwise(PVector[] contour) { // Si un contour est clockwise, alors il s'agit d'un contour extérieur
  double sum = 0;
  for(int k = 0; k < contour.length - 1; k++) {
    sum += (double)(contour[k+1].x - contour[k].x) / (contour[k+1].y + contour[k].y);
  }
  return sum >= 0;
}
