# Prueba técnica junior de datos · Primer Impacto

## Antes de empezar

Primer Impacto es una agencia de marketing de campo. Trabajamos para marcas de gran consumo y del sector farmacéutico, y nuestro equipo de campo recorre rutas en las que visita puntos de venta (farmacias, parafarmacias, supermercados…) y registra lo que ha ocurrido en cada visita. Todos esos registros acaban en nuestra plataforma de datos, donde los limpiamos, los comprobamos y los preparamos para que el resto de la empresa pueda consultarlos.

Esta prueba está pensada para personas que acaban de terminar la carrera, de modo que no damos por hecho que conozcas las herramientas que usamos. Por eso empieza con una pequeña guía en la que te enseñamos un ejemplo ya resuelto, y después te pedimos que apliques esas mismas ideas a un caso parecido, pero distinto. No buscamos que lo hagas todo perfecto ni que memorices comandos: lo que de verdad nos interesa es ver cómo razonas, cómo adaptas algo que acabas de aprender y cómo explicas por qué tu solución funciona. Copiar el ejemplo sin entenderlo nos dice muy poco, mientras que una solución sencilla bien explicada nos dice mucho.

Calculamos que la guía te llevará entre treinta y cuarenta y cinco minutos, y que el ejercicio completo puede hacerse en unas tres horas. Si en algún momento te atascas, apunta en qué punto te has quedado y qué habías intentado, porque eso también forma parte de la respuesta y lo valoraremos.

---

## Parte 1. Guía con un ejemplo resuelto

### 1.1. Qué hay en esta carpeta

Dentro de esta carpeta encontrarás dos subcarpetas. La carpeta `dbt` contiene un proyecto de **dbt**, una herramienta que permite transformar datos escribiendo consultas SQL organizadas en ficheros, de modo que cada fichero produce una tabla o una vista nueva a partir de otras. La carpeta `airflow` contiene un **DAG** de Airflow, que no es más que un fichero de Python en el que se describe qué tareas hay que ejecutar, en qué orden y con qué frecuencia.

Los datos de partida están en `dbt/seeds` y son dos ficheros CSV. El primero, `raw_workers.csv`, recoge a los trabajadores de campo con su provincia y su tipo de contrato. El segundo, `raw_visits.csv`, recoge las visitas realizadas a los puntos de venta, cada una con su fecha y su estado. Ambos ficheros están tal y como llegarían desde los sistemas de origen, es decir, con mayúsculas y minúsculas mezcladas, espacios sobrantes y algunos valores vacíos.

### 1.2. Cómo preparar el entorno

Para seguir la guía necesitas tener Python instalado. Desde la carpeta `junior-data-test/dbt`, instala dbt con su adaptador para DuckDB, que es una base de datos que se guarda en un único fichero y no requiere instalar ningún servidor:

```bash
pip install dbt-duckdb
cd junior-data-test/dbt
dbt seed --profiles-dir .
dbt run --profiles-dir .
dbt test --profiles-dir .
```

El primer comando, `dbt seed`, carga los CSV en la base de datos como tablas llamadas `raw_workers` y `raw_visits`. El segundo, `dbt run`, ejecuta los modelos, es decir, las consultas de la carpeta `models`, y crea a partir de ellas nuevas vistas. El tercero, `dbt test`, lanza las comprobaciones de calidad que explicamos más abajo. Si los tres terminan sin errores, el entorno está listo. Si alguno falla en tu ordenador, no pierdas demasiado tiempo peleándote con la instalación: describe el problema en tus respuestas y continúa con el resto del ejercicio, porque el código se puede leer y escribir aunque no llegues a ejecutarlo.

### 1.3. Un modelo dbt que limpia una fuente

Abre el fichero `dbt/models/staging/stg_workers.sql`. Se trata de un modelo de *staging*, que es el nombre que damos a la primera capa de limpieza: toma la tabla en bruto y devuelve la misma información, pero ordenada, con los tipos correctos y con los valores escritos siempre de la misma manera.

Si observas la columna de provincia en el CSV original, verás que una misma provincia aparece escrita de varias formas. Málaga aparece como `Málaga` y como `MALAGA`, Valencia aparece como `Valencia/València` y como `VALENCIA/VALÈNCIA`, y A Coruña aparece como `Coruña, A`. Si contáramos trabajadores por provincia sin limpiar estos valores, obtendríamos varias filas distintas para lo que en realidad es un mismo lugar. El modelo resuelve este problema en tres pasos que conviene leer en orden. Primero elimina los espacios sobrantes, convierte el texto a mayúsculas y quita las tildes, de forma que `Málaga` y `MALAGA` pasan a ser el mismo valor. Después se queda solo con la parte anterior a la barra en los nombres bilingües. Por último, reordena los nombres que llegan con el artículo al final y sustituye los valores vacíos por la palabra `DESCONOCIDA`.

