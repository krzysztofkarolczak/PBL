using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using KinectLib;
using Microsoft.Win32;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.ComponentModel;
using System.Windows.Threading;
using KinectReader.Lib;
using System.Windows.Controls;

namespace KinectReader
{
   /// <summary>
   /// Interaction logic for MainWindow.xaml
   /// </summary>
   public partial class MainWindow : Window
   {
      private const Double NODE_RADIUS = 5;
      private const Double BONE_WIDTH = 5;
      private const Double WIDTH = 200;
      private const Double HEIGHT = 200;
      private const Double RESOLUTION = 200/1.5;
      private Brush OUTLINE = Brushes.DarkGray;
      private Brush NODE_COLOR = Brushes.WhiteSmoke;
      private Brush BONE_COLOR = Brushes.Gray;

      private Boolean Initialized = false;

      private List<SkeletonFrame> Frames;
      private Int32 CurrentFrame;

      private DispatcherTimer Movie;
      private static List<DrawingGroup> MovieFrames;

      public MainWindow()
      {
         InitializeComponent();
         MovieFrames = new List<DrawingGroup>();
         Movie = new DispatcherTimer();
         Movie.Dispatcher.Thread.Priority = System.Threading.ThreadPriority.AboveNormal;
         Movie.Interval = TimeSpan.FromMilliseconds(40);
         Movie.Tick += (s, a) =>
            {
               imSkeleton.Source = new DrawingImage(MovieFrames.ElementAt(++CurrentFrame % MovieFrames.Count));
               if (CurrentFrame == MovieFrames.Count)
               {
                  Movie.Stop();
                  CurrentFrame = 0;
               }
            };
         
      }

