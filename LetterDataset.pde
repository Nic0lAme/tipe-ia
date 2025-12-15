/////////////////////////////////////////////////////////////////

// LetterDataset

// Classe utilitaire pour fournir les données de test et
// d'entrainement.
// Lorsque l'on crée un jeu de données, on récupère les images
// intactes des caractères, et on les déforme en appliquant divers
// transformations (translation, flou, "perlin noise", déformation
// élastique, bruitage aléatoire).
// Après ces transformations, on convertit ces images en données
// exploitables par le réseau : une image est codée par un vecteur
// colonne qui est la liste des intensités des pixels, et un jeu de
// données est une matrice qui a pour colonnes ces vecteurs. On renvoie
// également une autre matrice avec les réponses attendues pour chaque
// image. Le type est donc Matrix[][], un "couple" de deux matrices.
// Un jeu de données peut être exporté / importé pour éviter d'être
// regénérer à chaque fois

/////////////////////////////////////////////////////////////////

import java.util.Arrays;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.Executors;
import java.util.concurrent.Callable;
import java.util.concurrent.Future;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.ExecutionException;

public class LetterDataset {
  final int wData, hData;

  final float move = 0.12; // Translation
  final float blur = 0.02; // Flou
  final float density = 0.1; // Densité de pixels bruités
  final float perlin = 0.2; // "Perlin noise"
  final float deformation = 0.06; // Déformation élastique

  //c Créateur de dataset
  // Zone de travail définie par _wData_ * _hData_
  LetterDataset(int wData, int hData) {
    this.wData = wData;
    this.hData = hData;
  }

  //s On fixe le nombre de répétitions des caractères à _rep_. On fixe la _deformationRate_ à 1
  public Matrix[][] CreateSample(String[] characters, String[] hwSources, String[] fSources, int rep) {
    return this.CreateSample(characters, hwSources, fSources, rep, 1);
  }

  //s On fixe le nombre de répétitions des caractères à _rep_
  public Matrix[][] CreateSample(String[] characters, String[] hwSources, String[] fSources, int rep, float deformationRate) {
    int[] repList = new int[characters.length];
    Arrays.fill(repList, rep);

    return this.CreateSample(characters, hwSources, fSources, repList, deformationRate);
  }

  //s On fixe _deformationrate_ à 1
  public Matrix[][] CreateSample(String[] characters, String[] hwSources, String[] fSources, int[] repList) {
    return this.CreateSample(characters, hwSources, fSources, repList, 1);
  }

