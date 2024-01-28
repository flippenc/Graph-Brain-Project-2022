import re
from collections import defaultdict
import math

def getCubeData(fileName):
    sizeSearch = r'Sets of size ([0-9]+): ([0-9]+)'
    cubeDim = r'Cube of size ([0-9])+'
    evenSearch = r'Even sets: ([0-9]+)'
    oddSearch = r'Odd sets: ([0-9]+)'
    currentDim = 0
    currentEven = 0
    currentOdd = 0
    sizes = defaultdict(int)
    with open(fileName, 'r') as sizesFile:
        for currentLine in sizesFile:
            currentLine = currentLine.strip()
            if re.match(cubeDim, currentLine):
                currentDim = re.search(cubeDim, currentLine).groups()[0]
            elif re.match(evenSearch, currentLine):
                currentEven = re.search(evenSearch, currentLine).groups()[0]
            elif re.match(oddSearch, currentLine):
                currentOdd = re.search(oddSearch, currentLine).groups()[0]
            elif re.match(sizeSearch, currentLine):
                g = re.search(sizeSearch, currentLine).groups()
                sizes[g[0]] = g[1]
            elif currentLine.strip() == '':
                print(f'The cube on {currentDim} dimensions has {currentEven} even sets, {currentOdd} odd sets and:')
                for k in range(0,len(sizes.keys())+2):
                    try:
                        print(f'{sizes[str(k)]} sets of size {k} which has log2 = :{math.log2(int(sizes[str(k)]))}')
                    except:
                        continue
    print(f'The cube on {currentDim} dimensions has {currentEven} even sets, {currentOdd} odd sets and:')
    for k in range(0,len(sizes.keys())+1):
        try:
            print(f'{sizes[str(k)]} sets of size {k} which has log2 = :{math.log2(int(sizes[str(k)]))}')
        except:
            break

if __name__ == "__main__":
    getCubeData('cubeSetSizes.txt')