import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.DatasetRenderingOrder;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import java.text.DecimalFormat;
import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.util.LinkedList;
import java.util.concurrent.atomic.AtomicBoolean;
import java.io.File;
import javax.imageio.ImageIO;
import java.io.IOException;
import java.text.NumberFormat;

class GraphApplet extends JFrame {
  private LearnGraph graph;

  private JButton pinButton, pauseButton, testButton;
  JMenu files, edit, display;
  private JMenuItem importItem, newNNItem, exportItem, dataItem, avgItem;
  JMenuBar menuBar;
  private boolean pin = false;

  public GraphApplet(String gTitle) {
    graph = new LearnGraph(gTitle, "Itérations", "Coût");
    this.setTitle("TIPE");
    
    this.getContentPane().setPreferredSize(new Dimension(600, 400));
    
    
    try { this.setIconImage(ImageIO.read(new File(sketchPath() + "/AuxiliarFiles/icon.png"))); }
    catch(Exception e) { println(e); }
    
    setResizable(true);
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    setVisible(true);
    setAlwaysOnTop(pin);
    
    
    Init(graph);
    pack();
    
    CenterFrame(this);
  }
  
  private void CenterFrame(JFrame frame) {
    Dimension windowSize = frame.getSize();
    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    Point centerPoint = ge.getCenterPoint();
  
    int dx = centerPoint.x - windowSize.width / 2;
    int dy = centerPoint.y - windowSize.height / 2;    
    frame.setLocation(dx, dy);
  }


  public void AddValue(double x, double y) {
    graph.Add(x, y);
  }

  public void AddValue(double y) {
    graph.Add(y);
  }

  public void ClearGraph()  {
    graph.Clear();
  }

  private void TogglePin() {
    pin = !pin;
    setAlwaysOnTop(pin);
    if (pin) pinButton.setText("Désépingler");
    else pinButton.setText("Épingler");
  }
  
  private void ExportNN() {
    if (!stopLearning.get()) TogglePause();
    pauseButton.setEnabled(false);
    JFileChooser fileChooser = new JFileChooser();
    fileChooser.setAcceptAllFileFilterUsed(false);
    
    File defaultDir = new File(sketchPath() + "/NeuralNetworkSave");
    fileChooser.setCurrentDirectory(defaultDir);
    int response = fileChooser.showOpenDialog(null);
    if (response == JFileChooser.APPROVE_OPTION) {
      nn.Export(fileChooser.getSelectedFile().getAbsolutePath());
    }
    pauseButton.setEnabled(true);
    if (stopLearning.get()) TogglePause();
  }
  
  /*
  private void ImportNN() {
    if (!stopLearning.get()) TogglePause();
    pauseButton.setEnabled(false);
    JFileChooser fileChooser = new JFileChooser();
    fileChooser.setAcceptAllFileFilterUsed(false);
    
    File defaultDir = new File(sketchPath() + "/NeuralNetworkSave");
    fileChooser.setCurrentDirectory(defaultDir);
    int response = fileChooser.showOpenDialog(null);
    if (response == JFileChooser.APPROVE_OPTION) {
      nn.Import(fileChooser.getSelectedFile().getAbsolutePath());
    }
    pauseButton.setEnabled(true);
    if (stopLearning.get()) TogglePause();
  }
  */
  
