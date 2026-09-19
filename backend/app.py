"""
Flask REST API and Web Application for Music Streaming DBMS.
Serves the Spotify-inspired Web UI, provides RESTful endpoints for catalog operations,
manages user playlists and playback history, and provides the interactive 10 DML Queries Lab.
"""

import os
import sys
import threading
import webbrowser
from flask import Flask, jsonify, render_template, request, send_from_directory

# Ensure current directory is in path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.db import db, TEN_DML_QUERIES

app = Flask(
    __name__,
    template_folder=os.path.join(os.path.dirname(os.path.abspath(__file__)), "templates"),
    static_folder=os.path.join(os.path.dirname(os.path.abspath(__file__)), "static")
)


# --- Frontend Route ---

@app.route("/")
def index():
    return render_template("index.html")


# --- System & DB Endpoints ---

@app.route("/api/status", methods=["GET"])
def get_status():
    return jsonify(db.get_status())


@app.route("/api/db/config", methods=["POST"])
def update_db_config():
    data = request.get_json() or {}
    host = data.get("host")
    port = data.get("port")
    user = data.get("user")
    password = data.get("password")
    database = data.get("database")

    result = db.update_config(host=host, port=port, user=user, password=password, database=database)
    return jsonify(result)


@app.route("/api/db/init", methods=["POST"])
def init_db():
    try:
        db.load_sqlite_from_sql_files()
        return jsonify({"success": True, "message": "Database initialized with sample data successfully."})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/api/stats", methods=["GET"])
def get_stats():
    return jsonify(db.get_stats())


# --- Catalog Endpoints ---

@app.route("/api/songs", methods=["GET"])
def list_songs():
    search = request.args.get("q")
    genre_id = request.args.get("genre_id", type=int)
    artist_id = request.args.get("artist_id", type=int)
    album_id = request.args.get("album_id", type=int)
    limit = request.args.get("limit", default=100, type=int)

    songs = db.get_songs(
        search=search, 
        genre_id=genre_id, 
        artist_id=artist_id, 
        album_id=album_id, 
        limit=limit
    )
    return jsonify(songs)


@app.route("/api/artists", methods=["GET"])
def list_artists():
    return jsonify(db.get_artists())


@app.route("/api/artists/<int:artist_id>", methods=["GET"])
def artist_detail(artist_id):
    details = db.get_artist_details(artist_id)
    if not details:
        return jsonify({"error": "Artist not found"}), 404
    return jsonify(details)


@app.route("/api/albums", methods=["GET"])
def list_albums():
    return jsonify(db.get_albums())


@app.route("/api/albums/<int:album_id>", methods=["GET"])
def album_detail(album_id):
    details = db.get_album_details(album_id)
    if not details:
        return jsonify({"error": "Album not found"}), 404
    return jsonify(details)


@app.route("/api/playlists", methods=["GET", "POST"])
def manage_playlists():
    if request.method == "POST":
        data = request.get_json() or {}
        name = data.get("name")
        user_id = data.get("user_id", 1)
        if not name:
            return jsonify({"error": "Playlist name is required"}), 400
        res = db.create_playlist(name, user_id)
        return jsonify(res)
    else:
        user_id = request.args.get("user_id", type=int)
        return jsonify(db.get_playlists(user_id=user_id))


@app.route("/api/playlists/<int:playlist_id>", methods=["GET"])
def playlist_detail(playlist_id):
    details = db.get_playlist_details(playlist_id)
    if not details:
        return jsonify({"error": "Playlist not found"}), 404
    return jsonify(details)


@app.route("/api/playlists/<int:playlist_id>/songs", methods=["POST"])
def add_song_to_playlist(playlist_id):
    data = request.get_json() or {}
    song_id = data.get("song_id")
    if not song_id:
        return jsonify({"error": "song_id is required"}), 400
    res = db.add_song_to_playlist(playlist_id, song_id)
    return jsonify(res)


@app.route("/api/playlists/<int:playlist_id>/songs/<int:song_id>", methods=["DELETE"])
def remove_song_from_playlist(playlist_id, song_id):
    res = db.remove_song_from_playlist(playlist_id, song_id)
    return jsonify(res)


@app.route("/api/podcasts", methods=["GET"])
def list_podcasts():
    return jsonify(db.get_podcasts())


@app.route("/api/podcasts/<int:podcast_id>", methods=["GET"])
def podcast_detail(podcast_id):
    details = db.get_podcast_details(podcast_id)
    if not details:
        return jsonify({"error": "Podcast not found"}), 404
    return jsonify(details)


@app.route("/api/users", methods=["GET"])
def list_users():
    return jsonify(db.get_users())


@app.route("/api/users/<int:user_id>/history", methods=["GET"])
def user_history(user_id):
    return jsonify(db.get_user_history(user_id))


@app.route("/api/history", methods=["POST"])
def log_play():
    data = request.get_json() or {}
    user_id = data.get("user_id", 1)
    song_id = data.get("song_id")
    if not song_id:
        return jsonify({"error": "song_id is required"}), 400
    res = db.record_play(user_id, song_id)
    return jsonify(res)


# --- DML Queries & SQL Console Endpoints ---

@app.route("/api/dml-queries", methods=["GET"])
def list_dml_queries():
    return jsonify(db.get_dml_queries())


@app.route("/api/dml-queries/<int:query_id>", methods=["GET"])
def run_single_dml(query_id):
    matched = [q for q in TEN_DML_QUERIES if q["id"] == query_id]
    if not matched:
        return jsonify({"error": "Query not found"}), 404
    q = matched[0]
    exec_res = db.execute_query(q["sql"])
    return jsonify({
        "id": q["id"],
        "title": q["title"],
        "description": q["description"],
        "sql": q["sql"],
        **exec_res
    })


@app.route("/api/custom-query", methods=["POST"])
def run_custom_query():
    data = request.get_json() or {}
    sql = data.get("query", "").strip()
    if not sql:
        return jsonify({"error": "Query string is required"}), 400

    # Execute custom query
    res = db.execute_query(sql)
    return jsonify(res)


@app.route("/api/schema", methods=["GET"])
def get_schema():
    return jsonify(db.get_schema_info())


def open_browser():
    """Open web browser once server is ready."""
    try:
        webbrowser.open("http://localhost:5000")
    except Exception as e:
        print(f"Could not auto-open browser: {e}")


if __name__ == "__main__":
    port = 5000
    print(f"Starting Music Streaming DBMS Server on http://localhost:{port}...")
    print(f"Database Engine: {db.engine_type.upper()}")
    # Schedule browser open after 1.2 seconds
    threading.Timer(1.2, open_browser).start()
    app.run(host="0.0.0.0", port=port, debug=False)
