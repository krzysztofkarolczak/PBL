using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Microsoft.Kinect;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using KinectLib;
using Microsoft.Win32;

namespace KinectRecorder
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private KinectSensor sensor;
        private Boolean isRecording;

        private List<KinectLib.SkeletonFrame> Frames;
        private List<KinectLib.SkeletonFrame> OpenedFrames;

        public MainWindow()
        {
            InitializeComponent();
            isRecording = false;
            Frames = new List<KinectLib.SkeletonFrame>();
        }

        private void button1_Click(object sender, RoutedEventArgs e)
        {
            isRecording = !isRecording;
            label1.Content = isRecording ? "recording..." : "recording stopped";
            if (isRecording == false)
            {
                SaveFileDialog dlg = new SaveFileDialog();
                dlg.CheckPathExists = true;
                dlg.ShowDialog();
                String path = dlg.FileName;
                if (path != String.Empty)
                {
                    if (!File.Exists(path))
                    {
                        using (FileStream s = File.Create(path)) ;
                    }
                    using (FileStream writer = File.OpenWrite(path))
                    {
                        IFormatter formatter = new BinaryFormatter();
                        formatter.Serialize(writer, Frames);
                    }
                }
            }
        }

        private void WindowLoaded(object sender, RoutedEventArgs e)
        {
            foreach (var potentialSensor in KinectSensor.KinectSensors)
            {
                if (potentialSensor.Status == KinectStatus.Connected)
                {
                    this.sensor = potentialSensor;
                    break;
                }
            }

            if (null != this.sensor)
            {
                this.sensor.SkeletonStream.Enable();
                this.sensor.SkeletonFrameReady += this.SensorSkeletonFrameReady;
                label1.Content = "Kinect ready";

                // Start the sensor!
                try
                {
                    this.sensor.Start();
                }
                catch (IOException)
                {
                    this.sensor = null;
                }
            }

            if (null == this.sensor)
            {
                label1.Content = "No kinect ready";
                button1.IsEnabled = false;
            }
        }
        private void WindowClosing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if (null != this.sensor)
            {
                this.sensor.Stop();
            }
        }
        private void SensorSkeletonFrameReady(object sender, SkeletonFrameReadyEventArgs e)
        {
            if (isRecording)
            {
                DateTime Time = DateTime.Now;
                Skeleton[] skeletons = new Skeleton[0];

                using (Microsoft.Kinect.SkeletonFrame skeletonFrame = e.OpenSkeletonFrame())
                {
                    if (skeletonFrame != null)
                    {
                        skeletons = new Skeleton[skeletonFrame.SkeletonArrayLength];
                        skeletonFrame.CopySkeletonDataTo(skeletons);
                    }
                }
                foreach (Skeleton skel in skeletons)
                {
                    if (skel.TrackingState == SkeletonTrackingState.Tracked)
                    {
                        KinectLib.SkeletonFrame frame = new KinectLib.SkeletonFrame();
                        frame.Date = Time;
                        frame.SkeletonId = skel.TrackingId;
                        frame.Nodes = new List<SkeletonNode>();
                        frame.X = skel.Position.X;
                        frame.Y = skel.Position.Y;
                        frame.Z = skel.Position.Z;

                        foreach (Joint joint in skel.Joints)
                        {
                            SkeletonNode node = new SkeletonNode();
                            node.NodeType = (int)joint.JointType;
                            node.X = joint.Position.X;
                            node.Y = joint.Position.Y;
                            node.Z = joint.Position.Z;

                            frame.Nodes.Add(node);
                        }
                        Frames.Add(frame);

                        Skeleton DisplaySkeleton = skel;
                        Joint Crotch = DisplaySkeleton.Joints.First(j => j.JointType == JointType.HipCenter);
                        if (Crotch != null)
                        {
                            DrawingGroup DrawingGroup = new DrawingGroup();
                            using (DrawingContext Context = DrawingGroup.Open())
                            {
                                Double CrotchDisplayX = image1.Width / 2;
                                Double CrotchDisplayY = image1.Height / 2;

                                foreach (Joint Node in DisplaySkeleton.Joints)
                                {
                                    double X = (Node.Position.X - Crotch.Position.X) / 2.5 * image1.Width + CrotchDisplayX;
                                    double Y = (-Node.Position.Y + Crotch.Position.Y) / 2.5 * image1.Height + CrotchDisplayY;
                                    Context.DrawEllipse(Brushes.Wheat, new Pen(Brushes.Navy, 2), new Point(X, Y), 7, 7);
                                }

                            }
                            DrawingGroup.Freeze();
                            Dispatcher.Invoke(new Action(() => { image1.Source = new DrawingImage(DrawingGroup); }));
                        }
                    }
                }
            }
        }

        private void button2_Click(object sender, RoutedEventArgs e)
        {
            if (!isRecording)
            {
                using (FileStream writer = File.OpenRead(@"D:\KinectRecordings.txt"))
                {
                    IFormatter formatter = new BinaryFormatter();
                    OpenedFrames = formatter.Deserialize(writer) as List<KinectLib.SkeletonFrame>;
                }
            }

        }

    }
}