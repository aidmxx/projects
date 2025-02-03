import sys
import math
import random
import argparse
from typing import NoReturn


def generate_points(N: int, mindist: float, rseed=None):
    if rseed is not None:
        random.seed(rseed)
    check_points = []
    while len(check_points) < N:
        #create 2 decmial random points in given range
        x = round(random.uniform(-50, 50), 2)
        y = round(random.uniform(-50, 50), 2)
        new_point = [x, y]
        valid = True
        for x1, y1 in check_points:
            #find Euclidean short distances bewteen 2 points
            distance = math.sqrt(
                math.pow((new_point[0] - x1), 2) + math.pow((new_point[1] - y1), 2))
            if distance <= mindist:
                valid = False
                break
        if valid:
            check_points.append(new_point)
    return check_points


def main():
    # a subclass to customise an error message when there exists not enough command-line arguments
    # this will donot show out the argparse default error message
    class selfArgumentParser(argparse.ArgumentParser):
        def error(self, message: str) -> NoReturn:
            sys.stderr.write('invalid arguments\n')
            sys.exit(-4)
    parser = selfArgumentParser(description='Generate a set of 2D points')
    parser.add_argument("-N", type=int, required=True,
                        help='number of 2D points')
    parser.add_argument("-mindist", type=float, required=True,
                        help='minimum distance between 2 points')
    parser.add_argument("-rseed", type=int, help='random seed', default=None)
    args = parser.parse_args()
    #error handles
    if args.N < 0:
        sys.stderr.write("N less than zero\n")
        sys.exit(-1)
    if args.mindist < 0 or args.mindist > 10:
        sys.stderr.write("mindist outside range\n")
        sys.exit(-2)
    if args.N > 10000/(math.pi * math.pow(args.mindist, 2)):
        sys.stderr.write("point saturation\n")
        sys.exit(-3)
    points = generate_points(args.N, args.mindist, args.rseed)
    for i in points:
        print(i[0], ",", i[1], file=sys.stdout)


if __name__ == "__main__":
    main()
