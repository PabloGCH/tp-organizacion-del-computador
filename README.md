# README - Juego "El Asalto"

### Ejecución

Para iniciar el juego, únicamente debes correr ./run.sh, lo cual compila y ejecuta el juego.
> El script únicamente funciona en máquinas que utilizan Linux. Para utilizar el juego en Windows/Mac debes compilarlo por tu cuenta.

### Juego

El juego consiste de un tablero de 7x7 casilleros con las cuatro esquinas 3x3 inaccesibles. En una de las 4 direcciones de la "cruz" accesible del tablero, está la Fortaleza de los soldados.

En el menu inicial puedes elegir empezar una partida desde cero, cargar una partida que hayas guardado, o configurar varias partes del juego.
> Se puede configurar la dirección de la fortaleza, quien de los dos jugadores comienza la partida, y los caracteres que usan las fichas.

Luego de empezar una partida, podrás guardar el estado del tablero, y tu configuración, en un archivo que luego puedes cargar. Para eso, escribe "Save" en lugar del movimiento que se te pediría que hagas. 
De la misma forma, puedes escribir "Quit" si en algun momento deseas guardar. Esto NO guarda la partida.

### Fichas
Hay dos tipos de fichas, *Oficiales* y *Soldados*, los cuales corresponden a jugadores distintos.
- Los *Oficiales* pueden moverse en cualquiera de las ocho direcciones, la cantidad de casilleros que deseen, mientras que no hayan otras fichas de por medio.
- Los *Soldados* pueden moverse únicamente en dirección hacia la fortaleza, ya sea directamente o de forma diagonal, un solo casillero.
- Existen **dos** Oficiales, y **veinticuatro** Soldados al inicio del juego.

### Captura

- Los *Oficiales* pueden capturar soldados cuando su movimiento atraviesa directamente un soldado, y su movimiento termina en la casilla inmediatamente posterior al soldado. Esta es la única situación en la cual el movimiento de un Oficial puede atravesar casillas que contienen otras fichas.
- Los *Soldados* no pueden capturar Oficiales. La única forma de que un Oficial sea retirado del juego es si el Oficial tiene la posibilidad de capturar un Soldado pero no lo hace. Esto incluye el caso de que se mueva el otro Oficial.

### Victoria

El juego puede terminar de cuatro formas:
- Los soldados ganan porque ambos oficiales están fuera del juego.
- Los soldados ganan porque ninguno de los dos oficiales puede realizar un movimiento válido.
- Los soldados ganan porque ocuparon los nueve casilleros de la fortaleza.
- Los oficiales ganan porque quedan menos de nueve soldados en juego.
