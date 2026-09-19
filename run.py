"""
Root launcher for SoundVault Music Streaming DBMS.
Usage: python run.py
"""
import os
import sys

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, base_dir)
    from backend.app import app, db, open_browser, threading
    
    port = 5000
    print("============================================================")
    print("SoundVault Music Streaming DBMS Platform (Group 21)")
    print("============================================================")
    print(f"Database Engine: {db.engine_type.upper()}")
    print(f"Local URL:       http://localhost:{port}")
    print(f"Network URL:     http://127.0.0.1:{port}")
    print("============================================================")
    threading.Timer(1.2, open_browser).start()
    app.run(host="0.0.0.0", port=port, debug=False)
