
def rec_add(a, b):
    if a == 0:
        return b
    else:
        return rec_add(a-1, b+1)

if __name__ == '__main__':
    print rec_add(3,4)