  //f Renvoie un couple entrée / sortie d'images pour le réseau
  // -> _characters_ correspond à la liste des caractères dont on créera un dataset
  // -> _hwSources_ et _fSources_ correspondent aux noms respectivement des écritures à la main et des polices utilisées
  // -> _repList_ correspond au nombre de répétition de chaque caractère respectivement, par échantillon initial
  // -> _deformationRate_ correspond au taux de déformation utilisé
  // Pour accélérer cette génération d'image, on parallélise le processus
  public Matrix[][] CreateSample(String[] characters, String[] hwSources, String[] fSources, int[] repList, float deformationRate) {
    int repSum = 0;
    for(int k = 0; k < repList.length; k++) repSum += repList[k];

    int nbChar = characters.length; // Nombre de caractère distincs
    int nbSources = hwSources.length + fSources.length; // Nombre de sources dont l'écriture est utilisée
    int sampleSize = nbSources * repSum;

    cl.pln("Creating Dataset of size " + sampleSize + "...");

    Matrix[] inputs = new Matrix[sampleSize];
    Matrix outputs = new Matrix(nbChar, sampleSize);
    outputs.Fill(0);

    final int startTime = millis();

    int index = 0;

    // Objets pour paralléliser le traitement des images
    ExecutorService executor = Executors.newFixedThreadPool(numThreadsDataset);
    ArrayList<Callable<Object>> tasks = new ArrayList<Callable<Object>>();
    ArrayList<Matrix[]> results = new ArrayList();

    // Pour chaque caractère
    for (int c1 = 0; c1 < nbChar; c1++) {
      // Pour chaque répétition demandée pour ce caractère
      for (int k1 = 0; k1 < repList[c1]; k1++) {
        // Pour chaque élément de la base de données qui représente ce caractère
        for (int s1 = 0; s1 < nbSources; s1++) {

          final int c = c1;
          final int s = s1;
          final int idx = index;
          index++;

          // Tache associée au triplet (c1, k1, s1)
          class ScramblingTask implements Callable<Object> {
            public Object call() {
              // Termine en avance si une demande d'arrêt a été faite
              if (abortTraining.get()) return this;

              // Récupère l'image source et la modifie
              String path = s < hwSources.length
                ? "./TextFileGetter/output/" + characters[c] + "/" + characters[c] + " - " + hwSources[s] + ".jpg"
                : "./FromFontGetter/output/" + characters[c] + "/" + characters[c] + " - " + fSources[s - hwSources.length] + ".jpg";
              PImage original = loadImage(path);

              // Modifie cette image
              PImage img = im.ScrambleImage(im.Resize(original, wData, hData), move * deformationRate, blur * deformationRate, density * deformationRate, perlin * deformationRate, deformation * deformationRate);

              // Récupère les pixels et les normalise
              Matrix imgPixels = session.ImgPP(img);
              float[] answerArray = new float[nbChar];
              answerArray[c] = 1;

              Matrix[] r = new Matrix[2];
              r[0] = imgPixels;
              r[1] = new Matrix(nbChar, 1).ColumnFromArray(0, answerArray);

              // En cas de demande de pause depuis l'interface
              synchronized (stopLearning) {
                if (stopLearning.get()) {
                  try { println("Création de données interrompue"); stopLearning.wait(); println("Création de données reprise");}
                  catch (Exception e) { e.printStackTrace(); }
                }
              }

              // Ajoute l'image à _results_
              AddToRes(results, r, sampleSize, startTime);
              return this;
            }
          }

          // Ajoute la tache à la liste des taches à effectuer
          tasks.add(new ScramblingTask());
        }
      }
    }

    // On lance les taches en parallèle, et on actualise les
    // matrices entrées / sorties en regroupant les données
    try {
      List<Future<Object>> answers = executor.invokeAll(tasks);
      int k = 0;
      for (Matrix[] ms : results) {
        inputs[k] = ms[0];
        outputs.ColumnFromArray(k, ms[1].ColumnToArray(0));
        k++;
      }
    } catch (InterruptedException e) {
      cl.pln("LetterDataset, CreateSample : Erreur (dans la parallélisation)");
    }

    if (abortTraining.get()) cl.pln("Création de données arrêtée");
    else cl.pln("Données terminées - Temps total", String.format("%9.3f",(float)(millis() - startTime) / 1000));

    // Renvoie les résultats sous forme d'un couple [entrées, sorties attendues]
    return new Matrix[][]{ inputs, {outputs} };
  }

  //f Renvoit une sous-échantillon aléatoire de taille _size_ du jeu de données _sample_ (échantillonnage sans remise)
  // Les jeux de données doivent être adapté au CNN (Matrix[][], avec Matrix[0] liste d'image d'entrée, Matrix[1][0] la matrice de sortie attendue)
  public Matrix[][] CNNSampleASample(Matrix[][] sample, int size) {
    int[] indices = new int[sample[0].length];

    for (int i = 0; i < indices.length; i++) indices[i] = i;

    int temp = 0;
    for (int i = 0; i < indices.length; i++) {
      int j = floor(random(i, indices.length));
      temp = indices[i];
      indices[i] = indices[j];
      indices[j] = temp;
    }

    int actualSize = min(size, sample[0].length);
    Matrix[] sampleInputs = new Matrix[actualSize];
    Matrix sampleOutputs = new Matrix(sample[1][0].n, actualSize);

    for(int k = 0; k < actualSize; k++) {
      sampleInputs[k] = sample[0][indices[k]];
      sampleOutputs.ColumnFromArray(k, sample[1][0].ColumnToArray(indices[k]));
    }

    return new Matrix[][]{sampleInputs, {sampleOutputs}};
  }

  //f Prend un jeu de données CNN (Matrix[][] avec Matrix[0] liste d'images d'entrée, Matrix[1][0] la matrice de sortie attendue)
  // Renvoie un jeu de données "classique" (Matrix[] avec Matrix[0] la matrice d'entrée, Matrix[1] la matrice de sortie attendue)
  public Matrix[] SampleLining(Matrix[][] sample) {
    if (abortTraining.get()) return new Matrix[0];
    if (sample[0].length == 0) return new Matrix[]{new Matrix(0)};
    Matrix inputs = new Matrix(sample[0][0].n * sample[0][0].p, sample[0].length);
    for(int k = 0; k < sample[0].length; k++) {
      for(int i = 0; i < sample[0][k].n; i++)
        for(int j = 0; j < sample[0][k].p; j++)
          inputs.values[(i * sample[0][k].p + j) * inputs.p + k] = sample[0][k].values[i * sample[0][k].p + j];
    }

    return new Matrix[]{inputs, sample[1][0]};
  }

