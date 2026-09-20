"""
Database management module for Music Streaming DBMS.
Supports both MySQL (via mysql-connector-python) and SQLite (automatic fallback)
using the exact schema and data from database/02_create_tables.sql and database/03_insert_data.sql.
"""

import os
import re
import sqlite3
import time
from datetime import datetime
from typing import Any, Dict, List, Optional, Tuple

try:
    import mysql.connector
    from mysql.connector import Error as MySQLError
    MYSQL_AVAILABLE = True
except ImportError:
    MYSQL_AVAILABLE = False
    MySQLError = Exception

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATABASE_DIR = os.path.join(BASE_DIR, "database")
SQLITE_DB_PATH = os.path.join(BASE_DIR, "backend", "music_streaming.db")

# Default connection settings
DEFAULT_CONFIG = {
    "host": os.environ.get("DB_HOST", "localhost"),
    "port": int(os.environ.get("DB_PORT", 3306)),
    "user": os.environ.get("DB_USER", "root"),
    "password": os.environ.get("DB_PASSWORD", ""),
    "database": os.environ.get("DB_NAME", "music_streaming_db")
}

# The 10 DML Queries defined in docs/TenDMLQueries.txt for Project Review 2
TEN_DML_QUERIES = [
    {
        "id": 1,
        "title": "Display all songs",
        "description": "Display the title and duration of all songs in the catalog.",
        "sql": "SELECT Title, Duration FROM song ORDER BY Title ASC;"
    },
    {
        "id": 2,
        "title": "Songs longer than 4 minutes",
        "description": "Display all songs having a duration greater than 4 minutes (240 seconds).",
        "sql": "SELECT Title, Duration FROM song WHERE Duration > 240 ORDER BY Duration DESC;"
    },
    {
        "id": 3,
        "title": "Songs sorted by duration",
        "description": "Display all songs in descending order of their playback duration.",
        "sql": "SELECT Title, Duration FROM song ORDER BY Duration DESC;"
    },
    {
        "id": 4,
        "title": "Songs with album names",
        "description": "Display each song along with its associated album name using an INNER JOIN.",
        "sql": """SELECT S.Title, A.Album_Name 
FROM song S 
JOIN album A ON S.Album_ID = A.Album_ID 
ORDER BY A.Album_Name, S.Title;"""
    },
    {
        "id": 5,
        "title": "Songs with artist names",
        "description": "Display each song along with the name of its artist through the artist_song junction table.",
        "sql": """SELECT S.Title, AR.Artist_Name 
FROM song S 
JOIN artist_song ASG ON S.Song_ID = ASG.Song_ID 
JOIN artist AR ON ASG.Artist_ID = AR.Artist_ID 
ORDER BY AR.Artist_Name, S.Title;"""
    },
    {
        "id": 6,
        "title": "Number of songs per artist",
        "description": "Display each artist and the total number of songs associated with them using GROUP BY.",
        "sql": """SELECT AR.Artist_Name, COUNT(ASG.Song_ID) AS Song_Count 
FROM artist AR 
JOIN artist_song ASG ON AR.Artist_ID = ASG.Artist_ID 
GROUP BY AR.Artist_ID, AR.Artist_Name 
ORDER BY Song_Count DESC, AR.Artist_Name ASC;"""
    },
    {
        "id": 7,
        "title": "Artists with more than 3 songs",
        "description": "Display artists who have more than three songs in the catalog using GROUP BY and HAVING.",
        "sql": """SELECT AR.Artist_Name, COUNT(ASG.Song_ID) AS Song_Count 
FROM artist AR 
JOIN artist_song ASG ON AR.Artist_ID = ASG.Artist_ID 
GROUP BY AR.Artist_ID, AR.Artist_Name 
HAVING COUNT(ASG.Song_ID) > 3 
ORDER BY Song_Count DESC;"""
    },
    {
        "id": 8,
        "title": "Songs in a particular playlist",
        "description": "Display all songs belonging to Playlist ID 1 ('Aarav Favorites') with their playlist name.",
        "sql": """SELECT P.Playlist_Name, S.Title 
FROM playlist P 
JOIN playlist_song PS ON P.Playlist_ID = PS.Playlist_ID 
JOIN song S ON PS.Song_ID = S.Song_ID 
WHERE P.Playlist_ID = 1 
ORDER BY S.Title ASC;"""
    },
    {
        "id": 9,
        "title": "Listening history of a user",
        "description": "Display songs listened to by User 1 ('Aarav Mehta') along with playback timestamps.",
        "sql": """SELECT U.Name, S.Title, LH.Played_At 
FROM listening_history LH 
JOIN users U ON LH.User_ID = U.User_ID 
JOIN song S ON LH.Song_ID = S.Song_ID 
WHERE U.User_ID = 1 
ORDER BY LH.Played_At DESC;"""
    },
    {
        "id": 10,
        "title": "Most listened-to songs",
        "description": "Display songs that have been played the most across all users, sorted by total play count.",
        "sql": """SELECT S.Title, COUNT(LH.Song_ID) AS Times_Played 
FROM song S 
JOIN listening_history LH ON S.Song_ID = LH.Song_ID 
GROUP BY S.Song_ID, S.Title 
ORDER BY Times_Played DESC, S.Title ASC;"""
    }
]


