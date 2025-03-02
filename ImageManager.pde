import java.util.HashSet;

class ImageManager {
  int index = 0;
  
  color AverageColor(PImage img) {
    float sz = 2 * (img.width + img.height) - 4;

    float r = 0;
    float g = 0;
    float b = 0;

    color c;

    for (int i = 0; i < img.width; i++) {
      c = img.get(i,0);
      r += red(c) / sz;
      g += green(c) / sz;
      b += blue(c) / sz;

      c = img.get(i,img.height - 1);
      r += red(c) / sz;
      g += green(c) / sz;
      b += blue(c) / sz;

    }

    for (int j = 1; j < img.height - 1; j++) {
      c = img.get(0, j);
      r += red(c) / sz;
      g += green(c) / sz;
      b += blue(c) / sz;

      c = img.get(img.width - 1, j);
      r += red(c) / sz;
      g += green(c) / sz;
      b += blue(c) / sz;
    }

    return color(r,g,b);
  }

  PImage Resize(PImage img, float s) {
    int x = floor(s * img.width);
    int y = floor(s * img.height);

    return Resize(img, x,y);
  }

  PImage Resize(PImage img, int x, int y) {
    img.resize(x, y);
    return img;
  }

  PImage Gray(PImage img) {
    img.filter(GRAY);
    return img;
  }

  PImage BlackAndWhite(PImage img, float threshold) {
    img.filter(THRESHOLD, threshold);
    return img;
  }

  PImage ScrambleImage(PImage img, float move, float blur, float density, float perlin, float deformation, PGraphics pg) {
    return ScrambleImage(img, false, move, blur, density, perlin, deformation, pg);
  }

  PImage ScrambleImage(PImage img, boolean save, float move, float blur, float density, float perlin, float deformation, PGraphics pg) {
    pg.beginDraw();
    pg.background(this.AverageColor(img));

    float zRot = 0.7;
    float d = 0.9;
    float delta = 0.02;
    float perlinScale = 1;
    float scaleScale = 0.5;

    PImage scrambledImage = img.copy();
    int x = scrambledImage.width;
    int y = scrambledImage.height;
    float size = sqrt(x*y);
    
    scrambledImage = this.Contrast(scrambledImage, 0);
    scrambledImage = this.ElasticDeformation(scrambledImage, floor(deformation * size), 0.1);
    scrambledImage.filter(BLUR, 0.3 * random(blur * size));

    noiseSeed((long)random(0,100));
    for (int i = 0; i < x; i++) {
      for (int j = 0; j < y; j++) {
        float pI = perlin * noise((float)i / x * perlinScale, (float)j / y * perlinScale) - perlin / 2;
        color init = scrambledImage.get(i,j);
        scrambledImage.set(i, j, color(100 * pI + red(init),pI + green(init), pI+blue(init)));

        if (random(1) > density) continue;

        scrambledImage.set(i, j, color(floor(random(1 - delta, 1 + delta) * brightness(scrambledImage.get(i,j)))));
      }
    }
    
    pg.translate(floor(x/2) + d * random(-size * move, size * move), floor(y/2) + d * random(-size * move, size * move));

    pg.rotate(zRot *(random(PI * move) - PI * move/2));

    pg.scale(random(1, 1 + scaleScale * move));

    pg.translate(-floor(x/2) + d * random(-size * move, size * move), -floor(y/2) + d * random(-size * move, size * move));


    pg.image(scrambledImage, 0, 0);

    if(save) pg.save("./outputedFrame/" + str(millis()) + str(this.index) + str(second()) + str(minute()) + str(hour()) + str(day()) + str(month()) + str(year()) + ".jpg" );

    pg.loadPixels();
    scrambledImage = pg.get(0, 0, scrambledImage.width, scrambledImage.height);
    pg.background(0);
    pg.endDraw();

    this.index += 1;
    return scrambledImage;
  }
  
