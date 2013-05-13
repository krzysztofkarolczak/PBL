using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using KinectLib;
using System.Windows.Media.Media3D;

namespace KinectReader.Lib
{
   class PathDetector
   {
      private IEnumerable<SkeletonFrame> Frames;
      public List<Point3D> Path;

      public PathDetector(List<SkeletonFrame> frames)
      {
         Frames = frames;

         String SS = "";
         foreach (SkeletonFrame Frame in Frames)
         {
            SkeletonNode Crotch = Frame.Nodes.First(n => n.NodeType == 0);
            //SS += String.Format("{0} {1} {2}\n", Frame.X, Frame.Y, Frame.Z);
            SS += String.Format("{0} {1} {2}\n", Crotch.X, Crotch.Y, Crotch.Z);
         }

      }


   }
}
