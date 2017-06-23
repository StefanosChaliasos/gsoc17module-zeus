cimport libffpy

cdef class BigNum:
    cdef Fr[curve] *_thisptr

    def __cinit__(self, init=True):
        if init:
            self._thisptr = new Fr[curve]()

    def __dealloc__(self):
        self.free()

    def free(self):
        if self._thisptr != NULL:
            del self._thisptr

    @staticmethod
    def getOrder():
        cdef Fr[curve] *newptr
        cdef BigNum res = BigNum()

        newptr = new Fr[curve](get_order())
        res.setElem(newptr)

        return res

    cdef setElem(self, Fr[curve] *b):
        self.free()
        self._thisptr = b

    cdef Fr[curve] *getElemRef(self):
        return self._thisptr

    cdef BigNum createElem(self, Fr[curve]* b):
        cdef BigNum bg = BigNum(init=False)
        bg.setElem(b)
        return bg

    cpdef BigNum add(self, BigNum other):
        cdef Fr[curve] *newptr
        newptr = new Fr[curve](self.getElemRef()[0] + other.getElemRef()[0])
        return self.createElem(newptr)

    cpdef BigNum sub(self, BigNum other):
        cdef Fr[curve] *newptr
        newptr = new Fr[curve](self.getElemRef()[0] - other.getElemRef()[0])
        return self.createElem(newptr)

    def __add__(x, y):
        cdef BigNum left, right

        if not (isinstance(x, BigNum) and isinstance(y, BigNum)):
            return NotImplemented

        left = <BigNum>x
        right = <BigNum>y
        return left.add(right)

    def __sub__(x, y):
        cdef BigNum left, right

        if not (isinstance(x, BigNum) and isinstance(y, BigNum)):
            return NotImplemented

        left = <BigNum>x
        right = <BigNum>y
        return left.sub(right)


cdef class G1Py:
    cdef G1[curve] *_thisptr
    cdef size_t g1_exp_count
    cdef size_t g1_window_size
    cdef window_table[G1[curve]] g1_table

    def __cinit__(self, init=True):
        if init:
            self._thisptr = new G1[curve]()

    def __dealloc__(self):
        self.free()

    def init(self, int n):
        self.g1_exp_count = 4 * n + 7;
        self.g1_window_size = get_g1_exp_window_size(self.g1_exp_count)
        self.g1_table = get_g1_window_table(self.g1_window_size, self.getElemRef()[0])

    def free(self):
        if self._thisptr != NULL:
            del self._thisptr

    cdef setElem(self, G1[curve] *g):
        self.free()
        self._thisptr = g

    cdef G1[curve] *getElemRef(self):
        return self._thisptr

    cdef G1Py createElem(self, G1[curve] *g):
        cdef G1Py g1 = G1Py(init=False)
        g1.setElem(g)
        return g1

    cpdef G1Py mul(self, BigNum bgpy):
        cdef G1[curve] *newptr
        cdef Fr[curve] bg = bgpy.getElemRef()[0]
        newptr = new G1[curve](g1_mul(self.g1_window_size, self.g1_table, bg))
        return self.createElem(newptr)

    cpdef G1Py add(self, G1Py other):
        cdef G1[curve] *newptr
        newptr = new G1[curve](self.getElemRef()[0] + other.getElemRef()[0])
        return self.createElem(newptr)

    cpdef eq(self, G1Py other):
        return self.getElemRef()[0] == other.getElemRef()[0]

    def __mul__(x, y):
        cdef G1Py g1
        cdef BigNum bg

        if not (isinstance(x, G1Py) or isinstance(y, G1Py)):
            return NotImplemented

        if isinstance(x, G1Py):
            if not isinstance(y, BigNum):
                return NotImplemented
            g1 = <G1Py>x
            bg = <BigNum>y
        elif isinstance(x, BigNum):
            g1 = <G1Py>y
            bg = <BigNum>x

        return g1.mul(bg)

    def __add__(x, y):
        cdef G1Py left, right

        if not (isinstance(x, G1Py) and isinstance(y, G1Py)):
            return NotImplemented

        left = <G1Py>x
        right = <G1Py>y

        return left.add(right)

    def __richcmp__(x, y, cmp):
        cdef G1Py left, right

        if cmp != 2:
            # not ==
            return NotImplemented

        if not (isinstance(x, G1Py) and isinstance(y, G1Py)):
            return NotImplemented

        left = <G1Py>x
        right = <G1Py>y

        return left.eq(right)


