#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const int max_attempts = 1000;

// a struct method to store each stdin 2D points
struct Points {
  float x;
  float y;
};

// a struct method to store 3 points' sum of short distances, 3 points' index that stored in Points, and a int variable to determine 3 points are collinear or not
struct Perimeter {
  float perimeter;
  int point1Index;
  int point2Index;
  int point3Index;
  int collinear;
};

int valid_format(char *buf, float *x, float *y) {
  // char * comma_rules = strchr(buf, ',');
  // if (!comma_rules || !isdigit(*(comma_rules - 1)) || *(comma_rules + 1) != '
  // ' || !isdigit(*(comma_rules + 2))){
  //     return 0;
  // }
  // char * points = strtok(buf, ",");
  // for (int i = 0; points[i]; i++){

  // }
  int comma = 0;
  // find the amount of comma inside the input line
  for (int i = 0; buf[i] != '\n'; i++) {
    if (buf[i] == ',') {
      comma++;
    }
  }
  // check if only exists 1 comma
  if (comma != 1) {
    return -1;
  }
  // check if exactly 1 whitespace after the comma
  char *comma_position = strchr(buf, ',');
  if (comma_position[1] != ' ' ||
      (comma_position[2] == ' ' || comma_position[2] == '\0')) {
    return -1;
  }
  char *pointx = strtok(buf, ", ");
  char *pointy = strtok(NULL, ", ");
  if (pointx == NULL || pointy == NULL) {
    return -1;
  }

  //check whether exists a non-numerical char
  for (int i = 0; pointx[i] != '\0'; i++) {
    if (!isdigit(pointx[i]) && pointx[i] != '.') {
      return -1;
    }
  }

  for (int i = 0; pointy[i] != '\0'; i++) {
    if (!isdigit(pointy[i]) && pointy[i] != '.' && pointy[i] != '\n') {
      return -1;
    }
  }

  // find dot location in x and y
  char *dotlocX = strchr(pointx, '.');
  char *dotlocY = strchr(pointy, '.');
  // check if any extra whitspaces inside the float nums and before dot exists a
  // digit or not
  if (strchr(pointx, ' ') != NULL || (dotlocX && !isdigit(*(dotlocX - 1)))) {
    return -1;
  }
  if (strchr(pointy, ' ') != NULL || (dotlocY && !isdigit(*(dotlocY - 1)))) {
    return -1;
  }
  // check float nums no more than 2 decimal place
  if (dotlocX) {
    // check if there not exists any digit after dot
    if (!isdigit(dotlocX[1])) {
      return -1;
    }
    // only allow two digits after dot
    if (isdigit(dotlocX[1]) && isdigit(dotlocX[2])) {
      if (dotlocX[3] != '\0') {
        return -1;
      }
    }
  }

  if (dotlocY) {
    if (!isdigit(dotlocY[1])) {
      return -1;
    }
    if (isdigit(dotlocY[1]) && isdigit(dotlocY[2])) {
      if (dotlocY[3] != '\n') {
        return -1;
      }
    }
  }

  // convert into float numbers
  float currentX = atof(pointx);
  float currentY = atof(pointy);
  //   char *end;
  //   float currentX = strtof(pointx, &end);
  //   if (*end != '\0') { // Check if the entire string was consumed in
  //   conversion
  //     return -1;
  //   }

  //   float currentY = strtof(pointy, &end);
  //   if (*end != '\0') { // Check if the entire string was consumed in
  //   conversion
  //     return -1;
  //   }
  //   float * currentX, * currentY;
  //   while (split != NULL) {
  //     if (elem == 0) {
  //         * currentX = atof(split);
  //     }else if (elem == 1) {
  //         * currentY = atof(split);
  //     }
  //     elem++;
  //     split = strtok(NULL, ", ");
  //   }
  if (currentX < -50 || currentX > 50 || currentY < -50 || currentY > 50) {
    return -1;
  }
  // store value into memory address
  *x = roundf(currentX * 100) / 100;
  *y = roundf(currentY * 100) / 100;
  return 0;
}

// formula to calculate the short distance
float calculate_distance(struct Points point1, struct Points point2) {
  return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2));
}

