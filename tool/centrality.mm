//
//  centrality.mm
//  Aquaterm2
//
//  Created by Per Persson on 13-08-26.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#include "centrality.h"

/* Dispute:
 * Hi! I'm not sure but I think, that the function computing Katz Centrality - void central_katz() is not correct. I do not think that this formula is correct:
 *                C[i] = 0.0;
 *                for(int j=0;j<NV;++j) if(i!=j)
 *                        C[i] += pow(alpha,dist[i+NV*j]);
 * Assuming that 'alpha' is decay factor and 'dist[i+NV*j]' is shortest path from i to j.
 * Regards
 * Przemek
 */


/**********************************
 * (C)2012 Claudio Rocchini       *
 *  www.rockini.name              *
 *  CC-BY 3.0                     *
 **********************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <vector>
// #include <gsl/gsl_matrix.h>
// #include <gsl/gsl_linalg.h>
// #include <gsl/gsl_eigen.h>
// #include "rand.h"

static inline unsigned char f2b( double f ) {
    if(f<0) f = 0; if(f>1) f = 1;
    int i = int(f*256);
    return i<0 ? 0 : i>255 ? 255 : i;
}

void HSV2RGB(double h, double s, double v, unsigned char rgb[3] ) {
    if (s == 0) {
        rgb[0] = rgb[1] = rgb[2] = f2b(v);
    } else {
        double v_h = h * 6;
        double v_i = floor(v_h);
        double v_1 = v * (1 - s);
        double v_2 = v * (1 - s * (v_h - v_i));
        double v_3 = v * (1 - s * (1 - (v_h - v_i)));
        double v_r,v_g,v_b;
        if (v_i == 0) {v_r = v;   v_g = v_3; v_b = v_1;}
        else if (v_i == 1) {v_r = v_2; v_g = v;   v_b = v_1;}
        else if (v_i == 2) {v_r = v_1; v_g = v;   v_b = v_3;}
        else if (v_i == 3) {v_r = v_1; v_g = v_2; v_b = v  ;}
        else if (v_i == 4) {v_r = v_3; v_g = v_1; v_b = v  ;}
        else               {v_r = v;   v_g = v_1; v_b = v_2;};
        
        rgb[0] = f2b(v_r);
        rgb[1] = f2b(v_g);
        rgb[2] = f2b(v_b);
    }
}

class point2 {
public:
    double x,y;
};

double squared_dist( const point2 & p, const point2 & q ) {
    const double dx = p.x - q.x;
    const double dy = p.y - q.y;
    return dx*dx+dy*dy;
}

class edge {
public:
    int a,b;
    edge() {}
    edge( int na, int nb ): a(na),b(nb) {}
};

void floyd_warshall( int NV, const std::vector<edge> & e,
                    std::vector<double> & dist, std::vector<int> & conn ) {
    dist.resize(NV*NV); conn.resize(NV*NV);
    std::fill(dist.begin(),dist.end(),0.0);
    std::fill(conn.begin(),conn.end(),-1);
    std::vector<edge>::const_iterator ie;
    for(ie=e.begin();ie!=e.end();++ie) {
        dist[(*ie).a+NV*(*ie).b] = 1;
        dist[(*ie).b+NV*(*ie).a] = 1;
    }
    for(int k=0;k<NV;++k) for(int i=0;i<NV;++i) for(int j=0;j<NV;++j)
        if((dist[i+NV*k] * dist[k+NV*j] != 0) && (i != j))
            if((dist[i+NV*k] + dist[k+NV*j] < dist[i+NV*j]) || (dist[i+NV*j] == 0)) {
                conn[i+NV*j] = k;
                dist[i+NV*j] = dist[i+NV*k] + dist[k+NV*j];
            }
}

void central_degree( int NV, const std::vector<edge> & e, std::vector<double> & C ) {
    std::fill(C.begin(),C.end(),0.0);
    std::vector<edge>::const_iterator i;
    for(i=e.begin();i!=e.end();++i) {
        C[(*i).a] += 1;
        C[(*i).b] += 1;
    }
}

void central_closeness( int NV, const std::vector<edge> & e, std::vector<double> & C ) {
    std::vector<double> dist;
    std::vector<int> conn;
    floyd_warshall(NV,e,dist,conn);
    for(int i=0;i<NV;++i) {
        C[i] = 0;
        for(int j=0;j<NV;++j) 
            C[i] += dist[i+NV*j];
        if(C[i]!=0.0) 
            C[i] = 1.0/C[i];
    }
}

void central_betweenness( int NV, const std::vector<edge> & e, std::vector<double> & C ) {
    std::vector<double> dist; 
    std::vector<int> conn;
    floyd_warshall(NV, e, dist, conn);
    std::fill(C.begin(), C.end(), 0.0);
    for(size_t i=0; i<conn.size(); ++i)
        if(conn[i]>=0 && conn[i]<NV) 
            C[conn[i]] += 1.0;
    for(size_t j=0; j<C.size(); ++j) 
        C[j] = log(1+C[j]); // NOTE: the log!
}

#if 1
void central_eigenvector( int NV, const std::vector<edge> & e, std::vector<double> & C ) {
}
#else
void central_eigenvector( int NV, const std::vector<edge> & e, std::vector<double> & C ) {
    int i,j;
    gsl_eigen_symmv_workspace * w = gsl_eigen_symmv_alloc(NV);
    gsl_matrix * A    = gsl_matrix_alloc(NV,NV);
    gsl_vector * eval = gsl_vector_alloc(NV);
    gsl_matrix * evec = gsl_matrix_alloc(NV,NV);
    for(i=0;i<NV;++i) for(j=0;j<NV;++j)
        gsl_matrix_set(A,i,j,0.0);
    for(std::vector<edge>::const_iterator ei=e.begin();ei!=e.end();++ei) {
        gsl_matrix_set(A,(*ei).a,(*ei).b,1.0);
        gsl_matrix_set(A,(*ei).b,(*ei).a,1.0);
    }
    gsl_eigen_symmv(A,eval,evec,w);
    int maxj = 0; double maxv = gsl_vector_get(eval,0);
    for(j=1;j<NV;++j)
        if(maxv<gsl_vector_get(eval,j)) {
            maxv = gsl_vector_get(eval,j);
            maxj = j;
        }
    for(i=0;i<NV;++i)
        C[i] = log(gsl_matrix_get(evec,i,maxj));    // NOTE: the log!
    gsl_matrix_free(evec);
    gsl_vector_free(eval);
    gsl_matrix_free(A);
    gsl_eigen_symmv_free(w);
}
#endif

void central_katz( int NV, const std::vector<edge> & e, std::vector<double> & C ) {
    const double alpha = 0.5;
    std::vector<double> dist; std::vector<int> conn;
    floyd_warshall(NV,e,dist,conn);
    for(int i=0;i<NV;++i) {
        C[i] = 0.0;
        for(int j=0;j<NV;++j) if(i!=j)
            C[i] += pow(alpha,dist[i+NV*j]);
    }
}

#if 1
void central_alpha( int NV, const std::vector<edge> & e, std::vector<double> & C ) {
}
#else
void central_alpha( int NV, const std::vector<edge> & e, std::vector<double> & C ) {
    const double alpha = 0.1;
    int i,j;
    gsl_matrix * A    = gsl_matrix_alloc(NV,NV);
    for(i=0;i<NV;++i) for(j=0;j<NV;++j)
        gsl_matrix_set(A,i,j,0.0);
    for(std::vector<edge>::const_iterator ei=e.begin();ei!=e.end();++ei) {
        gsl_matrix_set(A,(*ei).a,(*ei).b,1.0);
        gsl_matrix_set(A,(*ei).b,(*ei).a,1.0);
    }
    for(i=0;i<NV;++i) for(j=0;j<NV;++j) {
        double t = -alpha*gsl_matrix_get(A,i,j);
        if(i==j) t += 1.0;
        gsl_matrix_set(A,i,j,t);
    }
    gsl_vector * x = gsl_vector_alloc(NV);
    gsl_vector * b = gsl_vector_alloc(NV);
    for(i=0;i<NV;++i) gsl_vector_set(b,i,1.0);
    gsl_linalg_HH_solve(A,b,x);
    for(i=0;i<NV;++i) C[i] = gsl_vector_get(x,i);
    gsl_vector_free(b);
    gsl_vector_free(x);
    gsl_matrix_free(A);
}
#endif

void central( int NV, const std::vector<edge> & e, std::vector<double> & C, double & minv, double & maxv, int m )  {
    C.resize(NV);
    switch(m) {
        case 0: central_degree(NV,e,C); break;
        case 1: central_closeness(NV,e,C); break;
        case 2: central_betweenness(NV,e,C); break;
        case 3: central_eigenvector(NV,e,C); break;
        case 4: central_katz(NV,e,C); break;
        case 5: central_alpha(NV,e,C); break;
    }
    minv = maxv = C[0];
    for(int i=1;i<NV;++i) {
        if(minv>C[i]) minv = C[i];
        if(maxv<C[i]) maxv = C[i];
    }
}

void centrality(AQTAdapter *canvas, int ctype)
{
    const int N = 256;
    // const int NR = 3;
    // const int NC = 2;
    const double SS = 600;
    const double R=5, B=6;
    const double MD2=(0.03)*(0.03),D2=(0.1)*(0.1);
    int i,j;
    point2 pts[N];
    srand48(0);
    for (i=0; i<N; ++i) {
        do {
            pts[i].x = drand48(); // DRand();
            pts[i].y = drand48(); // DRand();
            for (j=0; j<i; ++j) {
                if (squared_dist(pts[i],pts[j]) < MD2)
                    break;
            }
        } while (j<i);
    }
    
    std::vector<edge> edges;
    for (i=0; i<N-1; ++i) {
        for (j=i+1; j<N; ++j) {
            if (squared_dist(pts[i], pts[j]) < D2) {
                edges.push_back(edge(i,j));
            }
        }
    }
    
    
    
    {
        std::vector<double> C;
        double minv,maxv;
        central(N, edges, C, minv, maxv, ctype);
        [canvas setColorRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        for (i=0; i < int(edges.size()); ++i) {
            NSPoint p1 = NSMakePoint(B+(SS-B*2)*pts[edges[i].a].x,
                                     B+(SS-B*2)*pts[edges[i].a].y);
            NSPoint p2 = NSMakePoint(B+(SS-B*2)*pts[edges[i].b].x,
                                     B+(SS-B*2)*pts[edges[i].b].y);
            [canvas moveToPoint:p1];
            [canvas addLineToPoint:p2];
            
        }
        
         [canvas setLineCapStyle:AQTRoundLineCapStyle];
         for(i=0;i<N;++i) {
             unsigned char rgb[3];
             HSV2RGB( (2*(maxv-C[i]))/(3*(maxv-minv)), 0.9, 1.0, rgb);
             NSPoint p1 = NSMakePoint(B+(SS-B*2)*pts[i].x, B+(SS-B*2)*pts[i].y);
             NSPoint p2 = p1;
             p2.x += 0.01;
             // "Border"
             [canvas setLinewidth:2*(R+1)];
             [canvas setColorRed:0.0 green:0.0 blue:0.0 alpha:1.0];
             [canvas moveToPoint:p1];
             [canvas addLineToPoint:p2];
             // Fill
             [canvas setColorRed:rgb[0]/255.0 green:rgb[1]/255.0 blue:rgb[2]/255.0 alpha:1.0];
             [canvas setLinewidth:2*R];
             [canvas moveToPoint:p1];
             [canvas addLineToPoint:p2];
         
         }
         

        
    }
    
    
    
#if 0
    {
        FILE * fo = fopen("central.svg","w");
        fprintf(fo,
                "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"
                "<svg xmlns:svg=\"http://www.w3.org/2000/svg\" xmlns=\"http://www.w3.org/2000/svg\"\n"
                "version=\"1.0\" width=\"%g\" height=\"%g\" id=\"central\">\n"
                ,SX,SY
                );
        
        for(int ir=0;ir<NR;++ir) {
            for(int ic=0;ic<NC;++ic) {
                std::vector<double> C;
                double minv,maxv;
                central(N,edges,C,minv,maxv,ic+NC*ir);
                
                fprintf(fo,"<g style=\"stroke:#000000;stroke-width:1;stroke-linejoin:round;fill:none\">\n");
                for(i=0;i<int(edges.size());++i)
                    fprintf(fo,"<line x1=\"%6.2f\" y1=\"%6.2f\" x2=\"%6.2f\" y2=\"%6.2f\"/>\n"
                            ,SX*ic/NC + (SX/NC-B*2)*pts[edges[i].a].x
                            ,SY*ir/NR + (SY/NR-B*2)*pts[edges[i].a].y
                            ,SX*ic/NC + (SX/NC-B*2)*pts[edges[i].b].x
                            ,SY*ir/NR + (SY/NR-B*2)*pts[edges[i].b].y
                            );
                fprintf(fo,"</g>\n");
                for(i=0;i<N;++i) {
                    unsigned char rgb[3];
                    HSV2RGB( (2*(maxv-C[i]))/(3*(maxv-minv)),0.9,1.0,rgb);
                    fprintf(fo,"<circle cx=\"%6.2f\" cy=\"%6.2f\" r=\"%6.2f\" style=\"stroke:#000000;"
                            "stroke-width:0.5;stroke-linejoin:round;fill:#%02X%02X%02X\"/>\n"
                            ,SX*ic/NC + (SX/NC-B*2)*pts[i].x
                            ,SY*ir/NR + (SY/NR-B*2)*pts[i].y
                            ,R
                            ,rgb[0],rgb[1],rgb[2]
                            );
                }
            }
        }
        fprintf(fo,"</svg>\n");
        fclose(fo);
    }
#endif
}

