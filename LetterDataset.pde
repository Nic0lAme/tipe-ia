import java.util.Arrays;

public class LetterDataset {
  final int wData, hData;
  float move = 0.2;
  float blur = 0.1;
  float density = 0.01;
  float perlin = 1;
  float deformation = 0.03;

  LetterDataset(int wData, int hData) {
    this.wData = wData;
    this.hData = hData;
  }
  
  public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int rep) {
    int[] repList = new int[characters.length];
    Arrays.fill(repList, rep);
    
    return CreateSample(characters, hwSources, fSources, repList);
  }

  // Renvoie un couple entrée / sortie d'images pour le réseau
  public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int[] repList) {
    int repSum = 0;
    for(int k = 0; k < repList.length; k++) repSum += repList[k];
    
    int nbChar = characters.length;
    int nbSources = hwSources.length + fSources.length;
    int sampleSize = nbSources * repSum;
    
    cl.pln("Creating Dataset of size " + sampleSize + "...");
    
    PGraphics pg = createGraphics(this.wData, this.hData, P2D);

    Matrix inputs = new Matrix(w*h, sampleSize);
    Matrix outputs = new Matrix(nbChar, sampleSize);
    outputs.Fill(0);
    
    int startTime = millis();

    int numColonne = 0;
    for (int c = 0; c < nbChar; c++) {
      for (int k = 0; k < repList[c]; k++) {
        for (int s = 0; s < nbSources; s++) {
          // Récupère l'image source et la modifie
          String path = s < hwSources.length
            ? "./TextFileGetter/output/" + characters[c] + "/" + characters[c] + " - " + hwSources[s] + ".jpg"
            : "./FromFontGetter/output/" + characters[c] + "/" + characters[c] + " - " + fSources[s - hwSources.length] + ".jpg";
          PImage original = loadImage(path);
          PImage img = im.ScrambleImage(im.Resize(original, this.wData, this.hData), move, blur, density, perlin, deformation, pg);

          // Récupère les pixels et les normalise
          double[] imgPixels = ImgPP(img);

          // Actualise les matrices entrées / sorties
          inputs.ColumnFromArray(numColonne, imgPixels);
          outputs.Set(c, numColonne, 1);
          numColonne += 1;
        }
        System.gc();
      }
      cl.pln(characters[c], "\t(" + repList[c] + ")", "\t Remaining Time :", RemainingTime(startTime, c+1, nbChar));
    }
    cl.pln();
    
    return new Matrix[]{ inputs, outputs };
  }

  // Renvoie une image affichable de l'image stockée en colonne j de l'entrée
  public PImage GetImageFromInputs(Matrix inputs, int j) {
    PImage img = createImage(w, h, RGB);
    img.loadPixels();
    for(int i = 0; i < img.pixels.length; i++) {
      int val = floor((float)inputs.Get(i, j) * 255);
      img.pixels[i] = color(val, val, val);
    }
    img.updatePixels();
    return img;
  }
  
  public void Export(Matrix[] data, String name) {
    ArrayList<String> output = new ArrayList<String>();

    output.add(data[0].n + "," + data[1].n + "," + data[0].p);

    String[] inputSave = data[0].SaveToString(true);
    for (String s : inputSave) output.add(s);
    cl.pln("Inputs exported");
    
    String[] outputSave = data[1].SaveToString(true);
    for (String s : outputSave) output.add(s);
    cl.pln("Outputs exported");

    String[] writedOutput = new String[output.size()];
    saveStrings(name, output.toArray(writedOutput));
  }
  
  public Matrix[] Import(String name) {
    String[] input = loadStrings(name);
    String[] sizes = split(input[0], ',');
    int n0 = int(sizes[0]); int n1 = int(sizes[1]); int p = int(sizes[2]);
    
    Matrix sampleInput = new Matrix(n0, p);
    Matrix sampleOutput = new Matrix(n1, p);
   
    String[] inputString = new String[n0];
    for (int k = 0; k < n0; k++) {
      inputString[k] = input[k+1];
    }
    sampleInput.LoadString(inputString);
    
    String[] outputString = new String[n1];
    for (int k = 0; k < n1; k++) {
      outputString[k] = input[n0+k+1];
    }
    sampleOutput.LoadString(outputString);


    return new Matrix[]{ sampleInput, sampleOutput };
  }

}
