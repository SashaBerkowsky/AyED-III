module Proceso (Procesador, AT(Nil,Tern), RoseTree(Rose), Trie(TrieNodo), foldAT, foldRose, foldTrie, procVacio, procId, procCola, procHijosRose, procHijosAT, procRaizTrie, procSubTries, unoxuno, sufijos, inorder, preorder, postorder, preorderRose, hojasRose, ramasRose, caminos, palabras, ifProc,(++!), (.!)) where

import Test.HUnit


--Definiciones de tipos

type Procesador a b = a -> [b]


-- Árboles ternarios
data AT a = Nil | Tern a (AT a) (AT a) (AT a) deriving Eq
at = Tern 1 (Tern 2 Nil Nil Nil) (Tern 3 Nil Nil Nil) (Tern 4 Nil Nil Nil)
--Es es árbol ternario con 1 en la raíz, y con sus tres hijos 2, 3 y 4.

-- RoseTrees
data RoseTree a = Rose a [RoseTree a] deriving Eq
rt = Rose 1 [Rose 2 [], Rose 3 [], Rose 4 [], Rose 5 []] 
--es el RoseTree con 1 en la raíz y 4 hijos (2, 3, 4 y 5)

-- Tries
data Trie a = TrieNodo (Maybe a) [(Char, Trie a)] deriving Eq
t = TrieNodo (Just True) [('a', TrieNodo (Just True) []), ('b', TrieNodo Nothing [('a', TrieNodo (Just True) [('d', TrieNodo Nothing [])])]), ('c', TrieNodo (Just True) [])]
-- es el Trie Bool de que tiene True en la raíz, tres hijos (a, b, y c), y, a su vez, b tiene como hijo a d.


-- Definiciones de Show

instance Show a => Show (RoseTree a) where
    show = showRoseTree 0
      where
        showRoseTree :: Show a => Int -> RoseTree a -> String
        showRoseTree indent (Rose value children) =
            replicate indent ' ' ++ show value ++ "\n" ++
            concatMap (showRoseTree (indent + 2)) children

instance Show a => Show (AT a) where
    show = showAT 0
      where
        showAT :: Show a => Int -> AT a -> String
        showAT _ Nil = replicate 2 ' ' ++ "Nil"
        showAT indent (Tern value left middle right) =
            replicate indent ' ' ++ show value ++ "\n" ++
            showSubtree (indent + 2) left ++
            showSubtree (indent + 2) middle ++
            showSubtree (indent + 2) right

        showSubtree :: Show a => Int -> AT a -> String
        showSubtree indent subtree =
            case subtree of
                Nil -> replicate indent ' ' ++ "Nil\n"
                _   -> showAT indent subtree

instance Show a => Show (Trie a) where
    show = showTrie ""
      where
        showTrie :: Show a => String -> Trie a -> String
        showTrie indent (TrieNodo maybeValue children) =
            let valueLine = case maybeValue of
                                Nothing -> indent ++ "<vacío>\n"
                                Just v  -> indent ++ "Valor: " ++ show v ++ "\n"
                childrenLines = concatMap (\(c, t) -> showTrie (indent ++ "  " ++ [c] ++ ": ") t) children
            in valueLine ++ childrenLines


--Ejercicio 1
procVacio :: Procesador a b
procVacio _ = []

procId :: Procesador a a
procId a = [a]

procCola :: Procesador [a] a
procCola [] = []
procCola (_:xs) = xs

procHijosRose :: Procesador (RoseTree a) (RoseTree a)
procHijosRose (Rose _ children) = children

procHijosAT :: Procesador (AT a) (AT a)
procHijosAT Nil = []
procHijosAT (Tern _ left middle right) = [left, middle, right]

procRaizTrie :: Procesador (Trie a) (Maybe a)
procRaizTrie  (TrieNodo a _) = [a]

procSubTries :: Procesador (Trie a) (Char, Trie a)
procSubTries (TrieNodo _ children) = children


--Ejercicio 2

--foldAT :: undefined
foldAT = undefined

--foldRose :: undefined
foldRose = undefined

--foldTrie :: undefined
foldTrie = undefined


--Ejercicio 3
unoxuno :: Procesador [a] [a]
unoxuno = map (: [])

sufijos :: Procesador [a] [a]
sufijos [] = [[]]
sufijos xs = xs : sufijos (tail xs)


--Ejercicio 4
preorder :: Procesador (AT a) a
preorder Nil = []
preorder (Tern a l c r) = a:preorder l ++ preorder c ++ preorder r

--inorder :: undefined
inorder = undefined

postorder :: Procesador (AT a) a
postorder Nil = []
postorder (Tern value left middle right) = postorder left ++ postorder middle ++ postorder right ++ [value]

--Ejercicio 5

-- PARA FUTURA ACLARACION
-- concatMap combina concat y map, recibe dos parametros:
-- 1 - una funcion lambda la cual recibe un parametro y retorna un array en base al parametro
-- 2 - un array
-- concatmap mapea el array (2) y le aplica a cada elemento la función lambda (1) y luego concatena todos los resultados
-- el retorno de concatmap es un array compuesto de aplicar f(2) a cada elemento de (1) y luego unir los resultados

