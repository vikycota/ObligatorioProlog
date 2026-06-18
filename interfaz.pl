:- use_module(library(pce)).
:- use_module(library(csv)).
:- use_module(library(solution_sequences)).

:- use_module('datos.pl').
:- use_module('Dijkstra.pl').
:- use_module('conectividad.pl').
:- use_module('rutas_posibles.pl').
:- use_module('diametro.pl').
:- use_module('ford_fulkerson.pl').

:- dynamic mapa_actual/1.
:- dynamic limites_actuales/4.


% ============================================================
% INTERFAZ PRINCIPAL
% ============================================================
iniciar_interfaz :-
    new(Dialogo, dialog('GPS Visual - Operaciones sobre Grafos')),
    send(Dialogo, gap, size(5, 2)),

    % Ventana separada de resultados
    crear_ventana_resultados(_ResultadoFrame, Resultado),

    % Mapa
    new(Mapa, picture('Mapa')),
    send(Mapa, size, size(560, 390)),
    send(Mapa, background, colour(white)),

    send(Dialogo, append,
         label(titulo, 'GPS Visual sobre Manzanas y Calles')),

    send(Dialogo, append,
         label(info, 'Seleccione mapa, origen y destino. Ejemplo: a1, c3, f6.'),
         below),

    send(Dialogo, append, new(MapaItem, menu(mapa, cycle)), below),
    send_list(MapaItem, append,
              ['26x26_dirigido',
               '6x6_dirigido',
               '6x6_no_dirigido']),
    send(MapaItem, selection, '6x6_dirigido'),

    send(Dialogo, append, new(OrigenItem, text_item(origen)), right),
    send(OrigenItem, selection, 'a1'),
    send(OrigenItem, length, 8),

    send(Dialogo, append, new(DestinoItem, text_item(destino)), right),
    send(DestinoItem, selection, 'c3'),
    send(DestinoItem, length, 8),

    send(Dialogo, append,
         button('Cargar mapa',
                message(@prolog,
                        accion_cargar_mapa,
                        MapaItem?selection,
                        Mapa,
                        Resultado)),
         below),

    send(Dialogo, append,
         button('Dijkstra',
                message(@prolog,
                        accion_dijkstra,
                        OrigenItem?selection,
                        DestinoItem?selection,
                        Mapa,
                        Resultado)),
         right),

    send(Dialogo, append,
         button('Ford-Fulkerson',
                message(@prolog,
                        accion_ford_fulkerson,
                        OrigenItem?selection,
                        DestinoItem?selection,
                        Resultado)),
         right),

    send(Dialogo, append,
         button('Conectividad',
                message(@prolog,
                        accion_conectividad,
                        OrigenItem?selection,
                        DestinoItem?selection,
                        Resultado)),
         right),

    send(Dialogo, append,
         button('Todas rutas',
                message(@prolog,
                        accion_todas_las_rutas,
                        OrigenItem?selection,
                        DestinoItem?selection,
                        Mapa,
                        Resultado)),
         below),

    send(Dialogo, append,
         button('Diametro',
                message(@prolog,
                        accion_diametro,
                        Resultado)),
         right),

    send(Dialogo, append,
         button('Redibujar',
                message(@prolog,
                        accion_redibujar_mapa,
                        Mapa,
                        Resultado)),
         right),

    send(Dialogo, append,
         button('Salir',
                message(Dialogo, destroy)),
         right),

    send(Dialogo, append, Mapa, below),

    accion_cargar_mapa('6x6_dirigido', Mapa, Resultado),

    send(Dialogo, open).
% ============================================================
% MAPAS DISPONIBLES
% ============================================================

mapa_a_archivos(MapaSeleccionado, IdMapa, ArchivoManzanas, ArchivoCalles) :-
    texto_a_string(MapaSeleccionado, Texto),
    mapa_a_archivos_string(Texto, IdMapa, ArchivoManzanas, ArchivoCalles).

mapa_a_archivos_string("26x26_dirigido",
                       mapa_26_dirigido,
                       'Manzanas.csv',
                       'Calles.csv').

mapa_a_archivos_string("6x6_dirigido",
                       mapa_6_dirigido,
                       'Manzanas_6x6.csv',
                       'Calles_6x6.csv').

mapa_a_archivos_string("6x6_no_dirigido",
                       mapa_6_no_dirigido,
                       'Manzanas_6x6.csv',
                       'NoD_Calles_6x6.csv').


mapa_permite_todo(mapa_6_dirigido).
mapa_permite_todo(mapa_6_no_dirigido).


mapa_grande :-
    mapa_actual(mapa_26_dirigido).


