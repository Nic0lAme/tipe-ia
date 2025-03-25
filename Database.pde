import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Date;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.security.cert.X509Certificate;

class Database {
  String databaseLink;
  
  //c _link_ correspond au lien de la realtime database
  Database(String link) { 
    this.databaseLink = link;
    DisableSSLVerification();
  }
  
  public void DisableSSLVerification() {
    try {
      TrustManager[] trustAllCerts = new TrustManager[]{
        new X509TrustManager() {
          public X509Certificate[] getAcceptedIssuers() {
            return null;
          }

          public void checkClientTrusted(X509Certificate[] certs, String authType) {
          }

          public void checkServerTrusted(X509Certificate[] certs, String authType) {
          }
        }
      };

      SSLContext sc = SSLContext.getInstance("TLS");
      sc.init(null, trustAllCerts, new java.security.SecureRandom());
      HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

      // Optionnel : Désactiver l'hôte de vérification
      HttpsURLConnection.setDefaultHostnameVerifier((hostname, session) -> true);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  //f Réccupère le contenu des _data_ dans la base de donnée, dans la section _fileName_
  public JSONArray GetData(String fileName) {
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
      
      JSONArray outputJSON = new JSONArray();
      for(Object k : jsonObject.keys()) {
        outputJSON.append(jsonObject.getJSONObject(k.toString()).getJSONObject("data"));
      }
      
      conn.disconnect();
      
      return outputJSON;
    } catch (Exception e) {
      e.printStackTrace();
      return new JSONArray();
    }
  }
   
  //f Ajoute à la base de donnée, dans la section _fileName_, le String _data_
  public void PostData(String fileName, JSONObject data) {
    try {
      // URL pour lire tous les posts sous le nœud "posts"
      URL url = new URL(this.databaseLink + fileName + ".json");
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setDoOutput(true);
      conn.setRequestMethod("POST");
      conn.setRequestProperty("Content-Type", "application/json");

      // Données du post à ajouter
      Date d = new Date();
      String postData = "{\"data\": " + data.toString() + ", \"timestamp\": \"" + d.getTime() + "\"}";
      cl.pln(postData);

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
  
  //f Ajoute à la base de donnée, dans la section _fileName_, le String _data_
  public void DeleteData(String fileName) {
    try {
      // URL pour lire tous les posts sous le nœud "posts"
      URL url = new URL(this.databaseLink + fileName + ".json");
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setDoOutput(true);
      conn.setRequestMethod("DELETE");

      if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
        throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode());
      }

      conn.disconnect();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
}
