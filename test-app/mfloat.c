#include <stdio.h>
#define PI 3.14159265

int main(int argc, char **argv)
{
    int i;
    double d_area, d_perimeter, d_radius;
    d_radius = 3;

    for(i=1; i<100000; i++){
        d_perimeter = 2 * PI * (d_radius * i);
        d_area = PI * (d_radius * i) * (d_radius * i);
    }

    printf("The Radius is %f, Perimeter is %f, Area is %f \n", d_radius*i, d_perimeter, d_area);
    printf("Hello World!!!\n");

    return 0;
}