cdef class G2Py:
    cdef G2[curve] *_thisptr
    cdef size_t g2_exp_count
    cdef size_t g2_window_size
    cdef window_table[G2[curve]] g2_table

    def __cinit__(self, init=True):
        if init:
            self._thisptr = new G2[curve]()

    def __dealloc__(self):
        self.free()

    def init(self, int n):
        self.g2_exp_count = n + 6
        self.g2_window_size = get_g2_exp_window_size(self.g2_exp_count)
        self.g2_table = get_g2_window_table(self.g2_window_size, self.getElemRef()[0])

    def free(self):
        if self._thisptr != NULL:
            del self._thisptr

    cdef setElem(self, G2[curve] *g):
        self.free()
        self._thisptr = g

    cdef G2[curve] *getElemRef(self):
        return self._thisptr

    cdef createElem(self, G2[curve] *g):
        cdef G2Py g2 = G2Py(init=False)
        g2.setElem(g)
        return g2

    cpdef G2Py mul(self, BigNum bgpy):
        cdef G2[curve] *newptr
        cdef Fr[curve] bg = bgpy.getElemRef()[0]
        newptr = new G2[curve](g2_mul(self.g2_window_size, self.g2_table, bg))
        return self.createElem(newptr)

    cpdef G2Py add(self, G2Py other):
        cdef G2[curve] *newptr
        newptr = new G2[curve](self.getElemRef()[0] + other.getElemRef()[0])
        return self.createElem(newptr)

    cpdef eq(self, G2Py other):
        return self.getElemRef()[0] == other.getElemRef()[0]

    def __mul__(x, y):
        cdef G2Py g2
        cdef BigNum bg
        if not (isinstance(x, G2Py) or isinstance(y, G2Py)):
            return NotImplemented

        if isinstance(x, G2Py):
            if not isinstance(y, BigNum):
                return NotImplemented
            g2 = <G2Py>x
            bg = <BigNum>y
        elif isinstance(x, BigNum):
            g2 = <G2Py>y
            bg = <BigNum>x

        return g2.mul(bg)

    def __add__(x, y):
        cdef G2Py left, right

        if not (isinstance(x, G2Py) and isinstance(y, G2Py)):
            return NotImplemented

        left = <G2Py>x
        right = <G2Py>y

        return left.add(right)

    def __richcmp__(x, y, cmp):
        cdef G2Py left, right

        if cmp != 2:
            # not ==
            return NotImplemented

        if not (isinstance(x, G2Py) and isinstance(y, G2Py)):
            return NotImplemented

        left = <G2Py>x
        right = <G2Py>y

        return left.eq(right)


cdef class GTPy:
    cdef GT[curve] *_thisptr

    def __cinit__(self, init=True):
        if init:
            self._thisptr = new GT[curve]()

    def __dealloc__(self):
        self.free()

    def free(self):
        if self._thisptr != NULL:
            del self._thisptr

    cdef GT[curve]* getElemRef(self):
        return self._thisptr

    cdef setElem(self, GT[curve] *g):
        self.free()
        self._thisptr = g

    def pair(self, G1Py g1, G2Py g2):
        cdef GT[curve] *newptr;
        newptr = new GT[curve](reduced_pairing(g1.getElemRef()[0], g2.getElemRef()[0]))
        self.setElem(newptr)


cdef class LibffPy:
    cdef G1Py g1
    cdef G2Py g2

    def __init__(self, int n):
        init_public_params()
        self.g1 = G1Py()
        self.g2 = G2Py()

        self.g1.init(n)
        self.g2.init(n)

    def order(self):
        return BigNum.getOrder()

    def gen1(self):
        return self.g1

    def gen2(self):
        return self.g2

    def pair(self, G1Py g1, G2Py g2):
        gt = GTPy(init=False)
        gt.pair(g1, g2)
        return gt