  private void ImportNN() {
    NeuralNetwork newNN = new NeuralNetwork();
    
    JFrame frame = new JFrame("Importer un réseau");
    frame.setSize(600, 200);
    CenterFrame(frame);
    
    frame.addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
        pauseButton.setEnabled(true);
        if (stopLearning.get()) TogglePause();
      }
    });
    
    if (!stopLearning.get()) TogglePause();
    pauseButton.setEnabled(false);
    JFileChooser fileChooser = new JFileChooser();
    fileChooser.setAcceptAllFileFilterUsed(false);
    
    File defaultDir = new File(sketchPath() + "/NeuralNetworkSave");
    fileChooser.setCurrentDirectory(defaultDir);

    JPanel panel = new JPanel();
    panel.setLayout(new GridLayout(5, 2));
    
    JLabel wLabel = new JLabel("Largeur");
    JFormattedTextField wField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    wField.setValue(w);
    
    JLabel hLabel = new JLabel("Hauteur");
    JFormattedTextField hField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    hField.setValue(h);
    
    JButton openFile = new JButton("Ouvrir");
    openFile.setFocusable(false);
    openFile.setMargin(new Insets(5, 5, 5, 5));
    openFile.setFont(new Font("", Font.PLAIN, 16));
    openFile.addActionListener(new ActionListener() {
        @Override
        public void actionPerformed(ActionEvent e) {
            int response = fileChooser.showOpenDialog(null);
            if (response == JFileChooser.APPROVE_OPTION) {
              return;
            }
        }
    });

    JLabel checkboxLabel = new JLabel("Soft Max");
    JCheckBox checkBox = new JCheckBox();
    checkBox.setSelected(true);

    JButton validateButton = new JButton("Valider");
    
    /*
    importButton.setFocusable(false);
    importButton.setMargin(new Insets(5, 5, 5, 5));
    importButton.setFont(new Font("", Font.PLAIN, 16));
    */
    
    validateButton.addActionListener(new ActionListener() {
        @Override
        public void actionPerformed(ActionEvent e) {
            boolean isChecked = checkBox.isSelected();
            
            w = int(wField.getText());
            h = int(hField.getText());
            
            NeuralNetwork newNN = new NeuralNetwork().Import(fileChooser.getSelectedFile().getAbsolutePath());
            
            if (newNN.entrySize != w*h) {
              cl.pln("Wrong input size");
              return;
            }
            
            if (newNN.outputSize != characters.length) {
              cl.pln("Wrong output size");
              return;
            }
            
            dataset = new LetterDataset(5*w, 5*h);
            nn = newNN;
            nn.useSoftMax = isChecked;
            
            println(nn);
            
            pauseButton.setEnabled(true);
            if (stopLearning.get()) TogglePause();
            frame.setVisible(false);
        }
    });
    
    panel.add(wLabel);
    panel.add(wField);
    panel.add(hLabel);
    panel.add(hField);
    panel.add(new JLabel());
    panel.add(openFile);
    panel.add(checkboxLabel);
    panel.add(checkBox);
    panel.add(new JLabel());
    panel.add(validateButton);

    frame.add(panel);

    // Affichez la fenêtre
    frame.setVisible(true);
  }
  
  private void NewNN() {
    JFrame frame = new JFrame("Nouveau réseau");
    frame.setSize(600, 200);
    CenterFrame(frame);

    JPanel panel = new JPanel();
    panel.setLayout(new GridLayout(5, 2));
    
    JLabel wLabel = new JLabel("Largeur");
    JFormattedTextField wField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    wField.setValue(w);
    
    JLabel hLabel = new JLabel("Hauteur");
    JFormattedTextField hField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    hField.setValue(h);

    JLabel textLabel = new JLabel("Hidden Layers (, or ;)");
    JTextField textField = new JTextField();

    JLabel checkboxLabel = new JLabel("Soft Max");
    JCheckBox checkBox = new JCheckBox();
    checkBox.setSelected(true);

    JButton validateButton = new JButton("Valider");
    
    /*
    importButton.setFocusable(false);
    importButton.setMargin(new Insets(5, 5, 5, 5));
    importButton.setFont(new Font("", Font.PLAIN, 16));
    */
    
    validateButton.addActionListener(new ActionListener() {
        @Override
        public void actionPerformed(ActionEvent e) {
            String text = textField.getText();
            boolean isChecked = checkBox.isSelected();
            
            w = int(wField.getText());
            h = int(hField.getText());
            dataset = new LetterDataset(5*w, 5*h);

            int[] layers = int((str(w*h) + "," + text + "," + str(characters.length)).split("[,\\;]"));
            
            nn = new NeuralNetwork(layers);
            nn.useSoftMax = isChecked;
            
            println(nn);
            frame.setVisible(false);
        }
    });
    
    panel.add(wLabel);
    panel.add(wField);
    panel.add(hLabel);
    panel.add(hField);
    panel.add(textLabel);
    panel.add(textField);
    panel.add(checkboxLabel);
    panel.add(checkBox);
    panel.add(new JLabel());
    panel.add(validateButton);

    frame.add(panel);

    // Affichez la fenêtre
    frame.setVisible(true);
  }
  
  
  private void TogglePause() {
    synchronized(stopLearning) {
      stopLearning.set(!stopLearning.get());
      if (!stopLearning.get()) stopLearning.notifyAll();
      
      try { Thread.sleep(500); }
      catch (Exception e) {}
      if (stopLearning.get()) pauseButton.setText("Reprendre");
      else pauseButton.setText("Pause");
    }
  }

  private void ToggleAvg() {
    graph.ToggleAvg();
    avgItem.setText((graph.IsAvgShowed() ? "Masquer" : "Afficher") + " la moyenne glissante");
  }

  private void ToggleData() {
    graph.ToggleData();
    dataItem.setText((graph.IsDataShowed() ? "Masquer" : "Afficher") + " les données brutes");
  }
  
  private void ToggleTest() {
    testImages = true;
    try { Thread.sleep(500); }
      catch (Exception e) {}
    testImages = false;
  }

  private void Init(LearnGraph graph) {
    setLayout(new BorderLayout());
    
    menuBar = new JMenuBar();
    files = new JMenu("Fichier");
    
    newNNItem = new JMenuItem("Nouveau réseau");
    newNNItem.setFocusable(false);
    newNNItem.addActionListener(e -> NewNN());
    newNNItem.setMargin(new Insets(5, 5, 5, 5));
    newNNItem.setFont(new Font("", Font.PLAIN, 16));
    newNNItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_N, KeyEvent.CTRL_DOWN_MASK));
    files.add(newNNItem);
    
    importItem = new JMenuItem("Importer");
    importItem.setFocusable(false);
    importItem.addActionListener(e -> ImportNN());
    importItem.setMargin(new Insets(5, 5, 5, 5));
    importItem.setFont(new Font("", Font.PLAIN, 16));
    importItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_I, KeyEvent.CTRL_DOWN_MASK));
    files.add(importItem);
    
    exportItem = new JMenuItem("Exporter");
    exportItem.setFocusable(false);
    exportItem.addActionListener(e -> ExportNN());
    exportItem.setMargin(new Insets(5, 5, 5, 5));
    exportItem.setFont(new Font("", Font.PLAIN, 16));
    exportItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_E, KeyEvent.CTRL_DOWN_MASK));
    files.add(exportItem);
    
    menuBar.add(files);
    
    
    display = new JMenu("Affichage");
    
    dataItem = new JMenuItem("Masquer les données brutes");
    dataItem.setFocusable(false);
    dataItem.addActionListener(e -> ToggleData());
    dataItem.setMargin(new Insets(5, 5, 5, 5));
    dataItem.setFont(new Font("", Font.PLAIN, 16));
    display.add(dataItem);

    avgItem = new JMenuItem("Masquer la moyenne glissante");
    avgItem.setFocusable(false);
    avgItem.addActionListener(e -> ToggleAvg());
    avgItem.setMargin(new Insets(5, 5, 5, 5));
    avgItem.setFont(new Font("", Font.PLAIN, 16));
    display.add(avgItem);
    
    menuBar.add(display);
    

    JPanel top = new JPanel();
    JPanel topCenter = new JPanel();
    JPanel topCenterBottom = new JPanel();
    GridBagConstraints gbc = new GridBagConstraints();
    top.setLayout(new GridBagLayout());
    topCenter.setLayout(new GridBagLayout());
    topCenterBottom.setLayout(new GridBagLayout());
    gbc.gridx = 1;
    gbc.gridy = 0;
    top.add(topCenter, gbc);
    gbc.gridx = 1;
    gbc.gridy = 1;
    top.add(topCenterBottom, gbc);

    gbc.insets = new Insets(5, 10, 5, 10);
    gbc.weightx = 1;
    gbc.weighty = 1;

    pinButton = new JButton("Épingler");
    pinButton.setFocusable(false);
    pinButton.addActionListener(e -> TogglePin());
    pinButton.setMargin(new Insets(5, 5, 5, 5));
    pinButton.setFont(new Font("", Font.PLAIN, 16));
    gbc.gridx = 0;
    gbc.gridy = 0;
    gbc.anchor = GridBagConstraints.WEST;
    top.add(pinButton, gbc);
    
    pauseButton = new JButton("Pause");
    pauseButton.setFocusable(false);
    pauseButton.addActionListener(e -> TogglePause());
    pauseButton.setMargin(new Insets(5, 5, 5, 5));
    pauseButton.setFont(new Font("", Font.PLAIN, 16));
    gbc.gridx = 1;
    gbc.gridy = 0;
    gbc.anchor = GridBagConstraints.WEST;
    top.add(pauseButton, gbc);
    
    
    testButton = new JButton("Tester");
    testButton.setFocusable(false);
    testButton.addActionListener(e -> ToggleTest());
    testButton.setMargin(new Insets(5, 5, 5, 5));
    testButton.setFont(new Font("", Font.PLAIN, 16));
    gbc.gridx = 2;
    gbc.gridy = 0;
    gbc.anchor = GridBagConstraints.CENTER;
    top.add(testButton, gbc);
    
    this.setJMenuBar(menuBar);

    add(top, BorderLayout.NORTH);
    add(graph.GetPanel(), BorderLayout.CENTER);
  }
}

