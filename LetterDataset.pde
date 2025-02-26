import java.util.Arrays;

public class LetterDataset {
  final int w, h;
  float move = 0.25;
  float blur = 0.2;
  float density = 0.01;
  float perlin = 5;

  LetterDataset(int w, int h) {
    this.w = w;
    this.h = h;
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
    
    PGraphics pg = createGraphics(w, h, P3D);

    Matrix inputs = new Matrix(w*h, sampleSize);
    Matrix outputs = new Matrix(nbChar, sampleSize);
    outputs.Fill(0);

    int numColonne = 0;
    for (int c = 0; c < nbChar; c++) {
      for (int k = 0; k < repList[c]; k++) {
        for (int s = 0; s < nbSources; s++) {
          // Récupère l'image source et la modifie
          String path = s < hwSources.length
            ? "./TextFileGetter/output/" + characters[c] + "/" + characters[c] + " - " + hwSources[s] + ".jpg"
            : "./FromFontGetter/output/" + characters[c] + "/" + characters[c] + " - " + fSources[s - hwSources.length] + ".jpg";
          PImage original = loadImage(path);
          PImage img = im.ScrambleImage(im.Gray(im.Resize(original, w, h)),move, blur, density, perlin, pg);

          // Récupère les pixels et les normalise
          double[] imgPixels = new double[img.pixels.length];
          img.loadPixels();
          for (int i = 0; i < img.pixels.length; i++)
            imgPixels[i] = 1 - (double)brightness(img.pixels[i]) / 255;
          

          // Actualise les matrices entrées / sorties
          inputs.ColumnFromArray(numColonne, imgPixels);
          outputs.Set(c, numColonne, 1);
          numColonne += 1;
        }
        System.gc();
      }
    }
    
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

}
