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

  PImage ScrambleImage(PImage img, float move, float blur, float density, float perlin, PGraphics pg) {
    return ScrambleImage(img, false, move, blur, density, perlin, pg);
  }

  PImage ScrambleImage(PImage img, boolean save, float move, float blur, float density, float perlin, PGraphics pg) {
    pg.beginDraw();
    pg.background(this.AverageColor(img));

    float zRot = 0.7;
    float xyRot = 0.2;
    float d = 1.3;
    float delta = 0.02;
    float perlinScale = 1;
    float scaleScale = 0.5;

    PImage scrambledImage = img.copy();
    int x = scrambledImage.width;
    int y = scrambledImage.height;
    float size = log(x*y);

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

    pg.rotateX(xyRot*(random(PI * move) - PI * move/2));
    pg.rotateY(xyRot*(random(PI * move) - PI * move/2));
    pg.rotateZ(zRot *(random(PI * move) - PI * move/2));

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
  
  PImage AutoCrop(PImage img, float cap, float tolerance) { // Consider the object as black (or darker part)
    int left = width / 2, right = width / 2, top = height / 2, bottom = height / 2;
    
    float[] minBrightnessCol = new float[img.width];
    float[] minBrightnessRow = new float[img.height];
    img.loadPixels();
    
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
    for(int k = img.width / 2; k >= 0; k--) {
      if(minBrightnessCol[k] > cap) {
        marge--;
        if(marge <= 0) break;
      }
      left = k;
    }
    
    marge = tolerance * img.width;
    for(int k = img.width / 2; k < img.width; k++) {
      if(minBrightnessCol[k] > cap) {
        marge--;
        if(marge <= 0) break;
      }
      right = k;
    }
    
    marge = tolerance * img.height;
    for(int k = img.height / 2; k >= 0; k--) {
      if(minBrightnessRow[k] > cap) {
        marge--;
        if(marge <= 0) break;
      }
      top = k;
    }
    
    marge = tolerance * img.height;
    for(int k = img.height / 2; k < img.height; k++) {
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