public class LearnGraph {
  final private JFreeChart chart;
  final private XYSeries series, average;
  final private ChartPanel panel;
  final private JPanel jpanel;

  private final int DATA_INDEX, AVG_INDEX;
  private float strokeWeight = 1.25f;

  private final LinkedList<Double> avgDatas = new LinkedList<Double>();
  private final int avgPeriod = 200;
  private double somme = 0;

  public LearnGraph(String title, String abscisses, String ordonnees) {
    series = new XYSeries("Coût");
    average = new XYSeries("Moyenne glissante");
    XYSeriesCollection dataset = new XYSeriesCollection();
    dataset.addSeries(average);
    dataset.addSeries(series);
    AVG_INDEX = 0;
    DATA_INDEX = 1;
    chart = ChartFactory.createXYLineChart(title, abscisses, ordonnees, dataset, PlotOrientation.VERTICAL, true, true, true);
    SetStrokeWeight(strokeWeight);
    chart.getXYPlot().getRenderer().setSeriesPaint(DATA_INDEX, Color.decode("#ff535a"));
    chart.getXYPlot().getRenderer().setSeriesPaint(AVG_INDEX, Color.decode("#786eff"));
    panel = new ChartPanel(chart);
    panel.setDomainZoomable(true);
    panel.setRangeZoomable(false);
    panel.setMouseWheelEnabled(true);
    chart.getXYPlot().setDomainPannable(true);
    NumberAxis absAxis = new NumberAxis(abscisses);
    LogAxis ordAxis = new LogAxis(ordonnees + " (log)");
    ordAxis.setBase(10);
    ordAxis.setNumberFormatOverride(new DecimalFormat("0.000E0"));
    chart.getXYPlot().setDomainAxis(absAxis);
    chart.getXYPlot().setRangeAxis(ordAxis);

    jpanel = new JPanel();
    jpanel.setLayout(new BorderLayout());
    jpanel.add(panel, BorderLayout.CENTER);
  }

