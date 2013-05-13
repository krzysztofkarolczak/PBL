using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
//using System.Windows.Media.Imaging;
using System.Windows.Media;

namespace KinectLib
{
   public class SkeletonBone
   {
      public double BeginX;
      public double BeginY;
      public double BeginZ;
      public double EndX;
      public double EndY;
      public double EndZ;

      public double ProjectionX0;
      public double ProjectionY0;
      public double ProjectionX1;
      public double ProjectionY1;

      public virtual double Length { get { return Math.Sqrt(Math.Pow(EndX - BeginX, 2) + Math.Pow(EndY - BeginY, 2) + Math.Pow(EndZ - BeginZ, 2)); } }

      public SkeletonBone() { }

      public SkeletonBone(SkeletonNode BeginNode, SkeletonNode EndNode)
      {
         BeginX = BeginNode.X;
         BeginY = BeginNode.Y;
         BeginZ = BeginNode.Z;
         EndX = EndNode.X;
         EndY = EndNode.Y;
         EndZ = EndNode.Z;

      }

      public void Draw(DrawingContext Context, Brush Brush, Pen Pen)
      {

      }
   }
}