  //f Récupère le jeu de données MNIST et le renvoie sous
  // le format décrit précédemment
  public Matrix[][] GetMNISTDataset(String path) {
    cl.pln(path + " : Démarrage de l'import");
    Table table = loadTable(path);
    cl.pln(path + " : Import terminé");

    int imgSize = 28;
    int n = table.getRowCount();
    Matrix[] inputs = new Matrix[n];
    Matrix outputs = new Matrix(10, n);
    int k = 0;
    for (TableRow tr : table.rows()) {
      int size = tr.getColumnCount() - 1;

      float[] line = new float[size];
      for (int i = 1; i < size+1; i++) line[i-1] = map(tr.getFloat(i), 0, 255, 1, 0);
      inputs[k] = new Matrix(imgSize).FromArray(line);

      float[] col = new float[10];
      col[tr.getInt(0)] = 1;
      outputs.ColumnFromArray(k, col);
      k++;
    }

    return new Matrix[][]{ inputs, {outputs} };
  }

  //s Les paramètres de brouillage sont ceux de la classe
  public PImage[] GetRandomCouple(int xw, int xh) {
    return GetRandomCouple(xw, xh, this.move, this.blur, this.density, this.perlin, this.deformation);
  }

  //f Récupère un couple aléatoire [image, image brouillée pour les paramètres donnés]
  public PImage[] GetRandomCouple(int xw, int xh, float mv, float blr, float dst, float prln, float defrm) {
    int s = floor(random(1) * (handPolicies.length + fontPolicies.length));
    int c = floor(random(1) * (cs.NumChars()));
    PImage original;

    String path = s < handPolicies.length
      ? "./TextFileGetter/output/" + cs.GetChars()[c] + "/" + cs.GetChars()[c] + " - " + handPolicies[s] + ".jpg"
      : "./FromFontGetter/output/" + cs.GetChars()[c] + "/" + cs.GetChars()[c] + " - " + fontPolicies[s - handPolicies.length] + ".jpg";
    original = loadImage(path);
    PImage img = im.ScrambleImage(im.Resize(original, xw, xh), mv, blr, dst, prln, defrm);

    Matrix imgPixels = session.ImgPP(img);

    return new PImage[] {original, CNNGetImageFromInputs(imgPixels)};
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

  //f Renvoie une image affichable de l'image stockée en colonne _j_ de l'entrée _inputs_
  public PImage CNNGetImageFromInputs(Matrix inputs) {
    PImage img = createImage(session.w, session.h, RGB);
    img.loadPixels();
    for(int i = 0; i < img.pixels.length; i++) {
      int val = floor((float)inputs.Get(floor(i / session.w), i % session.w) * 255);
      img.pixels[i] = color(val, val, val);
    }
    img.updatePixels();
    return img;
  }

  //f Exporte le jeu de données _data_ dans le fichier _name_
  // (pour éviter d'avoir à regénérer des données à chaque fois)
  public void Export(Matrix[] data, String name) {
    ArrayList<String> output = new ArrayList<String>();

    output.add(data[0].n + "," + data[1].n + "," + data[0].p);

    String[] inputSave = data[0].SaveToString(true);
    for (String s : inputSave) output.add(s);
    cl.pln("Entrées exportées");

    String[] outputSave = data[1].SaveToString(true);
    for (String s : outputSave) output.add(s);
    cl.pln("Sorties exportées");

    String[] writenOutput = new String[output.size()];
    saveStrings(name, output.toArray(writenOutput));
  }

  //f Importe un jeu de données à partir du fichier _name_
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

//f Ajoute les resultats d'un traitement d'image à _res_
// Cette fonction est à part car les différents "threads" doivent y avoir accès
// sans créer de conflits
public synchronized void AddToRes(ArrayList<Matrix[]> res, Matrix[] toAdd, int sampleSize, int startTime) {
  res.add(toAdd);

  if(res.size() % (sampleSize / 10) == 0) {
    cl.pln(String.format("%5.3f", (float)res.size() / sampleSize), "Temps restant :", RemainingTime(startTime, res.size(), sampleSize));
  }
}
