# Jueves Santo

App del parche de fútbol de los jueves. Prototipo de laboratorio, no producto comercial.

## Qué es

`index.html` + `manifest.webmanifest` + `marca/`, servidos por GitHub Pages en
https://mateoposadazea.github.io/jueves-santo/
Se usa desde el celular como PWA (agregar a pantalla de inicio).

## Stack actual

- HTML/CSS/JS vanilla en un solo archivo. Sin build, sin dependencias, sin framework.
- Persistencia: `localStorage` (clave `cancha_v2`), con fallback en memoria. La noche en curso
  vive en `S.night` y sobrevive recargas: nunca se pierde por navegar a otra pantalla.
- Tone.js por CDN, solo para la música de menú. **Se precarga con el primer toque en cualquier
  parte de la app**, no al tocar el botón de música. Es a propósito: iOS solo deja arrancar audio
  dentro del gesto del usuario, y si uno espera a que llegue el script por CDN el permiso ya se
  venció y el celular queda mudo (en escritorio no se nota, la política de autoplay es más floja).
  `Tone.start()` tiene que correr sincrónicamente dentro del handler del toque. No volver a
  moverlo a un `onload`. Además se pone `navigator.audioSession.type='playback'` para que el
  switch de silencio del iPhone no lo calle.
- Fuentes: Hanken Grotesk (títulos/números) + Be Vietnam Pro (texto), vía Google Fonts.
- Iconografía: sprite SVG inline con `<symbol>` + `<use href="#i-...">`. Sin emojis en UI.
- Avatares: SVG generado en runtime (`avatarSVG`), estilo anime 80s. No usa fotos.

## Regla de arquitectura

**Nada derivado se guarda.** XP, overall y stats se calculan siempre desde los hechos
(partidos, retas, goles). Cambiar la fórmula nunca debe corromper datos históricos.

- `overall(p)` = 52 + (nivel-1)*2, tope 94.
- `nivel(xp)` = curva incremental (cada nivel cuesta 1.18x el anterior).
- `statVal(p,k)` deriva cada stat de hechos reales: TIR de goles, PAS de asistencias,
  DEF de vallas invictas, FIS/RIT de partidos jugados.

## Pantallas

1. **Carta** — carta del jugador (overall, stats, avatar), barra de XP, misiones semanales, temporada.
2. **Partido** — registro manual de un partido suelto (resultado, goles, asistencias, valla invicta).
3. **Parche** — tabla del grupo y entrada a Armar equipos.
4. **Armar equipos** — asistencia, equipos de 4 equilibrados por overall, y **ver alineación**:
   cada equipo dibujado en una cancha, rombo 1-2-1, derivado de las posiciones (`alinear()`).
5. **La noche** — pantalla propia, con su pestaña en el nav mientras haya noche viva. Cotejos en vivo:
   marcador por cotejo, quién ganó, quién espera turno y estadísticas al vuelo (enrachado, va mandando,
   aguanta la cancha, goles). Se puede salir y volver sin perder nada.
6. **Lista** — lista del jueves: confirmó → pagó, 12 cupos, lista de espera, recordatorio para WhatsApp.
7. **Perfil** — datos y editor de avatar. La posición se elige por frase ("me gusta tapar",
   "palomero"), no por sigla; internamente sigue siendo un código de 3 letras (ver `POS`).

## Modelo social (decisiones tomadas, no cambiar sin hablarlo)

- **Planillero**: una persona por noche lleva el celular. Pone el marcador y marca quién ganó cada
  **cotejo** (lo hace el equipo que espera, no el que juega) y al cerrar la noche registra los goles de todos.
- **Vocabulario**: se dice *cotejo*, no *reta*. En el código el contador sigue llamándose `N.reta`
  a propósito, para no romper las noches ya guardadas en `localStorage`.
- **Rey de la cancha**: quien aguantó más cotejos seguidos sin salir. Es el premio de la noche.
- **Jugador de la noche**: premio aparte, por goles (desempate por racha). No reemplaza al rey.
- **Pagos**: Nequi, fuera de la app. La app solo es el tablero de quién pagó. Nunca integrar pasarela.
- **Anti-trampa**: todo público dentro del parche + inflar tu overall te empareja contra mejores.
- **Sin rivales**: no se anota contra quién se jugó, y no hay head-to-head. Los equipos se
  rebarajan cada jueves, así que "el rival" no existe como entidad estable. Se quitó a propósito;
  no volver a agregarlo sin hablarlo.
- **Alcance**: solo el jueves, solo este grupo. Nada de torneos abiertos, matchmaking con
  desconocidos, ni suscripciones mensuales. Se cortaron a propósito.

## Marca

- Paleta: tinta `#000000` (negro puro, por contraste), superficie `#161D1A`, verde cancha `#1C5E36`,
  verde eléctrico `#C8FF32`, hueso `#F7F7F2`. Amarillo `#F2E14C` solo para detalles.
- Modo claro: fondo blanco; el eléctrico se sustituye por verde cancha (ilegible sobre blanco).
- Sin degradados. Color plano + línea.
- Isotipo: jugador rematando de volea + punto verde (el balón). Archivos: `js-icono.svg`,
  `js-icono-verde.svg`, `js-lockup.svg`.
- Pantalla de inicio / PWA: `js-icono-app.svg` (el isotipo al 80%, para que la máscara no recorte
  el balón) y los PNG `marca/icon-180|192|512.png`, declarados en `manifest.webmanifest`.
  Si cambia el isotipo hay que **regenerar los PNG**; el navegador no los deriva del SVG.
- **Tono**: jerga colombiana de parche, humor negro y autoburlón. Reglas del copy:
  - Se habla de **usted**, no de tú ("arme su carta", "marque quién cayó"). Es lo más colombiano.
  - Vocabulario del parche: *parce, llave, colado, vuelta, camello, berraco, cayó, lucas, picadito,
    prendido, va mandando*. Nada de español neutro.
  - Uno se marca a sí mismo con `(yo)`, no `(tú)`. Varias funciones lo recortan por regex — si cambia
    el marcador hay que tocar `iniciales()`, `corto()` y los `.replace(' (yo)','')`.
  - Sin insultos ni slurs en la interfaz. El chiste va contra uno mismo, no contra nadie más.
  - Las frases de posición y sus remates viven en `POS`.

## Fase siguiente (cuando el grupo valide)

Migrar a Supabase para datos compartidos:

- Auth con Google (no SMS, cuesta por mensaje).
- Tablas: `jugadores`, `parches`, `miembros`, `listas`, `estados_lista`, `noches`,
  `retas`, `eventos`. XP y overall siguen siendo calculados, nunca columnas.
- Row Level Security: solo el tesorero marca pagos; solo el planillero de la noche registra retas.
- Realtime para el modo noche (todos ven la reta en vivo).
- Frontend: separar en `index.html` + `app.js` + `estilos.css` + `supabase.js`. Sigue sin build.
- **La llave de Supabase nunca va en el HTML ni en un chat.** Variables de entorno / config aparte.

## Cómo se despliega

Push a `main` → GitHub Pages republica solo en ~1 minuto. No hay build step.