% ============================================================
% CARGA DE CSV
% ============================================================

accion_cargar_mapa(MapaSeleccionado, Mapa, Resultado) :-
    mapa_a_archivos(MapaSeleccionado, IdMapa, ArchivoManzanas, ArchivoCalles),

    cargar_manzanas_desde(ArchivoManzanas),
    cargar_calles_desde(ArchivoCalles),

    retractall(mapa_actual(_)),
    assertz(mapa_actual(IdMapa)),

    actualizar_limites_mapa,

    dibujar_grafo(Mapa, []),

    findall(Nodo, datos:manzana(Nodo, _, _), Nodos),
    findall(Calle, datos:calle(Calle, _, _, _), Calles),

    length(Nodos, CantNodos),
    length(Calles, CantCalles),

    limpiar_resultado(Resultado),

    format(atom(M1),
           'Mapa cargado: ~w',
           [MapaSeleccionado]),
    format(atom(M2),
           'Manzanas: ~w',
           [CantNodos]),
    format(atom(M3),
           'Calles: ~w',
           [CantCalles]),

    agregar_resultado(Resultado, M1),
    agregar_resultado(Resultado, M2),
    agregar_resultado(Resultado, M3),

    (
        IdMapa = mapa_26_dirigido
    ->
        agregar_resultado(Resultado, 'En este mapa grande use solo:'),
        agregar_resultado(Resultado, 'Dijkstra, Ford-Fulkerson y Conectividad.')
    ;
        agregar_resultado(Resultado, 'En este mapa funcionan todas las operaciones.')
    ).


cargar_manzanas_desde(Archivo) :-
    retractall(datos:manzana(_, _, _)),
    csv_read_file(Archivo,
                  [_Encabezado | Filas],
                  [functor(manzana), arity(3)]),
    cargar_manzanas_filas(Filas).


cargar_calles_desde(Archivo) :-
    retractall(datos:calle(_, _, _, _)),
    csv_read_file(Archivo,
                  [_Encabezado | Filas],
                  [functor(calle), arity(4)]),
    cargar_calles_filas(Filas).


cargar_manzanas_filas([]).

cargar_manzanas_filas([manzana(Id, X, Y) | Resto]) :-
    assertz(datos:manzana(Id, X, Y)),
    cargar_manzanas_filas(Resto).


cargar_calles_filas([]).

cargar_calles_filas([calle(Nombre, Origen, Destino, Peso) | Resto]) :-
    assertz(datos:calle(Nombre, Origen, Destino, Peso)),
    cargar_calles_filas(Resto).


% ============================================================
% ACCIONES DE BOTONES
% ============================================================

accion_dijkstra(OrigenTexto, DestinoTexto, Mapa, Resultado) :-
    leer_nodo(OrigenTexto, Origen),
    leer_nodo(DestinoTexto, Destino),

    limpiar_resultado(Resultado),
    agregar_resultado(Resultado, 'Dijkstra - Ruta mas corta'),
    agregar_resultado(Resultado, '------------------------------'),

    (
        dijkstra(Origen, Destino, Ruta, Peso)
    ->
        dibujar_grafo(Mapa, Ruta),
        formato_camino(Ruta, RutaTexto),
        agregar_resultado(Resultado, RutaTexto),
        format(atom(PesoTexto),
               'Peso total: ~w minutos',
               [Peso]),
        agregar_resultado(Resultado, PesoTexto)
    ;
        dibujar_grafo(Mapa, []),
        agregar_resultado(Resultado, 'No existe ruta entre esos nodos.')
    ).


accion_ford_fulkerson(OrigenTexto, DestinoTexto, Resultado) :-
    leer_nodo(OrigenTexto, Origen),
    leer_nodo(DestinoTexto, Destino),

    limpiar_resultado(Resultado),
    agregar_resultado(Resultado, 'Ford-Fulkerson'),
    agregar_resultado(Resultado, '------------------------------'),

    (
        flujo_maximo(Origen, Destino, Flujo)
    ->
        format(atom(Mensaje),
               'Flujo maximo desde ~w hasta ~w = ~w.',
               [Origen, Destino, Flujo])
    ;
        format(atom(Mensaje),
               'No se pudo calcular flujo maximo entre ~w y ~w.',
               [Origen, Destino])
    ),

    agregar_resultado(Resultado, Mensaje).


