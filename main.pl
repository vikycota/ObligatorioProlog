:- use_module(library(csv)).

:- dynamic calles/3.
:- dynamic manzanas/3.

cargar_manzanas:-
                retractall(manzana(_, _, _)), % borra todos los q quedaron cargados por si acaso
                csv_read_file('Manzanas.csv', [_Encabezado | Filas], [functor(manzana), arity(3)]),% esto toma las manzanas y [_Encabezado | Filas] las separa en el encabezado (titulos ) y las filas importantes y lo convierte en una funcion manzana con aridad 3  [functor(manzana), arity(3)]
                cargar_filas(Filas).% llama a la recursion solo con las filas importantes
                


cargar_filas([]).% base recursion

cargar_filas([Fila | Resto]) :-% carga las filas una a una con recurcion
                                assertz(Fila),% que lo guarde prolog
                                cargar_filas(Resto).% recurción



cargar_calles:-
                retractall(calles(_, _, _)), % borra todos los q quedaron cargados por si acasp
                csv_read_file('Calles.csv', [_Encabezado | Filas], [functor(calle), arity(3)]),% esto toma las manzanas y [_Encabezado | Filas] las separa en el encabezado (titulos ) y las filas importantes y lo convierte en una funcion manzana con aridad 3  [functor(manzana), arity(3)]
                cargar_filas(Filas).% llama a la recursion solo con las filas importantes
                

