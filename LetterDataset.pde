import java.util.Arrays;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.Executors;
import java.util.concurrent.Callable;
import java.util.concurrent.Future;

public class LetterDataset {
  final int wData, hData;
  float move = 0.1;
  float blur = 0.05;
  float density = 0.01;
  float perlin = 1;
  float deformation = 0.03;

  LetterDataset(int wData, int hData) {
    this.wData = wData;
    this.hData = hData;
  }
  
  public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int rep) {
    return this.CreateSample(characters, hwSources, fSources, rep, 1);
  }
  
  public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int rep, float deformationRate) {
    int[] repList = new int[characters.length];
    Arrays.fill(repList, rep);
    
    return this.CreateSample(characters, hwSources, fSources, repList, deformationRate);
  }
  
  public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int[] repList) {
    return this.CreateSample(characters, hwSources, fSources, repList, 1);
  }

  // Renvoie un couple entrée / sortie d'images pour le réseau
  public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int[] repList, float deformationRate) {
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
    
    ThreadPoolExecutor executor = (ThreadPoolExecutor) Executors.newFixedThreadPool(10);
    ArrayList<Callable<Object>> tasks = new ArrayList<Callable<Object>>();
    ArrayList<Matrix[]> results = new ArrayList<Matrix[]>();
    for (int c1 = 0; c1 < nbChar; c1++) {
      for (int k1 = 0; k1 < repList[c1]; k1++) {
        for (int s1 = 0; s1 < nbSources; s1++) {
          final int c = new Integer(c1);
          final int k = new Integer(k1);
          final int s = new Integer(s1);
          
          class ScramblingTask implements Runnable {
            public void run() {
              // Récupère l'image source et la modifie
              String path = s < hwSources.length
                ? "./TextFileGetter/output/" + characters[c] + "/" + characters[c] + " - " + hwSources[s] + ".jpg"
                : "./FromFontGetter/output/" + characters[c] + "/" + characters[c] + " - " + fSources[s - hwSources.length] + ".jpg";
              PImage original = loadImage(path);
              PImage img = im.ScrambleImage(im.Resize(original, wData, hData), move * deformationRate, blur * deformationRate, density * deformationRate, perlin * deformationRate, deformation * deformationRate, pg);
              
              // Récupère les pixels et les normalise
              double[] imgPixels = ImgPP(img);
              double[] answerArray = new double[nbChar];
              answerArray[c] = 1;
              
              Matrix[] r = new Matrix[2];
              r[0] = new Matrix(sampleSize, 1).ColumnFromArray(0, imgPixels);
              r[1] = new Matrix(nbChar, 1).ColumnFromArray(0, answerArray);

              results.add(r);
            }
          }
          
          tasks.add(Executors.callable(new ScramblingTask()));
          
        }
        System.gc();
      }
      //cl.pln(characters[c], "\t(" + repList[c] + ")", "\t Remaining Time :", RemainingTime(startTime, c+1, nbChar));
    }
    //cl.pln();
    
    // Actualise les matrices entrées / sorties en regroupant les données
    try {
      List<Future<Object>> answers = executor.invokeAll(tasks);
      int numColonne = 0;
      for (Matrix[] ms : results) {
        inputs.ColumnFromArray(numColonne, ms[0].ColToArray(0));
        outputs.ColumnFromArray(numColonne, ms[1].ColToArray(0));
        numColonne += 1;
      }
    } catch (InterruptedException e) {
      cl.pln("LetterDataset, CreateSample : Erreur critique, bonne chance pour la suite");
    }
    //inputs.ColumnFromArray(numColonne, imgPixels);
    //outputs.Set(c, numColonne, 1);
    
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
