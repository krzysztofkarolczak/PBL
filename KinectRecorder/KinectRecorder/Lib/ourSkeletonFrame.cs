using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace KinectRecorder
{
    [Serializable]
    public class Node
    {
        public int NodeType;
        public double X;
        public double Y;
        public double Z;

        public Node() { }

    }

    [Serializable]
    public class ourSkeletonFrame
    {
        public int SkeletonId;
        public DateTime Date;
        public List<Node> Nodes;
        public double X;
        public double Y;
        public double Z;

        public ourSkeletonFrame()
        {
        }


    }
}
