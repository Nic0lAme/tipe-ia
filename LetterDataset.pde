import java.util.Arrays;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.Executors;
import java.util.concurrent.Callable;
import java.util.concurrent.Future;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.ExecutionException;

public class LetterDataset {
  final int wData, hData;
  final float move = 0.15;
  final float blur = 0.07;
  final float density = 0.02;
  final float perlin = 2;
  final float deformation = 0.1;

  //c Créateur de dataset
  // Zone de travail définie par _wData_ * _hData_
  LetterDataset(int wData, int hData) {
    this.wData = wData;
    this.hData = hData;
  }

  //s On fixe le nombre de répétitions des caractères identiquement à _rep_. On fixe la _deformationRate_ à 1
  public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int rep) {
    return this.CreateSample(characters, hwSources, fSources, rep, 1);
  }

  //s On fixe le nombre de répétitions des caractères identiquement à _rep_
  public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int rep, float deformationRate) {
    int[] repList = new int[characters.length];
    Arrays.fill(repList, rep);

    return this.CreateSample(characters, hwSources, fSources, repList, deformationRate);
  }

  //s _deformationrate_ à 1
  public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int[] repList) {
    return this.CreateSample(characters, hwSources, fSources, repList, 1);
  }

  //f Renvoie un couple entrée / sortie d'images pour le réseau
  // _characters_ correspond à la liste des caractères dont on créera un dataset
  // _hwSources_ et _fSources_ correspondent aux noms respectivement des écritures à la main et des polices utilisées
  // _repList_ correspond au nombre de répétition de chaque caractère respectivement, par échantillon initial
  // _deformationRate_ correspond au taux de déformation utilisé
  public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int[] repList, float deformationRate) {
    int repSum = 0;
    for(int k = 0; k < repList.length; k++) repSum += repList[k];

    int nbChar = characters.length;
    int nbSources = hwSources.length + fSources.length;
    int sampleSize = nbSources * repSum;

    cl.pln("Creating Dataset of size " + sampleSize + "...");

    Matrix inputs = new Matrix(session.w*session.h, sampleSize);
    Matrix outputs = new Matrix(nbChar, sampleSize);
    outputs.Fill(0);

    final int startTime = millis();

    int index = 0;

    ExecutorService executor = Executors.newFixedThreadPool(numThreadsDataset);
    ArrayList<Callable<Object>> tasks = new ArrayList<Callable<Object>>();
    ArrayList<Matrix[]> results = new ArrayList();

    for (int c1 = 0; c1 < nbChar; c1++) {
      for (int k1 = 0; k1 < repList[c1]; k1++) {
        for (int s1 = 0; s1 < nbSources; s1++) {
          final int c = c1;
          final int s = s1;
          final int idx = index;
          index++;

          class ScramblingTask implements Callable<Object> {
            public Object call() {
              // Récupère l'image source et la modifie
              String path = s < hwSources.length
                ? "./TextFileGetter/output/" + characters[c] + "/" + characters[c] + " - " + hwSources[s] + ".jpg"
                : "./FromFontGetter/output/" + characters[c] + "/" + characters[c] + " - " + fSources[s - hwSources.length] + ".jpg";
              PImage original = loadImage(path);
              PImage img = im.ScrambleImage(im.Resize(original, wData, hData), move * deformationRate, blur * deformationRate, density * deformationRate, perlin * deformationRate, deformation * deformationRate);

              //cl.pln(idx);

              // Récupère les pixels et les normalise
              double[] imgPixels = session.ImgPP(img);
              double[] answerArray = new double[nbChar];
              answerArray[c] = 1;

              Matrix[] r = new Matrix[2];
              r[0] = new Matrix(imgPixels.length, 1).ColumnFromArray(0, imgPixels);
              r[1] = new Matrix(nbChar, 1).ColumnFromArray(0, answerArray);
              
              synchronized (stopLearning) {
                if (stopLearning.get()) {
                  try { println("Learning stopped"); stopLearning.wait(); println("Le retour");}
                  catch (Exception e) { e.printStackTrace(); }
                }
              }

              AddToRes(results, r, sampleSize, startTime);
              return this;
            }
          }

          tasks.add(new ScramblingTask());

        }
        // System.gc();
      }
      //cl.pln(characters[c], "\t(" + repList[c] + ")", "\t Remaining Time :", RemainingTime(startTime, c+1, nbChar));
    }
    //cl.pln();

    // Actualise les matrices entrées / sorties en regroupant les données
    try {
      List<Future<Object>> answers = executor.invokeAll(tasks);
      int numColonne = 0;
      for (Matrix[] ms : results) {
        inputs.ColumnFromArray(numColonne, ms[0].ColumnToArray(0));
        outputs.ColumnFromArray(numColonne, ms[1].ColumnToArray(0));
        numColonne += 1;
      }
    } catch (InterruptedException e) {
      cl.pln("LetterDataset, CreateSample : Erreur critique, bonne chance pour la suite");
    }
    //inputs.ColumnFromArray(numColonne, imgPixels);
    //outputs.Set(c, numColonne, 1);

    cl.pln("Created - Total time", String.format("%9.3f",(float)(millis() - startTime) / 1000));

    return new Matrix[]{ inputs, outputs };
  }



  //f Renvoie une image affichable de l'image stockée en colonne _j_ de l'entrée _inputs_
  public PImage GetImageFromInputs(Matrix inputs, int j) {
    PImage img = createImage(session.w, session.h, RGB);
    img.loadPixels();
    for(int i = 0; i < img.pixels.length; i++) {
      int val = floor((float)inputs.Get(i, j) * 255);
      img.pixels[i] = color(val, val, val);
    }
    img.updatePixels();
    return img;
  }

  //f Exporte le dataset _data_ dans le fichier _name_
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

  //f Importe un dataset à partir du fichier _name_
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

public synchronized void AddToRes(ArrayList<Matrix[]> res, Matrix[] toAdd, int sampleSize, int startTime) {
  res.add(toAdd);

  if(res.size() % (sampleSize / 10) == 0) {
    cl.pln(String.format("%5.3f", (float)res.size() / sampleSize), "Time Remaining :", RemainingTime(startTime, res.size(), sampleSize));
  }
}
