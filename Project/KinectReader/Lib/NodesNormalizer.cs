using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using KinectLib;

namespace KinectReader.Lib
{
   class NodesNormalizer
   {
      public Int32[] AVAILABLE_NODES = new Int32[] { 0, 12, 13, 14, 15, 16, 17, 18, 19 };

      private IEnumerable<SkeletonNode> Nodes;
      public List<SkeletonNode> NormalizedNodes;

      public NodesNormalizer(List<SkeletonNode> nodes)
      {
         Nodes = nodes.Where(n => AVAILABLE_NODES.Contains(n.NodeType));
         SkeletonNode Crotch = Nodes.First(n => n.NodeType == 0);

         NormalizedNodes = new List<SkeletonNode>();
         foreach (SkeletonNode Node in Nodes)
         {
            SkeletonNode NormalizedNode = new SkeletonNode();
            NormalizedNode.NodeType = Node.NodeType;
            NormalizedNode.X = Node.X - Crotch.X;
            NormalizedNode.Y = Crotch.Y - Node.Y;
            NormalizedNode.Z = Node.Z - Crotch.Z;
            NormalizedNodes.Add(NormalizedNode);
         }
      }


   }
}