  Matrix FullConvolution(Matrix images, Matrix filter, int w, int h) {
    if(images.n != w*h) { cl.pln("Convolution", "Wrong size Matrix"); Exception e = new Exception(); e.printStackTrace(); return images; }
    
    Matrix filtered = images.C();
    PImage img;
    for(int k = 0; k < images.p; k++) {
      img = createImage(w, h, RGB);
      img.loadPixels();
      for(int i = 0; i < images.n; i++) img.pixels[i] = color((int)(images.Get(i, k)));
      img.updatePixels();
      
      img = FullConvolution(img, filter);
      img.loadPixels();
      for(int i = 0; i < images.n; i++) filtered.Set(i, k, brightness(img.pixels[i]) / 255);
    }
    
    return filtered;
  }
  
  PImage FullConvolution(PImage img, Matrix filter) {
    PImage nImg = img.copy();
    nImg.loadPixels();
    for(int i = 0; i < img.width; i++) {
      for(int j = 0; j < img.height; j++) {
        nImg.set(i,j,this.Filter(img, filter, i, j));
      }
    }
    nImg.updatePixels();
    return nImg;
  }
  
  color Filter(PImage img, Matrix filter, int x, int y) {
    int r = 0, g = 0, b = 0;
    for(int i = 0; i < filter.n; i++) {
      for(int j = 0; j < filter.p; j++) {
        int rx = x + i - floor((float)filter.p / 2);
        int ry = y + j - floor((float)filter.p / 2);
        if(rx < 0 || ry < 0 || rx >= img.width || ry >= img.height) continue;
        
        r += red(img.get(rx, ry));
        g += green(img.get(rx, ry));
        b += blue(img.get(rx, ry));
      }
    }
    
    return color(r,g,b);
  }
  
  PImage Contrast(PImage img, float intensity) {
    return Contrast(img, intensity, (x) -> x);
  }
  
  PImage Contrast(PImage img, float intensity, FunctionMap contrastF) {
    if(intensity < 0) intensity = 0;
    if(intensity > 0.5) intensity = 0.5;
    
    PImage nImg = img.copy();
    nImg.loadPixels();
    float[] rVal = new float[nImg.pixels.length];
    float[] gVal = new float[nImg.pixels.length];
    float[] bVal = new float[nImg.pixels.length];
    for(int k = 0; k < nImg.pixels.length; k++) {
      rVal[k] = red(nImg.pixels[k]);
      gVal[k] = green(nImg.pixels[k]);
      bVal[k] = blue(nImg.pixels[k]);
    }
    
    rVal = sort(rVal);
    gVal = sort(gVal);
    bVal = sort(bVal);
    
    float rMin = rVal[floor(intensity * (nImg.pixels.length - 1))];
    float rMax = rVal[floor((1-intensity) * (nImg.pixels.length - 1))];
    float gMin = gVal[floor(intensity * (nImg.pixels.length - 1))];
    float gMax = gVal[floor((1-intensity) * (nImg.pixels.length - 1))];
    float bMin = bVal[floor(intensity * (nImg.pixels.length - 1))];
    float bMax = bVal[floor((1-intensity) * (nImg.pixels.length - 1))];
    
    for(int k = 0; k < nImg.pixels.length; k++) {
      nImg.pixels[k] = color(
        (int)Math.floor(rMax <= rMin ? red(nImg.pixels[k]) : 255 * contrastF.calc((red(nImg.pixels[k]) - rMin) / (rMax - rMin))),
        (int)Math.floor(gMax <= gMin ? green(nImg.pixels[k]) : 255 * contrastF.calc((green(nImg.pixels[k]) - gMin) / (gMax - gMin))),
        (int)Math.floor(bMax <= bMin ? blue(nImg.pixels[k]) : 255 * contrastF.calc((blue(nImg.pixels[k]) - bMin) / (bMax - bMin)))
      );
    }
    
    nImg.updatePixels();
    return nImg;
  }
  