accion_conectividad(OrigenTexto, DestinoTexto, Resultado) :-
    leer_nodo(OrigenTexto, Origen),
    leer_nodo(DestinoTexto, Destino),

    limpiar_resultado(Resultado),
    agregar_resultado(Resultado, 'Conectividad'),
    agregar_resultado(Resultado, '------------------------------'),

    (
        conectado(Origen, Destino)
    ->
        format(atom(Mensaje),
               'Si existe camino desde ~w hasta ~w.',
               [Origen, Destino])
    ;
        format(atom(Mensaje),
               'No existe camino desde ~w hasta ~w.',
               [Origen, Destino])
    ),

    agregar_resultado(Resultado, Mensaje).


accion_todas_las_rutas(OrigenTexto, DestinoTexto, Mapa, Resultado) :-
    (
        mapa_actual(IdMapa),
        mapa_permite_todo(IdMapa)
    ->
        leer_nodo(OrigenTexto, Origen),
        leer_nodo(DestinoTexto, Destino),

        limpiar_resultado(Resultado),
        agregar_resultado(Resultado, 'Todas las rutas'),
        agregar_resultado(Resultado, '------------------------------'),

        findall(Ruta-Peso,
        ruta_con_peso_interfaz(Origen, Destino, Ruta, Peso),
        Rutas),

        length(Rutas, Cantidad),

        (
            Cantidad =:= 0
        ->
            agregar_resultado(Resultado, 'No se encontraron rutas.'),
            dibujar_grafo(Mapa, [])
        ;
            format(atom(Titulo),
                   'Cantidad: ~w',
                   [Cantidad]),
            agregar_resultado(Resultado, Titulo),
            agregar_resultado(Resultado, ''),
            mostrar_rutas_en_panel(Resultado, Rutas),

            % Resalta la primera ruta encontrada.
            Rutas = [PrimeraRuta-_ | _],
            dibujar_grafo(Mapa, PrimeraRuta)
        )
    ;
        limpiar_resultado(Resultado),
        agregar_resultado(Resultado, 'Operacion no habilitada para el mapa 26x26.'),
        agregar_resultado(Resultado, 'Use un mapa 6x6 para listar todas las rutas.')
    ).


accion_diametro(Resultado) :-
    limpiar_resultado(Resultado),
    agregar_resultado(Resultado, 'Diametro'),
    agregar_resultado(Resultado, '------------------------------'),

    (
        mapa_actual(IdMapa),
        mapa_permite_todo(IdMapa)
    ->
        (
            diametro(Desde, Hasta, Diametro)
        ->
            format(atom(Mensaje),
                   'Diametro: ~w | Entre: ~w y ~w.',
                   [Diametro, Desde, Hasta])
        ;
            Mensaje = 'No se pudo calcular el diametro.'
        ),
        agregar_resultado(Resultado, Mensaje)
    ;
        agregar_resultado(Resultado, 'Diametro no habilitado para el mapa 26x26.'),
        agregar_resultado(Resultado, 'Use un mapa 6x6.')
    ).


accion_redibujar_mapa(Mapa, Resultado) :-
    dibujar_grafo(Mapa, []),
    limpiar_resultado(Resultado),
    agregar_resultado(Resultado, 'Mapa redibujado.').


% ============================================================
% RUTAS CON PESO PARA PANEL DE RESULTADOS
% ============================================================

ruta_con_peso_interfaz(Origen, Destino, Ruta, Peso) :-
    ruta(Origen, Destino, Ruta),
    suma_pesos_interfaz(Ruta, 0, Peso).


suma_pesos_interfaz([_], Suma, Suma).

suma_pesos_interfaz([Primero, Segundo | Resto], Suma, Total) :-
    datos:calle(_, Primero, Segundo, PesoCalle),
    NuevaSuma is Suma + PesoCalle,
    suma_pesos_interfaz([Segundo | Resto], NuevaSuma, Total).


% ============================================================
% DIBUJO DEL GRAFO
% ============================================================

dibujar_grafo(Mapa, RutaResaltada) :-
    send(Mapa, clear),

    forall(
        datos:calle(_, Origen, Destino, Peso),
        dibujar_calle(Mapa, Origen, Destino, Peso, RutaResaltada)
    ),

    forall(
        datos:manzana(Nodo, X, Y),
        dibujar_manzana(Mapa, Nodo, X, Y, RutaResaltada)
    ).


dibujar_calle(Mapa, Origen, Destino, Peso, RutaResaltada) :-
    datos:manzana(Origen, X1, Y1),
    datos:manzana(Destino, X2, Y2),

    coord_pantalla(X1, Y1, PX1, PY1),
    coord_pantalla(X2, Y2, PX2, PY2),

    send(Mapa, display, new(Linea, line(PX1, PY1, PX2, PY2))),

    (
        arista_en_ruta(Origen, Destino, RutaResaltada)
    ->
        send(Linea, colour, colour(red)),
        send(Linea, pen, 4),
        ColorPeso = red
    ;
        send(Linea, colour, colour(grey)),
        send(Linea, pen, 1),
        ColorPeso = black
    ),

    (
        mostrar_pesos
    ->
        MX is (PX1 + PX2) // 2,
        MY is (PY1 + PY2) // 2,
        term_string(Peso, PesoTexto),
        send(Mapa, display, new(TextoPeso, text(PesoTexto)), point(MX, MY)),
        send(TextoPeso, colour, colour(ColorPeso))
    ;
        true
    ).

