package pt.floraon.utmlatlong;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by miguel on 01-12-2016.
 */
public class Polygon {
    private int N;        // number of points in the polygon
    private Point2D[] a;    // the points, setting points[0] = points[N]
    private List<UTMCoordinate> UTMCoordinates = new ArrayList<>();

    // default buffer = 4
    public Polygon() {
        N = 0;
        a = new Point2D[4];
    }

    // double size of array
    private void resize() {
        Point2D[] temp = new Point2D[2*N+1];
        for (int i = 0; i <= N; i++) temp[i] = a[i];
        a = temp;
    }

    // return size
    public int size() { return N; }


    // add point p to end of polygon
    public void add(Point2D p) {
        if (N >= a.length - 1) resize();   // resize array if needed
        a[N++] = p;                        // add point
        a[N] = a[0];                       // close polygon

//        UTMCoordinate ut = CoordinateConversion.LatLonToUtmWGS84(p.y, p.x, 0);
//        System.out.println(ut.getX()+", "+ut.getY());
        UTMCoordinates.add(CoordinateConversion.LatLonToUtmWGS84(p.y, p.x, 0));
    }

    public void add(UTMCoordinate utmCoord) {
        this.add(new Point2D(utmCoord.getX(), utmCoord.getY()));
    }

    // return the perimeter
    public double perimeter() {
        double sum = 0.0;
        for (int i = 0; i < N; i++)
            sum = sum + a[i].distanceTo(a[i+1]);
        return sum;
    }

    // return signed area of polygon
    public double area() {
        double sum = 0.0;
        for (int i = 0; i < N; i++) {
            sum = sum + (a[i].x * a[i+1].y) - (a[i].y * a[i+1].x);
        }
        return 0.5 * sum;
    }

    // does this Polygon contain the point p?
    // if p is on boundary then 0 or 1 is returned, and p is in exactly one point of every partition of plane
    // Reference: http://exaflop.org/docs/cgafaq/cga2.html
    public boolean contains2(Point2D p) {
        int crossings = 0;
        for (int i = 0; i < N; i++) {
            int j = i + 1;
            boolean cond1 = (a[i].y <= p.y) && (p.y < a[j].y);
            boolean cond2 = (a[j].y <= p.y) && (p.y < a[i].y);
            if (cond1 || cond2) {
                // need to cast to double
                if (p.x < (a[j].x - a[i].x) * (p.y - a[i].y) / (a[j].y - a[i].y) + a[i].x)
                    crossings++;
            }
        }
        if (crossings % 2 == 1) return true;
        else                    return false;
    }

    // does this Polygon contain the point p?
    // Reference: http://softsurfer.com/Archive/algorithm_0103/algorithm_0103.htm
    public boolean contains(Point2D p) {
        int winding = 0;
        for (int i = 0; i < N; i++) {
            int ccw = Point2D.ccw(a[i], a[i+1], p);
            if (a[i+1].y >  p.y && p.y >= a[i].y)  // upward crossing
                if (ccw == +1) winding++;
            if (a[i+1].y <= p.y && p.y <  a[i].y)  // downward crossing
                if (ccw == -1) winding--;
        }
        return winding != 0;
    }


    // return string representation of this point
    public String toString() {
        if (N == 0) return "[ ]";
        String s = "";
        s = s + "[ ";
        for (int i = 0; i <= N; i++)
            s = s + a[i] + " ";
        s = s + "]";
        return s;
    }

    public List<UTMCoordinate> getUTMCoordinates() {
//        return UTMCoordinates;
        List<UTMCoordinate> out = new ArrayList<>(UTMCoordinates);
        out.add(UTMCoordinates.get(0));
        return out;
    }
}

