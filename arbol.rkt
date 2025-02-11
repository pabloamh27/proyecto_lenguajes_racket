#lang racket
(require pict
         pict/tree-layout)
; ------------------------------------------------------
; Instituto Tecnologico de Costa Rica
; ------------------------------------------------------
;                                    Pablo Muñoz Hidalgo
;                                 Jonathan Quesada Salas
; ------------------------------------------------------

; ---------------------- PROYECTO ----------------------
;-----------------------------------------------------------------------------
; ARBOL
;-----------------------------------------------------------------------------


#| DEFINICION DE STRUCTS|#

#|
define la estructura del arbol, nada mas tiene el node root,
el cual es un node comun y corriente por el cual se empieza todo.
|#
(define-struct struct_tree(root) #:transparent #:mutable) 


#|define la estructura del node, el cual tiene
un id, un name, value y una lista de childs.|#
(define-struct struct_node (id name value childs)#:transparent #:mutable)


#| FUNCIONES |#

#| Funcion que crea un node, recibe el id, name y el value|#
(define (create-node id name value )
  (make-struct_node id name value (list)))

(define (create-node-with-childs id name value childs)
  (make-struct_node id name value (list)))

#| Funcion que crea el arbol, recibe un node el cual pasara a ser la raiz del arbol.|#
(define (create-tree node)
  (make-struct_tree node))

#| agregar un hijo al node padre y retorna el nodo padre con el nuevo nodo ingresado en sus hijos.|#
(define (add-child father new-child)
 (define father-aux (struct-copy struct_node father [childs (append (struct_node-childs father) (list new-child))]))
 (set! father father-aux)
  father)


#| Recibe el arbol en el cual haremos la busqueda, y recibe el id del nodo que queremos buscar
devuelve falso sino encontro el nodo, o sino devuelve los datos del nodo|#
(define (find-node tree id)
  (cond
    [(empty? (struct_tree-root tree)) false]
    [else (define result (check-node (struct_tree-root tree) id))
          (cond
               [(boolean? result) result] #| si es booleano es que mando falso, entonces devuelvo falso |#
               [else (list (struct_node-id result) (struct_node-name result) (struct_node-value result))])])) 


#| Recibe el nodo y el id para verificar si el id coincide con el id del nodo
primero pregunta si el id coincide,
sino pregunta si no tiene hijos (si tiene hijos hay que seguir buscando) sino tiene hijos devuelve falso
si tiene hijos entonces llama a una funcion que recorre los hijos del nodo para seguir buscando por el id

si los ids coinciden devuelve una lista con los datos del nodo
si los ids no coinciden devuelve falso o busca el id en los hijos del nodo |#
(define (check-node node id)
  (cond
    [(equal? (struct_node-id node) id) node]
    [(empty? (struct_node-childs node)) false]
    [else (check-node-childs (struct_node-childs node) id)]))

#| Es una funcion recursiva que recorre una lista de nodos para encontrar un nodo con el id que estamos buscando
termina si la lista de nodo esta vacia
sino esta vacia llama a la funcion check-node para verificar si el id del nodo coincide con el id de busqueda
si check-node devuelve una lista, significa que encontro el nodo y por ende devuelve esta lista
sino sigue recorriendo la lista, si al final se acaba la lista sin encontrar el nodo entonces devuelve falso.|#
(define (check-node-childs node-list id)
  (cond
    [(empty? node-list) #f]
    [else
        (define result (check-node (first node-list) id))
         (cond
               [(not (boolean? result))  result]
               [else (check-node-childs (list-tail node-list 1) id)])]))


#|Recibe el arbol, el id del padre del nodo que vamos a insertar, y el id, nombre y valor del nuevo nodo
esta funcion crea un nuevo arbol con el nodo insertado
primero llama a una funcion auxiliar, esta va a ayudar a insertar el nodo y devuelve la nueva raiz del arbol|#
(define (insert-node tree father id name value)
  (define new-root (insert-node_aux (struct_tree-root tree) father id name value))
  (define new-tree (struct-copy struct_tree tree [root new-root])) #|se copia el mismo arbol con la nueva raiz |#
   new-tree) #| devuelve un arbol nuevo con el hijo ingreasdo|#


#| recibe la raiz, el id del padre del nodo a insertar, y el id,nombre y valor del nuevo nodo
llama a una funcion que recorre la lista de hijos en busca del id del padre del nodo a insertar
esta funcion devuelve la nueva raiz del arbol, con el nodo insertado si encuentra el padre. sino devuelve
el arbol tal como estaba antes
|#
(define (insert-node_aux root father id name value)
  (define new-node (create-node id name value))
  (cond
       [(equal? (struct_node-id root) father)
        (set! root (add-child root new-node))
        root]
     
       [else
        (define new-childs (through-node-list (struct_node-childs root) father new-node))
        (define aux (struct-copy struct_node root [childs new-childs]))
        (set! root aux)
        root]))


#| devuelve la raiz del arbol actualizada con su nuevo hijo en alguna parte
mediante recursion recorre la lista y llama a check-insert por cada nodo, esa funcion esta encargada
de verificar si en ese nodo se debe insertar el nuevo nuevo, la funcion va armando nuevamente el arbol mientras se recorre la lista
|#  
(define (through-node-list node-list father new-node)
  (cond
    [(empty? node-list)
    (list)]
    [else
      (append (list (check-insert (first node-list) father new-node)) (through-node-list (list-tail node-list 1) father new-node))
     ]))

#| se fija si el id del nodo coincide con el id del padre, si coinciden ingresa un hijo mediante la funcion add-child
si el nodo tenia hijos, llama a la funcion through-node-list para repetir el mismo proceso con los hijos (en caso de no haber ingresado un hijo hay que seguir buscando)
|#
(define (check-insert act-node father new-node)
  (cond
    [(equal? (struct_node-id act-node) father) 
             (set! act-node (add-child act-node new-node))
             act-node]
   
    [else
          (define new-childs (through-node-list (struct_node-childs act-node) father new-node))
          (define node-aux (struct-copy struct_node act-node [childs new-childs]))
          (set! act-node node-aux)
           act-node]))

#| Recibe el arbol y el id del nodo a eliminar
hace exactamente el mismo proceso de las funciones de insertar un nodo,
llama una funcion que recorre los hijos de cada nodo y en esta funcion a cada nodo se verifica si es el nodo a eliminar
y mientras hace esto va construyendo el nuevo arbol.
|#
(define (delete-node tree id-node)
  (cond
    [(equal? (delete-root? (struct_tree-root tree) id-node) 1) #|condicion especial por si se quiere eliminar la raiz|#
     (define new-tree (create-tree (list)))
     new-tree]
    [else
  (define new-root (delete-node-aux (struct_tree-root tree) id-node))
  (define new-tree (struct-copy struct_tree tree [root new-root]))
   new-tree])) #| devuelve un arbol nuevo con el hijo ingreasdo|#

#|funcion para ver si se esta eliminando la raiz, es para fines de evitar errores a la hora de eliminar el nodo raiz|#
(define (delete-root? root id-node)
  (cond
    [(equal? (struct_node-id root) id-node) 1]
    [else 0]))

#|hace inicio al recorrido de los hijos desde la raiz, la funcion recibe la raiz y el id del nodo a buscar
llama a una funcion que devuelve una nueva raiz con el nuevo arbol resultante|#
(define (delete-node-aux root id-node)
     (define new-childs (through-node-list2 (struct_node-childs root) id-node))
     (define aux (struct-copy struct_node root [childs new-childs]))
     (set! root aux)
      root) #| devuelve la raiz del arbol actualizada con su nuevo hijo en alguna parte|#  

#| devuelve la raiz del arbol actualizada el nodo eliminado
mediante recursion recorre la lista y llama a check-delete por cada nodo, esa funcion esta encargada
de verificar si ese nodo se debe eliminar, la funcion va armando nuevamente el arbol mientras se recorre la lista
|#  
(define (through-node-list2 node-list id)
  (cond
    [(empty? node-list)
    (list)]
    [else
       (define sub-tree (check-delete (first node-list) id))
       (cond
         [(empty? sub-tree) (through-node-list2 (list-tail node-list 1) id)]
         [else (append (list sub-tree)  (through-node-list2 (list-tail node-list 1) id))])]))

#|recibe el nodo y el id del nodo a eliminar
 si el nodo actual tiene el mismo id, se elimina convirtiendo el nodo en una lista vacia
sino si el nodo tiene hijos vuelve a a llamar a la funcion que recorre hijos para ver seguir buscando por el nodo a eliminar
|#
(define (check-delete act-node id)
  (cond
    [(equal? (struct_node-id act-node) id) 
             (set! act-node (list)) #| convierto el nodo en una lista vacia|#
             (list)]
    [else
          (define new-childs (through-node-list2 (struct_node-childs act-node) id ))
          (define node-aux (struct-copy struct_node act-node [childs new-childs]))
          (set! act-node node-aux)
           act-node]))


#| recibe el arbol y el id del nodo al que quiero conocer su ancestro
primero pregunta si la raiz del arbol esta vacia, si es asi devuelve falso
sino llama a la funcion check-ancestor el cual va a devolver el nodo ancestro
|#
(define (ancestor tree id)
  (cond
    [(empty? (struct_tree-root tree)) false]
    [else (define result (check-ancestor (struct_tree-root tree) id (struct_tree-root tree) ))
          (list (struct_node-id result) (struct_node-name result) (struct_node-value result))]))

#|
recibe un nodo cualquiera, el id del nodo a buscar y un nodo padre, el cual es el ultimo nodo llamado por esta funcion
la funcion va recorriendo el arbol, primero se fija si el nodo actual tiene el id que estoy buscando, si es asi devuelvo el padre
sino, llamo a la funcion check-ancestor-childs para repetir este mismo proceso por cada uno de los hijos del nodo, y mando en el parametro padre: el nodo actual
asi cuando se vuelva a llegar a esta funcion con sus hijos, se sepa quien es el padre
|#
(define (check-ancestor node id father)
  (cond
    [(equal? (struct_node-id node) id) father]
    [(empty? (struct_node-childs node)) false]
    [else (check-ancestor-childs (struct_node-childs node) id node)]))
#|
recibe una lista de hijos, el id a buscar y el nodo padre de la lista de hijos
Recorre la lista de hijos y llama a la funcion check-ancestor para ver si encontramos el nodo
|#
(define (check-ancestor-childs node-list id father)
  (cond
    [(empty? node-list) #f]
    [else
        (define result (check-ancestor (first node-list) id father))
         (cond
           [(boolean? result) (check-ancestor-childs (list-tail node-list 1) id father)]
           [else result])]))

#| FINDS SIBLINGS |#

#|
las funciones right-sibling y left-sibling son exactamente solo que una es para encontrar el hermano izquierdo y el otro el hermano derecho
la funciones reciben el arbol y el id del nodo a buscar
llama a la funcion ancestor para buscar el padre del nodo
una vez tenemos el nodo el padre, llamamos a la funcion find-siblings la cual devuelve un par (left right) con el hermano izquierdo y el hermano derecho del nodo
la funcion right-sibling agarra el segundo nodo y la funcion left-sibling agarra el primer nodo
y crean una lista con la informacion correspondiente al nodo
|#

(define (find-right-sibling tree id-node)
 (define father_data (ancestor tree id-node))
  (define father (check-node (struct_tree-root tree) (first father_data)))
  (cond
    [(boolean? father) false] #|no se encontro el nodo en el arbol |#
    [(equal? (struct_node-id father) id-node) false] #| no tiene hermanos pues el nodo es la raiz |#
    [else (define siblings (find-siblings (struct_node-childs father) false false id-node))
          (cond
            [(boolean? (second siblings)) false] #|si devuelve falso es que no tiene hermano derecho|# 
            [else (define right-sibling (second siblings))
                  (list (struct_node-id right-sibling) (struct_node-name right-sibling) (struct_node-value right-sibling))])]))

(define (find-left-sibling tree id-node)
 (define father_data (ancestor tree id-node))
  (define father (check-node (struct_tree-root tree) (first father_data)))
  (cond
    [(boolean? father) false] #|no se encontro el nodo en el arbol |#
    [(equal? (struct_node-id father) id-node) false] #| no tiene hermanos pues el nodo es la raiz |#
    [else (define siblings (find-siblings (struct_node-childs father) false false id-node))
          (cond
            [(boolean? (first siblings)) false] #|si devuelve falso es que no tiene hermano derecho|# 
            [else (define left-sibling (first siblings))
                  (list (struct_node-id left-sibling) (struct_node-name left-sibling) (struct_node-value left-sibling))])]))

#|
Recibe la lista de hermanos, el hermano izquierdo, el nodo del centro y el id del nodo a buscar
 mientras voy recorriendo la lista voy actualizando quien es el hermano izquierdo y el nodo del centro
(el nodo el centro es el ultimo nodo que entro a esta funcion antes de llamarse de nuevo)
entonces si el nodo del centro es igual al id, significa que el nodo actual es el hermano derecho, y devuelvo
defino el hermano derecho como el nodo actual de la lista y deveulvo los dos nodos
en caso de no tener hermano derecho o izquierdo se devuelve falso en esa posicion
|#
(define (find-siblings siblings-list left center id-node)
 
  (cond
    [(empty? siblings-list) (list left false)]
    [(not (boolean? center))
     (cond
       [(equal? (struct_node-id center) id-node)
        (define right (first siblings-list))
        (list left right)]
       [else
        (set! left center)
        (set! center (first siblings-list))
        (find-siblings (list-tail siblings-list 1) left center id-node)])]
    [else
        (set! left center)
        (set! center (first siblings-list))
        (find-siblings (list-tail siblings-list 1) left center id-node)]))

  

#|PRINT 

esta funcion recibe unicamente el arbol
para que el arbol pueda dibujarse utiliza la biblioteca
(require pict
         pict/tree-layout)
para que el arbol se pueda dibujar, necesita venir en un formato de listas
cada lista representa un sub arbol, por ejemplo, si tengo un arbol
con raiz 1, donde esta raiz tiene dos hijos 2 y 3, donde el nodo 2 tiene de hijos a 4 y 5
el formato quedaria (1 (2 4 5) 3), entonces se llama a la funcion get-tree el cual me lee el arbol
y devuelve el formato del arbol en listas para poder ser dibujado


|#
(define (draw-tree tree)
  (define root (struct_tree-root tree))
  (cond
    [(empty? root) false]
    [else (draw (get-tree root))]))  

(define (draw tree)
  (define (viz tree)
    (cond
      ((null? tree) #f)
      ((not (pair? tree))
       (tree-layout #:pict (cc-superimpose
                            (disk 30 #:color "white")
                            (text (number->string tree)))))
      ((not (pair? (car tree)))
       (apply tree-layout (map viz (cdr tree))
              #:pict (cc-superimpose
                      (disk 30 #:color "white")
                      (text (number->string (car tree))))))))
  (if (null? tree)
      #f
      (naive-layered (viz tree))))


#|
Devuelve la estructura del arbol en forma de lista para que el arbol pueda ser dibujado
sino tiene hijos me devuelve solamente el nodo, si tiene hijos entonces hay que hacer una lista con el nodo incluido
ya que, si tiene hijos significa que es un sub-arbol y hay que meter todos los subarbols en una lista como se vio en el ejemplo anterior
esta lista se hace, pegando el nodo actual + get-childs-tree, donde esta funcion llama a get-tree con cada uno de los hijos del nodo
|#
(define (get-tree node)
  (cond
    [(empty? (struct_node-childs node)) (struct_node-id node) ] #|no tiene hijos entonces devuelvalo solamente |#
    [else (append (list(struct_node-id node)) (get-childs-tree (struct_node-childs node))) ])) #| a cada hijo hay que hacerle get-tree  |#

(define (get-childs-tree list-childs)
  (cond
    [(empty? list-childs) (list)]
    [else (append (list(get-tree (first list-childs))) (get-childs-tree (list-tail list-childs 1)))]))

#|hace exactamente lo mismo que draw-tree, nada mas hay que buscar el nodo del id que se ingreso en el parametro
esto se hace nada mas llamando a la funcion check-node el cual devuelve el nodo que uno le ingrese.

cuando ya tenemos el nodo nada mas hay que llamar a get-tree y pasarle el nodo a la funcion. ya que el nodo actua como arbol ya que es un sub-arbol entonces
es completamente compatible
|#
(define (draw-sub-tree tree id)
  (cond
    [(empty? (struct_tree-root tree)) false]
    [else (define result (check-node (struct_tree-root tree) id))
          (cond
               [(boolean? result) result] #| si es booleano es que mando falso, entonces devuelvo falso |#
               [else (draw (get-tree result))])])) 



;------------------------------------
;TEST #2 , #3 definicions de arbol ingreso de nodos y busqueda de nodos
(define n1 (create-node 1 "1" 1))

(define tree (create-tree n1))
(set! tree (insert-node tree 1 2 "2" 2))
(set! tree (insert-node tree 1 3 "3" 3))

(set! tree (insert-node tree 2 4 "4" 4))
(set! tree (insert-node tree 2 5 "5" 5))
(set! tree (insert-node tree 2 6 "6" 6))

(find-node tree 1)
(find-node tree 2)
(find-node tree 3)
(find-node tree 4)
(find-node tree 5)
(find-node tree 6)
#|
TEST #3 eliminar un nodo sin hijos
(set! tree (delete-node tree 3))
TEST #4 eliminar un nodo con hijos
(set! tree (delete-node tree 2))

TEST #5 eliminar la raiz
(set! tree (delete-node tree 1))


TEST #6 ancestro de hijo de raiz
(ancestor tree 2)

TEST #7 ancestro de hijo de hoja
(ancestor tree 4)

TEST #7 ancestro de raiz
(ancestor tree 1)

TEST #8 PRINT TREE
(draw-tree tree)
(draw-sub-tree tree 2)


TEST #9 Buscar hijo derecho o izquierdo
(define (find-right-sibling tree id-node)
(find-right-sibling tree 1)
(find-right-sibling tree 2)
(find-right-sibling tree 3)
(find-right-sibling tree 4)
(find-right-sibling tree 5)
(find-right-sibling tree 6)

(find-left-sibling tree 1)
(find-left-sibling tree 2)
(find-left-sibling tree 3)
(find-left-sibling tree 4)
(find-left-sibling tree 5)
(find-left-sibling tree 6)

|#