      private void bnLoad_Click(object sender, RoutedEventArgs e)
      {
         OpenFileDialog dlg = new OpenFileDialog();
         if (dlg.ShowDialog() == true)
         {
            lbStatus.Content = "Please wait. File loading...";
            Dictionary<Int32, String> Items = new Dictionary<Int32, String>();

            BackgroundWorker BgWorker = new BackgroundWorker();
            BgWorker.WorkerReportsProgress = true;
            BgWorker.DoWork += (s, a) =>
               {
                  //Load Frames
                  using (FileStream writer = File.OpenRead(dlg.FileName))
                  {
                     IFormatter formatter = new BinaryFormatter();
                     Frames = formatter.Deserialize(writer) as List<KinectLib.SkeletonFrame>;
                  }

                  //Set up skeletons
                  Byte Index = 0;
                  foreach (Int32 SkeletonID in Frames.Select(f => f.SkeletonId).Distinct())
                  {
                     Items.Add(SkeletonID, "Skeleton " + Convert.ToString(++Index));
                  }

                  //Parse Frames

                  String Lengths = "";
                  PathDetector PathDetector = new PathDetector(Frames.Where(f => f.SkeletonId == Frames.First().SkeletonId).ToList());

                  Pen SkeletonPen = new Pen(OUTLINE, 2);
                  foreach (SkeletonFrame Frame in Frames.Where(f => f.SkeletonId == Frames.First().SkeletonId))
                  {
                     (s as BackgroundWorker).ReportProgress(0, "Frames loading " + Convert.ToString(Frames.IndexOf(Frame) + 1) + "/" + Convert.ToString(Frames.Count));
                     //String ss = String.Empty;
                     //foreach (SkeletonNode Node in Frame.Nodes)
                     //{
                     //   ss += String.Format("{0};{1};{2};{3}\n", Node.NodeType, Node.X, Node.Y, Node.Z);
                     //}

                     NodesNormalizer NodesNormalizer = new NodesNormalizer(Frame.Nodes);

                     //SkeletonBone b1 = new SkeletonBone(Nodes.First(n => n.NodeType == 0), Nodes.First(n => n.NodeType == 12));
                     //SkeletonBone b2 = new SkeletonBone(Nodes.First(n => n.NodeType == 0), Nodes.First(n => n.NodeType == 16));
                     //Lengths += String.Format("{0} {1}\n", b1.Length,b2.Length);
                     Lengths += String.Format("{0} {1} {2};\n", Frame.X, Frame.Y, Frame.Z);

                     DrawingGroup DrawingGroup = new DrawingGroup();
                     using (DrawingContext Context = DrawingGroup.Open())
                     {
                        Context.DrawRectangle(Brushes.Transparent, new Pen(Brushes.Transparent, 0), new Rect(0, 0, WIDTH, HEIGHT));
                        Double CrotchDisplayX = WIDTH / 2;
                        Double CrotchDisplayY = 20;
                        SkeletonNode Crotch = Frame.Nodes.FirstOrDefault(n => n.NodeType == 0);
                        if (Crotch != null)
                        {
                           foreach (SkeletonNode Node in NodesNormalizer.NormalizedNodes)
                           {
                              Context.DrawEllipse(NODE_COLOR, SkeletonPen, new Point(Node.X * RESOLUTION + CrotchDisplayX, Node.Y * RESOLUTION + CrotchDisplayY), NODE_RADIUS, NODE_RADIUS);
                           }
                           
                        }
                     }
                     DrawingGroup.Freeze();
                     MovieFrames.Add(DrawingGroup);
                  }
                  double x = 0;
               };
            BgWorker.ProgressChanged += (s, a) =>
               {
                  lbStatus.Content = a.UserState;
               };
            BgWorker.RunWorkerCompleted += (s, a) =>
               {
                  //Set up Window title
                  String[] FileParts = dlg.FileName.Split(@"\".ToCharArray());
                  Title = FileParts[FileParts.Length - 1] + " - KinectPlayer";

                  //Set up skeletons
                  cbSkeleton.ItemsSource = Items;
                  cbSkeleton.SelectedIndex = 0;
                  cbSkeleton.Visibility = Visibility.Visible;

                  //Show first skeleton frame
                  imSkeleton.Source = new DrawingImage(MovieFrames.ElementAt(0));

                  //Switch on movie buttons
                  dpMovieButtons.Visibility = Visibility.Visible;
                  lbStatus.Content = "File successfully loaded";
                  Initialized = true;
               };
            BgWorker.RunWorkerAsync();
         }
      }

      private void bnToMFile_Click(object sender, RoutedEventArgs e)
      {
         SaveFileDialog dlg = new SaveFileDialog();
         dlg.DefaultExt = "m";
         dlg.Filter = "M-Files (*.m)|*.m";
         dlg.FileName = "LoadSkeleton";
         if (dlg.ShowDialog() == true)
         {
            lbStatus.Content = "Please wait. M-File being generated...";
            IEnumerable<SkeletonFrame> ff = Frames.Where(f => f.SkeletonId == (int)cbSkeleton.SelectedValue).Skip(1794).Take(96);
            SkeletonFrame.ToMFile(Frames.Where(f => f.SkeletonId == (int)cbSkeleton.SelectedValue).ToList(), dlg.FileName);            
         }
      }

      private void bnNext_Click(object sender, RoutedEventArgs e)
      {
         imSkeleton.Source = new DrawingImage(MovieFrames.ElementAt(++CurrentFrame % MovieFrames.Count));
      }

      private void bnPrevious_Click(object sender, RoutedEventArgs e)
      {
         imSkeleton.Source = new DrawingImage(MovieFrames.ElementAt(--CurrentFrame % MovieFrames.Count));
      }

      private void bnRewind_Click(object sender, RoutedEventArgs e)
      {
         CurrentFrame = 0;
         imSkeleton.Source = new DrawingImage(MovieFrames.ElementAt(0));
      }

      private void bnPlay_Click(object sender, RoutedEventArgs e)
      {
         Movie.Start();
      }

      private void bnPause_Click(object sender, RoutedEventArgs e)
      {
         Movie.Stop();
      }

      private void bnStop_Click(object sender, RoutedEventArgs e)
      {
         Movie.Stop();
         CurrentFrame = 0;
      }

      private void cbSkeleton_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
      {
         if (Initialized == false) return;
         
         dpMovieButtons.Visibility = Visibility.Hidden;
         Movie.Stop();
         CurrentFrame = 0;
         MovieFrames.Clear();

         Int32 SkeletonID = (Int32)(sender as ComboBox).SelectedValue;
         BackgroundWorker BgWorker = new BackgroundWorker();
         BgWorker.WorkerReportsProgress = true;
         BgWorker.DoWork += (s, a) =>
         {
            Pen SkeletonPen = new Pen(OUTLINE, 2);
            foreach (SkeletonFrame Frame in Frames.Where(f => f.SkeletonId == SkeletonID))
            {
               (s as BackgroundWorker).ReportProgress(0, "Frames loading " + Convert.ToString(Frames.IndexOf(Frame) + 1) + "/" + Convert.ToString(Frames.Count));
               
               NodesNormalizer NodesNormalizer = new NodesNormalizer(Frame.Nodes);

               DrawingGroup DrawingGroup = new DrawingGroup();
               using (DrawingContext Context = DrawingGroup.Open())
               {
                  Context.DrawRectangle(Brushes.Transparent, new Pen(Brushes.Transparent, 0), new Rect(0, 0, WIDTH, HEIGHT));
                  Double CrotchDisplayX = WIDTH / 2;
                  Double CrotchDisplayY = 20;
                  SkeletonNode Crotch = Frame.Nodes.FirstOrDefault(n => n.NodeType == 0);
                  if (Crotch != null)
                  {
                     foreach (SkeletonNode Node in NodesNormalizer.NormalizedNodes)
                     {
                        Context.DrawEllipse(NODE_COLOR, SkeletonPen, new Point(Node.X * RESOLUTION + CrotchDisplayX, Node.Y * RESOLUTION + CrotchDisplayY), NODE_RADIUS, NODE_RADIUS);
                     }

                  }
               }
               DrawingGroup.Freeze();
               MovieFrames.Add(DrawingGroup);
            }
         };
         BgWorker.ProgressChanged += (s, a) =>
         {
            lbStatus.Content = a.UserState;
         };
         BgWorker.RunWorkerCompleted += (s, a) =>
         {
            //Show first skeleton frame
            imSkeleton.Source = new DrawingImage(MovieFrames.ElementAt(0));

            //Switch on movie buttons
            dpMovieButtons.Visibility = Visibility.Visible;
            lbStatus.Content = "File successfully loaded";
         };
         BgWorker.RunWorkerAsync();
      }
   }
}
