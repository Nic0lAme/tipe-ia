Matrix[] sample;
int w = 19;
int h = 21;

void setup() {
  size(500, 500, P3D);
  background(255);
  /*
  size(200, 200);
  background(255);

  Matrix m = new Matrix(2,3);
  m.Fill(1);
  m.Set(1,2, -1);

  Matrix b = m.C().T().Scale(2).Add(m.C().T());

  Matrix c = m.Mult(b);

  m.Debug();
  b.Debug();
  c.Debug();

  double[][] arr = {{1,2,3},{4,5,6},{7,7,9}};
  Matrix d = new Matrix(3).FromArray(arr);
  Matrix id = d.Inversed();
  d.Mult(id).Debug();
  println(d.Det());

  Matrix m2 = new Matrix(3).FromArray(arr);
  m2.Debug();
  m2.Map( (x) -> 5*x + 1 );
  m2.Debug();

  m2.Debug();
  d.Debug();
  m2.HProduct(d).Debug();
  */
  
  /*
  PImage img = loadImage("./AuxiliarFiles/UKFlag.jpg");
  img.resize(width, height);

  int N = floor(2.5 * w * h / 100);
  Matrix inputs = new Matrix(2, N);
  Matrix outputs = new Matrix(3, N);


  for(int k = 0; k < N; k++) {
    float x = random(1);
    float y = random(1);
    inputs.Set(0, k, x);
    inputs.Set(1, k, y);

    color c = img.get(floor(x * w), floor(y * h));
    outputs.Set(0, k, red(c) / 255);
    outputs.Set(1, k, green(c) / 255);
    outputs.Set(2, k, blue(c) / 255);
  }
  */


  

  

  // Exemple :
  // nn.Export("UKFlag.nn");
  // NeuralNetwork nn2 = new NeuralNetwork().Import("UKFlag.nn");
  
  /*
  for(int i = 0; i < width; i++) {
    for(int j = 0; j < height; j++) {
      Matrix output = nn.Predict(new Matrix(2,1).FromArray(new double[][]{{(float)i/width},{(float)j/height}}));
      color c = color(floor((float)output.Get(0,0) * 255), floor((float)output.Get(1,0) * 255), floor((float)output.Get(2,0) * 255));
      set(i, j, c);
    }
  }
  */

  //Matrix entries = new Matrix(3, 10000).Random(0, 1);
  //Matrix exit = new Matrix(2, 10000).Random(0,1);

  /*
  Matrix entries = new Matrix(2, 10).FromArray(new double[][]{
    {-1,-5,3,0,-3,10,1,-1,1,0},
    {0,1,0,1,5,-2,-7,-1,1000,-1000,-10}
  });
  Matrix exits = new Matrix(2, 10).FromArray(new double[][]{
    {1,1,0,0.5,1,0,0,1,0,0.5},
    {0,0,1,0.5,0,1,1,0,1,0.5}
  });
  
  NeuralNetwork nn = new NeuralNetwork(2, 4, 2);
  nn.UseSoftMax();
  println(nn);
  
  for(int i = 0; i < 100000; i++) {
    nn.Learn(entries.C(), exits.C(), 0.1);
  }

  Matrix entriesBis = new Matrix(2, 5).FromArray(new double[][]{
    {1,-5,0,0,-3},
    {0,-4,0,-100,5,2}
  });

  nn.Predict(entriesBis).Debug();
  */
  
  
  
  NeuralNetwork nn = new NeuralNetwork(w*h, 64, 32, 2);
  nn.UseSoftMax();
  println(nn);
  
  sample = CreateSample(w, h,
        new String[]{"uA", "uB"},
        new String[]{"NicolasMA", "AntoineME", "LenaME", "ElioKE", "AkramBE", "TheoLA"},
        new String[]{"Arial", "Consolas"},
        12
        );
  
  for(int k = 0; k < 100; k++)
    println(k+1, "\t-\t", nn.Learn(sample[0], sample[1], 0.1));
  
  println(AccuracyScore(nn, sample[0], sample[1]));
  
  frameRate(5);
}

int index = 0;

void draw() {
  background(255);
  DrawSample(index, w, h, sample[0]);
  
  index = (index+1)%sample[0].p;
}



Matrix[] CreateSample(int wdth, int hght, String[] characters, String[] handWritten, String[] fonts, int rep) {
  int fNum = fonts.length;
  int hNum = handWritten.length;
  
  Matrix inputs = new Matrix(wdth*hght, characters.length * (hNum + fNum) * rep);
  Matrix outputs = new Matrix(characters.length, characters.length * (hNum + fNum) * rep);
  
  PImage img;
  double[] imgPixels;
  
  float move = 0.05;
  float blur = 0.15;
  float density = 0;
  
  for(int c = 0; c < characters.length; c++) {
    for(int k = 0; k < rep; k++) {
      
      for(int h = 0; h < hNum; h++) {
        img = new ImageManager(loadImage("./TextFileGetter/output/" + characters[c] +"/" + characters[c] + " - " + handWritten[h] + ".jpg")).Resize(wdth, hght).Gray().ScrambleImage(true, move, blur, density);
        
        imgPixels = new double[img.pixels.length];
        img.loadPixels();
        for(int i = 0; i < img.pixels.length; i++) imgPixels[i] = 1 - (double)brightness(img.pixels[i]) / 255;
        
        inputs.ColumnFromArray(c* (hNum + fNum) * rep + h * rep, imgPixels);
      }
      
      for(int f = 0; f < fNum; f++) {
        img = new ImageManager(loadImage("./FromFontGetter/output/" + characters[c] +"/" + characters[c] + " - " + fonts[f] + ".jpg")).Resize(wdth, hght).Gray().ScrambleImage(true, move, blur, density);
        
        imgPixels = new double[img.pixels.length];
        img.loadPixels();
        for(int i = 0; i < img.pixels.length; i++) imgPixels[i] = 1 - (double)brightness(img.pixels[i]) / 255;
        
        inputs.ColumnFromArray(c* (hNum + fNum) * rep + hNum * rep + f * rep, imgPixels);
      }
      
    }
    
    for(int i = c * (hNum + fNum) * rep; i < (c+1) * (hNum + fNum) * rep; i++) outputs.Set(c, i, 1);
  }
  
  return new Matrix[]{ inputs, outputs };
}


float AccuracyScore(NeuralNetwork nn, Matrix inputs, Matrix outputs) {
  float score = 0;
  
  Matrix prediction = nn.Predict(inputs);
  
  prediction.Debug();
  outputs.Debug();
  
  for(int j = 0; j < inputs.p; j++) {
    for(int i = 0; i < outputs.n; i++) {
      if(outputs.Get(i,j) == 0) {
        score += prediction.Get(i,j);
        break;
      }
    }
  }
  
  return score / inputs.p;
}

void DrawSample(int j, int w, int h, Matrix inputs) {
  PImage img = createImage(w, h, RGB);
  img.loadPixels();
  for(int i = 0; i < img.pixels.length; i++) img.pixels[i] = color(floor((float)inputs.Get(i, j) * 255), floor((float)inputs.Get(i, j) * 255), floor((float)inputs.Get(i, j) * 255));
  img.updatePixels();
  
  img.save("./SampleTestOutput/" + str(j) + " - sdf.jpg");
}
