import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Date;

class Database {
  String databaseLink;
  
  //c _link_ correspond au lien de la realtime database
  Database(String link) { 
    this.databaseLink = link;
  }
  
  //f Réccupère le contenu des _data_ dans la base de donnée, dans la section _fileName_
  public String[] GetData(String fileName) {
    try {
      URL url = new URL(this.databaseLink + fileName + ".json");
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("GET");
      conn.setRequestProperty("Accept", "application/json");

      if (conn.getResponseCode() != 200) {
        throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode());
      }

      BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));
      StringBuilder sb = new StringBuilder();
      String output;
      while ((output = br.readLine()) != null) {
        sb.append(output);
      }
      
      JSONObject jsonObject = parseJSONObject(sb.toString());
      
      ArrayList<String> outputString = new ArrayList<String>();
      for(Object k : jsonObject.keys()) {
        outputString.add(jsonObject.getJSONObject(k.toString()).getString("data"));
      }
      
      conn.disconnect();
      
      return outputString.toArray(new String[]{});
    } catch (Exception e) {
      e.printStackTrace();
      return new String[]{};
    }
  }
   
  //f Ajoute à la base de donnée, dans la section _fileName_, le String _data_
  public void PostData(String fileName, String data) {
    try {
      // URL pour lire tous les posts sous le nœud "posts"
      URL url = new URL(this.databaseLink + fileName + ".json");
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setDoOutput(true);
      conn.setRequestMethod("POST");
      conn.setRequestProperty("Content-Type", "application/json");

      // Données du post à ajouter
      Date d = new Date();
      String postData = "{\"data\": \"" + data + "\", \"timestamp\": \"" + d.getTime() + "\"}";

      OutputStream os = conn.getOutputStream();
      os.write(postData.getBytes());
      os.flush();

      if (conn.getResponseCode() != HttpURLConnection.HTTP_CREATED) {
        throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode());
      }

      conn.disconnect();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
}