Fíjate en esta última decisión, porque es importante. Cuando falta un dato no intentamos adivinarlo, pero tampoco lo dejamos vacío sin más, ya que un valor vacío pasa desapercibido en un informe. Lo marcamos de forma explícita como desconocido para que cualquier persona que consulte los datos sepa que ahí falta información. El modelo hace lo mismo con el tipo de contrato, que en uno de los trabajadores viene vacío.

### 1.4. Una comprobación de calidad

Limpiar los datos no sirve de mucho si después no comprobamos que el resultado es el que esperábamos. Para eso dbt permite escribir **tests**, que son reglas que los datos deben cumplir y que se revisan cada vez que se ejecuta `dbt test`.

En el fichero `dbt/models/staging/schema.yml` verás tres tipos de comprobación sobre `stg_workers`. La comprobación `unique` asegura que ningún identificador de trabajador se repite, la comprobación `not_null` asegura que ninguna fila se queda sin identificador ni sin provincia, y la comprobación `accepted_values` asegura que el tipo de contrato solo puede tomar uno de los valores de una lista cerrada. Esta última es especialmente útil, porque si mañana llegara un tipo de contrato nuevo que no conocemos, el test fallaría y nos avisaría antes de que ese valor llegara a un informe.

Además de estas comprobaciones ya preparadas, dbt permite escribir otras a mano. En la carpeta `dbt/tests` hay un ejemplo, `assert_workers_created_at_not_in_future.sql`, que busca trabajadores dados de alta con una fecha posterior a hoy. La idea es sencilla: la consulta busca filas que *no* deberían existir, y si devuelve alguna, dbt considera que el test ha fallado.

### 1.5. Un DAG que ejecuta una secuencia de tareas

Abre ahora el fichero `airflow/dags/pipeline_prueba_junior.py`. En él se define un DAG con dos tareas. La primera, `cargar_datos`, ejecuta `dbt seed` para cargar los CSV, y la segunda, `construir_modelos`, ejecuta `dbt run` para crear los modelos. La última línea del fichero, `cargar_datos >> construir_modelos`, indica el orden: la flecha significa que la segunda tarea solo empezará cuando la primera haya terminado correctamente. Si la carga fallara, Airflow no intentaría construir los modelos, lo cual tiene sentido, porque no podemos limpiar unos datos que no se han cargado.

El DAG incluye también algunos ajustes generales. El parámetro `schedule` indica que el proceso se ejecuta todos los días a las seis de la mañana, y los parámetros `retries` y `retry_delay` indican que, si una tarea falla, Airflow la reintentará una vez después de esperar cinco minutos. No necesitas instalar Airflow para hacer esta prueba; basta con que entiendas qué hace el fichero y seas capaz de modificarlo.

### 1.6. Cómo consultar resultados y logs

Cuando trabajamos con datos, es tan importante saber construir un proceso como saber comprobar qué ha pasado después. Con dbt puedes ver las primeras filas de un modelo mediante el comando `dbt show`, por ejemplo así:

```bash
dbt show --select stg_workers --profiles-dir .
```

Si lo ejecutas, verás que las provincias ya aparecen escritas de forma homogénea. Cuando algo falla, dbt muestra un resumen del error en la propia terminal, pero el detalle completo se guarda en el fichero `logs/dbt.log`, y el resultado de cada modelo y de cada test, con su estado y su duración, se guarda en `target/run_results.json`. Cuando un test falla, la terminal indica cuántas filas no cumplen la regla, y puedes copiar la consulta compilada que aparece en la carpeta `target/compiled` para ver exactamente cuáles son.

En Airflow ocurre algo parecido. Desde la interfaz web se puede abrir cada ejecución del DAG, ver en qué estado ha quedado cada tarea y pulsar sobre ella para leer su log, que contiene exactamente lo mismo que habrías visto en la terminal si hubieras lanzado el comando a mano.

---

## Parte 2. Ejercicio: aplica lo aprendido a un caso nuevo

En esta segunda parte te pedimos que trabajes con el fichero de visitas, `raw_visits.csv`. Cada visita tiene un estado que indica cómo terminó, y los valores válidos son cuatro: `OK`, que significa que la visita se completó con normalidad; `INCID`, que significa que se completó pero hubo alguna incidencia; `INFO`, que corresponde a una visita solo informativa; y `NOVIS`, que significa que la visita no llegó a realizarse. Sin embargo, si revisas el fichero comprobarás que los estados no siempre llegan escritos de esa forma, y que en algunas filas el estado directamente no aparece.

