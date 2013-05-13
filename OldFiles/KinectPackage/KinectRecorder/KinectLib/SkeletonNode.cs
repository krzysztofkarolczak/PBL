using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace KinectLib
{
    [Serializable]
    public class SkeletonNode
        {
            public int NodeType;
        public double X;
        public double Y;
        public double Z;
        
        public SkeletonNode() { }
        }
}
