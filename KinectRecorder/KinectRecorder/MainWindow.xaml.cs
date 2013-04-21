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

namespace KinectRecorder
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private KinectSensor sensor;
        private Boolean isRecording;

        private List<ourSkeletonFrame> Frames;
        private List<ourSkeletonFrame> OpenedFrames;

        public MainWindow()
        {
            InitializeComponent();
            isRecording = false;
            Frames = new List<ourSkeletonFrame>();
        }

        private void button1_Click(object sender, RoutedEventArgs e)
        {
            isRecording = !isRecording;
            label1.Content = isRecording ? "recording..." : "recording stopped";
            if (isRecording == false)
            {
                if (!File.Exists(@"C:\KinectRecordings.txt"))
                {
                    File.Create(@"C:\KinectRecordings.txt");
                }
                using (FileStream writer = File.OpenWrite(@"C:\KinectRecordings.txt"))
                {
                    IFormatter formatter = new BinaryFormatter();
                    formatter.Serialize(writer, Frames);
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
                button2.IsEnabled = false;
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

                using (SkeletonFrame skeletonFrame = e.OpenSkeletonFrame())
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
                        ourSkeletonFrame frame = new ourSkeletonFrame();
                        frame.Date = Time;
                        frame.SkeletonId = skel.TrackingId;
                        frame.Nodes = new List<Node>();
                        frame.X = skel.Position.X;
                        frame.Y = skel.Position.Y;
                        frame.Z = skel.Position.Z;

                        foreach (Joint joint in skel.Joints)
                        {
                            Node node = new Node();
                            node.NodeType = (int)joint.JointType;
                            node.X = joint.Position.X;
                            node.Y = joint.Position.Y;
                            node.Z = joint.Position.Z;

                            frame.Nodes.Add(node);
                        }
                    }
                }

            }
        }

        private void button2_Click(object sender, RoutedEventArgs e)
        {
            if (!isRecording)
            {
                using (FileStream writer = File.OpenRead(@"C:\KinectRecordings.txt"))
                {
                    IFormatter formatter = new BinaryFormatter();
                    OpenedFrames = formatter.Deserialize(writer) as List<ourSkeletonFrame>;
                }
            }
        }

    }
}