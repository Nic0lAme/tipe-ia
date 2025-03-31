import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.DatasetRenderingOrder;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import java.text.DecimalFormat;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.event.AdjustmentEvent;
import java.awt.event.AdjustmentListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseListener;
import java.util.LinkedList;
import java.util.concurrent.atomic.AtomicBoolean;
import java.io.File;
import javax.imageio.ImageIO;
import java.io.IOException;
import java.io.OutputStream;
import java.text.NumberFormat;

class GraphApplet extends JFrame {
  private LearnGraph graph;

  private JButton pinButton, pauseButton;
  private JMenu files, edit, display;
  private JMenuItem newNNItem, importItem, exportItem;
  private JMenuItem testItem, trainItem, stopTrainItem;
  private JMenuItem dataItem, avgItem, axisItem;
  private JLabel networkLabel;
  private JMenuBar menuBar;
  public JScrollPane consoleScroll;
  public JTextArea console;
  private boolean pin = false;

  //c
  public GraphApplet() {
    graph = new LearnGraph("Itérations", "Coût");
    this.setTitle("TIPE");

    this.getContentPane().setPreferredSize(new Dimension(1000, 600));

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

  //f Centre la frame _frame_ dans l'écran
  private void CenterFrame(JFrame frame) {
    Dimension windowSize = frame.getSize();
    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    Point centerPoint = ge.getCenterPoint();

    int dx = centerPoint.x - windowSize.width / 2;
    int dy = centerPoint.y - windowSize.height / 2;
    frame.setLocation(dx, dy);
  }

  //f Change le nom du réseau de neurone affiché
  public void SetNetworkName(String name) {
    networkLabel.setText(name);
  }

  //f Ajoute le point _x_,_y_ au graphique
  public void AddValue(double x, double y) {
    graph.Add(x, y);
  }

  //f Ajoute le point _y_ au graphique
  public void AddValue(double y) {
    graph.Add(y);
  }

  public void AddTestResult(double train, double test) {
    graph.AddTestResult(train, test);
  }

  //f Nettoie le graphique
  public void ClearGraph()  {
    graph.Clear();
  }

  //f Active/désactive l'épinglage de la fenêtre
  private void TogglePin() {
    pin = !pin;
    setAlwaysOnTop(pin);
    if (pin) pinButton.setText("Désépingler");
    else pinButton.setText("Épingler");
  }

  //f Permet d'exporter le réseau de neurone actif
  // A FAIRE : Devra au final exporter toute la session
  private void ExportNN() {
    if (!stopLearning.get()) TogglePause();
    boolean wasPin = this.pin;
    if(wasPin) TogglePin();

    pauseButton.setEnabled(false);
    JFileChooser fileChooser = new JFileChooser();
    fileChooser.setAcceptAllFileFilterUsed(false);

    File defaultDir = new File(sketchPath() + "/NeuralNetworkSave");
    fileChooser.setCurrentDirectory(defaultDir);
    int response = fileChooser.showOpenDialog(null);
    if (response == JFileChooser.APPROVE_OPTION) {
      session.nn.Export(fileChooser.getSelectedFile().getAbsolutePath());
    }
    if(wasPin) TogglePin();
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

  //f Importe un réseau de neurone
  // A FAIRE : devra au final importer une session entière
  private void ImportNN() {
    JFrame frame = new JFrame("Importer un réseau");
    boolean wasPin = this.pin;
    if(wasPin) TogglePin();
    frame.setSize(600, 200);
    CenterFrame(frame);

    frame.addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) {
        if(wasPin) TogglePin();
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
    wField.setValue(session.w);

    JLabel hLabel = new JLabel("Hauteur");
    JFormattedTextField hField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    hField.setValue(session.h);

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

            HyperParameters hp = new HyperParameters();

            NeuralNetwork newNN = new NeuralNetwork().Import(fileChooser.getSelectedFile().getAbsolutePath());

            if (newNN.outputSize != session.characters.length) {
              cl.pln("Wrong output size");
              return;
            }

            Session s = new Session("", hp);
            s.nn = newNN;
            s.nn.useSoftMax = isChecked;
            s.w = int(wField.getText());
            s.h = int(hField.getText());

            SetMainSession(s);

            graph.Clear();

            cl.pln(s.nn);

            if(wasPin) TogglePin();
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

  //f Permet de créer un nouveau réseau de neurones
  // A FAIRE : devra au final permettre de créer une nouvelle session
  private void NewNN() {
    JFrame frame = new JFrame("Nouveau réseau");
    boolean wasPin = this.pin;
    if(wasPin) TogglePin();

    frame.setSize(600, 200);
    CenterFrame(frame);

    JPanel panel = new JPanel();
    panel.setLayout(new GridLayout(5, 2));

    JLabel wLabel = new JLabel("Largeur");
    JFormattedTextField wField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    wField.setValue(19);

    JLabel hLabel = new JLabel("Hauteur");
    JFormattedTextField hField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    hField.setValue(21);

    JLabel textLabel = new JLabel("Hidden Layers (, or ;)");
    JTextField textField = new JTextField("256;128;128");

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

            HyperParameters hp = new HyperParameters();
            session.w = int(wField.getText());
            session.h = int(hField.getText());

            int[] layers = int((str(session.w*session.h) + "," + text + "," + str(session.characters.length)).split("[,\\;]"));

            Session s = new Session("", hp);
            s.nn = new NeuralNetwork(layers);
            s.nn.useSoftMax = isChecked;

            SetMainSession(s);

            graph.Clear();

            cl.pln(s.nn);
            if(wasPin) TogglePin();
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

  //f Permet de mettre en pause les epochs
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

  //f Permet de montrer/cacher la valeur moyenne sur le graphique
  private void ToggleAvg() {
    graph.ToggleAvg();
    avgItem.setText((graph.IsAvgShowed() ? "Masquer" : "Afficher") + " la moyenne glissante");
  }

  //f Permet de montrer/cacher les valeurs des loss
  private void ToggleData() {
    graph.ToggleData();
    dataItem.setText((graph.IsDataShowed() ? "Masquer" : "Afficher") + " les données brutes");
  }

  //f Permet de passer en échelle log ou linéaire
  private void ToggleLogAxis() {
    graph.SwitchOrdAxis();
    axisItem.setText("Passer en échelle " + (graph.IsLogAxis() ? "linéaire" : "log"));
  }

  //f Permet de lancer un test du réseau de neurones actif
  private void ToggleTest() {
    testImages = true;
    try { Thread.sleep(500); }
      catch (Exception e) {}
    testImages = false;
  }

  //f Permet de lancer un entrainement du réseau de neurones actif
  private void ToggleTrain() {
    boolean wasPin = this.pin;
    if(wasPin) TogglePin();

    JFrame frame = new JFrame("Lancer un entrainement");
    frame.setSize(900, 200);
    CenterFrame(frame);

    JPanel panel = new JPanel();
    panel.setLayout(new GridLayout(4, 8));


    JLabel phaseLabel = new JLabel("# de phase");
    JFormattedTextField phaseField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    phaseField.setValue(4);

    JLabel epochLabel = new JLabel("# d'epoch");
    JFormattedTextField epochField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    epochField.setValue(16);

    JLabel batchLabel = new JLabel("Taille des batches");
    JFormattedTextField batchField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    batchField.setValue(64);

    JLabel periodLabel = new JLabel("Période de LR");
    JFormattedTextField periodField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    periodField.setValue(4);

    JLabel startMinLRLabel = new JLabel("LR min intial");
    JFormattedTextField startMinLRField = new JFormattedTextField();
    startMinLRField.setValue(0.5);

    JLabel startMaxLRLabel = new JLabel("LR max intial");
    JFormattedTextField startMaxLRField = new JFormattedTextField();
    startMaxLRField.setValue(1.5);

    JLabel endMinLRLabel = new JLabel("LR min final");
    JFormattedTextField endMinLRField = new JFormattedTextField();
    endMinLRField.setValue(0.1);

    JLabel endMaxLRLabel = new JLabel("LR max final");
    JFormattedTextField endMaxLRField = new JFormattedTextField();
    endMaxLRField.setValue(0.5);

    JLabel startDefLabel = new JLabel("Déformation initiale");
    JFormattedTextField startDefField = new JFormattedTextField();
    startDefField.setValue(1.0);

    JLabel endDefLabel = new JLabel("Déformation finale");
    JFormattedTextField endDefField = new JFormattedTextField();
    endDefField.setValue(1.0);

    JLabel repLabel = new JLabel("Répétition d'échantillon");
    JFormattedTextField repField = new JFormattedTextField(NumberFormat.getIntegerInstance());
    repField.setValue(8);

    JLabel propLabel = new JLabel("Proportion min");
    JFormattedTextField propField = new JFormattedTextField();
    propField.setValue(1.0);

    JButton validateButton = new JButton("Valider");

    validateButton.addActionListener(new ActionListener() {
        @Override
        public void actionPerformed(ActionEvent e) {
          frame.setVisible(false);
          if(wasPin) TogglePin();

          class Train implements Runnable {
            public void run() {
              session.TrainForImages (
                int(phaseField.getText()), int(epochField.getText()),
                float(startMinLRField.getText().replace(',', '.')), float(endMinLRField.getText().replace(',', '.')),
                float(startMaxLRField.getText().replace(',', '.')), float(endMaxLRField.getText().replace(',', '.')),
                int(periodField.getText()), int(batchField.getText()),
                float(startDefField.getText().replace(',', '.')), float(endDefField.getText().replace(',', '.')),
                int(repField.getText()), float(propField.getText().replace(',', '.'))
              );
            }
          }

          new Thread(new Train()).start();

          /*
          TrainForImages (
            int(phaseField.getText()), int(epochField.getText()),
            float(startMinLRField.getText()), float(endMinLRField.getText()),
            float(startMaxLRField.getText()), float(endMaxLRField.getText()),
            int(periodField.getText()), int(batchField.getText()),
            float(startDefField.getText()), float(endDefField.getText()),
            int(repField.getText()), float(propField.getText())
          );
          */
        }
    });

    panel.add(phaseLabel);
    panel.add(phaseField);
    panel.add(epochLabel);
    panel.add(epochField);
    panel.add(batchLabel);
    panel.add(batchField);
    panel.add(periodLabel);
    panel.add(periodField);
    panel.add(startMinLRLabel);
    panel.add(startMinLRField);
    panel.add(startMaxLRLabel);
    panel.add(startMaxLRField);
    panel.add(endMinLRLabel);
    panel.add(endMinLRField);
    panel.add(endMaxLRLabel);
    panel.add(endMaxLRField);
    panel.add(startDefLabel);
    panel.add(startDefField);
    panel.add(endDefLabel);
    panel.add(endDefField);
    panel.add(repLabel);
    panel.add(repField);
    panel.add(propLabel);
    panel.add(propField);

    for(int i = 0; i < 7; i++) panel.add(new JLabel());
    panel.add(validateButton);

    frame.add(panel);
    frame.setVisible(true);
  }

  //f Demande l'arrêt de l'entrainement en cours si il y en a
  private void TryStopTraining() {
    if (!session.IsInTraining()) cl.pln("[WARNING] Aucun entrainement en cours !");
    else session.AskStopTraining();
  }

  //f Ajoute l'entrée _text_ à la console
  public void WriteToConsole(String text) {
    console.append(text);
    consoleScroll.getVerticalScrollBar().setValue(consoleScroll.getVerticalScrollBar().getMaximum());
  }

  //f Initialise la fenêtre, en utlisant le graphique _graph_
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

    edit = new JMenu("Éditer");

    testItem = new JMenuItem("Tester");
    testItem.setFocusable(false);
    testItem.addActionListener(e -> ToggleTest());
    testItem.setMargin(new Insets(5, 5, 5, 5));
    testItem.setFont(new Font("", Font.PLAIN, 16));
    edit.add(testItem);

    trainItem = new JMenuItem("Entrainer");
    trainItem.setFocusable(false);
    trainItem.addActionListener(e -> ToggleTrain());
    trainItem.setMargin(new Insets(5, 5, 5, 5));
    trainItem.setFont(new Font("", Font.PLAIN, 16));
    edit.add(trainItem);

    stopTrainItem = new JMenuItem("Arrêter l'entrainement");
    stopTrainItem.setFocusable(false);
    stopTrainItem.addActionListener(e -> TryStopTraining());
    stopTrainItem.setMargin(new Insets(5, 5, 5, 5));
    stopTrainItem.setFont(new Font("", Font.PLAIN, 16));
    edit.add(stopTrainItem);

    menuBar.add(edit);


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

    axisItem = new JMenuItem("Passer en échelle linéaire");
    axisItem.setFocusable(false);
    axisItem.addActionListener(e -> ToggleLogAxis());
    axisItem.setMargin(new Insets(5, 5, 5, 5));
    axisItem.setFont(new Font("", Font.PLAIN, 16));
    display.add(axisItem);

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

    try { pinButton.setIcon(new ImageIcon(ImageIO.read(new File(sketchPath() + "/AuxiliarFiles/pin.png")).getScaledInstance(24, 24, Image.SCALE_DEFAULT))); }
    catch(Exception e) {}

    gbc.gridx = 0;
    gbc.gridy = 0;
    gbc.anchor = GridBagConstraints.WEST;
    top.add(pinButton, gbc);

    networkLabel = new JLabel("");
    networkLabel.setFont(new Font("", Font.PLAIN, 16));

    gbc.gridx = 1;
    gbc.gridy = 0;
    gbc.anchor = GridBagConstraints.CENTER;
    top.add(networkLabel, gbc);

    pauseButton = new JButton("Pause");
    pauseButton.setFocusable(false);
    pauseButton.addActionListener(e -> TogglePause());
    pauseButton.setMargin(new Insets(5, 5, 5, 5));
    pauseButton.setFont(new Font("", Font.PLAIN, 16));

    try { pauseButton.setIcon(new ImageIcon(ImageIO.read(new File(sketchPath() + "/AuxiliarFiles/pause.png")).getScaledInstance(24, 24, Image.SCALE_DEFAULT))); }
    catch(Exception e) {}

    gbc.gridx = 2;
    gbc.gridy = 0;
    gbc.anchor = GridBagConstraints.EAST;
    top.add(pauseButton, gbc);

    this.setJMenuBar(menuBar);

    add(top, BorderLayout.NORTH);

    JSplitPane split = new JSplitPane();
    split.setOrientation(JSplitPane.HORIZONTAL_SPLIT);
    split.setResizeWeight(0.6);

    graph.GetPanel().setPreferredSize(new Dimension(600, 200));

    console = new JTextArea();
    console.setBackground(Color.lightGray);
    console.setEditable(false);

    consoleScroll = new JScrollPane(console);
    consoleScroll.setPreferredSize(new Dimension(400, 200));
    consoleScroll.setBorder(new TitledBorder(new EtchedBorder(), "Console"));
    consoleScroll.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);

    split.add(graph.GetPanel(), JSplitPane.LEFT);
    split.add(consoleScroll, JSplitPane.RIGHT);

    add(split, BorderLayout.CENTER);
  }
}

public class LearnGraph {
  final private JFreeChart chart;
  final private XYSeries series, average;
  final private ChartPanel panel;
  final private JPanel jpanel;

  private final int DATA_INDEX, AVG_INDEX;
  private float strokeWeight = 1.25f;

  private final String ordonnesName;
  private final LogAxis logAxis;
  private final NumberAxis linAxis;
  private final Font annotationFont = new Font("Dialog", Font.PLAIN, 13);
  private boolean isLog;

  private final LinkedList<Double> avgDatas = new LinkedList<Double>();
  private final int avgPeriod = 100;
  private double somme = 0;

  public LearnGraph(String abscisses, String ordonnees) {
    ordonnesName = ordonnees;

    // Datasets
    series = new XYSeries("Coût");
    average = new XYSeries("Moyenne glissante");
    XYSeriesCollection dataset = new XYSeriesCollection();
    dataset.addSeries(average);
    dataset.addSeries(series);
    AVG_INDEX = 0;
    DATA_INDEX = 1;

    // Graphique
    chart = ChartFactory.createXYLineChart("", abscisses, ordonnees, dataset, PlotOrientation.VERTICAL, true, true, true);
    SetStrokeWeight(strokeWeight);
    chart.getXYPlot().getRenderer().setSeriesPaint(DATA_INDEX, Color.decode("#ff535a"));
    chart.getXYPlot().getRenderer().setSeriesPaint(AVG_INDEX, Color.decode("#786eff"));
    panel = new ChartPanel(chart);
    panel.setDomainZoomable(true);
    panel.setRangeZoomable(false);
    panel.setMouseWheelEnabled(true);
    chart.getXYPlot().setDomainPannable(true);

    // Axes
    NumberAxis absAxis = new NumberAxis(abscisses);
    linAxis = new NumberAxis(ordonnesName + " (linéaire)");
    linAxis.setNumberFormatOverride(new DecimalFormat("0.000E0"));
    linAxis.setAutoRangeIncludesZero(false);
    logAxis = new LogAxis(ordonnesName + " (log)");
    logAxis.setBase(10);
    logAxis.setNumberFormatOverride(new DecimalFormat("0.000E0"));
    chart.getXYPlot().setDomainAxis(absAxis);
    chart.getXYPlot().setRangeAxis(logAxis);
    isLog = true;

    jpanel = new JPanel();
    jpanel.setLayout(new BorderLayout());
    jpanel.add(panel, BorderLayout.CENTER);
  }

  public void SwitchOrdAxis() {
    if (isLog) chart.getXYPlot().setRangeAxis(linAxis);
    else chart.getXYPlot().setRangeAxis(logAxis);
    isLog = !isLog;
  }

  public boolean IsLogAxis() {
    return isLog;
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
    avgDatas.clear();
    somme = 0;
    chart.getXYPlot().clearAnnotations();
  }

  public void AddTestResult(double trainSet, double testSet) {
    int x = (series.getItemCount() == 0 ? 0 : series.getX(series.getItemCount()-1).intValue());
    double y = avgDatas.size() < avgPeriod
      ? series.getY(series.getItemCount()-1).doubleValue()
      : average.getY(average.getItemCount()-1).doubleValue();
    String tr = String.format("%.1f",trainSet*100) + "%";
    String ts = String.format("%.1f",testSet*100) + "%";
    String text = "[Train] " + tr + " [Test] " + ts;
    XYTextAnnotation result = new XYTextAnnotation(text, x, y);
    result.setBackgroundPaint(Color.WHITE);
    result.setFont(annotationFont);
    chart.getXYPlot().addAnnotation(result);
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
