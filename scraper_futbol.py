import requests
import json
import re
import time
import os

# === CONFIGURACIÓN ===
TELEGRAM_TOKEN = "8341606910:AAFSLNBpg2LYH1ydF3f1POlhlebPoo8ipC0"
CHAT_ID = "-1003231277453"  # ID del grupo de Telegram

players = {
    "Kylian Mbappé": ("701154", "kylian-mbappe"),
    "Dušan Vlahović": ("737857", "dusan-vlahovic"),
    "Luis Suárez": ("792303", "luis-suarez")
}

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}
results = {}

print("⚽ Extrayendo estadísticas desde FotMob (estructura 2025)…\n")


def find_season_entries(obj):
    """Busca recursivamente bloques que contengan seasonEntries."""
    if isinstance(obj, dict):
        if "seasonEntries" in obj:
            return obj["seasonEntries"]
        for v in obj.values():
            res = find_season_entries(v)
            if res:
                return res
    elif isinstance(obj, list):
        for item in obj:
            res = find_season_entries(item)
            if res:
                return res
    return None


# Cargar datos previos
old_data = {}
if os.path.exists("assets/goles.json"):
    with open("assets/goles.json", "r", encoding="utf-8") as f:
        old_data = json.load(f)

nuevos_goles = []

for name, (pid, slug) in players.items():
    print(f"Buscando estadísticas de {name}…")
    goals = assists = matches = 0

    try:
        # 1️⃣ Obtener HTML y extraer el buildId
        html_url = f"https://www.fotmob.com/es/players/{pid}/{slug}"
        html = requests.get(html_url, headers=headers)
        html.raise_for_status()

        match = re.search(r'"buildId":"(.*?)"', html.text)
        if not match:
            raise Exception("No se encontró buildId")
        build_id = match.group(1)

        # 2️⃣ Descargar JSON
        json_url = f"https://www.fotmob.com/_next/data/{build_id}/es/players/{pid}/{slug}.json"
        r = requests.get(json_url, headers=headers)
        r.raise_for_status()
        data = r.json()

        # 3️⃣ Buscar bloque seasonEntries
        season_entries = find_season_entries(data)
        if not season_entries:
            raise KeyError("No se encontró 'seasonEntries'")

        # 4️⃣ Buscar temporada actual o la más reciente
        selected = None
        for s in season_entries:
            if "2025/2026" in s.get("seasonName", ""):
                selected = s
                break
        if not selected and season_entries:
            selected = season_entries[-1]

        # 5️⃣ Extraer estadísticas
        if selected:
            goals = int(selected.get("goals", 0))
            assists = int(selected.get("assists", 0))
            matches = int(selected.get("appearances", 0))

            if not any([goals, assists, matches]):
                team_stats = selected.get("teamStats", [])
                for stat in team_stats:
                    title = stat.get("title", "").lower()
                    if "goles" in title or "goals" in title:
                        goals = int(stat.get("value", 0))
                    elif "asist" in title:
                        assists = int(stat.get("value", 0))
                    elif "partidos" in title or "apps" in title or "appearances" in title:
                        matches = int(stat.get("value", 0))

        results[name] = {
            "partidos": matches,
            "goles": goals,
            "asistencias": assists
        }

        # Comparar con datos anteriores
        old_goals = old_data.get(name, {}).get("goles", 0)
        if goals > old_goals:
            nuevos_goles.append((name, goals - old_goals))

        print(f"✅ {name}: {goals} goles • {matches} partidos • {assists} asistencias")
        time.sleep(1)

    except Exception as e:
        print(f"❌ Error procesando {name}: {e}")
        results[name] = {"partidos": matches, "goles": goals, "asistencias": assists}

# Guardar nuevo archivo
with open("assets/goles.json", "w", encoding="utf-8") as f:
    json.dump(results, f, indent=4, ensure_ascii=False)

print("\n✅ Archivo 'assets/goles.json' actualizado correctamente.\n")

# Enviar notificaciones si hay nuevos goles
if nuevos_goles:
    for name, nuevos in nuevos_goles:
        mensajes = [
            f"🔥 ¡{name} volvió a mojar la red con {nuevos} gol{'es' if nuevos > 1 else ''}! ⚽",
            f"💥 {name} se suma a la fiesta del gol 🟢",
            f"⚽ Gol de {name}! El grupo ya huele a cena gratis 😆",
            f"🚀 {name} no perdona, y sigue sumando tantos 💫",
        ]
        msg = mensajes[len(name) % len(mensajes)]
        requests.get(f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage",
                     params={"chat_id": CHAT_ID, "text": msg})
        print(f"📢 Notificación enviada por Telegram: {msg}")
else:
    print("ℹ️ No hay nuevos goles, no se envía notificación.")
