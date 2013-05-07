﻿using System;
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
using System.Timers;
using System.Windows.Threading;

namespace KinectProjection
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private List<KinectLib.SkeletonFrame> OpenedFrames;
        DispatcherTimer timer = new DispatcherTimer();
        int index = 1;
        double off_x = 0;
        double off_y = 0;
        double c_max;
        double c_min;
        double distance_to_start = 2.5;
        List<int> legs_int = new List<int>();
        List<int> leg_right = new List<int>();
        List<int> leg_left = new List<int>();
        public MainWindow()
        {
            InitializeComponent();
            List<JointType>  temp = new List<JointType>(new JointType[] { JointType.FootLeft, JointType.FootRight, JointType.AnkleLeft, JointType.AnkleRight, JointType.KneeLeft, JointType.KneeRight, JointType.HipCenter, JointType.HipLeft, JointType.HipRight } );
            legs_int = temp.Select(o=> (int)o).ToList();
            List<JointType> right = new List<JointType>(new JointType[] {  JointType.FootRight, JointType.AnkleRight, JointType.KneeRight, JointType.HipCenter, JointType.HipRight });
            List<JointType> left = new List<JointType>(new JointType[] { JointType.FootLeft, JointType.AnkleLeft, JointType.KneeLeft, JointType.HipCenter, JointType.HipLeft });
            leg_left = left.Select(o => (int)o).ToList();
            leg_right = right.Select(o => (int)o).ToList();
            timer.Interval = TimeSpan.FromMilliseconds(33);
            timer.Tick += timer_Tick;
            timer.Start();
            
        }

        void timer_Tick(object sender, EventArgs e)
        {
            if (OpenedFrames != null)
            {
                var frame = OpenedFrames[index];
                var frame_old = OpenedFrames[index-1];

                double x = frame.X - frame_old.X;
                double y = frame.Y - frame_old.Y;

                canvas1.Children.Clear();
                Ellipse el = new Ellipse();
                el.Width = 10;
                el.Height = 10;
                el.Fill = new SolidColorBrush(Colors.Green);
                Canvas.SetLeft(el, off_x +   x / c_max);
                Canvas.SetTop(el, off_y +   y / c_max);
                el.InvalidateVisual();
                canvas1.Children.Add(el);

                int center = (int)JointType.HipCenter;
                var hip = frame.Nodes.FirstOrDefault(o=>o.NodeType==center);


                frame.Nodes.Where(o=>legs_int.Contains(o.NodeType)).Zip(frame_old.Nodes.Where(o=>legs_int.Contains(o.NodeType)), (e1, e2) =>
                {

                    //SkeletonNode n = new SkeletonNode();

                    //double deg = Math.PI / 2;

                    //n.Y = e1.Y * Math.Cos(deg) - e1.Z * Math.Sin(deg);
                    //n.Z = e1.Y * Math.Sin(deg) + e1.Z * Math.Cos(deg);


                    Point a = new Point();
                    a.X = e1.X - x;
                    a.Y = e1.Y - y;
                    //a.X = e1.X - x - hip.X;
                    //a.Y = e1.Y - y - hip.Y;
                    //rotation

                    //a.X = n.X - x;
                    //a.Y = n.Y - y;

                    SolidColorBrush b = new SolidColorBrush(Colors.Black);
                    if(leg_right.Contains(e1.NodeType))
                        b = new SolidColorBrush(Colors.Red);
                    else
                        b = new SolidColorBrush(Colors.Blue);
                    return new { X=a.X,Y=a.Y,br=b };
                }).ToList().ForEach(o =>
                {
                    el = new Ellipse();
                    el.Width = 10;
                    el.Height = 10;
                    el.Fill = o.br;
                    Canvas.SetLeft(el, off_x +  o.X * 100);
                    Canvas.SetTop(el, off_y -  o.Y * 100);
                    canvas1.Children.Add(el);
                    
                });

                
                
                
                label1.Content = index++;
                UpdateLayout();
            }
        }

        private void button1_Click(object sender, RoutedEventArgs e)
        {
            label1.Content = "Drawing";
            UpdateLayout();
            using (FileStream writer = File.OpenRead(@"C:\Users\Bart\Desktop\KinectPackage\KrystianThird_Marek"))
            {
                IFormatter formatter = new BinaryFormatter();
                OpenedFrames = formatter.Deserialize(writer) as List<KinectLib.SkeletonFrame>;
            }

            int b = 1;
            off_x = canvas1.Width / 2;
            off_y = canvas1.Height / 2;
            canvas1.Children.Clear();
            c_max = OpenedFrames.Select(o => Math.Sqrt((o.X * o.X) + (o.Y * o.Y) + (o.Z * o.Z)) ).Max();
            c_min = OpenedFrames.Select(o => Math.Sqrt((o.X * o.X) + (o.Y * o.Y) + (o.Z * o.Z))).Min();
            timer.Start();
             
            /*foreach (var frame in OpenedFrames)
            {
                canvas1.Children.Clear();
                Ellipse el = new Ellipse();
                el.Width = 10;
                el.Height = 10;
                el.Fill = new SolidColorBrush(Colors.Red);
                Canvas.SetLeft(el, off_x + off_x / 2 * frame.X / c_max);
                Canvas.SetTop(el, off_y + off_x / 2 * frame.Y / c_max);
                el.InvalidateVisual();
                canvas1.Children.Add(el);
                UpdateLayout();
            }

            label1.Content = "Done";*/
        }
    }
}