class DatabaseManager:
    def __init__(self):
        self.config = dict(DEFAULT_CONFIG)
        self.engine_type = "sqlite"  # Default fallback
        self.last_error = None
        self._init_sqlite_if_needed()
        self.try_connect_mysql()

    def try_connect_mysql(self) -> bool:
        """Attempt to connect to MySQL. If successful, switch engine_type to mysql."""
        if not MYSQL_AVAILABLE:
            self.engine_type = "sqlite"
            self.last_error = "mysql-connector-python not available"
            return False
        try:
            conn = mysql.connector.connect(
                host=self.config["host"],
                port=self.config["port"],
                user=self.config["user"],
                password=self.config["password"],
                database=self.config["database"],
                connection_timeout=2
            )
            if conn.is_connected():
                conn.close()
                self.engine_type = "mysql"
                self.last_error = None
                return True
        except Exception as e:
            self.last_error = str(e)
            self.engine_type = "sqlite"
        return False

    def get_status(self) -> Dict[str, Any]:
        """Return current database connection status."""
        return {
            "engine": self.engine_type,
            "is_mysql": self.engine_type == "mysql",
            "mysql_available": MYSQL_AVAILABLE,
            "host": self.config["host"],
            "port": self.config["port"],
            "user": self.config["user"],
            "database": self.config["database"],
            "last_error": self.last_error,
            "sqlite_file": SQLITE_DB_PATH
        }

    def update_config(self, host=None, port=None, user=None, password=None, database=None) -> Dict[str, Any]:
        """Update MySQL connection parameters and test."""
        if host is not None: self.config["host"] = host
        if port is not None: self.config["port"] = int(port)
        if user is not None: self.config["user"] = user
        if password is not None: self.config["password"] = password
        if database is not None: self.config["database"] = database

        success = self.try_connect_mysql()
        return {
            "success": success,
            "status": self.get_status()
        }

    def _get_connection(self):
        """Get an active database connection."""
        if self.engine_type == "mysql" and MYSQL_AVAILABLE:
            return mysql.connector.connect(
                host=self.config["host"],
                port=self.config["port"],
                user=self.config["user"],
                password=self.config["password"],
                database=self.config["database"]
            )
        else:
            conn = sqlite3.connect(SQLITE_DB_PATH)
            conn.row_factory = sqlite3.Row
            conn.execute("PRAGMA foreign_keys = ON;")
            return conn

    def execute_query(self, query: str, params: Optional[Tuple] = None) -> Dict[str, Any]:
        """Execute any SELECT or modifying query and return columns, rows, latency, and count."""
        start_time = time.time()
        conn = None
        try:
            conn = self._get_connection()
            cursor = conn.cursor()
            
            # Clean query
            clean_query = query.strip()
            if clean_query.endswith(";"):
                # For sqlite or mysql single execution
                pass

            if params:
                cursor.execute(clean_query, params)
            else:
                cursor.execute(clean_query)

            is_select = clean_query.upper().startswith("SELECT") or clean_query.upper().startswith("PRAGMA") or clean_query.upper().startswith("SHOW") or clean_query.upper().startswith("DESC")

            rows = []
            columns = []
            if cursor.description:
                columns = [desc[0] for desc in cursor.description]
                raw_rows = cursor.fetchall()
                for r in raw_rows:
                    row_dict = {}
                    for idx, col in enumerate(columns):
                        val = r[idx]
                        if isinstance(val, (datetime, )):
                            val = val.strftime("%Y-%m-%d %H:%M:%S")
                        row_dict[col] = val
                    rows.append(row_dict)
            else:
                conn.commit()

            duration_ms = round((time.time() - start_time) * 1000, 2)
            cursor.close()
            conn.close()

            return {
                "success": True,
                "columns": columns,
                "rows": rows,
                "count": len(rows),
                "affected_rows": cursor.rowcount if not is_select else len(rows),
                "execution_time_ms": duration_ms,
                "engine": self.engine_type
            }
        except Exception as e:
            if conn:
                try: conn.close()
                except Exception: pass
            return {
                "success": False,
                "error": str(e),
                "execution_time_ms": round((time.time() - start_time) * 1000, 2),
                "engine": self.engine_type
            }

    def _init_sqlite_if_needed(self):
        """Initialize SQLite database with schema and sample data if not already populated."""
        needs_init = False
        if not os.path.exists(SQLITE_DB_PATH) or os.path.getsize(SQLITE_DB_PATH) == 0:
            needs_init = True
        else:
            try:
                conn = sqlite3.connect(SQLITE_DB_PATH)
                cursor = conn.cursor()
                cursor.execute("SELECT COUNT(*) FROM song;")
                count = cursor.fetchone()[0]
                conn.close()
                if count == 0:
                    needs_init = True
            except Exception:
                needs_init = True

        if needs_init:
            self.load_sqlite_from_sql_files()

    def load_sqlite_from_sql_files(self):
        """Parse MySQL schema and insert scripts and apply to SQLite."""
        schema_file = os.path.join(DATABASE_DIR, "02_create_tables.sql")
        data_file = os.path.join(DATABASE_DIR, "03_insert_data.sql")

        if os.path.exists(SQLITE_DB_PATH):
            try: os.remove(SQLITE_DB_PATH)
            except Exception: pass

        conn = sqlite3.connect(SQLITE_DB_PATH)
        cursor = conn.cursor()

        # Build schema for SQLite
        sqlite_schema = """
        DROP TABLE IF EXISTS user_episode;
        DROP TABLE IF EXISTS listening_history;
        DROP TABLE IF EXISTS user_artist;
        DROP TABLE IF EXISTS artist_song;
        DROP TABLE IF EXISTS playlist_song;
        DROP TABLE IF EXISTS episode;
        DROP TABLE IF EXISTS podcast;
        DROP TABLE IF EXISTS song;
        DROP TABLE IF EXISTS playlist;
        DROP TABLE IF EXISTS album;
        DROP TABLE IF EXISTS genre;
        DROP TABLE IF EXISTS artist;
        DROP TABLE IF EXISTS subscription;
        DROP TABLE IF EXISTS users;

        CREATE TABLE users(
            User_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Name TEXT NOT NULL,
            Email TEXT NOT NULL UNIQUE,
            Date_Joined TEXT NOT NULL
        );

        CREATE TABLE subscription(
            Subscription_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Plan_Type TEXT NOT NULL,
            Start_Date TEXT NOT NULL,
            End_Date TEXT,
            User_ID INTEGER NOT NULL UNIQUE,
            FOREIGN KEY (User_ID) REFERENCES users(User_ID)
        );

        CREATE TABLE artist(
            Artist_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Artist_Name TEXT NOT NULL,
            Country TEXT
        );

        CREATE TABLE genre(
            Genre_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Genre_Name TEXT NOT NULL UNIQUE
        );

        CREATE TABLE album(
            Album_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Album_Name TEXT NOT NULL,
            Release_Date TEXT,
            Artist_ID INTEGER NOT NULL,
            FOREIGN KEY (Artist_ID) REFERENCES artist(Artist_ID)
        );

        CREATE TABLE song(
            Song_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Title TEXT NOT NULL,
            Duration INTEGER NOT NULL CHECK (Duration > 0),
            Album_ID INTEGER NOT NULL,
            Genre_ID INTEGER NOT NULL,
            FOREIGN KEY (Album_ID) REFERENCES album(Album_ID),
            FOREIGN KEY (Genre_ID) REFERENCES genre(Genre_ID)
        );

        CREATE TABLE playlist(
            Playlist_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Playlist_Name TEXT NOT NULL,
            Created_Date TEXT NOT NULL,
            User_ID INTEGER NOT NULL,
            FOREIGN KEY (User_ID) REFERENCES users(User_ID)
        );

        CREATE TABLE playlist_song(
            Playlist_ID INTEGER NOT NULL,
            Song_ID INTEGER NOT NULL,
            PRIMARY KEY (Playlist_ID, Song_ID),
            FOREIGN KEY (Playlist_ID) REFERENCES playlist(Playlist_ID),
            FOREIGN KEY (Song_ID) REFERENCES song(Song_ID)
        );

        CREATE TABLE artist_song(
            Artist_ID INTEGER NOT NULL,
            Song_ID INTEGER NOT NULL,
            PRIMARY KEY (Artist_ID, Song_ID),
            FOREIGN KEY (Artist_ID) REFERENCES artist(Artist_ID),
            FOREIGN KEY (Song_ID) REFERENCES song(Song_ID)
        );

        CREATE TABLE user_artist(
            User_ID INTEGER NOT NULL,
            Artist_ID INTEGER NOT NULL,
            PRIMARY KEY (User_ID, Artist_ID),
            FOREIGN KEY (User_ID) REFERENCES users(User_ID),
            FOREIGN KEY (Artist_ID) REFERENCES artist(Artist_ID)
        );

        CREATE TABLE listening_history(
            History_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            User_ID INTEGER NOT NULL,
            Song_ID INTEGER NOT NULL,
            Played_At TEXT NOT NULL,
            FOREIGN KEY (User_ID) REFERENCES users(User_ID),
            FOREIGN KEY (Song_ID) REFERENCES song(Song_ID)
        );

        CREATE TABLE podcast(
            Podcast_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Podcast_Name TEXT NOT NULL,
            Description TEXT
        );

        CREATE TABLE episode(
            Episode_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Title TEXT NOT NULL,
            Duration INTEGER NOT NULL CHECK (Duration > 0),
            Release_Date TEXT,
            Podcast_ID INTEGER NOT NULL,
            FOREIGN KEY (Podcast_ID) REFERENCES podcast(Podcast_ID)
        );

        CREATE TABLE user_episode(
            User_ID INTEGER NOT NULL,
            Episode_ID INTEGER NOT NULL,
            Played_At TEXT NOT NULL,
            PRIMARY KEY (User_ID, Episode_ID, Played_At),
            FOREIGN KEY (User_ID) REFERENCES users(User_ID),
            FOREIGN KEY (Episode_ID) REFERENCES episode(Episode_ID)
        );
        """
        cursor.executescript(sqlite_schema)

        # Now parse 03_insert_data.sql for SQLite
        if os.path.exists(data_file):
            with open(data_file, "r", encoding="utf-8") as f:
                content = f.read()

            # Remove MySQL specific lines
            statements = content.split(";")
            for stmt in statements:
                stmt = stmt.strip()
                if not stmt:
                    continue
                # Skip MySQL set/alter/use statements
                upper_stmt = stmt.upper()
                if any(upper_stmt.startswith(k) for k in ["USE ", "SET ", "ALTER TABLE"]):
                    continue
                if upper_stmt.startswith("DELETE FROM"):
                    continue
                try:
                    cursor.execute(stmt)
                except Exception as e:
                    # Ignore single syntax discrepancies if any
                    pass
            conn.commit()

        conn.close()

    # --- High-level catalog methods ---

    def get_stats(self) -> Dict[str, int]:
        """Return platform summary counts."""
        tables = ["song", "artist", "album", "playlist", "podcast", "episode", "users"]
        stats = {}
        for t in tables:
            res = self.execute_query(f"SELECT COUNT(*) AS total FROM {t};")
            if res.get("success") and res.get("rows"):
                stats[t] = res["rows"][0]["total"]
            else:
                stats[t] = 0
        return stats

    def get_songs(self, search: Optional[str] = None, genre_id: Optional[int] = None, 
                  artist_id: Optional[int] = None, album_id: Optional[int] = None, limit: int = 100) -> List[Dict[str, Any]]:
        """Return songs with joined artist, album, and genre info."""
        sql = """
        SELECT 
            s.Song_ID, 
            s.Title, 
            s.Duration, 
            a.Album_ID, 
            a.Album_Name, 
            ar.Artist_ID, 
            ar.Artist_Name, 
            g.Genre_ID, 
            g.Genre_Name
        FROM song s
        JOIN album a ON s.Album_ID = a.Album_ID
        JOIN genre g ON s.Genre_ID = g.Genre_ID
        LEFT JOIN artist_song asg ON s.Song_ID = asg.Song_ID
        LEFT JOIN artist ar ON asg.Artist_ID = ar.Artist_ID
        WHERE 1=1
        """
        params = []
        if search:
            sql += " AND (s.Title LIKE ? OR ar.Artist_Name LIKE ? OR a.Album_Name LIKE ?)"
            # Handle placeholder for MySQL vs SQLite
            p_val = f"%{search}%"
            params.extend([p_val, p_val, p_val])
        if genre_id:
            sql += " AND s.Genre_ID = ?"
            params.append(genre_id)
        if artist_id:
            sql += " AND ar.Artist_ID = ?"
            params.append(artist_id)
        if album_id:
            sql += " AND s.Album_ID = ?"
            params.append(album_id)

        sql += f" ORDER BY s.Song_ID ASC LIMIT {int(limit)};"

        if self.engine_type == "mysql":
            sql = sql.replace("?", "%s")

        res = self.execute_query(sql, tuple(params) if params else None)
        return res.get("rows", [])

    def get_artists(self) -> List[Dict[str, Any]]:
        """Return artists with song and album counts."""
        sql = """
        SELECT 
            ar.Artist_ID, 
            ar.Artist_Name, 
            ar.Country,
            COUNT(DISTINCT asg.Song_ID) AS song_count,
            COUNT(DISTINCT a.Album_ID) AS album_count,
            COUNT(DISTINCT ua.User_ID) AS follower_count
        FROM artist ar
        LEFT JOIN artist_song asg ON ar.Artist_ID = asg.Artist_ID
        LEFT JOIN album a ON ar.Artist_ID = a.Artist_ID
        LEFT JOIN user_artist ua ON ar.Artist_ID = ua.Artist_ID
        GROUP BY ar.Artist_ID, ar.Artist_Name, ar.Country
        ORDER BY follower_count DESC, ar.Artist_Name ASC;
        """
        res = self.execute_query(sql)
        return res.get("rows", [])

    def get_artist_details(self, artist_id: int) -> Dict[str, Any]:
        """Return artist profile with albums and songs."""
        sql_artist = "SELECT * FROM artist WHERE Artist_ID = " + str(int(artist_id)) + ";"
        ar_res = self.execute_query(sql_artist)
        if not ar_res.get("rows"):
            return {}
        artist = ar_res["rows"][0]

        sql_albums = "SELECT * FROM album WHERE Artist_ID = " + str(int(artist_id)) + " ORDER BY Release_Date DESC;"
        albums = self.execute_query(sql_albums).get("rows", [])

        sql_songs = """
        SELECT s.Song_ID, s.Title, s.Duration, a.Album_Name, g.Genre_Name
        FROM song s
        JOIN artist_song asg ON s.Song_ID = asg.Song_ID
        JOIN album a ON s.Album_ID = a.Album_ID
        JOIN genre g ON s.Genre_ID = g.Genre_ID
        WHERE asg.Artist_ID = """ + str(int(artist_id)) + " ORDER BY s.Title ASC;"
        songs = self.execute_query(sql_songs).get("rows", [])

        artist["albums"] = albums
        artist["songs"] = songs
        return artist

    def get_albums(self) -> List[Dict[str, Any]]:
        """Return albums with artist name and song count."""
        sql = """
        SELECT 
            a.Album_ID, 
            a.Album_Name, 
            a.Release_Date, 
            ar.Artist_ID, 
            ar.Artist_Name,
            COUNT(s.Song_ID) AS song_count
        FROM album a
        JOIN artist ar ON a.Artist_ID = ar.Artist_ID
        LEFT JOIN song s ON a.Album_ID = s.Album_ID
        GROUP BY a.Album_ID, a.Album_Name, a.Release_Date, ar.Artist_ID, ar.Artist_Name
        ORDER BY a.Release_Date DESC;
        """
        res = self.execute_query(sql)
        return res.get("rows", [])

    def get_album_details(self, album_id: int) -> Dict[str, Any]:
        """Return album info with tracklist."""
        sql_album = """
        SELECT a.*, ar.Artist_Name 
        FROM album a 
        JOIN artist ar ON a.Artist_ID = ar.Artist_ID 
        WHERE a.Album_ID = """ + str(int(album_id)) + ";"
        res = self.execute_query(sql_album)
        if not res.get("rows"):
            return {}
        album = res["rows"][0]

        sql_songs = """
        SELECT s.Song_ID, s.Title, s.Duration, g.Genre_Name 
        FROM song s 
        JOIN genre g ON s.Genre_ID = g.Genre_ID 
        WHERE s.Album_ID = """ + str(int(album_id)) + " ORDER BY s.Song_ID ASC;"
        album["songs"] = self.execute_query(sql_songs).get("rows", [])
        return album

    def get_playlists(self, user_id: Optional[int] = None) -> List[Dict[str, Any]]:
        """Return playlists with creator name and song count."""
        sql = """
        SELECT 
            p.Playlist_ID, 
            p.Playlist_Name, 
            p.Created_Date, 
            p.User_ID, 
            u.Name AS Creator_Name,
            COUNT(ps.Song_ID) AS song_count
        FROM playlist p
        JOIN users u ON p.User_ID = u.User_ID
        LEFT JOIN playlist_song ps ON p.Playlist_ID = ps.Playlist_ID
        """
        if user_id:
            sql += f" WHERE p.User_ID = {int(user_id)}"
        sql += " GROUP BY p.Playlist_ID, p.Playlist_Name, p.Created_Date, p.User_ID, u.Name ORDER BY p.Playlist_ID ASC;"
        return self.execute_query(sql).get("rows", [])

    def get_playlist_details(self, playlist_id: int) -> Dict[str, Any]:
        """Return playlist info and songs."""
        sql_p = """
        SELECT p.*, u.Name AS Creator_Name 
        FROM playlist p 
        JOIN users u ON p.User_ID = u.User_ID 
        WHERE p.Playlist_ID = """ + str(int(playlist_id)) + ";"
        res = self.execute_query(sql_p)
        if not res.get("rows"):
            return {}
        playlist = res["rows"][0]

        sql_songs = """
        SELECT 
            s.Song_ID, 
            s.Title, 
            s.Duration, 
            a.Album_Name, 
            ar.Artist_Name, 
            g.Genre_Name
        FROM playlist_song ps
        JOIN song s ON ps.Song_ID = s.Song_ID
        JOIN album a ON s.Album_ID = a.Album_ID
        JOIN genre g ON s.Genre_ID = g.Genre_ID
        LEFT JOIN artist_song asg ON s.Song_ID = asg.Song_ID
        LEFT JOIN artist ar ON asg.Artist_ID = ar.Artist_ID
        WHERE ps.Playlist_ID = """ + str(int(playlist_id)) + " ORDER BY s.Title ASC;"
        playlist["songs"] = self.execute_query(sql_songs).get("rows", [])
        return playlist

    def create_playlist(self, name: str, user_id: int) -> Dict[str, Any]:
        """Create a new playlist."""
        created_date = datetime.now().strftime("%Y-%m-%d")
        placeholder = "%s" if self.engine_type == "mysql" else "?"
        sql = f"INSERT INTO playlist (Playlist_Name, Created_Date, User_ID) VALUES ({placeholder}, {placeholder}, {placeholder});"
        res = self.execute_query(sql, (name, created_date, user_id))
        return res

    def add_song_to_playlist(self, playlist_id: int, song_id: int) -> Dict[str, Any]:
        """Add a song to playlist."""
        placeholder = "%s" if self.engine_type == "mysql" else "?"
        sql = f"INSERT INTO playlist_song (Playlist_ID, Song_ID) VALUES ({placeholder}, {placeholder});"
        return self.execute_query(sql, (playlist_id, song_id))

    def remove_song_from_playlist(self, playlist_id: int, song_id: int) -> Dict[str, Any]:
        """Remove a song from playlist."""
        placeholder = "%s" if self.engine_type == "mysql" else "?"
        sql = f"DELETE FROM playlist_song WHERE Playlist_ID = {placeholder} AND Song_ID = {placeholder};"
        return self.execute_query(sql, (playlist_id, song_id))

    def get_podcasts(self) -> List[Dict[str, Any]]:
        """Return all podcasts with episode counts."""
        sql = """
        SELECT 
            p.Podcast_ID, 
            p.Podcast_Name, 
            p.Description, 
            COUNT(e.Episode_ID) AS episode_count
        FROM podcast p
        LEFT JOIN episode e ON p.Podcast_ID = e.Podcast_ID
        GROUP BY p.Podcast_ID, p.Podcast_Name, p.Description
        ORDER BY p.Podcast_ID ASC;
        """
        return self.execute_query(sql).get("rows", [])

    def get_podcast_details(self, podcast_id: int) -> Dict[str, Any]:
        """Return podcast and its episodes."""
        sql_p = f"SELECT * FROM podcast WHERE Podcast_ID = {int(podcast_id)};"
        res = self.execute_query(sql_p)
        if not res.get("rows"):
            return {}
        podcast = res["rows"][0]

        sql_e = f"SELECT * FROM episode WHERE Podcast_ID = {int(podcast_id)} ORDER BY Release_Date DESC;"
        podcast["episodes"] = self.execute_query(sql_e).get("rows", [])
        return podcast

    def get_users(self) -> List[Dict[str, Any]]:
        """Return users with subscription details."""
        sql = """
        SELECT 
            u.User_ID, 
            u.Name, 
            u.Email, 
            u.Date_Joined, 
            s.Plan_Type, 
            s.Start_Date, 
            s.End_Date
        FROM users u
        LEFT JOIN subscription s ON u.User_ID = s.User_ID
        ORDER BY u.User_ID ASC;
        """
        return self.execute_query(sql).get("rows", [])

    def get_user_history(self, user_id: int) -> List[Dict[str, Any]]:
        """Return listening history for a user."""
        sql = f"""
        SELECT 
            lh.History_ID, 
            lh.Played_At, 
            s.Song_ID, 
            s.Title, 
            s.Duration, 
            a.Album_Name, 
            ar.Artist_Name
        FROM listening_history lh
        JOIN song s ON lh.Song_ID = s.Song_ID
        JOIN album a ON s.Album_ID = a.Album_ID
        LEFT JOIN artist_song asg ON s.Song_ID = asg.Song_ID
        LEFT JOIN artist ar ON asg.Artist_ID = ar.Artist_ID
        WHERE lh.User_ID = {int(user_id)}
        ORDER BY lh.Played_At DESC
        LIMIT 50;
        """
        return self.execute_query(sql).get("rows", [])

    def record_play(self, user_id: int, song_id: int) -> Dict[str, Any]:
        """Log a listening history record."""
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        placeholder = "%s" if self.engine_type == "mysql" else "?"
        sql = f"INSERT INTO listening_history (User_ID, Song_ID, Played_At) VALUES ({placeholder}, {placeholder}, {placeholder});"
        return self.execute_query(sql, (user_id, song_id, now))

    def get_dml_queries(self) -> List[Dict[str, Any]]:
        """Return the 10 DML queries with their executed results."""
        results = []
        for q in TEN_DML_QUERIES:
            exec_res = self.execute_query(q["sql"])
            results.append({
                "id": q["id"],
                "title": q["title"],
                "description": q["description"],
                "sql": q["sql"],
                "success": exec_res.get("success", False),
                "columns": exec_res.get("columns", []),
                "rows": exec_res.get("rows", []),
                "count": exec_res.get("count", 0),
                "execution_time_ms": exec_res.get("execution_time_ms", 0),
                "error": exec_res.get("error", None)
            })
        return results

    def get_schema_info(self) -> List[Dict[str, Any]]:
        """Return list of tables and their column definitions."""
        tables = [
            "users", "subscription", "artist", "genre", "album", 
            "song", "playlist", "playlist_song", "artist_song", 
            "user_artist", "listening_history", "podcast", "episode", "user_episode"
        ]
        schema = []
        for t in tables:
            cols = []
            if self.engine_type == "sqlite":
                res = self.execute_query(f"PRAGMA table_info({t});")
                for r in res.get("rows", []):
                    cols.append({
                        "name": r.get("name"),
                        "type": r.get("type"),
                        "notnull": bool(r.get("notnull")),
                        "primary_key": bool(r.get("pk"))
                    })
            else:
                res = self.execute_query(f"DESCRIBE {t};")
                for r in res.get("rows", []):
                    cols.append({
                        "name": r.get("Field"),
                        "type": r.get("Type"),
                        "notnull": r.get("Null") == "NO",
                        "primary_key": r.get("Key") == "PRI"
                    })
            # Also get row count
            cnt = self.execute_query(f"SELECT COUNT(*) AS c FROM {t};")
            count = cnt.get("rows", [{}])[0].get("c", 0) if cnt.get("success") else 0
            schema.append({
                "table": t,
                "columns": cols,
                "row_count": count
            })
        return schema


# Singleton database manager
db = DatabaseManager()