  PImage AutoCrop(PImage img, float cap, float marge) {
    PImage cImg = img.copy();
    cImg.filter(THRESHOLD, cap / 255);
    ArrayList<ArrayList<PVector>> contours = this.ContourDetection(cImg, 2);
    
    if(contours.size() == 0) return OLD_AutoCrop(img, cap, marge);
    
    int mArea = 0;
    int objectIndex = 0;
    for(int k = 0; k < contours.size(); k++) {
      ArrayList contour = contours.get(k);
      if(!this.IsClockwise(contour)) continue;
      
      int[] rect = this.RectFromContour(contour);
      if(rect[2] * rect[3] > mArea) {
        mArea = rect[2] * rect[3];
        objectIndex = k;
      }
    }
    
    return ImageFromContour(img, contours.get(objectIndex), marge, (float)img.width / img.height);
  }
  
  PImage ImageFromContour(PImage img, ArrayList<PVector> contour, float marge, float ratio) {
   int[] rect = this.RectFromContour(contour);
    int left = rect[0];         int top = rect[1];
    int right = rect[2] + left; int bottom = rect[3] + top;
    
    left = constrain(left - floor(marge * img.width), 0, img.width - 1);
    right = constrain(right + floor(marge * img.width), 0, img.width - 1);
    top = constrain(top - floor(marge * img.height), 0, img.height - 1);
    bottom = constrain(bottom + floor(marge * img.height), 0, img.height - 1);
    
    
    if(top == bottom || right == left) return img; //En vrai c'est que l'image n'est pas centré, mais on renvoit qqc
    
    //Equilibrer le ratio width/height
    while((float)(right - left) / (bottom - top) > ratio * 1.2) { // Tolérance du ratio à 40%
      bottom = constrain(bottom + 1, 0, img.height - 1);
      top = constrain(top - 1, 0, img.height - 1);
      
      if(top == 0 && bottom == img.height - 1) break;
    }
    
    while((float)(right - left) / (bottom - top) < ratio * 0.83) { // Tolérance du ratio à 40%
      right = constrain(right + 1, 0, img.width - 1);
      left = constrain(left - 1, 0, img.width - 1);
      
      if(left == 0 && right == img.width - 1) break;
    }
    
    
    return img.get(left, top, right - left, bottom - top); 
  }
  
  PImage OLD_AutoCrop(PImage img, float cap, float tolerance) { // Consider the object as black (or darker part)
    int left = img.width / 2, right = img.width / 2, top = img.height / 2, bottom = img.height / 2;
    img.loadPixels();
    
    // Recherche d'un pixel appartenant (très probablement) à la forme
    int step = 1;
    whileloop:
    while(left >= 0 && left < img.width && top >= 0 && top < img.height) {
      for(int k = 0; k < step; k++) {
        if(2 * brightness(img.pixels[left + img.width * top]) < cap) break whileloop; //Je ne savais pas qu'on pouvait faire ça avant
        left += pow(-1, step);
      }
      
      for(int k = 0; k < step; k++) {
        if(2 * brightness(img.pixels[left + img.width * top]) < cap) break whileloop;
        top += pow(-1, step);
      }
      
      step++;
    }
    
    right = left;
    bottom = top;
    
    float[] minBrightnessCol = new float[img.width];
    float[] minBrightnessRow = new float[img.height];
    
    for(int k = 0; k < img.width; k++) {
      minBrightnessCol[k] = 255;
      for(int i = 0; i < img.height; i++) {
        minBrightnessCol[k] = min(minBrightnessCol[k], brightness(img.pixels[i * img.width + k]));
      }
    }
    
    for(int k = 0; k < img.height; k++) {
      minBrightnessRow[k] = 255;
      for(int i = 0; i < img.width; i++) {
        minBrightnessRow[k] = min(minBrightnessRow[k], brightness(img.pixels[k * img.width + i]));
      }
    }
    
    float marge = tolerance * img.width;
    for(int k = left; k >= 0; k--) {
      if(minBrightnessCol[k] > cap) {
        marge--;
        if(marge <= 0) break;
      }
      left = k;
    }
    
    marge = tolerance * img.width;
    for(int k = right; k < img.width; k++) {
      if(minBrightnessCol[k] > cap) {
        marge--;
        if(marge <= 0) break;
      }
      right = k;
    }
    
    marge = tolerance * img.height;
    for(int k = top; k >= 0; k--) {
      if(minBrightnessRow[k] > cap) {
        marge--;
        if(marge <= 0) break;
      }
      top = k;
    }
    
    marge = tolerance * img.height;
    for(int k = bottom; k < img.height; k++) {
      if(minBrightnessRow[k] > cap) {
        marge--;
        if(marge <= 0) break;
      }
      bottom = k;
    }
    
    if(top == bottom || right == left) return img; //En vrai c'est que l'image n'est pas centré, mais on renvoit qqc
    
    //Equilibrer le ratio width/height
    float ratio = img.width / img.height;
    while((right - left) / (bottom - top) > ratio * 1.1) { // Tolérance du ratio à 20%
      bottom = constrain(bottom + 1, 0, img.height - 1);
      top = constrain(top - 1, 0, img.height - 1);
    }
    
    while((right - left) / (bottom - top) < ratio * 0.91) { // Tolérance du ratio à 20%
      right = constrain(right + 1, 0, img.width - 1);
      left = constrain(left - 1, 0, img.width - 1);
    }
    
    return img.get(left, top, right - left, bottom - top);
  }
  