  public void SetStrokeWeight(float sw) {
    strokeWeight = sw;
    chart.getXYPlot().getRenderer().setSeriesStroke(DATA_INDEX, new BasicStroke(strokeWeight));
    chart.getXYPlot().getRenderer().setSeriesStroke(AVG_INDEX, new BasicStroke(strokeWeight));
  }

  public boolean IsAvgShowed() {
    return chart.getXYPlot().getRenderer().isSeriesVisible(AVG_INDEX);
  }

  public void ToggleAvg() {
    chart.getXYPlot().getRenderer().setSeriesVisible(AVG_INDEX, !IsAvgShowed());
  }

  public boolean IsDataShowed() {
    return chart.getXYPlot().getRenderer().isSeriesVisible(DATA_INDEX);
  }

  public void ToggleData() {
    chart.getXYPlot().getRenderer().setSeriesVisible(DATA_INDEX, !IsDataShowed());
  }

  public void Clear() {
    series.clear();
    average.clear();
  }

  public void Add(double y) {
    if (series.getItemCount() == 0) Add(1, y);
    else Add(series.getMaxX() + 1, y);
  }

  public void Add(double x, double y) {
    series.add(x, y);

    // Actualise la moyenne glissante
    somme += y;
    avgDatas.add(y);
    if (avgDatas.size() > avgPeriod) somme -= avgDatas.remove();
    if (avgDatas.size() == avgPeriod) average.add(x, somme/avgPeriod);
  }

  public JPanel GetPanel() {
    return jpanel;
  }
}