preorderRose :: Procesador (RoseTree a) a
preorderRose (Rose v children) = foldl (\acc child -> acc ++ preorderRose child ) [v] children

hojasRose :: Procesador (RoseTree a) a
hojasRose (Rose v []) = [v]
hojasRose (Rose _ children) = foldl (\acc child -> acc ++ hojasRose child) [] children

ramasRose :: Procesador (RoseTree a) [a]
ramasRose (Rose v []) = [[v]]
ramasRose (Rose v children) = map (v: ) (concatMap ramasRose children)


--Ejercicio 6

--caminos :: undefined
caminos :: Trie a -> [String]
caminos trie = caminosAux trie ""

caminosAux :: Trie a -> String -> [String]
caminosAux (TrieNodo _ []) acc = [acc]  
caminosAux (TrieNodo _ children) acc = acc : concatMap (\(char, accTrie) -> caminosAux accTrie (acc ++ [char])) children


--Ejercicio 7

--palabras :: undefined
palabras :: Trie a -> [String]
palabras trie = palabrasAux trie ""

palabrasAux :: Trie a -> String -> [String]
palabrasAux (TrieNodo _ []) acc = [acc]  
palabrasAux (TrieNodo _ children) acc =
    concatMap (\(char, accTrie) -> palabrasAux accTrie (acc ++ [char])) children


--Ejercicio 8
-- 8.a)
ifProc :: (a->Bool) -> Procesador a b -> Procesador a b -> Procesador a b
ifProc f g h s | f s        = g s
               | otherwise  = h s

-- 8.b)
(++!) :: Procesador a b -> Procesador a b -> Procesador a b
(++!) f g s = f s ++ g s

-- 8.c)
(.!) :: Procesador b c -> Procesador a b -> Procesador a c
(.!) f g s = concatMap f (g s)

--Ejercicio 9
-- Se recomienda poner la demostración en un documento aparte, por claridad y prolijidad, y, preferentemente, en algún formato de Markup o Latex, de forma de que su lectura no sea complicada.


{-Tests-}

main :: IO Counts
main = do runTestTT allTests

allTests = test [ -- Reemplazar los tests de prueba por tests propios
  "ejercicio1" ~: testsEj1,
  "ejercicio2" ~: testsEj2,
  "ejercicio3" ~: testsEj3,
  "ejercicio4" ~: testsEj4,
  "ejercicio5" ~: testsEj5,
  "ejercicio6" ~: testsEj6,
  "ejercicio7" ~: testsEj7,
  "ejercicio8a" ~: testsEj8a,
  "ejercicio8b" ~: testsEj8b,
  "ejercicio8c" ~: testsEj8c
  ]

testsEj1 = test [ -- Casos de test para el ejercicio 1
  0             -- Caso de test 1 - expresión a testear
    ~=? 0                                                               -- Caso de test 1 - resultado esperado
  ,
  1     -- Caso de test 2 - expresión a testear
    ~=? 1                                                               -- Caso de test 2 - resultado esperado
  ]

testsEj2 = test [ -- Casos de test para el ejercicio 2
  (0,0)       -- Caso de test 1 - expresión a testear
    ~=? (0,0)                   -- Caso de test 1 - resultado esperado
  ]

testsEj3 = test [ -- Casos de test para el ejercicio 3
  'a'      -- Caso de test 1 - expresión a testear
    ~=? 'a'            -- Caso de test 1 - resultado esperado
  ]

testsEj4 = test [ -- Casos de test para el ejercicio 4
  ""       -- Caso de test 1 - expresión a testear
    ~=? ""                             -- Caso de test 1 - resultado esperado
  ]

testsEj5 = test [ -- Casos de test para el ejercicio 5
  0       -- Caso de test 1 - expresión a testear
    ~=? 0                                       -- Caso de test 1 - resultado esperado
  ]

testsEj6 = test [ -- Casos de test para el ejercicio 6
  False       -- Caso de test 1 - expresión a testear
    ~=? False                                            -- Caso de test 1 - resultado esperado
  ]

testsEj7 = test [ -- Casos de test para el ejercicio 7
  True         -- Caso de test 1 - expresión a testear
    ~=? True                                          -- Caso de test 1 - resultado esperado
  ]

testsEj8a = test [ -- Casos de test para el ejercicio 7
  True         -- Caso de test 1 - expresión a testear
    ~=? True                                          -- Caso de test 1 - resultado esperado
  ]
testsEj8b = test [ -- Casos de test para el ejercicio 7
  True         -- Caso de test 1 - expresión a testear
    ~=? True                                          -- Caso de test 1 - resultado esperado
  ]
testsEj8c = test [ -- Casos de test para el ejercicio 7
  True         -- Caso de test 1 - expresión a testear
    ~=? True                                          -- Caso de test 1 - resultado esperado
  ]