dibujar_manzana(Mapa, Nodo, X, Y, RutaResaltada) :-
    coord_pantalla(X, Y, PX, PY),

    tamanio_nodo(Tam, Mitad, PenNormal, PenRuta),

    XCirculo is PX - Mitad,
    YCirculo is PY - Mitad,

    send(Mapa, display, new(Circulo, ellipse(Tam, Tam)), point(XCirculo, YCirculo)),

    (
        member(Nodo, RutaResaltada)
    ->
        send(Circulo, colour, colour(red)),
        send(Circulo, pen, PenRuta)
    ;
        send(Circulo, colour, colour(black)),
        send(Circulo, pen, PenNormal)
    ),

    (
        mostrar_etiquetas_nodos
    ->
        term_string(Nodo, Texto),
        XTexto is PX - 9,
        YTexto is PY + 8,
        send(Mapa, display, new(TextoNodo, text(Texto)), point(XTexto, YTexto)),
        send(TextoNodo, colour, colour(black))
    ;
        true
    ).


tamanio_nodo(Tam, Mitad, PenNormal, PenRuta) :-
    (
        mapa_grande
    ->
        Tam = 4,
        Mitad = 2,
        PenNormal = 1,
        PenRuta = 3
    ;
        Tam = 14,
        Mitad = 7,
        PenNormal = 1,
        PenRuta = 3
    ).


mostrar_etiquetas_nodos :-
    \+ mapa_grande.


mostrar_pesos :-
    \+ mapa_grande.


arista_en_ruta(Origen, Destino, Ruta) :-
    append(_, [Origen, Destino | _], Ruta).


% ============================================================
% ESCALADO AUTOMATICO DEL MAPA
% ============================================================

actualizar_limites_mapa :-
    findall(X, datos:manzana(_, X, _), Xs),
    findall(Y, datos:manzana(_, _, Y), Ys),

    min_list(Xs, MinX),
    max_list(Xs, MaxX),
    min_list(Ys, MinY),
    max_list(Ys, MaxY),

    retractall(limites_actuales(_, _, _, _)),
    assertz(limites_actuales(MinX, MaxX, MinY, MaxY)).


coord_pantalla(X, Y, PX, PY) :-
    limites_actuales(MinX, MaxX, MinY, MaxY),

    Ancho is 430,
    Alto is 280,
    MargenX is 35,
    MargenY is 30,

    DX is MaxX - MinX,
    DY is MaxY - MinY,

    (
        DX =:= 0
    ->
        PX is MargenX + Ancho // 2
    ;
        PX is MargenX + round(((X - MinX) * Ancho) / DX)
    ),

    (
        DY =:= 0
    ->
        PY is MargenY + Alto // 2
    ;
        PY is MargenY + round(((Y - MinY) * Alto) / DY)
    ).


% ============================================================
% PANEL DE RESULTADOS
% ============================================================

limpiar_resultado(Resultado) :-
    send(Resultado, clear).


agregar_resultado(Resultado, Mensaje) :-
    send(Resultado, append, Mensaje).


mostrar_rutas_en_panel(_, []).

mostrar_rutas_en_panel(Resultado, [Ruta-Peso | Resto]) :-
    formato_camino(Ruta, RutaTexto),
    format(atom(Line),
           '~w | Peso: ~w',
           [RutaTexto, Peso]),
    agregar_resultado(Resultado, Line),
    mostrar_rutas_en_panel(Resultado, Resto).


% ============================================================
% UTILIDADES DE TEXTO
% ============================================================

leer_nodo(Texto, Nodo) :-
    texto_a_string(Texto, String),
    normalize_space(string(Limpio), String),
    atom_string(Nodo, Limpio).


texto_a_string(Valor, String) :-
    string(Valor),
    !,
    String = Valor.

texto_a_string(Valor, String) :-
    atom(Valor),
    !,
    atom_string(Valor, String).

texto_a_string(Valor, String) :-
    term_string(Valor, String).


formato_camino(Ruta, Texto) :-
    maplist(term_to_atom, Ruta, Partes),
    atomic_list_concat(Partes, ' -> ', Texto).