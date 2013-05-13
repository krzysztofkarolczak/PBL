using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace KinectLib
{
   public enum SkeletonNodes { Crotch, Spine, Neck, Head, LeftShoulder, LeftElbow, LeftHand, RightShoulder, RightElbow, RightHand, LeftHip, LeftKnee, LeftAnckle, LeftFoot, RightHip, RightKnee, RightAnckle, RightFoot }

   [Serializable]
   public class SkeletonFrame
   {
      public static String[] NAMES = { "Crotch", "Spine", "Neck", "Head", "LeftShoulder", "LeftElbow", "LeftHand", "LeftFingers", "RightShoulder", "RightElbow", "RightHand", "RightFingers", "LeftHip", "LeftKnee", "LeftAnckle", "LeftFoot", "RightHip", "RightKnee", "RightAnckle", "RightFoot" };
      public int SkeletonId;
      public DateTime Date;
      public List<SkeletonNode> Nodes;
      public double X;
      public double Y;
      public double Z;

      public SkeletonFrame()
      {
      }

      public static void ToMFile(IEnumerable<SkeletonFrame> Frames, String Path)
      {
         if (File.Exists(Path))
         {
            File.Delete(Path);
         }
         using (StreamWriter Writer = File.CreateText(Path))
         {
            for (Int32 Type = 0; Type < 20; ++Type)
            {
               Writer.WriteLine("S." + SkeletonFrame.NAMES[Type] + ".X = [");
               foreach (SkeletonFrame Frame in Frames)
               {
                  foreach (SkeletonNode Node in Frame.Nodes.Where(n => n.NodeType == Type))
                  {
                     Writer.WriteLine(Math.Round(-Node.X, 3).ToString().Replace(",", "."));
                  }
               }
               Writer.WriteLine("];");
               Writer.WriteLine("S." + SkeletonFrame.NAMES[Type] + ".Y = [");
               foreach (SkeletonFrame Frame in Frames)
               {
                  foreach (SkeletonNode Node in Frame.Nodes.Where(n => n.NodeType == Type))
                  {
                     Writer.WriteLine(Math.Round(Node.Y, 3).ToString().Replace(",", "."));
                  }
               }
               Writer.WriteLine("];");
               Writer.WriteLine("S." + SkeletonFrame.NAMES[Type] + ".Z = [");
               foreach (SkeletonFrame Frame in Frames)
               {
                  foreach (SkeletonNode Node in Frame.Nodes.Where(n => n.NodeType == Type))
                  {
                     Writer.WriteLine(Math.Round(-Node.Z, 3).ToString().Replace(",", "."));
                  }
               }
               Writer.WriteLine("];");
            }
            Writer.WriteLine("S.Skeleton.X = [");
            foreach (SkeletonFrame Frame in Frames)
            {
               Writer.WriteLine(Math.Round(-Frame.X, 3).ToString().Replace(",", "."));
            }
            Writer.WriteLine("];");
            Writer.WriteLine("S.Skeleton.Y = [");
            foreach (SkeletonFrame Frame in Frames)
            {
               Writer.WriteLine(Math.Round(Frame.Y, 3).ToString().Replace(",", "."));
            }
            Writer.WriteLine("];");
            Writer.WriteLine("S.Skeleton.Z = [");
            foreach (SkeletonFrame Frame in Frames)
            {
               Writer.WriteLine(Math.Round(Frame.Z, 3).ToString().Replace(",", "."));
            }
            Writer.WriteLine("];");
         }
      }

   }
}