  PImage ElasticDeformation(PImage img, float intensity, float noiseScale) {
    PImage deformedImg = createImage(img.width, img.height, RGB);

    img.loadPixels();
    deformedImg.loadPixels();
    for(int x = 0; x < img.width; x++) {
      for(int y = 0; y < img.height; y++) {        
        int offsetX = (int)((noise(x * noiseScale, y * noiseScale) * 2 - 1) * intensity);
        int offsetY = (int)((noise(x * noiseScale + 1000, y * noiseScale + 1000) * 2 - 1) * intensity);
        
        int newX = constrain(x + offsetX, 0, img.width - 1);
        int newY = constrain(y + offsetY, 0, img.height - 1);
        
        deformedImg.pixels[x + y * img.width] = img.pixels[newX + newY * img.width];
      }
    }
    deformedImg.updatePixels();
    
    return deformedImg;
  }
  
  // Radial Sweep Algorithm
  // https://www.imageprocessingplace.com/downloads_V3/root_downloads/tutorials/contour_tracing_Abeer_George_Ghuneim/ray.html
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
    return this.RectFromContour(contour.toArray(new PVector[0]));
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
    return this.IsClockwise(contour.toArray(new PVector[0]));
  }
  
  // Il s'agit évidemment de magie noire, toujours pas regardé d'où ça vient ce truc
  // https://stackoverflow.com/questions/1165647/how-to-determine-if-a-list-of-polygon-points-are-in-clockwise-order
  boolean IsClockwise(PVector[] contour) {  // Si un contour est clockwise, alors il s'agit d'un contour extérieur
    double sum = 0;
    for(int k = 0; k < contour.length - 1; k++) {
      sum += (double)(contour[k+1].x - contour[k].x) / (contour[k+1].y + contour[k].y); 
    }
    return sum >= 0;
  }
  
  ArrayList<ArrayList<int[]>> RectGroups(ArrayList<int[]> rect, float hMarge, float vMarge) {
    return this.RectGroups(rect.toArray(new int[0][]), hMarge, vMarge);
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
    return this.CompilRect(rects.toArray(new int[0][]));
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
}

/*
void setup() {
  size(200,200,P3D);
  ImageManager img = new ImageManager(loadImage("@ - NicolasMA.jpg"));
  img.Resize(19,21);

  background(0);
  //noLoop();
  noLoop();


  img.Gray();
  for(int i = 0; i < 5000; i++)
    img.ScrambleImage(false, 0.2,0.1,0.05);
}
*/
