# Jueves Santo

App del parche de fútbol de los jueves. Prototipo de laboratorio, no producto comercial.

## Qué es

Un solo archivo `index.html` (~55KB) servido por GitHub Pages en
https://mateoposadazea.github.io/jueves-santo/
Se usa desde el celular como PWA (agregar a pantalla de inicio).

## Stack actual

- HTML/CSS/JS vanilla en un solo archivo. Sin build, sin dependencias, sin framework.
- Persistencia: `localStorage` (clave `cancha_v2`), con fallback en memoria.
- Tone.js por CDN, solo para la música de menú (carga diferida al primer toque).
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
2. **Partido** — registro manual de un partido suelto (resultado, goles, asistencias, rival).
3. **Parche** — tabla del grupo, rivalidades (head-to-head calculado), y entrada a Armar equipos.
4. **Armar equipos → Noche** — asistencia, equipos de 4 equilibrados por overall, y modo noche en vivo.
5. **Lista** — lista del jueves: confirmó → pagó, 12 cupos, lista de espera, recordatorio para WhatsApp.
6. **Perfil** — datos e editor de avatar.

## Modelo social (decisiones tomadas, no cambiar sin hablarlo)

- **Planillero**: una persona por noche lleva el celular. Marca quién ganó cada reta
  (lo hace el equipo que espera, no el que juega) y al cerrar la noche registra los goles de todos.
- **Rey de la cancha**: quien aguantó más retas seguidas sin salir. Es el premio de la noche.
- **Pagos**: Nequi, fuera de la app. La app solo es el tablero de quién pagó. Nunca integrar pasarela.
- **Anti-trampa**: todo público dentro del parche + inflar tu overall te empareja contra mejores.
- **Alcance**: solo el jueves, solo este grupo. Nada de torneos abiertos, matchmaking con
  desconocidos, ni suscripciones mensuales. Se cortaron a propósito.

## Marca

- Paleta: tinta `#000000` (negro puro, por contraste), superficie `#161D1A`, verde cancha `#1C5E36`,
  verde eléctrico `#C8FF32`, hueso `#F7F7F2`. Amarillo `#F2E14C` solo para detalles.
- Modo claro: fondo blanco; el eléctrico se sustituye por verde cancha (ilegible sobre blanco).
- Sin degradados. Color plano + línea.
- Isotipo: jugador rematando de volea + punto verde (el balón). Archivos: `js-icono.svg`,
  `js-icono-verde.svg`, `js-lockup.svg`.

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
