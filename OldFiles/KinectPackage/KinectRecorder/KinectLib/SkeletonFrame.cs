using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace KinectLib
{
    [Serializable]
    public class SkeletonFrame
        {
            public int SkeletonId;
            public DateTime Date;
            public List<SkeletonNode> Nodes;
            public double X;
            public double Y;
            public double Z;

            public SkeletonFrame()
            {
            }
        }
}