// check 3 points are collinear or not through area of triangle formula
// if area equal to 0, means 3 points are collinear
int is_on_same_line(struct Points pointA, struct Points pointB, struct Points pointC){
  float area = 0.5 * fabs(pointA.x* (pointB.y - pointC.y) + pointB.x* (pointC.y - pointA.y) + pointC.x* (pointA.y - pointB.y));
  if (area == 0){
    return -1;
  }
  return 0;
}

void find_closest_point(int index, struct Points myPoints[],
                        struct Perimeter mytriangle[]) {
  int count = 0;
  for (int i = 0; i < index; i++) {
    for (int j = i + 1; j < index; j++) {
      for (int k = j + 1; k < index; k++) {
        // calculate 3 short distance between each 2 points
        float distanceA = calculate_distance(myPoints[i], myPoints[j]);
        float distanceB = calculate_distance(myPoints[k], myPoints[j]);
        float distanceC = calculate_distance(myPoints[i], myPoints[k]);
        mytriangle[count].perimeter = distanceA + distanceB + distanceC;
        mytriangle[count].point1Index = i;
        mytriangle[count].point2Index = j;
        mytriangle[count].point3Index = k;
        mytriangle[count].collinear = is_on_same_line(myPoints[i], myPoints[j], myPoints[k]);
        count++;
      }
    }
  }
  //   puts("======");
  //   for (int j = 0; j < count; j++){
  //       printf("%f, %d, %d, %d\n", mytriangle[j].perimeter,
  //       mytriangle[j].point1Index, mytriangle[j].point2Index,
  //       mytriangle[j].point3Index);
  //   }
}

// find the minimum sum and return its index in struct Perimeter 
int is_a_triangle(struct Perimeter mytriangle[], int size) {
  float minP = mytriangle[0].perimeter;
  int minIndex = 0;
  for (int n = 1; n < size; n++) {
    if (mytriangle[n].perimeter < minP) {
      minP = mytriangle[n].perimeter;
      minIndex = n;
    }
  }
  return minIndex;
}

// calculate factorial value
int factorial(int index){
    int fact = 1;
    for (int i = 1; i <= index; i++){
        fact *= i;
    }
    return fact;
}

int main() {
  int attempt = 0;
  int index = 0;
  float x, y;
  char buf[256];
  struct Points myPoints[max_attempts];
  while (fgets(buf, sizeof(buf), stdin) != NULL) {
    if (attempt >= max_attempts || index >= max_attempts) {
      break;
    }
    if (valid_format(buf, &x, &y) == 0) {
      myPoints[index].x = x;
      myPoints[index].y = y;
      index++;
    }
    attempt++;
  }
  printf("read %d points\n", index);
  // if valid stdin points amount < 3, directly print not a triangle
  if (index < 3) {
    for (int i = 0; i < index; i++) {
      printf("%.2f, %.2f\n", myPoints[i].x, myPoints[i].y);
    }
    printf("This is not a triangle\n");
    return 0;
  }
  // formula to find the size of values stored in struct Perimeter
  int total = factorial(index) / (factorial(3) * factorial(index - 3));
  struct Perimeter mytriangle[total];
  find_closest_point(index, myPoints, mytriangle);
  int minIndex = is_a_triangle(mytriangle, total);
  printf("%.2f, %.2f\n%.2f, %.2f\n%.2f, %.2f\n",
         myPoints[mytriangle[minIndex].point1Index].x,
         myPoints[mytriangle[minIndex].point1Index].y,
         myPoints[mytriangle[minIndex].point2Index].x,
         myPoints[mytriangle[minIndex].point2Index].y,
         myPoints[mytriangle[minIndex].point3Index].x,
         myPoints[mytriangle[minIndex].point3Index].y);
  if (mytriangle[minIndex].perimeter > 0.001 && mytriangle[minIndex].collinear == 0) {
    printf("This is a triangle\n");
  } else {
    printf("This is not a triangle\n");
  }
  // for (int i = 0; i < index; i++){
  //     printf("%f, %f\n", myPoints[i].x, myPoints[i].y);
  // }
  // puts("-------");
  // if (check == 0){
  //     int num = (index+1) * (index) / 2;
  //     printf("read ", num, "points\n");
  //     for (int i = 0; i < 3; i++){
  //         printf("%.2f, %.2f", myPoints[mydistance[i].point1Index].x,
  //         myPoints[mydistance[i].point1Index].y);
  //     }
  // }
  return 0;
}