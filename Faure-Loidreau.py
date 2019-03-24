
# coding: utf-8

# In[56]:


from random import randint
import numpy as np


# In[57]:


# params
m = 4
p = 2
q = 2**m
k = 3
n = 4
# u = 3


# In[66]:


class Polynom(object):
    
    def __init__(self, *args, **kwargs):
        self.coefs = list(args)[::-1]
        self.p = kwargs['p']
        self.mod = kwargs['mod']
    
    def _val(self, val):
        result = 0
        for i, coef in enumerate(self.coefs):
            result = (result + coef* val**(self.p**i)) % self.mod
        return result
        
    def __call__(self, val):
        return self._val(val)
    
    def __getitem__(self, index):
        return self.coefs[index]
    
    def __setitem__(self, index, val):
        self.coefs[index] = val
        
    def __str__(self):
        result = '{}'.format(self.coefs[0])
        for i, coef in enumerate(self.coefs[1:]):
            result = '{}x^(p^{}) + '.format(coef, i+1) + result
        return result
    
    def __repr__(self):
        return 'Polynom({}, p={}, mod={})'.format(self.coefs,self.p, self.mod)
    


# In[67]:


b = Polynom(4, 1, 2, 7, 9, p=p, mod=16)
print(b)


# In[72]:


def choose_polynom(p, q, k):
    coefs = []
    for i in range(k):
        coefs.append(randint(0, q-1))
    return Polynom(*coefs, p=p, mod=q)


# In[73]:


def key_gen(p, q, k, gen):
    P = choose_polynom(p, q, k)
    P_g = []
    for i in range(len(gen)):
        P_g[i] = P(gen[i])
    W = randint((n - k)//2 + 1, n)
    E = choose_vector(p, q, W)
    return np.array(P_g) + np.array(E), W

def encrypt(message, q, gen, K, W):
    mes_polynom = Polynom(message)
    enc_mes = []
    for i in range(len(gen)):
        enc_mes[i] = mes_polynom(gen[i])
    alpha = randint(0, q-1)
    w = randint(0, (n - k - W)//2)
    e = choose_vector(p, q, w)
    return np.array(enc_mes) + alpha * K + np.array(e)