**Ejercicio 1. Modelo de limpieza de visitas.** Crea un modelo nuevo llamado `stg_visits.sql` en la carpeta `dbt/models/staging`. El modelo debe devolver todas las visitas con los identificadores convertidos a número, las fechas convertidas a tipo fecha y el estado normalizado, de manera que solo pueda tomar uno de los cuatro valores válidos o el valor `DESCONOCIDO` cuando no se sepa cómo terminó la visita. Antes de escribir el código, revisa los datos y anota qué variantes del estado has encontrado y qué has decidido hacer con cada una. Si te parece útil, puedes añadir una columna más que facilite el análisis posterior, como por ejemplo una que indique si la visita se llegó a realizar o no, pero en ese caso explica por qué la has añadido y qué criterio has seguido.

**Ejercicio 2. Comprobaciones de calidad.** Añade al fichero `schema.yml` las comprobaciones que consideres necesarias para el modelo `stg_visits`. Como mínimo, debes asegurarte de que el identificador de la visita es único y no está vacío, y de que el estado solo toma los valores permitidos. Después, escribe en la carpeta `dbt/tests` al menos una comprobación propia, distinta de la del ejemplo, que tenga sentido para las visitas. No hay una única respuesta correcta; lo que valoraremos es que la regla tenga sentido para el negocio y que expliques qué problema detectaría.

**Ejercicio 3. Una tercera tarea en el DAG.** El DAG del ejemplo carga los datos y construye los modelos, pero en ningún momento comprueba su calidad. Añade al fichero `pipeline_prueba_junior.py` una tercera tarea que ejecute los tests de dbt y colócala en el lugar de la secuencia que te parezca más adecuado. En tus respuestas, explica por qué la has puesto ahí y no en otro sitio, qué ocurriría con el resto de tareas si los tests fallaran, y si cambiarías algo del DAG para que ese fallo no pasara desapercibido.

---

## Parte 3. Preguntas para reflexionar

Responde a estas preguntas en un fichero llamado `respuestas.md`, dentro de esta misma carpeta. No hace falta que sean respuestas largas, pero sí que expliques tu razonamiento con tus propias palabras.

1. En el ejemplo decidimos marcar las provincias vacías como `DESCONOCIDA` en lugar de eliminar esas filas. ¿Qué habría pasado con los informes si hubiéramos eliminado las visitas sin estado en lugar de marcarlas como `DESCONOCIDO`? ¿Se te ocurre algún caso en el que sí tendría sentido eliminarlas?
2. Imagina que, dentro de un mes, empieza a llegar un estado nuevo llamado `CANCEL` que hoy no existe. ¿Qué haría tu modelo con ese valor y qué harían tus tests? ¿Te parece un comportamiento razonable o lo cambiarías?
3. Elige una de las decisiones que hayas tomado durante la prueba y explica qué alternativa descartaste y por qué.
4. Si tuvieras que explicar a una persona de otro departamento, sin conocimientos técnicos, para qué sirve la tarea que has añadido al DAG, ¿cómo se lo contarías en dos o tres frases?

---

## Qué tienes que entregar

Al terminar, la carpeta `junior-data-test` de tu copia del repositorio debería contener, además de lo que ya había, el modelo `dbt/models/staging/stg_visits.sql`, las comprobaciones que hayas añadido en `schema.yml` y en `dbt/tests`, el DAG modificado en `airflow/dags/pipeline_prueba_junior.py` y el fichero `respuestas.md` con tus explicaciones y con las respuestas a las preguntas de la parte 3. Si no has podido ejecutar algún paso, indícalo también en ese fichero.

## Cómo lo valoraremos

Lo que más nos importa es que hayas sabido trasladar las ideas del ejemplo a un caso distinto y que expliques por qué tu adaptación funciona. Nos fijaremos en que la limpieza de los estados sea completa y coherente, en que las comprobaciones de calidad tengan sentido, en que la tercera tarea del DAG esté bien situada y razonada, y en la claridad con la que expliques tus decisiones. No penalizaremos que una solución sea sencilla, siempre que esté bien pensada, ni que algo no llegue a ejecutarse si nos cuentas qué ha ocurrido.

## Nota importante

Esta prueba debe hacerse sin ayuda de herramientas de inteligencia artificial (ChatGPT, Copilot, Claude o similares). Puedes consultar la documentación oficial de dbt, de DuckDB y de Airflow, así como cualquier recurso que usarías en tu día a día, pero queremos conocer tu forma de razonar, y en la conversación posterior hablaremos sobre las decisiones que hayas tomado.

## Cómo empezar

1. Haz un *fork* de este repositorio en tu cuenta de GitHub.
2. Clona tu copia y trabaja únicamente dentro de la carpeta `junior-data-test`.
3. Cuando termines, sube los cambios a tu *fork* y responde al correo en el que recibiste la prueba con el enlace a tu repositorio.

Si tienes cualquier duda, puedes abrir una *issue* en este repositorio. ¡Mucha suerte!
