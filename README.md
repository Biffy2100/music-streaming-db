# SoundVault — Music Streaming Database Management System

> **DBMS Mini Project — Group 21**  
> **Topic:** Music Streaming Platform Database Design, Implementation & Interactive UI

---

## 👥 Team Members

| Sr. No. | PRN | Student Name | Project Role |
| :--- | :--- | :--- | :--- |
| 1 | `1272260925` | **Aadi Hanumante** | Database Design & Schema Architecture |
| 2 | `1272260894` | **Yash Gujar** | Data Population & Sample Dataset |
| 3 | `1272260928` | **Ritvik Kamble** | Relational DML & Verification Queries |
| 4 | `1272260889` | **Vedant Parab** | Full-Stack Web UI, Audio Player & Flask API |

---

## 🚀 Key Features

- 🎧 **Spotify-Grade Modern Web UI**: Sleek dark-mode aesthetic with glassmorphic surfaces, animated vinyl artwork, responsive grids, and genre filters.
- ⚡ **Review 2 DML Showcase Lab**: Dedicated interactive lab demonstrating all **10 DML Queries** from `docs/TenDMLQueries.txt` with problem statements, syntax-highlighted SQL, live execution, and formatted result tables.
- 🛠️ **Interactive SQL Console & Schema Inspector**: Execute arbitrary SQL queries with instant results, latency benchmarking, and inspect all 14 database table structures.
- 🎵 **Web Audio API Real Sound Synthesizer**: The player actually plays melodic tones when tracks are played, complete with scrubbable seekbar, volume control, shuffle, and repeat.
- 🔄 **Dual Engine Architecture**: Automatically connects to MySQL on port 3306 or falls back to SQLite, allowing instant zero-configuration testing while maintaining 100% MySQL compatibility.
- 👤 **Multi-User Profiles**: Switch between users (Aarav, Maya, Noah, Sofia) with distinct subscription tiers (Premium, Family, Free) and individualized listening histories.
- 📚 **Full Catalog Operations**:
  - 49 songs across 7 genres (Bollywood, R&B, Rock, Pop, Indie, Electronic, Christmas)
  - 11 global artists with discography modals
  - 17 albums with vinyl details and tracklists
  - 15 playlists with song addition and removal
  - 3 podcast shows with episode tracking

---

## 🛠️ Technology Stack

| Layer | Technology |
| :--- | :--- |
| **Frontend** | HTML5, Modern CSS3 (Glassmorphism & Flex/Grid), Vanilla JavaScript (ES6+), Lucide Icons, Web Audio API |
| **Backend** | Python 3.12, Flask, REST API |
| **Database** | MySQL 8.0+ / SQLite 3 Dual Engine |
| **Connector** | `mysql-connector-python` |
| **Version Control** | Git & GitHub (`ved-ui` branch) |

---

## ⚡ Quick Start

### 1. Run Application
Run the backend application with Python:

```bash
python backend/app.py
```

The server starts at `http://127.0.0.1:5000` and automatically opens your default browser!

### 2. Connect to MySQL (Optional)
If you have MySQL running locally:
1. Open the web interface.
2. Click the **Database Config** pill in the sidebar or footer.
3. Enter your MySQL password (default user is `root`, database is `music_streaming_db`).
4. Click **Test & Connect MySQL**.

---

## 📊 The 10 DML Relational Queries (Review 2)

| # | Query Goal | SQL Concept |
| :--- | :--- | :--- |
| **1** | Display all songs | `SELECT ... FROM song` |
| **2** | Songs longer than 4 minutes | `WHERE Duration > 240` |
| **3** | Songs sorted by duration | `ORDER BY Duration DESC` |
| **4** | Songs with album names | `INNER JOIN album` |
| **5** | Songs with artist names | `INNER JOIN artist_song` & `artist` |
| **6** | Number of songs per artist | `GROUP BY Artist_ID, Artist_Name` |
| **7** | Artists with more than 3 songs | `GROUP BY ... HAVING COUNT(*) > 3` |
| **8** | Songs in a particular playlist | Parameterized `JOIN playlist_song` |
| **9** | Listening history of a user | `JOIN users` & `listening_history` |
| **10** | Most listened-to songs | `COUNT(*) ... GROUP BY ... ORDER BY DESC` |

---

## 📁 Repository Structure

```
music-streaming-db/
├── backend/
│   ├── app.py                     # Flask REST API server & router
│   ├── db.py                      # Dual-engine DB manager (MySQL + SQLite)
│   ├── music_streaming.db         # Pre-loaded SQLite database
│   ├── static/
│   │   ├── css/
│   │   │   └── style.css          # Design system & Spotify dark-mode styling
│   │   └── js/
│   │       ├── app.js             # Client SPA controller & DML/SQL engine
│   │       └── player.js          # Web Audio tone synthesizer & playback
│   └── templates/
│       └── index.html             # Single-page application shell
├── database/
│   ├── 01_create_database.sql     # MySQL database creation
│   ├── 02_create_tables.sql       # 14 Relational DDL table schemas
│   ├── 03_insert_data.sql         # Comprehensive sample dataset
│   └── 04_queries.sql             # SQL query verification suite
├── docs/
│   ├── 21_Music_Streaming_DBMS_Review1.pdf
│   ├── DBMS Mini Project Review 1.docx
│   ├── Music Streaming DBMS-ER-DIAGRAM.jpg
│   ├── Music Streaming DBMS-SCHEMAS.jpg
│   ├── Notes.txt
│   └── TenDMLQueries.txt          # Review 2 DML queries specification
└── README.md                      # Project documentation
```
